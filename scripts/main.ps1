## Datei mit der connect-Funktion
#. $(Get-Location).Path\mysql_connection.ps1
. C:\Skripte\mysql_connection.ps1 
# connect ()
. C:\Skripte\acl.ps1 
# acl () # new_acl ($DirectoryPath, $IdentityRef, $rights)
. C:\Skripte\folder.ps1 
# new-folder ()
. C:\Skripte\share.ps1 
# set-share ()
. C:\Skripte\user.ps1 
# new-user ()
. C:\Skripte\pc.ps1 
# new-pc ()
. C:\Skripte\ou.ps1 
# new-ou () # verschachtel-ou ()
. C:\Skripte\group.ps1 
# new-group ()
. C:\Skripte\transport.ps1 
# transport-user-in-ou () # transport-pc-in-ou () # transport-user-in-group ()

## mySQL Verbindung aufbauen
connect

## Ordner anlegen
new-folder

## AbteilungsShares anlegen
set-share

## User anlegen
new-user

## PCs anlegen
new-pc

## OUs anlegen
new-ou

## Gruppen anlegen
new-group

## User und PCs in OU verlegen
## Benutzer
transport-user-in-ou

## PC
transport-pc-in-ou

## User in Gruppen verlegen
transport-user-in-group

## OUs verschachteln
verschachel-ou

## ACL setzten
acl


write-host ""
write-host "Mission completed"
