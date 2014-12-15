# http://www.powershellpraxis.de/index.php/berechtigungen

. C:\Skripte\mysql_connection.ps1
connect

function setacl ($DirectoryPath, $IdentityRef, $rights)
{

# $DirectoryPath="c:\temp\homes\homeuser001"
# $IdentityRef = "DOM1\Karl_Napf"  #User oder Group

#$FileSystemRights = [System.Security.AccessControl.FileSystemRights]"131487"
#$FileSystemRights = [System.Security.AccessControl.FileSystemRights]"Write,Read"
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

function setacl2 ($DirectoryPath, $IdentityRef, $rights) 
{
    $ACL = Get-Acl $DirectoryPath
    $ACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
        ($IdentityRef,$rights, "ContainerInherit, ObjectInherit", "Inheritonly", "Allow")
    $ACL.AddAccessRule($ACE)
    Set-Acl $DirectoryPath $ACL
}


## Homelaufwerke
$global:Query = 'SELECT login, abteilung FROM benutzer'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
    $DirectoryPath="c:\smart\home\$($result.login)"
    # $IdentityRef = Get-ADUser -Identity $($result.login)
    $IdentityRef = "smart-in-hamburg\$($result.login)"
    for ($i=0; $i -le 0; $i++){
            write-host $DirectoryPath
            write-host $IdentityRef
            #setacl $DirectoryPath $IdentityRef "Write,Read"
            setacl2 $DirectoryPath $IdentityRef "Write,Read"
            break
    }
}
