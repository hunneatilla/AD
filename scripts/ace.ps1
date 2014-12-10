# http://www.powershellpraxis.de/index.php/berechtigungen

$DirectoryPath = "c:"
# $IdentityRef = "DOM1\Karl_Napf"  #User oder Group
$IdentityRef = Get-ADObject -Identity Benutzer

$ACL = Get-ACL $DirectoryPath
$ACEs=(Get-Acl $DirectoryPath).Access | where {$_.IdentityReference -eq $IdentityRef}
$ACEs | foreach{
    try{
    $null=$ACL.RemoveAccessRule($_)
    Set-ACL $DirectoryPath $ACL
    "ACE für $IdentityRef erfolgreich entfernt"
    }
    catch{
    #keine ACE mehr vorhanden
    }
 }
