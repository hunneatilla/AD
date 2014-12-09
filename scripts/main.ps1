## Datei mit der connect-Funktion
#. C:\mysql_connection.ps1
. $(Get-Location).Path\mysql_connection.ps1

## Funktion um die Verbindung aufzubauen
write-host ""
write-host "Verbindung zur Datenbank wird aufgebaut:"
connect
write-host "Verbindung aufgebaut!"

## User anlegen
write-host ""
write-host "Benutzer werden angelegt:"
$global:Query = 'SELECT * FROM benutzer'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	$secure_string_pwd = convertto-securestring $($result.password) -asplaintext -force
	New-ADUser -Name $($result.login) -AccountNotDelegated $false -AuthType "Negotiate" -CannotChangePassword $false -ChangePasswordAtLogon $true -Company $($result.company) -Department $($result.abteilung) -Description $($result.description) -EmailAddress $($result.email) -EmployeeID $($result.id) -GivenName $($result.vorname) -MobilePhone $($result.mphone) -Office $($result.office) -OfficePhone $($result.ophone) -PasswordNeverExpires $false -PasswordNotRequired $false -Surname $($result.nachname) -Title $($result.description) -TrustedForDelegation $true -AccountPassword $secure_string_pwd -Enabled $true -ProfilePath "\\dc\profiles$\%username%"
	write-host "Benutzer $($result.login) wurde erstellt."
}

## PCs anlegen
write-host ""
write-host "Rechner werden angelegt:"
$global:Query = 'SELECT * FROM rechner'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	[string]$dnsname = ""+$($result.name)+".smart-in-hamburg.org"
	New-ADComputer -Description $($result.description) -DisplayName $($result.displayname) -DNSHostName $dnsname -Name $($result.name) -ManagedBy $($result.manage) -OperatingSystem $($result.os)
	write-host "Rechner $($result.name) wurde erstellt."
}

## OUs anlegen
write-host ""
write-host "OUs werden angelegt:"
$global:Query = 'SELECT * FROM ou'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	New-ADOrganizationalUnit -Name $($result.name) -Description $($result.description) -DisplayName $($result.name) -ProtectedFromAccidentalDeletion $false
	write-host "OU $($result.name) wurde erstellt."
}

## Gruppen anlegen
write-host ""
write-host "Gruppen werden angelegt:"
$global:Query = 'SELECT * FROM gruppe'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	New-ADGroup -Name $($result.name) -ManagedBy $($result.manager) -Description $($result.description) -DisplayName $($result.name) -GroupScope Global
	write-host "Gruppe $($result.name) wurde erstellt."
}

## User und PCs in OU verlegen
## Benutzer
write-host ""
write-host "Benutzer werden in OU verlegt:"
$global:Query = 'SELECT benutzer.login as benutzer, ou.name as ou FROM benutzer, ou WHERE benutzer.ou = ou.id'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	[string]$path = "OU="+$($result.ou)+",DC=smart-in-hamburg,DC=org"
	Get-ADUser -Identity $($result.benutzer) | Move-ADObject -TargetPath $path
	write-host "Benutzer $($result.benutzer) wurde in OU $($result.ou) verlegt."
}

## PC
write-host ""
write-host "Rechner werden in OU verlegt:"
$global:Query = 'SELECT rechner.name as rechner, ou.name as ou FROM rechner, ou WHERE rechner.ou = ou.id'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	[string]$path = "OU="+$($result.ou)+",DC=smart-in-hamburg,DC=org"
	Get-ADComputer -Identity $($result.rechner) | Move-ADObject -TargetPath $path
	write-host "Rechner $($result.benutzer) wurde in OU $($result.ou) verlegt."
}

## User in Gruppen verlegen
write-host ""
write-host "Benutzer werden in Gruppen verlegt:"
$global:Query = 'SELECT benutzer.login as benutzer, gruppe.name as gruppe FROM benutzer, gruppe, benutzer_gruppe WHERE benutzer.id = benutzer_gruppe.benutzer AND gruppe.id = benutzer_gruppe.gruppe'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	Add-ADGroupMember -Identity $($result.gruppe) -Member $($result.benutzer)
	write-host "Benutzer $($result.benutzer) wurde in Gruppe $($result.gruppe) verlegt."
}

## OUs verschachteln
write-host ""
write-host "OUs werden verschachtelt:"
Move-ADObject -Identity "OU=Geschäftsführung,DC=smart-in-hamburg,DC=org" -TargetPath "OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Verwaltung,DC=smart-in-hamburg,DC=org" -TargetPath "OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Schulung,DC=smart-in-hamburg,DC=org" -TargetPath "OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Allgemein,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Technik,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum1,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum2,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum3,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum4,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum5,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum6,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
write-host "Verschachtelung abgeschlossen!"
write-host ""
write-host "Mission completed"
