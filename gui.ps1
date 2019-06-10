while (1) {
	Start-Sleep -Seconds 1
	$turn = Get-Content -Path .\turn.txt
	
	#	CHECK FOR SPECIAL VALUES
	if ($turn -eq "continue") {
		continue
	} elseif ($turn -eq "stop") {
		Clear-Content -Path .\turn.txt
		echo "stop found"
		Start-Sleep -Seconds 1
		exit
	}
	
	#	SHIP PRINTING
	Clear-Host
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

	if ([int]$health[12] -lt 0) {
		$bc = "darkRed"
	}
	if ([int]$health[13] -lt 0) {
		$mc = "darkRed"
	}
	if ([int]$health[14] -lt 0) {
		$sc = "darkRed"
	}

	Get-Content .\images\defaultShip.txt | ForEach-Object {
		$b = $_.Substring(0,30)
		$m = $_.Substring(30,20)
		$s = $_.Substring(50)
		
		
		Write-Host -NoNewline -F $bc $b
		Write-Host -NoNewline -F $mc $m
		Write-Host -F $sc $s
	}
	
	#I'm sorry master Gates
	try {
		Clear-Content -Path .\turn.txt
		Add-Content -Path .\turn.txt -Value "continue"
	} catch {
		Start-Sleep -Milliseconds 10
		Clear-Content -Path .\turn.txt
		Add-Content -Path .\turn.txt -Value "continue"
	}
}
