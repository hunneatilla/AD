## User anlegen

function new-user ()
{
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
}
