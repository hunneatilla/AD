# http://www.powershellpraxis.de/index.php/berechtigungen

#. C:\Skripte\mysql_connection.ps1
#connect
#acl

[String[]] $global:arrPath = $null

function new_acl ($DirectoryPath, $IdentityRef, $rights)
{
    $ACL = Get-Acl -Path $DirectoryPath
    
    # Wenn der Pfad noch nicht bearbeitet wurde, dann lösche alle bisherigen Berechtigungen
    if($global:arrPath -notcontains $DirectoryPath)
    {
        $global:arrPath += $DirectoryPath
        
        $ACL.SetAccessRuleProtection($true,$false)
        $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
        
        $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
        $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SMART\Administrator","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
    }
    $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SMART\$IdentityRef",$rights,"ContainerInherit,ObjectInherit","None","Allow")))
    
    Set-Acl -Path $DirectoryPath $ACL
}

function acl ()
{
    write-host "ACL werden erstellt!"
    
    # Alle
    # global
    new_acl "C:\smart\global" "global" "Read"
    new_acl "C:\smart\abteilung\geschäftsführung" "geschäftsführung" "Write,Read,Modify"
    new_acl "C:\smart\abteilung\verwaltung" "verwaltung" "Write,Read,Modify"
    new_acl "C:\smart\abteilung\schulung_allgemein" "schulung_allgemein" "Write,Read,Modify"
    new_acl "C:\smart\abteilung\schulung_technik" "schulung_technik" "Write,Read,Modify"
    new_acl "C:\smart\schulung\raum1" "raum1" "Read"
    new_acl "C:\smart\schulung\raum1" "schulungsleiter" "Write,Read,Modify"
    new_acl "C:\smart\schulung\raum2" "raum2" "Read"
    new_acl "C:\smart\schulung\raum2" "schulungsleiter" "Write,Read,Modify"
    new_acl "C:\smart\schulung\raum3" "raum3" "Read"
    new_acl "C:\smart\schulung\raum3" "schulungsleiter" "Write,Read,Modify"
    new_acl "C:\smart\schulung\raum4" "raum4" "Read"
    new_acl "C:\smart\schulung\raum4" "schulungsleiter" "Write,Read,Modify"
    new_acl "C:\smart\schulung\raum5" "raum5" "Read"
    new_acl "C:\smart\schulung\raum5" "schulungsleiter" "Write,Read,Modify"
    new_acl "C:\smart\schulung\raum6" "raum6" "Read"
    new_acl "C:\smart\schulung\raum6" "schulungsleiter" "Write,Read,Modify"
    
    ## Homelaufwerke
    $global:Query = 'SELECT ou, login, abteilung, office FROM benutzer'
    $mysqlresults = Get-SqlDataTable $Query
    
    ForEach ($result in $mysqlresults){
        $HomeDirectoryPath="C:\smart\home\$($result.login)"
        $SchulungDirectoryPath="C:\smart\schulung\$($result.office)"
        $AbteilungDirectoryPath="C:\smart\abteilung\$($result.abteilung)"
        
        # Schulungsteilnehmer
        if ($($result.abteilung) -eq "Schulung")
        {
            # home
            new_acl $HomeDirectoryPath $($result.login) "Write,Read,Modify"
            new_acl $HomeDirectoryPath "schulungsleiter" "Write,Read,Modify"
        }
        # alle Mitarbeiter
        else
        {
            # home
            new_acl $HomeDirectoryPath $($result.login) "FullControl"
        }
    }
    write-host "ACL wurden erstellt!"
}
