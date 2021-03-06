## Datei mit der connect-Funktion
#. $(Get-Location).Path\mysql_connection.ps1
. C:\Skripte\mysql_connection.ps1 # connect ()
. C:\Skripte\alc.ps1 # set-acl ($DirectoryPath, $IdentityRef, $rights)
. C:\Skripte\folder.ps1 # new-folder ()

## Funktion um die Verbindung aufzubauen
connect

## Ordner anlegen
write-host ""
write-host "Ordner werden angelegt:"
New-Item -Path "C:\" -Name "smart" -ItemType directory
New-Item -Path "C:\smart\" -Name "profile$" -ItemType directory
New-Item -Path "C:\smart\" -Name "global" -ItemType directory
New-Item -Path "C:\smart\" -Name "abteilung" -ItemType directory
New-Item -Path "C:\smart\" -Name "schulung" -ItemType directory
New-Item -Path "C:\smart\" -Name "home" -ItemType directory
New-Item -Path "C:\smart\abteilung\" -Name "geschäftsführung" -ItemType directory
New-Item -Path "C:\smart\abteilung\" -Name "verwaltung" -ItemType directory
New-Item -Path "C:\smart\abteilung\" -Name "schulung_allgemein" -ItemType directory
New-Item -Path "C:\smart\abteilung\" -Name "schulung_technik" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum1" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum2" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum3" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum4" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum5" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum6" -ItemType directory

#$global:Query = 'SELECT login FROM benutzer'
#$mysqlresults = Get-SqlDataTable $Query

#ForEach ($result in $mysqlresults){
#	New-Item -Path "C:\smart\home\" -Name $($result.login) -ItemType directory
#}
write-host "Ordner wurden angelegt!"

## AbteilungsShares anlegen
write-host ""
write-host "Ordner werden freigegeben:"
New-SmbShare -Name "global" -Path C:\global -Description GlobalShare
New-SmbShare -Name "geschäftsführung" -Path C:\smart\abteilung\geschäftsführung -Description GeschäftsführungShare
New-SmbShare -Name "verwaltung" -Path C:\smart\abteilung\verwaltung -Description VerwaltungShare
New-SmbShare -Name "schulung_allgemein" -Path C:\smart\abteilung\schulung_allgemein -Description SchulungAllgemeinShare
New-SmbShare -Name "schulung_technik" -Path C:\smart\abteilung\schulung_technik -Description SchulungTechnikShare
New-SmbShare -Name "raum1" -Path C:\smart\schulung\raum1 -Description Raum1Share
New-SmbShare -Name "raum2" -Path C:\smart\schulung\raum2 -Description Raum2Share
New-SmbShare -Name "raum3" -Path C:\smart\schulung\raum3 -Description Raum3Share
New-SmbShare -Name "raum4" -Path C:\smart\schulung\raum4 -Description Raum4Share
New-SmbShare -Name "raum5" -Path C:\smart\schulung\raum5 -Description Raum5Share
New-SmbShare -Name "raum6" -Path C:\smart\schulung\raum6 -Description Raum6Share
write-host "Ordner wurden freigegeben!"

## User anlegen
write-host ""
write-host "Benutzer werden angelegt:"
$global:Query = 'SELECT * FROM benutzer'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	$Drive = "\\dc\$($result.login)"
	$secure_string_pwd = convertto-securestring $($result.password) -asplaintext -force
	New-ADUser -Name $($result.login) -AccountNotDelegated $false -AuthType "Negotiate" -CannotChangePassword $false -ChangePasswordAtLogon $true -Company $($result.company) -Department $($result.abteilung) -Description $($result.description) -EmailAddress $($result.email) -EmployeeID $($result.id) -GivenName $($result.vorname) -MobilePhone $($result.mphone) -Office $($result.office) -OfficePhone $($result.ophone) -PasswordNeverExpires $false -PasswordNotRequired $false -Surname $($result.nachname) -Title $($result.description) -TrustedForDelegation $true -AccountPassword $secure_string_pwd -Enabled $true -ProfilePath "\\dc\profile$\%username%" -HomeDrive "Z:" -HomeDirectory $Drive
	New-Item -Path "C:\smart\home\" -Name $($result.login) -ItemType directory
	New-SmbShare -Name $($result.login) -Path C:\smart\home\$($result.login) -Description HomeShare
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
