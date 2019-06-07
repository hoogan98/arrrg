#	SHIP PRINTING
Get-Content .\images\defaultShip.txt | ForEach-Object {
    $b = $_.Substring(0,30)
	$m = $_.Substring(30,20)
	$s = $_.Substring(50)
	Write-Host -NoNewline -F "red" $b
	Write-Host -NoNewline $m
	Write-Host -F "blue" $s
}
$turn = Get-Content -Path .\turn.txt
echo $turn

#	CHECK FOR CLOSE
while (1) {
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
