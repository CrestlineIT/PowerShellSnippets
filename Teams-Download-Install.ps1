#OFFICE bitKey
$bitKey = get-itemproperty HKLM:\Software\Microsoft\Office\14.0\Outlook -name Bitness
if($bitKey -eq $null) {
$bitKey = get-itemproperty HKLM:\Software\Microsoft\Office\15.0\Outlook -name Bitness}
if($bitKey -eq $null) {
$bitKey = get-itemproperty HKLM:\Software\Microsoft\Office\16.0\Outlook -name Bitness}
if($bitKey -eq $null) {
$bitKey = get-itemproperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\14.0\Outlook -name Bitness}
if($bitKey -eq $null) {
$bitKey = get-itemproperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\15.0\Outlook -name Bitness}
if($bitKey -eq $null) {
$bitKey = get-itemproperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\16.0\Outlook -name Bitness}

Write-Host $bitKey.Bitness

if ($bitKey.Bitness -eq "x86")
{
  $url = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&managedInstaller=true&download=true"
  $output = "C:\windows\Temp\Teams_windows.msi"
}
else
{
  $url = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"
  $output = "C:\windows\Temp\Teams_windows_x64.msi"
}
Invoke-WebRequest -Uri $url -OutFile $output

$output = "C:\windows\Temp\Teams_windows.msi"
$arglist  = "/i $output /qn ALLUSERS=1"
write-host $arglist
Start-Process -FilePath "msiexec" -ArgumentList $arglist