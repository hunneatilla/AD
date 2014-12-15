# http://www.powershellpraxis.de/index.php/berechtigungen

#. C:\Skripte\mysql_connection.ps1
#connect

function new_acl ($DirectoryPath, $IdentityRef, $rights)
{
$ACL = Get-Acl -Path $DirectoryPath

$ACL.SetAccessRuleProtection($true,$false)
$ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}

$ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
$ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SMART\Administrator","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
$ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SMART\$IdentityRef",$rights,"ContainerInherit,ObjectInherit","None","Allow")))

Set-Acl -Path $DirectoryPath $ACL
}

## Homelaufwerke
$global:Query = 'SELECT ou, login, abteilung, office FROM benutzer'
$mysqlresults = Get-SqlDataTable $Query

ForEach ($result in $mysqlresults){
    $HomeDirectoryPath="C:\smart\home\$($result.login)"
    $SchulungDirectoryPath="C:\smart\schulung\$($result.office)"
    $AbteilungDirectoryPath="C:\smart\abteilung\$($result.abteilung)"
    
    # Alle
    # global
    new_acl "C:\smart\global" $($result.login) "Read"
    
    # Schulungsteilnehmer
    if ($($result.abteilung) -eq "Schulung")
    {
        # home
        new_acl $HomeDirectoryPath $($result.login) "Write,Read,Modify"
        # schulung
        new_acl $SchulungDirectoryPath $($result.login) "Read"
    }
    # alle Mitarbeiter
    else
    {
        # home
        new_acl $HomeDirectoryPath $($result.login) "FullControl"
        # abteilung
        new_acl $AbteilungDirectoryPath $($result.login) "Write,Read,Modify"
        
        # Schulungleiter
        if ($($result.ou) -eq "4" -or $($result.ou) -eq "5")
        {
            for ($i=1; $i -le 6; $i++)
            {
                # schulung
                new_acl "C:\smart\schulung\raum$i" $($result.login) "Write,Read,Modify"
                
                for ($k=1; $k -le 12; $k++)
                {
                # home
                new_acl "C:\smart\home\s$i.p$k" $($result.login) "Write,Read,Modify"
                }
            }
        }
    }
}
