## Gruppen anlegen

function new-group ()
{
  write-host ""
  write-host "Gruppen werden angelegt:"
  $global:Query = 'SELECT * FROM gruppe'
  $mysqlresults = Get-SqlDataTable $Query
  
  ForEach ($result in $mysqlresults){
  	New-ADGroup -Name $($result.name) -ManagedBy $($result.manager) -Description $($result.description) -DisplayName $($result.name) -GroupScope Global
  	write-host "Gruppe $($result.name) wurde erstellt."
  }
}
