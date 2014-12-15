## PCs anlegen

function new-pc ()
{
  write-host ""
  write-host "Rechner werden angelegt:"
  $global:Query = 'SELECT * FROM rechner'
  $mysqlresults = Get-SqlDataTable $Query
  
  ForEach ($result in $mysqlresults){
  	[string]$dnsname = ""+$($result.name)+".smart-in-hamburg.org"
  	New-ADComputer -Description $($result.description) -DisplayName $($result.displayname) -DNSHostName $dnsname -Name $($result.name) -ManagedBy $($result.manage) -OperatingSystem $($result.os)
  	write-host "Rechner $($result.name) wurde erstellt."
  }
}
