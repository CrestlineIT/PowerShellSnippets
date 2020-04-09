#status files save location
$rootFolder = 'C:\CITS\OneDriveStatus'
$odStatusFiles = $rootFolder + "\*-OneDriveLogging.txt"
#define states that are error
$ErrorList = @("NotInstalled", "ReadOnly", "Error", "OndemandOrUnknown")
#Initialize output; assume healthy by default
$ODOutputStatus = "Healthy"
$ODErrorCount = 0

$statusFiles = Get-ChildItem -Path $odStatusFiles

if ($statusFiles.Count -gt 0){
    #we have status files but check that at least one is at least 2 hours old
    $hasRecentUpdate = $false
    foreach ($odStatusFile in $statusFiles){
        $deltaTime = Get-ChildItem $odStatusFile | New-TimeSpan
        if (!($hasRecentUpdate) -and ($deltaTime.TotalHours -lt 2)) {
            $hasRecentUpdate = $true
        }
    }
	
	if ($hasRecentUpdate) {
		foreach ($odStatusFile in $statusFiles){
			$ODStatus = (get-content $odStatusFile | convertfrom-json).value
			foreach ($ODStat in $ODStatus) {
				if ($ODStat.StatusString -in $ErrorList) { 
					$ODOutputStatus = "$($ODStat.LocalPath) is in state $($ODStat.StatusString)" 
					$ODErrorCount++
				}
			}
		}
	} else {
		$ODOutputStatus = "No recent updates for OneDrive Status files in at least 2 hours" 
		$ODErrorCount = -2	
	}
} else {
	$ODOutputStatus = "No status files" 
	$ODErrorCount = -1
}
# test output
Write-Host $ODOutputStatus
Write-Host $ODErrorCount
