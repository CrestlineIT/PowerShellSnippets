$rootFolder = 'C:\CITS\OneDriveStatus'
$odLIB = $rootFolder + '\OneDriveLib.dll'
$odStatusFile = $rootFolder + "\$env:UserName-OneDriveLogging.txt"

if (!(Test-Path -Path $rootFolder)){
	New-Item -Path $rootFolder -ItemType directory -Force -ErrorAction SilentlyContinue
}
if (!(Test-Path -Path $odLIB)){
	Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/rodneyviana/ODSyncService/master/Binaries/PowerShell/OneDriveLib.dll' -OutFile $odLIB
}

$ODOutputStatus = ""
Unblock-File $odLIB
Import-Module $odLIB
$ODStatus = Get-ODStatus -Type Business | convertto-json | out-file $odStatusFile



