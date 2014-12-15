## AbteilungsShares anlegen

function share ()
{
write-host ""
write-host "Ordner werden freigegeben:"
New-SmbShare -Name "global" -Path C:\global -Description GlobalShare
New-SmbShare -Name "geschäftsführung" -Path C:\smart\abteilung\geschäftsführung -Description GeschäftsführungShare
New-SmbShare -Name "verwaltung" -Path C:\smart\abteilung\verwaltung -Description VerwaltungShare
New-SmbShare -Name "schulung_allgemein" -Path C:\smart\abteilung\schulung_allgemein -Description SchulungAllgemeinShare
New-SmbShare -Name "schulung_technik" -Path C:\smart\abteilung\schulung_technik -Description SchulungTechnikShare
New-SmbShare -Name "raum1" -Path C:\smart\schulung\raum1 -Description Raum1Share
New-SmbShare -Name "raum2" -Path C:\smart\schulung\raum2 -Description Raum2Share
New-SmbShare -Name "raum3" -Path C:\smart\schulung\raum3 -Description Raum3Share
New-SmbShare -Name "raum4" -Path C:\smart\schulung\raum4 -Description Raum4Share
New-SmbShare -Name "raum5" -Path C:\smart\schulung\raum5 -Description Raum5Share
New-SmbShare -Name "raum6" -Path C:\smart\schulung\raum6 -Description Raum6Share
write-host "Ordner wurden freigegeben!"
}
