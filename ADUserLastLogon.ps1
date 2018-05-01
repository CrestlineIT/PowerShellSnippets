Import-Module ActiveDirectory
 
function Get-ADUsersLastLogon()
{
  $dcs = Get-ADDomainController -Filter {Name -like "*"}
  $users = Get-ADUser -Filter *
  $time = 0
  $columns = "name,username,datetime"

  foreach($user in $users)
  {
    foreach($dc in $dcs)
    { 
      $hostname = $dc.HostName
      $currentUser = Get-ADUser $user.SamAccountName | Get-ADObject -Server $hostname -Properties lastLogon

      if($currentUser.LastLogon -gt $time) 
      {
        $time = $currentUser.LastLogon
      }
    }

    $dt = [DateTime]::FromFileTime($time)
    $row = $user.Name+","+$user.SamAccountName+","+$dt
	$Object = New-Object PSObject
	Add-Member -InputObject $Object -NotePropertyName "Name" -NotePropertyValue $user.Name
	Add-Member -InputObject $Object -NotePropertyName "SamAccountName" -NotePropertyValue $user.SamAccountName
	Add-Member -InputObject $Object -NotePropertyName "LastLogon" -NotePropertyValue $dt.ToString("yyyy-MM-dd HH:mm")
	
	Write-Output $Object

    #Out-File -filepath $exportFilePath -append -noclobber -InputObject $row

    $time = 0
  }
}
 
Get-ADUsersLastLogon