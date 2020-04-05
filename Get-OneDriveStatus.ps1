$rootFolder = 'C:\CITS\OneDriveStatus'
$odLIB = $rootFolder + '\OneDriveLib.dll'
$odStatusFile = $rootFolder + '\OneDriveLogging.txt'

function Send-Notification([String] $Subject, [String] $Status)
{
	$username = "cits-onedrivestatuscheck"
	$password = ConvertTo-SecureString "OXJ6b3N4eTY0Mmww" -AsPlainText -Force
	$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
	[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,TLS11,TLS12'
    $smtpClient = New-Object system.net.mail.smtpClient
    $smtpClient.Host = 'mail.smtp2go.com'
    $smtpClient.Port = 2525
    $smtpClient.EnableSsl = $true
    $smtpClient.Credentials = [Net.NetworkCredential]$cred
    $smtpClient.Send('onedrivestatus@crestline.net', 'perry@crestline.net', $Subject, "This is the automated check for OneDrive Status`r`n`r`n$Status`r`n`r`nRegards,`r`nCrestline IT Services")

    #Not stable
	#Send-MailMessage -From "onedrivestatus@crestline.net" -To "perry@crestline.net" -Subject $Subject -Body "This is the automated check for OneDrive Status" -SmtpServer "mail.smtp2go.com" -Credential $cred -Port 2525 -UseSsl $True
}

if (!(Test-Path -Path $rootFolder)){
	New-Item  -ItemType directory -Force -ErrorAction SilentlyContinue
}
if (!(Test-Path -Path $odLIB)){
	Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/rodneyviana/ODSyncService/master/Binaries/PowerShell/OneDriveLib.dll' -OutFile $odLIB
}

$ODOutputStatus = ""
Unblock-File $odLIB
Import-Module $odLIB
$ODStatus = Get-ODStatus -Type Business | convertto-json | out-file $odStatusFile

$ErrorList = @("NotInstalled", "ReadOnly", "Error", "OndemandOrUnknown")
$ODStatus = (get-content $odStatusFile | convertfrom-json).value
foreach ($ODStat in $ODStatus) {
    if ($ODStat.StatusString -in $ErrorList) { 
		$ODOutputStatus = "$($ODStat.LocalPath) is in state $($ODStat.StatusString)" 
		Send-Notification -Subject "OneDriveCheck Failed - $env:ComputerName for $env:UserName" -Status $ODOutputStatus
	}
}
if (!$ODOutputStatus) {
    $ODOutputStatus = "Healthy"
	Send-Notification -Subject "OneDriveCheck Good - $env:ComputerName for $env:UserName" -Status $ODOutputStatus
}

