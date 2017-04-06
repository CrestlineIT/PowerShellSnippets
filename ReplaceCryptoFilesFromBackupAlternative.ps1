# Author: Perry Stathopoulos
# Company: Crestline IT Services
# You have one good folder (like from a backup restore) and you want to overwrite only files with a bad extension (like from a crypto virus)
# When SimulateCopy is $true, no changes are done. When $false, files that end with $ExtensionToRemove from the source
# ex: files from "C:\Temp\A\MyFile.txt" would overwrite the file "C:\Temp\B\MyFile.txt.LOL!"

$SimulateCopy = $true
$SourceFolder = "C:\Temp\A"
$DestinationFolder = "C:\Temp\B"
$cnt = 0

Get-ChildItem -Path $SourceFolder -File -Recurse | foreach{
	$cnt = $cnt + 1
    #Write-Host $_.FullName
    $RelativePath = $_.FullName.Substring($SourceFolder.Length)
    #Write-Host $RelativePath

    $FullDestination = Join-Path $DestinationFolder -ChildPath $RelativePath
	if ($cnt % 10000 -eq 0) {
		Write-Host ("checked {0} files" -f ($cnt))
	}
	
	if (!(Test-Path $FullDestination)) {
		if ($SimulateCopy){
			Write-Host ("Copying {0} to {1}...not really" -f ($_.FullName, $FullDestination))
		}
		else {
			Write-Host ("Copying {0} to {1}..." -f ($_.FullName, $FullDestination))
			# Create the folder structure and empty destination file, similar to
			# the Unix 'touch' command
			New-Item -ItemType File -Path $FullDestination -Force
			#Now delete the dummy file
			Remove-Item -Path $FullDestination
			Copy-Item $_.FullName -Destination $FullDestination
		}
	}
}