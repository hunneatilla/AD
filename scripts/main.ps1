
## OUs anlegen
$global:Query = 'SELECT * FROM ou'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
	## echo $($result.name)
	## echo $($result.description)
	New-ADOrganizationalUnit -Name $($result.name) -Description $($result.description) -DisplayName $($result.name) -ProtectedFromAccidentalDeletion $false

}

## Gruppen anlegen
