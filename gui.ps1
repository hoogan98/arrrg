#	SHIP PRINTING
Get-Content .\defaultShip.txt | ForEach-Object {
    echo $_
}
$turn = Get-Content -Path .\turn.txt
echo $turn

#	CHECK FOR CLOSE
while (1) {
	echo "loop"
	Start-Sleep -Seconds 1
	$turn = Get-Content -Path .\turn.txt
	if ($turn -eq "stop") {
		Clear-Content -Path .\turn.txt
		Add-Content -Path .\turn.txt -Value "start"
		echo "stop found"
		Start-Sleep -Seconds 1
		exit
	}
}
