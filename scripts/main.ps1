## Datei mit der connect-Funktion
#. C:\mysql_connection.ps1
. $(Get-Location).Path\mysql_connection.ps1

## Funktion um die Verbindung aufzubauen
connect

## User anlegen
$global:Query = 'SELECT * FROM benutzer'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	$secure_string_pwd = convertto-securestring $($result.password) -asplaintext -force
	New-ADUser -Name $($result.login) -AccountNotDelegated $false -AuthType "Negotiate" -CannotChangePassword $false -ChangePasswordAtLogon $true -Company $($result.company) -Department $($result.abteilung) -Description $($result.description) -EmailAddress $($result.email) -EmployeeID $($result.id) -GivenName $($result.vorname) -MobilePhone $($result.mphone) -Office $($result.office) -OfficePhone $($result.ophone) -PasswordNeverExpires $false -PasswordNotRequired $false -Surname $($result.nachname) -Title $($result.description) -TrustedForDelegation $true -AccountPassword $secure_string_pwd -Enabled $true -ProfilePath "\\dc\profiles$\%username%"
}

## PCs anlegen
$global:Query = 'SELECT * FROM rechner'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	[string]$dnsname = ""+$($result.name)+".smart-in-hamburg.org"
	New-ADComputer -Description $($result.description) -DisplayName $($result.displayname) -DNSHostName $dnsname -Name $($result.name) -ManagedBy $($result.manage) -OperatingSystem $($result.os)
}

## OUs anlegen
$global:Query = 'SELECT * FROM ou'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	New-ADOrganizationalUnit -Name $($result.name) -Description $($result.description) -DisplayName $($result.name) -ProtectedFromAccidentalDeletion $false
}

## Gruppen anlegen
$global:Query = 'SELECT * FROM gruppe'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	New-ADGroup -Name $($result.name) -ManagedBy $($result.manager) -Description $($result.description) -DisplayName $($result.name) -GroupScope Global
}

## User und PCs in OU verlegen
## Benutzer
$global:Query = 'SELECT benutzer.login as benutzer, ou.name as ou FROM benutzer, ou WHERE benutzer.ou = ou.id'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	[string]$path = "OU="+$($result.ou)+",DC=smart-in-hamburg,DC=org"
	Get-ADUser -Identity $($result.benutzer) | Move-ADObject -TargetPath $path
}

## PC
$global:Query = 'SELECT rechner.name as rechner, ou.name as ou FROM rechner, ou WHERE rechner.ou = ou.id'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	[string]$path = "OU="+$($result.ou)+",DC=smart-in-hamburg,DC=org"
	Get-ADComputer -Identity $($result.rechner) | Move-ADObject -TargetPath $path
}

## User in Gruppen verlegen
$global:Query = 'SELECT benutzer.login as benutzer, gruppe.name as gruppe FROM benutzer, gruppe, benutzer_gruppe WHERE benutzer.id = benutzer_gruppe.benutzer AND gruppe.id = benutzer_gruppe.gruppe'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	Add-ADGroupMember -Identity $($result.gruppe) -Member $($result.benutzer)
}

## OUs verschachteln
Move-ADObject -Identity "OU=Geschäftsführung,DC=smart-in-hamburg,DC=org" -TargetPath "OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Verwaltung,DC=smart-in-hamburg,DC=org" -TargetPath "OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Schulung,DC=smart-in-hamburg,DC=org" -TargetPath "OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Allgemein,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Technik,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum1,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum2,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum2,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum3,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum4,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
Move-ADObject -Identity "OU=Raum5,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
