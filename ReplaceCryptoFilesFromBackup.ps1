# Author: Perry Stathopoulos
# Company: Crestline IT Services
# You have one good folder (like from a backup restore) and you want to overwrite only files with a bad extension (like from a crypto virus)
# When SimulateCopy is $true, no changes are done. When $false, files that end with $ExtensionToRemove from the source
# ex: files from "C:\Temp\A\MyFile.txt" would overwrite the file "C:\Temp\B\MyFile.txt.LOL!"

$SimulateCopy = $true
$SourceFolder = "C:\Temp\A"
$DestinationFolder = "C:\Temp\B"
$ExtensionToRemove = ".LOL!"
$cnt = 0

Get-ChildItem -Path $DestinationFolder -File -Filter ("*" + $ExtensionToRemove) -Recurse | foreach{
	$cnt = $cnt + 1
    Write-Host $_.FullName
    $RelativePath = $_.FullName.Substring($DestinationFolder.Length).TrimEnd($ExtensionToRemove)
    Write-Host $RelativePath

    $GoodFullSource = Join-Path $SourceFolder -ChildPath $RelativePath
	if ($cnt % 10000 -eq 0) {
		Write-Host ("checked {0} files" -f ($cnt))
	}
	
    if ($SimulateCopy){
        Write-Host ("Copying {0} to {1}...not really" -f ($GoodFullSource, $_.FullName))
    }
    else {
        Write-Host ("Copying {0} to {1}..." -f ($GoodFullSource, $_.FullName))
        Copy-Item $GoodFullSource -Destination $_.FullName.TrimEnd($ExtensionToRemove)
        Remove-Item $_.FullName
    }
}
