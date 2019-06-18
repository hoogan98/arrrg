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
	$i = 0;
	for ($i; $i -lt 100; $i++) {
		if ($turn[$i] -eq " ") {
			$i++
			break
		}
	}
	$str = $turn.Substring($i)
	$turn = $turn.Substring(0,$i)
	echo "		The R.M.S $str"
	$health = $turn.Split(",")
	$bc = "white"
	$mc = "white"
	$sc = "white"
	if ([int]$health[3] -lt 41) {
		$bc = "red"
	} elseif ([int]$health[3] -lt 70) {
		$bc = "Yellow"
	} 
	if ([int]$health[7] -lt 41) {
		$mc = "red"
	} elseif ([int]$health[7] -lt 70) {
		$mc = "yellow"
	}
	if ([int]$health[11] -lt 41) {
		$sc = "red"
	} elseif ([int]$health[11] -lt 70) {
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
	
	$code = [int]$health[15]
	$file = "init"
	switch ($code) {
		{$code -eq 0}	{$file = ".\images\defaultShip.txt"; break}
		{$code -eq 1}	{$file = ".\images\rammingShip.txt"; break}
		{$code -eq 2}	{$file = ".\images\undeadShip.txt"; break}
		{$code -eq 3}	{$file = ".\images\vikingShip.txt"; break}
		{$code -eq 4}	{$file = ".\images\cursedShip.txt"; break}
		{$code -eq 5}	{$file = ".\images\turtleShip.txt"; break}
	}
	Get-Content -Path "$($file)" | ForEach-Object {
		$b = $_.Substring(0,30)
		$m = $_.Substring(30,30)
		$s = $_.Substring(60)
		
		
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
