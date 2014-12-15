#hohlen von der acl des ordners test
$ACL = Get-Acl -Path C:\test

#löschen von acl einträgen

$ACL.SetAccessRuleProtection($true,$false)
$ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}

#hinzufügen von acl einträgen
#SYSTEM und Administrator müssen unbedingt bleiben !!!!!!!!11111!!!1!

$ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
$ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SMART\Administrator","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
$ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SMART\grace.hopper","FullControl","ContainerInherit,ObjectInherit","None","Allow")))

#acl updaten mit neuen settings

Set-Acl -Path C:\test $ACL
