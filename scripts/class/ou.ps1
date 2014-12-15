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

## OUs verschachteln

function verschachel-ou ()
{
  write-host ""
  write-host "OUs werden verschachtelt:"
  Move-ADObject -Identity "OU=Geschäftsführung,DC=smart-in-hamburg,DC=org" -TargetPath "OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  Move-ADObject -Identity "OU=Verwaltung,DC=smart-in-hamburg,DC=org" -TargetPath "OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  Move-ADObject -Identity "OU=Schulung,DC=smart-in-hamburg,DC=org" -TargetPath "OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  Move-ADObject -Identity "OU=Allgemein,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  Move-ADObject -Identity "OU=Technik,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  Move-ADObject -Identity "OU=Räume,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  Move-ADObject -Identity "OU=Raum1,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Räume,OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  Move-ADObject -Identity "OU=Raum2,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Räume,OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  Move-ADObject -Identity "OU=Raum3,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Räume,OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  Move-ADObject -Identity "OU=Raum4,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Räume,OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  Move-ADObject -Identity "OU=Raum5,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Räume,OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  Move-ADObject -Identity "OU=Raum6,DC=smart-in-hamburg,DC=org" -TargetPath "OU=Räume,OU=Schulung,OU=SmartGmbH,DC=smart-in-hamburg,DC=org"
  write-host "Verschachtelung abgeschlossen!"
}
