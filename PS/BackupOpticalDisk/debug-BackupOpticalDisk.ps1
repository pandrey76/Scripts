Import-Module "$PSScriptRoot\BackupOpticalDisk.psm1" -Force

Backup-OpticalDisk -BackupRoot "c:\Users\admin1\OP" -DriveLetter "D:" -SkipIso -Verbose