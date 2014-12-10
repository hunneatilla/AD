$zahlEins=0;

while(($eingabe = Read-Host -Prompt "Wählen Sie bitte eine Raumnummer -  z.B 4: Bei exit Q") -ne "Q"){
	switch($eingabe){
		1 {$zahlEins=1}
		2 {$zahlEins=2}
		3 {$zahlEins=3}
		4 {$zahlEins=4}
		5 {$zahlEins=5}
        	6 {$zahlEins=6}
		Q {"Ende"}
		default {"Ungültige Eingabe"}
   }
	for ($zahlZwei=1;$zahlZwei -le 12;$zahlZwei++){
	Set-ADAccountPassword -Identity "s$zahlEins.p$zahlZwei" -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Changeme1!" -Force) -ChangePasswordAtLogon $true
	remove-item C:\smart\home\s$zahlEins.p$zahlZwei\*
	}
	write-host "Alle Benutzer $zahlEins von Raum wurden zurückgesezt!"
}
