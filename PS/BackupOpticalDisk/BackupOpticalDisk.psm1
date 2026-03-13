using namespace System.IO
using namespace System.Collections.Generic

#region Private: MD5

function Get-FileMD5Internal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Быстрый стандартный способ на базе .NET
    $md5 = [System.Security.Cryptography.MD5]::Create()
    try {
        $stream = [System.IO.File]::OpenRead($Path)
        try {
            $hashBytes = $md5.ComputeHash($stream)
        } finally {
            $stream.Dispose()
        }
    } finally {
        $md5.Dispose()
    }

    # Преобразуем в строку вида "AB12CD..."
    ($hashBytes | ForEach-Object { $_.ToString("x2") }) -join ''
}

#endregion


#region Private: File type classifier

function Get-FileTypeInternal {
    param([string]$Extension)
    $ext = $Extension.ToLower().Trim('.')
    switch -Wildcard ($ext) {
        { $_ -in 'txt','log','cfg','ini','inf','md' }         { "text"; break }
        { $_ -in 'js','ts','cs','cpp','c','h','hpp','go','java','py','ps1','sh','bat','cmd' } { "source"; break }
        { $_ -in 'exe','dll','msi','com','sys','scr' }        { "application"; break }
        { $_ -in 'doc','docx','rtf','odt' }                   { "document"; break }
        { $_ -in 'xls','xlsx','csv','ods' }                   { "spreadsheet"; break }
        { $_ -in 'pdf' }                                      { "pdf"; break }
        { $_ -in 'jpg','jpeg','png','bmp','gif','tiff','ico' }{ "image"; break }
        { $_ -in 'mp3','wav','aac','flac','wma' }             { "audio"; break }
        { $_ -in 'mp4','avi','mpg','mpeg','mkv','mov' }       { "video"; break }
        default                                               { "unknown" }
    }
}

#endregion

#region Private: IMAPI2 Writer helper

Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;

namespace CustomConverter {
    public static class Helper {

        public static void WriteStreamToFile(object stream, string filePath) {
            IStream inputStream = stream as IStream;
            if (inputStream == null)
                throw new ArgumentException("stream must be IStream", "stream");

            using (FileStream outputFileStream = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.None)) {
                byte[] buffer = new byte[2048];
                IntPtr bytesReadPtr = Marshal.AllocHGlobal(sizeof(int));
                try {
                    while (true) {
                        inputStream.Read(buffer, buffer.Length, bytesReadPtr);
                        int bytesRead = Marshal.ReadInt32(bytesReadPtr);
                        if (bytesRead <= 0) {
                            break;
                        }
                        outputFileStream.Write(buffer, 0, bytesRead);
                    }
                    outputFileStream.Flush();
                }
                finally {
                    Marshal.FreeHGlobal(bytesReadPtr);
                }
            }
        }
    }
}
"@

#endregion

#region Private: Cluster size (GetDiskFreeSpace)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class DiskInfo {
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern bool GetDiskFreeSpace(
        string lpRootPathName,
        out uint lpSectorsPerCluster,
        out uint lpBytesPerSector,
        out uint lpNumberOfFreeClusters,
        out uint lpTotalNumberOfClusters);

    public static bool GetClusterInfo(string rootPath, out uint clusterSize, out uint bytesPerSector) {
        uint spc, bps, nfc, tnc;
        bool ok = GetDiskFreeSpace(rootPath, out spc, out bps, out nfc, out tnc);
        if (!ok) {
            clusterSize = 0;
            bytesPerSector = 0;
            return false;
        }
        clusterSize = spc * bps;
        bytesPerSector = bps;
        return true;
    }
}
"@

function Get-ClusterSizeInternal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootPath
    )

    [uint32]$clusterSize   = 0
    [uint32]$bytesPerSector = 0

    $ok = [DiskInfo]::GetClusterInfo($RootPath, [ref]$clusterSize, [ref]$bytesPerSector)

    if (-not $ok -or $clusterSize -eq 0) {
        # Fallback для оптических дисков: 2048 байт на сектор, 1 сектор на кластер
        Write-Verbose "GetDiskFreeSpace failed or returned 0 cluster size for '$RootPath'. Using fallback 2048 bytes."
        return 2048
    }

    return [int]$clusterSize
}

