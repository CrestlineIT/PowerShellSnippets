# Author: Perry Stathopoulos, Richard Gardner
# Company: Crestline IT Services
# Use this script to run from a central server, like AD, to install the Salt Minion on all PC's and then restart the Salt-Minion service



#command strings
# $StopCommand = "psexec.exe $Computer -u $AdminUser -p $AdminPassword net stop salt-minion"
# $StartCommand = "psexec.exe $Computer -u $AdminUser -p $AdminPassword net start salt-minion"
# $InstallCommand = "psexec.exe $Computer -u $AdminUser -p $AdminPassword $SaltInstallCmd"

$ErrorActionPreference = 'SilentlyContinue'

function global:Deploy-Salt-Minions { 
#Requires -Version 2.0             
[CmdletBinding()]             
 Param              
   (                        
    [Parameter(Mandatory=$true, 
               Position=0)]
    [String]$AdminUser,
    [Parameter(Mandatory=$true, 
               Position=1)]
    [String]$AdminPassword,
    [Parameter(Mandatory=$true, 
               Position=2)]
    [String]$SaltInstallCmd
   )#End Param 
 
Begin             
{             
 $i = 0             
}#Begin           
Process             
{ 
    # Get current domain
    $AD = Get-ADDomain -Current LocalComputer
    #Get list of computers in AD
    $Comps = Get-ADComputer -searchbase $AD.ComputersContainer -prop * -filter * | select -ExpandProperty Name 

    $Comps | ForEach-Object { 
        if ($_.ComputerName) { 
                $Computer = $_.ComputerName     
        } else { 
                $Computer = $_ 
        } 
         
        if (Test-Connection -ComputerName $Computer -Count 1 -Quiet -EA 0) 
            { 
                $i++ 
                
                #Reset control vars
                $InstallSuccess = 1
                $InstallSalt = 1
                $SaltFailsafe = 0
                $StopSalt = 1
                $SaltStopFailsafe = 0
                $StartSalt = 1
                $SaltStartFailsafe = 0


                #Install Salt
                while ($InstallSalt -ne 0)
                {

                    
                    $InstallCommand = "psexec.exe \\$Computer -u $AdminUser -p $AdminPassword $SaltInstallCmd"
                    $StopCommand = "psexec.exe \\$Computer -u $AdminUser -p $AdminPassword net stop salt-minion"
                    $StartCommand = "psexec.exe \\$Computer -u $AdminUser -p $AdminPassword net start salt-minion"

                    Write-Host "*** Installing ->" $InstallCommand

                    Invoke-Expression $InstallCommand
                    $InstallSalt = $LASTEXITCODE
                    $SaltFailsafe++
                    if ($SaltFailsafe -ge 2)
                    {
                        Write-Host "Salt install for $Computer failed, last exit code was $InstallSalt"
                        $InstallSalt = 0
                        $InstallSuccess = 0
                    }
                }

                #if $InstallSallt and $LASTEXITCODE do not match, it means salt failed to install successfully, dont bother with services

                if ($InstallSalt -eq $LASTEXITCODE) 
                {
                    while ($StopSalt -ne 0)
                    {
                        Write-Host "*** Stopping ->" $StopCommand
                        Invoke-Expression $StopCommand
                        $StopSalt = $LASTEXITCODE
                        $SaltStopFailsafe++
                        if ($SaltStopFailsafe -ge 5)
                        {
                            Write-Host "Salt service for $Computer failed to stop, last exit code was $StopSalt"
                            $StopSalt = 0
                            $InstallSuccess = 0
                        }
                    }

                    #if $StopSalt and $LASTEXITCODE do not match, it means the Salt-Minion service failed to stop, dont bother trying to start it

                    if ($StopSalt -eq $LASTEXITCODE)
                    {
                        while ($StartSalt -ne 0)
                        {
                            Write-Host "*** Starting ->" $StartCommand
                            Invoke-Expression $StartCommand
                            $StartSalt = $LASTEXITCODE
                            $SaltStopFailsafe++
                            if ($SaltStartFailsafe -ge 5)
                            {
                                Write-Host "Salt service for $Computer failed to start, last exit code was $StartSalt"
                                $StartSalt = 0
                                $InstallSuccess = 0
                            }
                        }
                    }
                }


                #if we failed at any point, $InstallSuccess gets changed to 0, send a success message if we did all three steps successfully

                if ($InstallSuccess -eq 1) {
                    Write-Host "Salt-minion successfully installed on $Computer"
                }
                
            } else  { 
                Write-Host "Offline: $($Computer)" -background red -foreground white 
            } 
    }#Foreach-Object (Computers) 
     
}#Process 
End 
{ 
    #Write-Host "AdminUser=" + $AdminUser + " AdminPass=" + $AdminPassword + " SaltCommand=" + $SaltInstallCmd


    "`n$($i) Computers online." | Out-Host 
}#End 
 
}#Deploy-Salt-Minions  



#Deploy-Salt-Minions -AdminUser "***insertUserName***" -AdminPassword "***insertPassword***" -SaltInstallCmd "\\SERVER\company\Salt-Minion-2016.3.4-AMD64-Setup.exe /S /master=[SALTMASTER-URL] /start-service=1"


