#	SHIP PRINTING
$turn = Get-Content -Path .\turn.txt
echo $turn
$health = $turn.Split(",")
$bc = "white"
$mc = "white"
$sc = "white"
if ([int]$health[3] -lt 41) {
	$bc = "red"
} elseif ([int]$health[3] -lt 71) {
	$bc = "Yellow"
} 
if ([int]$health[7] -lt 41) {
	$mc = "red"
} elseif ([int]$health[7] -lt 71) {
	$mc = "yellow"
}
if ([int]$health[11] -lt 41) {
	$sc = "red"
} elseif ([int]$health[11] -lt 71) {
	$sc = "Yellow"
}

Get-Content .\images\defaultShip.txt | ForEach-Object {
    $b = $_.Substring(0,30)
	$m = $_.Substring(30,20)
	$s = $_.Substring(50)
	
	
	Write-Host -NoNewline -F $bc $b
	Write-Host -NoNewline -F $mc $m
	Write-Host -F $sc $s
}

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
