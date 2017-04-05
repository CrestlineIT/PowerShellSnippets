# Import the Active Directory Module
Import-module activedirectory
#
# Create a variable for get-date (current date)
$date = get-date
#
# Create a variable called $User to get all users in Active Directory with all Properties
$User = Get-ADUser -Filter 'objectclass -eq "User"' -Properties *
#
# Display all Users within Active Directory that have been created in the last 30 days
$User | Where-Object {$_.LastLogonDate -gt $date.adddays(-30)} |
#
# Sort the out-put data by LastLogonDate
Sort-Object -Property LastLogonDate |
#
# Display the information with the below headings
Select Name,LastLogonDate,Enabled |
#
# Export the results to CSV file
Out-file .\UsersLast30Days.csv