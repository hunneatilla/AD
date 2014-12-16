## Ordner anlegen

function new-folder ()
{
write-host ""
write-host "Ordner werden angelegt:"
New-Item -Path "C:\" -Name "smart" -ItemType directory
New-Item -Path "C:\smart\" -Name "software$" -ItemType directory
New-Item -Path "C:\smart\" -Name "profile$" -ItemType directory
New-Item -Path "C:\smart\" -Name "global" -ItemType directory
New-Item -Path "C:\smart\" -Name "abteilung" -ItemType directory
New-Item -Path "C:\smart\" -Name "schulung" -ItemType directory
New-Item -Path "C:\smart\" -Name "home" -ItemType directory
New-Item -Path "C:\smart\abteilung\" -Name "geschäftsführung" -ItemType directory
New-Item -Path "C:\smart\abteilung\" -Name "verwaltung" -ItemType directory
New-Item -Path "C:\smart\abteilung\" -Name "schulung_allgemein" -ItemType directory
New-Item -Path "C:\smart\abteilung\" -Name "schulung_technik" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum1" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum2" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum3" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum4" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum5" -ItemType directory
New-Item -Path "C:\smart\schulung\" -Name "raum6" -ItemType directory

write-host "Ordner wurden angelegt!"
}
