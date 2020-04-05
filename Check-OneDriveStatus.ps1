#status files save location
$rootFolder = 'C:\CITS\OneDriveStatus'
$odStatusFiles = $rootFolder + "\*-OneDriveLogging.txt"
#define states that are error
$ErrorList = @("NotInstalled", "ReadOnly", "Error", "OndemandOrUnknown")
#Initialize output; assume healthy by default
$ODOutputStatus = "Healthy"
$ODErrorCount = 0

$statusFiles = Get-ChildItem -Path $odStatusFiles

foreach ($odStatusFile in $statusFiles){

	$ODStatus = (get-content $odStatusFile | convertfrom-json).value

	foreach ($ODStat in $ODStatus) {
		if ($ODStat.StatusString -in $ErrorList) { 
			$ODOutputStatus = "$($ODStat.LocalPath) is in state $($ODStat.StatusString)" 
			$ODErrorCount++
		}
	}
}
# test output
#Write-Host $ODOutputStatus
#Write-Host $ODErrorCount
