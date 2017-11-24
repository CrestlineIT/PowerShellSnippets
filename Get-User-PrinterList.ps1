Get-ChildItem Registry::\HKEY_Users | 
Where-Object { $_.PSChildName -NotMatch ".DEFAULT|S-1-5-18|S-1-5-19|S-1-5-20|_Classes" } | 
Select-Object -ExpandProperty PSChildName | 
ForEach-Object { Get-ChildItem Registry::\HKEY_Users\$_\Printers\Connections -Recurse | Select-Object -ExpandProperty Name }