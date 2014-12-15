## Datei mit der connect-Funktion
#. $(Get-Location).Path\mysql_connection.ps1
. C:\Skripte\mysql_connection.ps1 # connect ()
. C:\Skripte\alc.ps1 # set-acl ($DirectoryPath, $IdentityRef, $rights)
. C:\Skripte\folder.ps1 # new-folder ()
. C:\Skripte\share.ps1 # share ()
. C:\Skripte\user.ps1 # new-user ()
. C:\Skripte\pc.ps1 # new-pc ()

## mySQL Verbindung aufbauen
connect

## Ordner anlegen
new-folder

## AbteilungsShares anlegen
share

## User anlegen
new-user

## PCs anlegen
new-pc

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
	write-host "Rechner $($result.rechner) wurde in OU $($result.ou) verlegt."
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
