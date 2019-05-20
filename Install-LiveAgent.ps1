# Author: Perry Stathopoulos
# Company: Crestline IT Services

#Uncomment the following line if you are missing the powershell commandlets for AcitveDirectory
#get-windowsfeature | where name -like RSAT-AD-PowerShell | Install-WindowsFeature

#Need a network share with the LA installed
$installLA = "\\kronos\temp\Crestline.LiveAgent.ClientSetup.exe"
$comps = Get-AdComputer -prop * -Filter  {(Enabled -eq $True)} | select -ExpandProperty Name

$psexecURL = "https://live.sysinternals.com/PsExec.exe"
$psexecLocal = "C:\temp\PsExec.exe"
if (!(Test-Path $psexecLocal)) {
	Invoke-WebRequest -Uri $psexecURL -OutFile $psexecLocal
}

foreach($comp in $comps)
{
	$dest ="\\$comp\c$\windows\temp\" 
	write-host $dest
	Copy-Item $installLA -Destination $dest
	start-process -Wait -FilePath $psexecLocal -ArgumentList "\\$comp c:\windows\temp\Crestline.LiveAgent.ClientSetup.exe /qn" -RedirectStandardError c:\temp\error.log -RedirectStandardOutput c:\temp\output.log
	
}