#endregion

function Backup-OpticalDisk {
    <#
    .SYNOPSIS
        Р‘СЌРєР°Рї РѕРїС‚РёС‡РµСЃРєРѕРіРѕ РґРёСЃРєР° РІ РґРёСЂРµРєС‚РѕСЂРёСЋ С„РѕСЂРјР°С‚Р° 0001-OP (ISO + ZIP + meta.json).

    .DESCRIPTION
        РЎРѕР·РґР°С‘С‚ РІ СѓРєР°Р·Р°РЅРЅРѕРј РєРѕСЂРЅРµРІРѕРј РєР°С‚Р°Р»РѕРіРµ РїРѕРґРїР°РїРєСѓ РІРёРґР° 0001-OP, 0002-OP Рё С‚.Рґ.,
        РєРѕРїРёСЂСѓРµС‚ СЃРѕРґРµСЂР¶РёРјРѕРµ РґРёСЃРєР°, С„РѕСЂРјРёСЂСѓРµС‚ ZIPвЂ‘Р°СЂС…РёРІ, ISOвЂ‘РѕР±СЂР°Р· С‡РµСЂРµР· IMAPI2 Рё
        JSONвЂ‘С„Р°Р№Р» СЃ РјРµС‚Р°вЂ‘РёРЅС„РѕСЂРјР°С†РёРµР№ Рё РґРµСЂРµРІРѕРј С„Р°Р№Р»РѕРІ.

    .PARAMETER BackupRoot
        РљРѕСЂРЅРµРІР°СЏ РґРёСЂРµРєС‚РѕСЂРёСЏ РґР»СЏ С…СЂР°РЅРµРЅРёСЏ Р±СЌРєР°РїРѕРІ РґРёСЃРєРѕРІ.

    .PARAMETER DriveLetter
        Р‘СѓРєРІР° РѕРїС‚РёС‡РµСЃРєРѕРіРѕ РґРёСЃРєРѕРІРѕРґР°, РЅР°РїСЂРёРјРµСЂ "D:".

    .PARAMETER SkipIso
        РќРµ СЃРѕР·РґР°РІР°С‚СЊ ISO (С‚РѕР»СЊРєРѕ ZIP Рё meta.json).

    .PARAMETER SkipCrc
        РќРµ РїРѕРґСЃС‡РёС‚С‹РІР°РµС‚ CRC РѕС‚ РєР°Р¶РґРѕРіРѕ С„Р°Р№Р»Р°.

    .EXAMPLE
        Backup-OpticalDisk -BackupRoot "D:\OpticalBackups" -DriveLetter "E:" -SkipIso -SkipCrc

    .EXAMPLE
        Backup-OpticalDisk -DriveLetter "D:" -Verbose
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter()][string]$BackupRoot   = "C:\Backups\Optical",
        [Parameter()][string]$DriveLetter  = "D:",
        [Parameter()][switch]$SkipIso,
	[Parameter()][switch]$SkipCrc
    )

    if (-not $DriveLetter.EndsWith(':')) {
        $DriveLetter = "$DriveLetter" + ":"
    }

    $VerbosePreference = if ($PSBoundParameters.ContainsKey('Verbose')) { "Continue" } else { "SilentlyContinue" }

    $null = New-Item -ItemType Directory -Path $BackupRoot -ErrorAction SilentlyContinue

    $pattern = '^\d{4}-OP$'
    $dirs = Get-ChildItem -Path $BackupRoot -Directory |
            Where-Object { $_.Name -match $pattern } |
            Sort-Object { [int]$_.Name.Substring(0,4) } -Descending

    if ($dirs) { $n = [int]$dirs[0].Name.Substring(0,4) } else { $n = 0 }
    $n++
    $folderName = '{0:D4}-OP' -f $n
    $targetDir  = Join-Path $BackupRoot $folderName

    if (-not (Test-Path "$DriveLetter\")) {
        throw "Drive $DriveLetter is not ready."
    }

    if ($PSCmdlet.ShouldProcess("Drive $DriveLetter", "Backup to $targetDir")) {

        New-Item -ItemType Directory -Path $targetDir -ErrorAction Stop | Out-Null
        Write-Verbose "TargetDir: $targetDir"

        $driveInfo   = [System.IO.DriveInfo]::new($DriveLetter)
        if (-not $driveInfo.IsReady) {
            throw "Drive $DriveLetter is not ready."
        }

# Размер кластера файловой системы (или 2048 по умолчанию)
$clusterSize = Get-ClusterSizeInternal -RootPath "$DriveLetter\"
Write-Verbose "Cluster size for $DriveLetter is $clusterSize bytes."

        $label       = $driveInfo.VolumeLabel
        $fileSystem  = $driveInfo.DriveFormat
        $capacity    = $driveInfo.TotalSize
        $usedBytes   = $driveInfo.TotalSize - $driveInfo.TotalFreeSpace
        $freeBytes   = $driveInfo.TotalFreeSpace

        $mediaType = $null
        try {
            $cdDrive = Get-CimInstance Win32_CDROMDrive | Where-Object { $_.Drive -eq $DriveLetter }
            if ($cdDrive) {
                $mediaType = $cdDrive.MediaType
                if (-not $mediaType) { $mediaType = $cdDrive.Name }
            }
        } catch { $mediaType = "Optical" }

        $serial = $null
        try {
            $part = Get-Partition -DriveLetter ($DriveLetter.TrimEnd(':')) -ErrorAction SilentlyContinue
            if ($part) {
                $disk = Get-Disk -Partition $part -ErrorAction SilentlyContinue
                if ($disk) { $serial = $disk.SerialNumber }
            }
        } catch { $serial = $null }

        $tempMountDir = Join-Path $env:TEMP ("OpticalBackupTemp_" + [guid]::NewGuid().ToString("N"))
        New-Item -ItemType Directory -Path $tempMountDir -ErrorAction Stop | Out-Null

        Write-Verbose "Copying $DriveLetter\* to $tempMountDir ..."
        Copy-Item -Path "$DriveLetter\*" -Destination $tempMountDir -Recurse -Force

        $allFiles = Get-ChildItem -Path $tempMountDir -Recurse -File
        $allDirs  = Get-ChildItem -Path $tempMountDir -Recurse -Directory

        $fileCount = $allFiles.Count
        $dirCount  = $allDirs.Count

        $newestFile = $null
        $oldestFile = $null

        if ($fileCount -gt 0) {
            $newestFile = $allFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            $oldestFile = $allFiles | Sort-Object CreationTime | Select-Object -First 1
        }

        $fileList = New-Object 'System.Collections.Generic.List[object]'

foreach ($f in $allFiles) {
    $fullPath = $f.FullName
    $relPath  = $f.FullName.Substring($tempMountDir.Length).TrimStart('\')

#       $cluster = 4096
#    $sizeOnDisk = [Math]::Ceiling($f.Length / $cluster) * $cluster
    $sizeOnDisk = [Math]::Ceiling([double]$f.Length / [double]$clusterSize) * $clusterSize
    $ft = Get-FileTypeInternal $f.Extension

    $attrs = @()
    if ($f.Attributes -band [FileAttributes]::ReadOnly)   { $attrs += "ReadOnly" }
    if ($f.Attributes -band [FileAttributes]::Hidden)     { $attrs += "Hidden" }
    if ($f.Attributes -band [FileAttributes]::System)     { $attrs += "System" }
    if ($f.Attributes -band [FileAttributes]::Archive)    { $attrs += "Archive" }
    if ($f.Attributes -band [FileAttributes]::Compressed) { $attrs += "Compressed" }
    if ($f.Attributes -band [FileAttributes]::Encrypted)  { $attrs += "Encrypted" }

  $md5 = $null
    if (-not $SkipCrc) {
        Write-Verbose "Calculating MD5 for: $relPath"
        $md5 = Get-FileMD5Internal -Path $fullPath
    }

    $fileList.Add([ordered]@{
        Name            = $relPath
        Type            = $ft
        SizeBytes       = $f.Length
        SizeOnDiskBytes = $sizeOnDisk
        CreationTime    = $f.CreationTimeUtc.ToString('o')
        LastWriteTime   = $f.LastWriteTimeUtc.ToString('o')
        LastAccessTime  = $f.LastAccessTimeUtc.ToString('o')
        Attributes      = $attrs
        Md5             = $md5
        })
}

        $extCounts = $fileList | Group-Object -Property {
            $ext = $_.Name -split '\.' | Select-Object -Last 1
            if ($ext -notmatch '^[\w\d]+$') { 'noext' } else { $ext.ToLower() }
        } | Select-Object Name,Count

        $topExtensions = $extCounts |
            Sort-Object Count -Descending |
            Select-Object -First 10 |
            ForEach-Object { "$($_.Name)($($_.Count))" }

        $quickSummary = @(
            "Total files: $fileCount"
            "Total dirs:  $dirCount"
            "Used bytes:  $usedBytes"
            "Free bytes:  $freeBytes"
            "Top extensions: $($topExtensions -join ', ')"
        ) -join '; '

        $isoPath = Join-Path $targetDir "$folderName.iso"
        if (-not $SkipIso) {
            try {
                Write-Verbose "Creating ISO via IMAPI2 from $tempMountDir ..."
                $fsi = New-Object -ComObject IMAPI2FS.MsftFileSystemImage
                $fsi.FileSystemsToCreate = 7
                if ([string]::IsNullOrWhiteSpace($label)) {
                    $fsi.VolumeName = "DISC_$($folderName)"
                } else {
                    $fsi.VolumeName = $label
                }
                $fsi.FreeMediaBlocks = -1
                $fsi.Root.AddTree($tempMountDir, $true)
                $resultImage  = $fsi.CreateResultImage()
                $resultStream = $resultImage.ImageStream
                [CustomConverter.Helper]::WriteStreamToFile($resultStream, $isoPath)
                Write-Verbose "ISO created: $isoPath"
            } catch {
                Write-Warning "Failed to create ISO via IMAPI2: $($_.Exception.Message)"
                $isoPath = $null
            }
        } else {
            Write-Verbose "ISO creation skipped (SkipIso switch)."
            $isoPath = $null
        }

        $zipPath = Join-Path $targetDir "$folderName.zip"
        if ($PSVersionTable.PSVersion.Major -ge 5) {
            Write-Verbose "Creating ZIP: $zipPath"
            Compress-Archive -Path "$tempMountDir\*" -DestinationPath $zipPath -CompressionLevel Optimal
        } else {
            Write-Warning "Compress-Archive requires PowerShell 5+. ZIP will not be created."
            $zipPath = $null
        }

        $meta = [ordered]@{
            DiskLabel           = $label
            DiskSerialNumber    = $serial
            FileSystem          = $fileSystem
            ClusterSize         = $clusterSize
            MediaType           = $mediaType
            TotalCapacityBytes  = $capacity
            UsedBytes           = $usedBytes
            FreeBytes           = $freeBytes
            FileCount           = $fileCount
            DirectoryCount      = $dirCount
            NewestFile          = $null
            OldestFile          = $null
            QuickSummary        = $quickSummary
            DirectoryTree       = $fileList
        }

        if ($newestFile) {
            $meta.NewestFile = [ordered]@{
                Name            = $newestFile.FullName.Substring($tempMountDir.Length).TrimStart('\')
                CreationTime    = $newestFile.CreationTimeUtc.ToString('o')
                LastWriteTime   = $newestFile.LastWriteTimeUtc.ToString('o')
                LastAccessTime  = $newestFile.LastAccessTimeUtc.ToString('o')
            }
        }

        if ($oldestFile) {
            $meta.OldestFile = [ordered]@{
                Name            = $oldestFile.FullName.Substring($tempMountDir.Length).TrimStart('\')
                CreationTime    = $oldestFile.CreationTimeUtc.ToString('o')
                LastWriteTime   = $oldestFile.LastWriteTimeUtc.ToString('o')
                LastAccessTime  = $oldestFile.LastAccessTimeUtc.ToString('o')
            }
        }

        $metaPath = Join-Path $targetDir "meta.json"
        $meta | ConvertTo-Json -Depth 10 | Set-Content -Path $metaPath -Encoding UTF8

        Remove-Item -Path $tempMountDir -Recurse -Force -ErrorAction SilentlyContinue

        [pscustomobject]@{
            BackupFolder = $targetDir
            IsoPath      = $isoPath
            ZipPath      = $zipPath
            MetaPath     = $metaPath
            DiskLabel    = $label
            DriveLetter  = $DriveLetter
        }
    }
}

Export-ModuleMember -Function Backup-OpticalDisk

