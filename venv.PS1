
function Get-PythonFolder	{
	[CmdletBinding()]
	param (
		[ValidateNotNullOrEmpty()]
		[string[]]$MinimalVersion = "3.7"
	)
	# First way to collect regexp
	$RegexVersion = [regex]::Match($MinimalVersion, '^.*([0-9])[.,:;_-]?([0-9])$')
	Write-Host $RegexVersion
	#if ( $Version -match '^.*([0-9])[.,:;_-]?([0-9])$')	{
	$MajorMinimalVersion = 1
	$MinorMinimalVersion = 2
    if ($RegexVersion.Success)	{
	
		$MajorMinimalVersion = [int]$RegexVersion.Groups[1].Value
		Write-Host $MajorMinimalVersion
		$MinorMinimalVersion = [int]$RegexVersion.Groups[2].Value
		Write-Host $MinorMinimalVersion
	}	
	else
	{
		Write-Host "Wrong python version."
		exit
	}
	
	$PythonPath = ""
	$PATHES = (Get-ChildItem Env:"PATH").Value -split ";"
	Write-Host $PATHES
	Write-Host $PATHES[0]
    foreach ($CURRENT_PATH in $PATHES)    {	
 # $PATHES | ForEach-Object	{
		# Second way to collect regexp
		# Find path as "C:\Users\admin1\AppData\Local\Programs\Python\Python37\Scripts\"
		if ( $CURRENT_PATH -match '[\\/][Pp][Yy][Tt][Hh][Oo][Nn]([0-9])([0-9])[\\/].+[\\/]?' )	{
			Write-Host " Match 0:	"$Matches[1]
			Write-Host " Match 1:	"$Matches[2]
			# Write-Host " Current Path:	"$_
			if ( [int]$Matches[1] -ge $MajorMinimalVersion )	{
				if ( [int]$Matches[2] -ge $MinorMinimalVersion )	{
                    #$_
                    Return ($CURRENT_PATH)
#                    return
#                    break
                    # Write-Host "Finding path:	"$PythonPath
				}
			}
		}
		else	{
			Write-Host "Error match $PATH"
		}
		
	}	
#    Write-Host "return from function"
#	return $PythonPath
}
$Path = Get-PythonFolder -MinimalVersion 3.5
Write-Host "Get-PythonFolder return:    "$Path
exit

# PS C:\Work\acvpServer\backend>> Invoke-Expression "C:/Users/admin1/AppData/Local/Programs/Python/Python37/python.exe -m venv win_venv"
# PS C:\Work\acvpServer\backend\win_venv>> Invoke-Expression "C:/Work/acvpServer/backend/win_venv/Scripts/pip.exe install --no-index -r C:/Work/acvpServer/backend/requirements.txt --find-links=C:/Work/acvpServer/backend/win_venv/libs"
# C:\Python36\;C:\Python36\Scripts\;C:\Program Files (x86)\Common Files\Oracle\Java\javapath;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files\Git\cmd;C:\Users\admin1\AppData\Local\Programs\Python\Python37\Scripts\;C:\Users\admin1\AppData\Local\Programs\Python\Python37\;C:\Users\admin1\AppData\Local\Microsoft\WindowsApps;;C:\Program Files\JetBrains\PyCharm 2019.1.1\bin;