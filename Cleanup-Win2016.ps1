# Author: Perry Stathopoulos
# Company: Crestline IT Services
# Inspired by https://blogs.technet.microsoft.com/secguide/2017/05/29/guidance-on-disabling-system-services-on-windows-server-2016-with-desktop-experience/


# This script disables unwanted Windows services. If you do not want to disable
# certain services comment out the corresponding lines below.
function Disable-Services { 
	$services = @(

		"AxInstSV"                                 #	ActiveX Installer (AxInstSV)
		"bthserv"                                  #	Bluetooth Support Service
		"CDPUserSvc"                               #	CDPUserSvc
		"PimIndexMaintenanceSvc"                   #	Contact Data
		"dmwappushservice"                         #	dmwappushsvc
		"MapsBroker"                               #	Downloaded Maps Manager
		"lfsvc"                                    #	Geolocation Service
		"SharedAccess"                             #	Internet Connection Sharing (ICS)
		"lltdsvc"                                  #	Link-Layer Topology Discovery Mapper
		"wlidsvc"                                  #	Microsoft Account Sign-in Assistant
		"NgcSvc"                                   #	Microsoft Passport
		"NgcCtnrSvc"                               #	Microsoft Passport Container
		"NcbService"                               #	Network Connection Broker
		"PhoneSvc"                                 #	Phone Service
		#"Spooler"                                 #	Print Spooler
		#"PrintNotify"                             #	Printer Extensions and Notifications
		"PcaSvc"                                   #	Program Compatibility Assistant Service
		"QWAVE"                                    #	Quality Windows Audio Video Experience
		"RmSvc"                                    #	Radio Management Service
		"SensorDataService"                        #	Sensor Data Service
		"SensrSvc"                                 #	Sensor Monitoring Service
		"SensorService"                            #	Sensor Service
		"ShellHWDetection"                         #	Shell Hardware Detection
		"ScDeviceEnum"                             #	Smart Card Device Enumeration Service
		"SSDPSRV"                                  #	SSDP Discovery
		"WiaRpc"                                   #	Still Image Acquisition Events
		"OneSyncSvc"                               #	Sync Host
		"TabletInputService"                       #	Touch Keyboard and Handwriting Panel Service
		"upnphost"                                 #	UPnP Device Host
		"UserDataSvc"                              #	User Data Access
		"UnistoreSvc"                              #	User Data Storage
		"WalletService"                            #	WalletService
		"Audiosrv"                                 #	Windows Audio
		"AudioEndpointBuilder"                     #	Windows Audio Endpoint Builder
		"FrameServer"                              #	Windows Camera Frame Server
		"stisvc"                                   #	Windows Image Acquisition (WIA)
		"wisvc"                                    #	Windows Insider Service
		"icssvc"                                   #	Windows Mobile Hotspot Service
		"WpnService"                               #	Windows Push Notifications System Service
		"WpnUserService"                           #	Windows Push Notifications User Service
		"XblAuthManager"                           #	Xbox Live Auth Manager
		"XblGameSave"                              # Xbox Live Game Save

	)

	foreach ($service in $services) {
		Write-Output "Trying to disable $service"
		Get-Service -Name $service | Set-Service -StartupType Disabled
	}
}

function Remove-ScheduledTasks{
	Write-Output "Removing scheduled task"
	Get-ScheduledTask -TaskPath '\Microsoft\XblGameSave\' -TaskName 'XblGame*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
}

Disable-Services
Remove-ScheduledTasks