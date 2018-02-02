# Author: Perry Stathopoulos
# Company: Crestline IT Services
# Inspired by Debloat-Windows-10 scripts

function Disable-Services { 
# This script disables unwanted Windows services. If you do not want to disable
# certain services comment out the corresponding lines below.

	$services = @(
		"diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
		"DiagTrack"                                # Diagnostics Tracking Service
		"dmwappushservice"                         # WAP Push Message Routing Service (see known issues)
		"HomeGroupListener"                        # HomeGroup Listener
		"HomeGroupProvider"                        # HomeGroup Provider
		"lfsvc"                                    # Geolocation Service
		"MapsBroker"                               # Downloaded Maps Manager
		"NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
		"RemoteAccess"                             # Routing and Remote Access
		"RemoteRegistry"                           # Remote Registry
		"SharedAccess"                             # Internet Connection Sharing (ICS)
		"TrkWks"                                   # Distributed Link Tracking Client
		"WbioSrvc"                                 # Windows Biometric Service
		#"WlanSvc"                                 # WLAN AutoConfig
		"WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
		#"wscsvc"                                  # Windows Security Center Service
		#"WSearch"                                 # Windows Search
		"XblAuthManager"                           # Xbox Live Auth Manager
		"XblGameSave"                              # Xbox Live Game Save Service
		"XboxNetApiSvc"                            # Xbox Live Networking Service

		# Services which cannot be disabled
		#"WdNisSvc"
	)

	foreach ($service in $services) {
		Write-Output "Trying to disable $service"
		Get-Service -Name $service | Set-Service -StartupType Disabled
	}
}

function Remove-DefaultApps {
#   Description:
# This script removes unwanted Apps that come with Windows. If you  do not want
# to remove certain Apps comment out the corresponding lines below.

	Write-Output "Uninstalling default apps"
	$apps = @(
		# default Windows 10 apps
		"Microsoft.3DBuilder"
		"Microsoft.Appconnector"
		"Microsoft.BingFinance"
		"Microsoft.BingNews"
		"Microsoft.BingSports"
		"Microsoft.BingWeather"
		#"Microsoft.FreshPaint"
		"Microsoft.Getstarted"
		"Microsoft.MicrosoftOfficeHub"
		"Microsoft.MicrosoftSolitaireCollection"
		#"Microsoft.MicrosoftStickyNotes"
		"Microsoft.Office.OneNote"
		#"Microsoft.OneConnect"
		"Microsoft.People"
		"Microsoft.SkypeApp"
		#"Microsoft.Windows.Photos"
		"Microsoft.WindowsAlarms"
		#"Microsoft.WindowsCalculator"
		"Microsoft.WindowsCamera"
		"Microsoft.WindowsMaps"
		"Microsoft.WindowsPhone"
		"Microsoft.WindowsSoundRecorder"
		#"Microsoft.WindowsStore"
		"Microsoft.XboxApp"
		"Microsoft.ZuneMusic"
		"Microsoft.ZuneVideo"
		"microsoft.windowscommunicationsapps"
		"Microsoft.MinecraftUWP"
		"Microsoft.MicrosoftPowerBIForWindows"
		"Microsoft.NetworkSpeedTest"
		
		# Threshold 2 apps
		"Microsoft.CommsPhone"
		"Microsoft.ConnectivityStore"
		"Microsoft.Messaging"
		"Microsoft.Office.Sway"
		"Microsoft.OneConnect"
		"Microsoft.WindowsFeedbackHub"


		#Redstone apps
		"Microsoft.BingFoodAndDrink"
		"Microsoft.BingTravel"
		"Microsoft.BingHealthAndFitness"
		"Microsoft.WindowsReadingList"

		# non-Microsoft
		"9E2F88E3.Twitter"
		"PandoraMediaInc.29680B314EFC2"
		"Flipboard.Flipboard"
		"ShazamEntertainmentLtd.Shazam"
		"king.com.CandyCrushSaga"
		"king.com.CandyCrushSodaSaga"
		"king.com.*"
		"ClearChannelRadioDigital.iHeartRadio"
		"4DF9E0F8.Netflix"
		"6Wunderkinder.Wunderlist"
		"Drawboard.DrawboardPDF"
		"2FE3CB00.PicsArt-PhotoStudio"
		"D52A8D61.FarmVille2CountryEscape"
		"TuneIn.TuneInRadio"
		"GAMELOFTSA.Asphalt8Airborne"
		#"TheNewYorkTimes.NYTCrossword"
		"DB6EA5DB.CyberLinkMediaSuiteEssentials"
		"Facebook.Facebook"
		"flaregamesGmbH.RoyalRevolt2"
		"Playtika.CaesarsSlotsFreeCasino"
		"A278AB0D.MarchofEmpires"
		"KeeperSecurityInc.Keeper"
		"ThumbmunkeysLtd.PhototasticCollage"
		"XINGAG.XING"
		"89006A2E.AutodeskSketchBook"
		"D5EA27B7.Duolingo-LearnLanguagesforFree"
		"46928bounde.EclipseManager"
		"ActiproSoftwareLLC.562882FEEB491" # next one is for the Code Writer from Actipro Software LLC
		"DolbyLaboratories.DolbyAccess"
		"SpotifyAB.SpotifyMusic"
		"A278AB0D.DisneyMagicKingdoms"
		"WinZipComputing.WinZipUniversal"


		# apps which cannot be removed using Remove-AppxPackage
		#"Microsoft.BioEnrollment"
		#"Microsoft.MicrosoftEdge"
		#"Microsoft.Windows.Cortana"
		#"Microsoft.WindowsFeedback"
		#"Microsoft.XboxGameCallableUI"
		#"Microsoft.XboxIdentityProvider"
		#"Windows.ContactSupport"
	)

	foreach ($app in $apps) {
		Write-Output "Trying to remove $app"

		Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers

		Get-AppXProvisionedPackage -Online |
			Where-Object DisplayName -EQ $app |
			Remove-AppxProvisionedPackage -Online
	}

	# Prevents "Suggested Applications" returning
	force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content"
	Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content" "DisableWindowsConsumerFeatures" 1
}

