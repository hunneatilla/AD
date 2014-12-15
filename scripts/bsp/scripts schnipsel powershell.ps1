Gruppe:
#input
[string]$groupname = "Wuerste"
[string]$manage = "atopar"
[string]$state = "Las Vegas"
[string]$gstreet = "street"
[string]$gdescription = "Kingz"
New-ADGroup -Name $groupname -ManagedBy $manage -Description $gdescription -DisplayName $groupname -GroupScope Global
#del
Remove-ADGroup -Identity "Wuerste"
-------------------------------------------
OU:
#input
[string]$ouname = "Test"
[string]$oucountry = "DE"
[string]$oucity = "Las Vegas"
[string]$oudescription = "OU der Welt"
[string]$oustate = "Nord Reihn Westfalen"
[string]$oustreet = "street"
New-ADOrganizationalUnit -Name $ouname -Country $oucountry -City $oucity -Description $oudescription -State $oustate -StreetAddress $oustreet -DisplayName $ouname -ProtectedFromAccidentalDeletion $false

#del
Remove-ADOrganizationalUnit -Identity "OU=Test,DC=smart-in-hamburg,DC=org" -Recursive
---------------------------------------------------------------------------------------
User:
#input
[string]$name = "atopar"
[string]$description = "König der Welt"
[string]$gname = "atilla"
[string]$surname = "toparlak"
[string]$email = "funky@test.com"
[int]$mphone = 542159
[int]$ophone = 752155554
[string]$company = "telekomico"
[string]$department = "Verwaltung"
[string]$title = "Consultant"
[int]$eid = 1
[string]$office = "room"
[string]$street = "street"
[string]$city = "Miami"
[string]$state = "Florida"
[string]$country = "DE"
[string]$path = "\\dc\profiles$\%username%"
$secure_string_pwd = convertto-securestring "test1234!" -asplaintext -force
New-ADUser -Name $name -AccountNotDelegated $false -AuthType "Negotiate" -CannotChangePassword $false -ChangePasswordAtLogon $true -City $city -Company $company -Country $country -Department $department -Description $description -EmailAddress $email -EmployeeID $eid -GivenName $gname -MobilePhone $mphone -Office $office -OfficePhone $ophone -PasswordNeverExpires $false -PasswordNotRequired $false -State $state -StreetAddress $street -Surname $surname -Title $title -TrustedForDelegation $true -AccountPassword $secure_string_pwd -Enabled $true -ProfilePath $path
#description und title evt. zusammen
#del
Remove-ADUser -Identity "atopar"
---------------------------------
User in OU verlegen:
#user
Get-ADUser -Identity "atopar" | Move-ADObject -TargetPath "OU=Test,DC=smart-in-hamburg,DC=org"#
#pcs
Get-ADComputer -Identity "R1C1" | Move-ADObject -TargetPath "OU=Test,DC=smart-in-hamburg,DC=org"
------------------------------------------------------------------------------------------------
PC Konten anlegen:

[string]$description = "BossPC"
[string]$displayname = "PCBoss"
[string]$dnsname = "pc1.smart-in-hamburg.org"
[string]$name = "the boss pc"
[string]$manage = "admin"
[string]$os = "Windows 8"
New-ADComputer -Description $description -DisplayName $displayname -DNSHostName $dnsname -Name $name -ManagedBy $manage -OperatingSystem $os 

------------------------------------------------------------------------------------------------
User in Gruppe verlegen:
#user
Add-ADGroupMember -Identity TestGroup1 -Member $_.UserName 