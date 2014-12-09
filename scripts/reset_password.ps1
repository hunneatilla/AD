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
}

for ($zahlZwei=1;$zahlZwei -ge 12;$zahlZwei++){
Set-ADAccountPassword -Identity FLee -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Changme1!" -Force)
#Set-ADAccountPassword -Identity "s" + $zahlEins + ".p"+ $zahlZwei -OldPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -NewPassword (ConvertTo-SecureString -AsPlainText "qwert@12345" -Force)
}
