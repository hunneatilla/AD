# http://www.powershellpraxis.de/index.php/berechtigungen

function set-acl ($DirectoryPath, $IdentityRef, $rights)
{

# $DirectoryPath="c:\temp\homes\homeuser001"
# $IdentityRef = "DOM1\Karl_Napf"  #User oder Group

#$FileSystemRights = [System.Security.AccessControl.FileSystemRights]"131487"
# $FileSystemRights = [System.Security.AccessControl.FileSystemRights]"Write,Read"
$FileSystemRights = [System.Security.AccessControl.FileSystemRights]$rights

$InheritanceFlag1 = [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
$InheritanceFlag2 = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit
$InheritanceFlag=$InheritanceFlag1 -bor $InheritanceFlag2

$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::InheritOnly
$AccessControlType =[System.Security.AccessControl.AccessControlType]::Allow
$User = New-Object System.Security.Principal.NTAccount($IdentityRef)

$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $FileSystemRights,`
    $InheritanceFlag, $PropagationFlag, $AccessControlType)
$ACL = Get-ACL $DirectoryPath
$ACL.AddAccessRule($ACE)

Set-ACL $DirectoryPath $ACL
}


## Homelaufwerke
$global:Query = 'SELECT login, abteilung FROM benutzer'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
    $IdentityRef = Get-ADUser -Identity $($result.benutzer)
    switch ($($result.abteilung))
    {
        "Geschäftsführung" { set-acl "C:\smart\home\$($result.login)" $IdentityRef "FullControl" }
        "Verwaltung" { set-acl "C:\smart\home\$($result.login)" $IdentityRef "FullControl" }
        "Schulungen Allgemein" { set-acl "C:\smart\home\$($result.login)" $IdentityRef "FullControl" }
        "Schulungen Technik" { set-acl "C:\smart\home\$($result.login)" $IdentityRef "FullControl" }
        "Schulung" { set-acl "C:\smart\home\$($result.login)" $IdentityRef "Write,Read,Modify" }
        default {}
    }
}
