# Author: Perry Stathopoulos
# Company: Crestline IT Services
# Use this script to run from a central server, like AD, to find all the computers with active users and where their documents folder points to
# Set the variable $domain to your AD domain name

$domain = "YOUR_AD_DOMAIN"

function Get-LoggedOnUser { 
#Requires -Version 2.0             
[CmdletBinding()]             
 Param              
   (                        
    [Parameter(Mandatory=$true, 
               Position=0,                           
               ValueFromPipeline=$true,             
               ValueFromPipelineByPropertyName=$true)]             
    [String[]]$ComputerName 
   )#End Param 
 
Begin             
{             
 Write-Host "`n Checking Users . . . " 
 $i = 0             
}#Begin           
Process             
{ 
    $ComputerName | Foreach-object { 
    $Computer = $_ 
    try 
        { 
            $processinfo = @(Get-WmiObject -class win32_process -ComputerName $Computer -ErrorAction Stop) 
                if ($processinfo) 
                {     
                    $processinfo | Foreach-Object {$_.GetOwner()} | 
                    Where-Object {$_.Domain -eq $domain} |  
                    Sort-Object -Property User -Unique | 
                    #Foreach-Object {Write-Host $_.Domain + ", " + $_.User} | 
                    ForEach-Object { New-Object psobject -Property @{Computer=$Computer;LoggedOn=$_.User} } |  
                    Select-Object Computer,LoggedOn 
                }#If 
        } 
    catch 
        { 
            "Cannot find any processes running on $computer" | Out-Host 
        } 
     }#Forech-object(Computers)        
             
}#Process 
End 
{ 
 
}#End 
 
}#Get-LoggedOnUser 

function global:Test-Online { 
#Requires -Version 2.0             
[CmdletBinding()]             
 Param              
   (                        
    [Parameter(Mandatory=$true, 
               Position=0,                           
               ValueFromPipeline=$true,             
               ValueFromPipelineByPropertyName=$true)]             
    [Object]$Object, 
    [String]$Parameter 
     
   )#End Param 
 
Begin             
{             
 Write-Verbose "`n Testing Server Response . . . " 
 $i = 0             
}#Begin           
Process             
{ 
    $Object | ForEach-Object { 
        if ($Parameter) 
            { 
                $Computer = $_."$Parameter" 
            } 
        elseif ($_.ComputerName) 
            { 
                $Computer = $_.ComputerName     
            } 
        else     
            { 
                $Computer = $_ 
            } 
         
        if (Test-Connection -ComputerName $Computer -Count 1 -Quiet -EA 0) 
            { 
                $i++ 
                Write-Verbose "Online : $($Computer)" -Verbose 
                $_ 
            } 
         else 
            { 
                Write-Host "Offline: $($Computer)" -background red -foreground white 
            } 
    }#Foreach-Object (Computers) 
     
}#Process 
End 
{ 
    "`n$($i) Computers online." | Out-Host 
}#End 
 
}#Test-Online  



$Comps = Get-ADComputer -prop * -filter * | select -ExpandProperty Name 

$Comps | Test-Online | Get-LoggedOnUser | ForEach-Object{
$objUser = New-Object System.Security.Principal.NTAccount($domain, $_.LoggedOn)
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])

$strRegPath = $strSID.Value + "\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"

$hku = 2147483651
$value = "Personal"

$wmi = get-wmiobject -list "StdRegProv" -namespace "root\default" -computername $_.Computer
$location = $wmi.GetStringValue($hku, $strRegPath, $value).svalue


 New-Object psobject -Property @{Computer=$_.Computer;User=$_.Loggedon;DocumentLocation=$location} 

}

