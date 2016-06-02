# Author: Perry Stathopoulos
# Company: Crestline IT Services
# Set the $folder variable to check if the files in the folder and all its sub-folders are set to offline. Should only happen when the PC is away from the office

$folder = C:\User\USER_NAME\Documents

Get-ChildItem $folder -recurse | Where-Object {$_.Attributes -eq 'offline'} 