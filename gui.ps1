	
while (1) {
	echo "loop"
	Start-Sleep -Seconds 1
	$turn = Get-Content -Path .\turn.txt
	echo $turn
	if ($turn -eq "stop") {
		Clear-Content -Path .\turn.txt
		Add-Content -Path .\turn.txt -Value "start"
		echo "stop found"
		Start-Sleep -Seconds 1
		exit
	}
}
