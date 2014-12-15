## OUs anlegen

function new-ou ()
{
  write-host ""
  write-host "OUs werden angelegt:"
  $global:Query = 'SELECT * FROM ou'
  $mysqlresults = Get-SqlDataTable $Query
  
  ForEach ($result in $mysqlresults){
  	New-ADOrganizationalUnit -Name $($result.name) -Description $($result.description) -DisplayName $($result.name) -ProtectedFromAccidentalDeletion $false
  	write-host "OU $($result.name) wurde erstellt."
  }
}