# While `mkdir -force` works fine when dealing with regular folders, it behaves
# strange when using it at registry level. If the target registry key is
# already present, all values within that key are purged.
function force-mkdir($path) {
    if (!(Test-Path $path)) {
        #Write-Host "-- Creating full path to: " $path -ForegroundColor White -BackgroundColor DarkGreen
        New-Item -ItemType Directory -Force -Path $path
    }
}

function Remove-OneDrive{
# This script will remove and disable OneDrive integration.

	Write-Output "Kill OneDrive process"
	taskkill.exe /F /IM "OneDrive.exe"
	taskkill.exe /F /IM "explorer.exe"

	Write-Output "Remove OneDrive"
	if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
		& "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
	}
	if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
		& "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
	}

	Write-Output "Removing OneDrive leftovers"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp"
	# check if directory is empty before removing:
	If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
		Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:userprofile\OneDrive"
	}

	Write-Output "Disable OneDrive via Group Policies"
	force-mkdir "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive"
	Set-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1

	Write-Output "Remove Onedrive from explorer sidebar"
	New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
	mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	Set-ItemProperty "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
	mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	Set-ItemProperty "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
	Remove-PSDrive "HKCR"

	# Thank you Matthew Israelsson
	Write-Output "Removing run hook for new users"
	reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
	reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
	reg unload "hku\Default"

	Write-Output "Removing startmenu entry"
	Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

	Write-Output "Removing scheduled task"
	Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

	Write-Output "Restarting explorer"
	Start-Process "explorer.exe"

	Write-Output "Waiting for explorer to complete loading"
	Start-Sleep 10

	Write-Output "Removing additional OneDrive leftovers"
	foreach ($item in (Get-ChildItem "$env:WinDir\WinSxS\*onedrive*")) {
		#Takeown-Folder $item.FullName
		Remove-Item -Recurse -Force $item.FullName
	}
}


Disable-Services
Remove-DefaultApps
Remove-OneDrive
