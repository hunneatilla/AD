## Datei mit der connect-Funktion
#. C:\mysql_connection.ps1
. $(Get-Location).Path\mysql_connection.ps1

## Funktion um die Verbindung aufzubauen
connect

## User anlegen
$global:Query = 'SELECT * FROM benutzer'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	$secure_string_pwd = convertto-securestring $($result.pass) -asplaintext -force
	New-ADUser -Name $($result.login) -AccountNotDelegated $false -AuthType "Negotiate" -CannotChangePassword $false -ChangePasswordAtLogon $true -Company $($result.company) -Department $($result.abteilung) -Description $($result.description) -EmailAddress $($result.email) -EmployeeID $($result.id) -GivenName $($result.vorname) -MobilePhone $($result.mphone) -Office $($result.office) -OfficePhone $($result.ophone) -PasswordNeverExpires $false -PasswordNotRequired $false -Surname $($result.nachname) -Title $($result.description) -TrustedForDelegation $true -AccountPassword $secure_string_pwd -Enabled $true -ProfilePath "\\dc\profiles$\%username%"
}

## PCs anlegen
$global:Query = 'SELECT * FROM rechner'
$mysqlresults = Get-SqlDataTable $Query
[string]$dnsname = ".smart-in-hamburg.org"

ForEach ($result in $mysqlresults){
	New-ADComputer -Description $($result.description) -DisplayName $($result.displayname) -DNSHostName $($result.name)+$dnsname -Name $($result.name) -ManagedBy $($result.manage) -OperatingSystem $($result.os)
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
$global:Query = 'SELECT benutzer.name as benutzer, ou.name as ou FROM benutzer, ou WHERE benutzer.ou = ou.id'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	Get-ADUser -Identity $($result.benutzer) | Move-ADObject -TargetPath "OU="+$($result.ou)+",DC=smart-in-hamburg,DC=org"
}

## PC
$global:Query = 'SELECT rechner.name as rechner, ou.name as ou FROM rechner, ou WHERE rechner.ou = ou.id'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	Get-ADUser -Identity $($result.rechner) | Move-ADObject -TargetPath "OU="+$($result.ou)+",DC=smart-in-hamburg,DC=org"
}

## User und PCs in Gruppen verlegen
