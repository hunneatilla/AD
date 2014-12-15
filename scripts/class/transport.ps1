## User und PCs in OU verlegen
## Benutzer

function transport-user-in-ou ()
{
  write-host ""
  write-host "Benutzer werden in OU verlegt:"
  $global:Query = 'SELECT benutzer.login as benutzer, ou.name as ou FROM benutzer, ou WHERE benutzer.ou = ou.id'
  $mysqlresults = Get-SqlDataTable $Query
  
  ForEach ($result in $mysqlresults){
  	[string]$path = "OU="+$($result.ou)+",DC=smart-in-hamburg,DC=org"
  	Get-ADUser -Identity $($result.benutzer) | Move-ADObject -TargetPath $path
  	write-host "Benutzer $($result.benutzer) wurde in OU $($result.ou) verlegt."
  }
}

## PC

function transport-pc-in-ou ()
{
  write-host ""
  write-host "Rechner werden in OU verlegt:"
  $global:Query = 'SELECT rechner.name as rechner, ou.name as ou FROM rechner, ou WHERE rechner.ou = ou.id'
  $mysqlresults = Get-SqlDataTable $Query
  
  ForEach ($result in $mysqlresults){
  	[string]$path = "OU="+$($result.ou)+",DC=smart-in-hamburg,DC=org"
  	Get-ADComputer -Identity $($result.rechner) | Move-ADObject -TargetPath $path
  	write-host "Rechner $($result.rechner) wurde in OU $($result.ou) verlegt."
  }
}

## User in Gruppen verlegen

function transport-user-in-group ()
{
  write-host ""
  write-host "Benutzer werden in Gruppen verlegt:"
  $global:Query = 'SELECT benutzer.login as benutzer, gruppe.name as gruppe FROM benutzer, gruppe, benutzer_gruppe WHERE benutzer.id = benutzer_gruppe.benutzer AND gruppe.id = benutzer_gruppe.gruppe'
  $mysqlresults = Get-SqlDataTable $Query
  
  ForEach ($result in $mysqlresults){
  	Add-ADGroupMember -Identity $($result.gruppe) -Member $($result.benutzer)
  	write-host "Benutzer $($result.benutzer) wurde in Gruppe $($result.gruppe) verlegt."
  }
}
