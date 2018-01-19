Import-Module ActiveDirectory
 
function Add-LocalAdmin
{
[CmdletBinding()]             
 Param              
   (                        
    [Parameter(Mandatory=$true)]             
    [string]$localusername, 
    [Parameter(Mandatory=$true)]             
    [string]$password 
     
   )#End Param 
 
Begin             
{             
}#Begin           
Process             
{ 
	# TODO: remove AD servers from the list
    $Comps = Get-ADComputer -prop * -filter {(Enabled -eq $True)} | select -ExpandProperty Name
    #$Comps = "TCBMW-MGMT-01"

    foreach($comp in $Comps)
    {
        $object = New-Object PSObject
        Add-Member -InputObject $object -NotePropertyName "ComputerName" -NotePropertyValue $comp
        Add-Member -InputObject $object -NotePropertyName "Status" -NotePropertyValue ""
        if(Test-Connection -ComputerName $comp -Count 1 -Quiet -EA 0) 
        {
            $users = $null
            $computer = [ADSI]“WinNT://$comp”
            try {
                $users = $computer.psbase.children | select -expand name  
                if ($users -like $localusername) {
                    $object.Status = "Exists"
                } else {
                    $user_obj = $computer.Create(“user”, “$localusername”)
                    $user_obj.SetPassword($password)
                    $user_obj.SetInfo()
                    $user_obj.FullName = "Pfaff Tech"
                    $user_obj.SetInfo()
                    $user_obj.Put("Description", "Local Admin Account")
                    $user_obj.SetInfo()
                    $user_obj.UserFlags = 65536 # PASSWD_NEVER_EXPIRE
                    $user_obj.SetInfo()
                    $Group = [ADSI]("WinNT://$comp/Administrators,Group")
                    $Group.add("WinNT://$comp/$localusername")
                    $users = $computer.psbase.children | select -expand name
                    if ($users -like $localusername) {
                        $object.Status = "Added"
                    } else {
                        $object.Status = "Failed"
                    }
                }
            } catch {
                $object.Status = "Failed"
            }
        }
        else
        {
            $object.Status = "Offline"
        }
        Write-Output $object
    }
}
End 
{ 
}#End 
 
}#Add-LocalAdmin

Add-LocalAdmin "localadmin" "P@ssw0rd#!" | Export-Csv -Path "C:\temp\localtech-admin.csv"