clear
Import-Module ActiveDirectory

#---
$ErrorActionPreference="SilentlyContinue"
$WarningPreference='silentlycontinue'
#$ErrorActionPreference="Continue"
#$WarningPreference='continue'
Start-Transcript -path C:\log.txt -append #LogFile  

#Domainnamen einholen
$NTDOMAIN = Get-ADDomain.name

#-----Ordnerpfade Definieren
$Shares=Get-WmiObject Win32_Share `
    -List -ComputerName "SERVER"
  
  


           #Ordner Erstellen
           New-Item –type directory –path "C:\" -name data
           New-Item –type directory –path "C:\" -name home
           New-Item –type directory –path "C:\" -name profile
           New-Item –type directory –path "C:\data\" -name global
           New-Item –type directory –path "C:\data\" -name Schulungen
           New-Item –type directory –path "C:\data\" -name Abteilung


           #Freigaben Erstellen
           $Shares.Create("C:\data","data",0)
           $Shares.Create("C:\home","Home",0)
           $Shares.Create("C:\profile","Profile",0)
           $Shares.Create("C:\data\global","Global",0)
           $Shares.Create("C:\data\Schulungen","Schulungen",0)
           $Shares.Create("C:\data\Abteilung","Abteilung",0)
           $Shares.Create("C:\data\Tauschen","Tauschen",0)
           
               
          #Berechtigung definieren und Ordner Erstellen von einzelnen Abteilungsordner
          $abteilungen = $Abt | select -unique
          foreach($Abteilung in $Abteilungen){
          
          $path= "C:\data\Abteilung\"+ $Abteilung
          $sharename = $Abteilung 

          New-Item -Path $path  -ItemType directory
          $ACL = Get-Acl $path
          $Shares.Create($path,$ShareName,0)
          $ACL.SetAccessRuleProtection($true,$false)
          $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
          $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Mitarbeiter","Modify","ContainerInherit,ObjectInherit","None","Allow")))
          $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
          $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
          #Berechtigung Setzen von Abteilungsordner
          Set-Acl $path $ACL
          }

                
              #Berechtigung Definieren und Ordner Erstellen von einzelnen Schulungsordner
              For ($index=0;$index -lt $Abt.Length;$index++){
              $Abteilung = $Abt[$index]
              $path = "C:\data\Schulungen\" + $Abteilung + "\" + $Gruppe[$index]
              $sharename = "Schulungen." + $Gruppe[$index]
              Write-Host $path   
              New-Item –type directory –path $path
              $Shares.Create($path ,$Sharename,0)
              
              $ACL = Get-Acl $path
              $ACL.SetAccessRuleProtection($true,$false)
              $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
              $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Schulungsleiter","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
              $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
              $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
              #Berechtigung Setzen von Schulungsordner
              Set-Acl $path $ACL
              }

             
    #Berechtigung Derfinieren und Ordner Erstellen und Share Anlegen von Raumtauschverzeichnisse
    for($Roomnr=1; $Roomnr -le 6; $Roomnr++){
        $Room = "R"+$Roomnr
        $path= "C:\data\Tauschen\"+ $Room
        $sharename = $Room 

        New-Item –type directory –path $path
        $ACL = Get-Acl $path
        $Shares.Create($path,$ShareName,0)
        $ACL.SetAccessRuleProtection($true,$false)
        $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
        $seachbase = "OU=Teilnehmer"+$Room + ",OU=" + $Room + ",OU=Rooms,OU=Hamburg,OU=LOCATION,DC=smart-in-hamburg,DC=org"
        $Schuler = Get-ADUser -filter * -searchbase $seachbase
            
            #Berechtigung der Teilnehmer auf die einzelnen Tauschordner Definieren
            foreach($Schuler_ in $Schuler){
                $Sname = $Schuler_.SamAccountName
                $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\$Sname","readandexecute","ContainerInherit,ObjectInherit","None","Allow")))
                $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\$Sname","readandexecute","ContainerInherit,ObjectInherit","None","Allow")))
                $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
            }

        #Berechtigung Definieren für die Schulungsleiter auf die Tauschordner
        $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Schulungsleiter","Modify","ContainerInherit,ObjectInherit","None","Allow")))
        $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
        $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
        #Berechtigung Setzen von Tauschordner
        Set-Acl $path $ACL
    }



           #Berechtigung Definieren von data
           $ACL = Get-Acl "C:\data"
           $ACL.SetAccessRuleProtection($true,$false)
           $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Jeder","readandexecute","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Administrator","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-AUTORITÄT\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           #Berechtigung Setzen von data
           Set-Acl "C:\data" $ACL


           #Berechtigung Definieren von home
           $ACL = Get-Acl "C:\home"
           $ACL.SetAccessRuleProtection($true,$false)
           $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Jeder","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Administrator","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-AUTORITÄT\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           #Berechtigung Setzen von home
           Set-Acl "C:\home" $ACL


           #Berechtigung Definieren von NETLOGON
           $ACL = Get-Acl "\\SERVER\NETLOGON"
           $ACL.SetAccessRuleProtection($true,$false)
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Jeder","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Administrator","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-AUTORITÄT\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           #Berechtigung Setzen von NETLOGON
           Set-Acl "\\SERVER\NETLOGON" $ACL

           
           #Berechtigung Definieren von Profile
           $ACL = Get-Acl "C:\profile"
           $ACL.SetAccessRuleProtection($true,$false)
           $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Jeder","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Administrator","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-AUTORITÄT\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           #Berechtigung Setzen von Profile
           Set-Acl "C:\profile" $ACL

           #Berechtigung Definieren von Abteilung
           $ACL = Get-Acl "C:\data\Abteilung"
           $ACL.SetAccessRuleProtection($true,$false)
           $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Mitarbeiter","Modify","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           #Berechtigung Setzen von Abteilung
           Set-Acl "C:\data\Abteilung" $ACL


           #Berechtigung Definieren von Abteilungsverzeichnis
           $ACL = Get-Acl "C:\data\Abteilung"
           $ACL.SetAccessRuleProtection($true,$false)
           $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Mitarbeiter","Modify","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           #Berechtigung setzen Abteilungsverzeichnis
           Set-Acl "C:\data\Abteilung" $ACL

           
           #Berechtigung Definieren von Globalverzeichnis
           $ACL = Get-Acl "C:\data\global"
           $ACL.SetAccessRuleProtection($true,$false)
           $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Benutzer","Readandexecute","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           #Berechtigung Setzen von Globalverzeichnis
           Set-Acl "C:\data\global" $ACL

           #Berechtigung Definieren von Schulungsordner(Oberste Ebene)
           $ACL = Get-Acl "C:\data\Schulungen"
           $ACL.SetAccessRuleProtection($true,$false)
           $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Schulungsleiter","Modify","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
           #Berechtigung Setzen von Schulungsordner(Oberste Ebene)
           Set-Acl "C:\\data\Schulungen" $ACL



#--SQL Daten abrufen
Clear-Host

$ErrorActionPreference="SilentlyContinue"
$WarningPreference='silentlycontinue'
#$ErrorActionPreference="Continue"
#$WarningPreference='continue'
Stop-Transcript
Start-Transcript -path C:\log.txt -append #LogFile   

#-Daten zur Datenbank
$SERVER= "127.0.0.1"
$username= "root"
$password= ""
$database= "addb"
#Definition eines dynamischen Arrays
$global:Vname = @()
$global:Nname = @()
$global:Abt = @() 
$global:Gruppe = @()
$global:leitung = @()	
[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector Net 6.9.4\Assemblies\v2.0\MySql.Data.dll")

#Einlesen der Verbindungsdaten	 
function global:Set-SqlConnection ($SERVER = $(Read-Host "SQL SERVER Name"), $username = $(Read-Host "Username"), $password = $(Read-Host "Password"), $database = $(Read-Host "Default Database") ) {
$SqlConnection.ConnectionString = "SERVER=$SERVER;user id=$username;password=$password;database=$database;pooling=false;Allow Zero Datetime=True;"
	}

#Aufbauen der Verbindung	 
function global:Get-SqlDataTable( $Query = $(if (-not ($Query -gt $null)) {Read-Host "Query to run"}) ) {
if (-not ($SqlConnection.State -like "Open")) { $SqlConnection.Open() }
$SqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand $Query, $SqlConnection
$SqlAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet) | Out-Null
$SqlConnection.Close()
return $DataSet.Tables[0]
}

#Erstellen einer Variable mit Zugangsdaten der Datenbank
Set-Variable SqlConnection (New-Object MySql.Data.MySqlClient.MySqlConnection) -Scope Global -Option AllScope -Description "Personal variable for Sql Query functions"
Set-SqlConnection $SERVER $username $password $database

#Definition des Querys aus SQL
$global:Query = 'SELECT mitarbeiter.vorname, mitarbeiter.name, kurse.kurs, kurse.FK_Abteilung, mitarbeiter.leitung, abteilungen.abteilung FROM abteilungen, mitarbeiter, kurse Where (mitarbeiter.FK_Fach = kurse.nr AND mitarbeiter.FK_abteilung=abteilungen.nr)order by mitarbeiter.nr'
$mysqlresults = Get-SqlDataTable $Query

#Einlesen der Datensätze ins Array
ForEach ($result in $mysqlresults){
  $Vname += $result.vorname
  $Nname += $result.name
  $Abt += $result.abteilung
  $Gruppe += $result.kurs
    
    if ($result.Leitung -eq "1"){
        $Leitung += $result.vorname + "." + $result.name
    }
}
Stop-Transcript

<#Ausgabe Array, um Verbindung zu Prüfen
for($i=20 ; $i -gt 0; $i--){
write-host $VName
write-host $NName
write-host $Abt
write-host $Gruppe
} 
#>







#----Teilnehmer in NamensArray einfügen----
for ($R=1;$R -le 6 ;$R++){
        for ($U=1;$U -le 12 ;$U++){
        $Vname += "R"+$R
        $Nname += "P"+$U
    
        }
    }


#-----------User-Attribute für die Erstellung der User
For ($inc=0;$inc -le $Vname.Length;$inc++){

$Vorname = $Vname[$inc]
$Nachname = $Nname[$inc]
$NamefULL = $Vname[$inc] + " " + $Nname[$inc]
$AnmeldeName = $Vname[$inc] + "." + $Nname[$inc]
$UPN =  $Vname[$inc] + "." + $Nname[$inc] + "@smart-in-hamburg.org"
$Passwort = ConvertTo-SecureString 'ChangeMe1' -AsPlainText -Force
$Profilpfad = "\\SERVER\profile\" + $AnmeldeName
$Homepfad = "\\SERVER\home\" + $AnmeldeName
$Profilpfad_lokal = "C:\profile\" + $Anmeldename
$Homepfad_lokal = "C:\home\" + $Anmeldename




#Unterscheidung nach Teilnehmer
if ($Vname[$inc] -match "R[1-6]" ){
    
    #Teilnehmer User anlegen
    $email=""
    $U_OUPfad ="OU=Teilnehmer"+$Vname[$inc]+",OU="+$Vname[$inc]+",OU=Rooms,OU=Hamburg,OU=LOCATION,DC=smart-in-hamburg,DC=org"
    
    New-ADUser -Path $U_OUPfad  -UserPrincipalName $UPN -SamAccountName $AnmeldeName -HomeDrive "H:" -HomeDirectory $Homepfad -Name $NamefULL -GivenName $Vorname -Surname $Nachname -ProfilePath $Profilpfad  -EmailAddress $email -AccountPassword $Passwort -ChangePasswordAtLogon $true  -Department $Abt[$inc] -Office $Gruppe[$inc] -Enabled $true 
    Add-ADGroupMember -Identity Teilnehmer -Members $AnmeldeName
            
            #home-ordner anlegen & Rechte
            New-Item –type directory –path $Homepfad_lokal
            $ACL = Get-Acl $Homepfad_lokal
            $ACL.SetAccessRuleProtection($true,$false)
            $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
                $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\$AnmeldeName","Modify","ContainerInherit,ObjectInherit","None","Allow")))
                $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Schulungsleiter","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
                $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-ADMINS","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
                $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow"))) 
            
}

else{

    #Mitarbeiter User anlegen
    $email = $Vname[$inc] + "." + $Nname[$inc] + "@smart-in-hamburg.org"
    $U_OUPfad ="OU=Mitarbeiter,OU=User,OU=Hamburg,OU=LOCATION,DC=smart-in-hamburg,DC=org"
    New-ADUser -Path $U_OUPfad  -UserPrincipalName $UPN -SamAccountName $AnmeldeName -HomeDrive "H:" -HomeDirectory $Homepfad -Name $NamefULL -GivenName $Vorname -Surname $Nachname -ProfilePath $Profilpfad  -EmailAddress $email -AccountPassword $Passwort -ChangePasswordAtLogon $true  -Department $Abt[$inc] -Office $Gruppe[$inc] -Enabled $true 

        if ($Abt[$inc] -ne "Geschaeftsfuehrung"){
        Add-ADGroupMember -Identity Mitarbeiter -Members $AnmeldeName
        }
            else{
            Add-ADGroupMember -Identity Geschaeftsfuehrung -Members $AnmeldeName
           }
                
            #home-ordner anlegen & Rechte
            New-Item –type directory –path $Homepfad_lokal
                $ACL = Get-Acl $Homepfad_lokal
                $ACL.SetAccessRuleProtection($true,$false)
                $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
                $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\$AnmeldeName","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
                $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
                $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-ADMINS","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
        }
        
        #Berechtigung Definieren von Homeordner der User
        $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
        $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\$AnmeldeName","readandexecute","ContainerInherit,ObjectInherit","None","Allow")))
        $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
        #Berechtigung Setzen von Homeordner der User
        Set-Acl $Homepfad_lokal $ACL

        <#geschieht automatisch
        #Berechtigung Definieren und Ordner Anlegen von Profilordner der User
        New-Item –type directory –path $Profilpfad_lokal
        $ACL = Get-Acl $Profilpfad_lokal
        $ACL.SetAccessRuleProtection($true,$false)
        $ACL.Access | ForEach {[Void]$ACL.RemoveAccessRule($_)}
        $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\$AnmeldeName","FullControl","ContainerInherit,ObjectInherit","None","Allow" )))
        $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\Domänen-Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
        $ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDOMAIN\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")))
        #Berechtigung Setzen von Profilordner
        Set-Acl $Profilpfad_lokal $ACL
        #>

    #Ausgabe für Prüfung
    Write-Host  "Abteilung: " $Abt[$inc] "Name : " $AnmeldeName   "OU : " $U_OUPfad
}


 #--Schulungsleiter zur Gruppe hinzufügen
 Add-ADGroupMember -Identity Schulungsleiter -Members $Leitung
