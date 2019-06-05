
# 3 zones: bough, mid, stern
# 3 health nums: crew, cannons, hull
# 3 actions per turn, choose from: move crew(zone to zone, same ship), board (ship to ship, same zone), fire cannon[chain(/\crew,-cannon,\/hull),round(\/crew,-cannon,/\hull),grape(-crew,/\cannon,\/hull),start fire, 
#	put out fire, repair hull, repair cannon(all zone based, effectiveness is based on crew in area), wait
# add ins:
#approach/flee system where you have to get close before boarding
#damage scaling with distance
#ui with ship images in seperate terminal
#"animate" ui by keeping size of window constant and printing something new
#more ships with special stats
# fast ship? can flee once per turn for free
# undead crew: crew heals, but can't board
# boarder: ship has inwards facing cannons (always on defense no matter what), can move crew for free and has hella crew
# firebreather: shoots fire, but has a chance to set fire to self and has only 1 type of shot aside from it
#defensive musket attack that does damage if the enemy decides to board on the next turn

#mvp add
# on board: offense loses 10% of defense, defense loses 15% of offense
# on ship-side battle: vice versa of above

#set up names / meta stuff
$End = 0;
$Name1 = Read-Host -Prompt "Input name for p1"
$Name2 = Read-Host -Prompt "Input name for p2"
$Turn = 0;
$AcNum = 1;

#the name dreadPirateTed wins automatically
if ($Name1 -eq "dreadPirateTed" -or $Name2 -eq "dreadPirateTed") {
    echo "dreadPirateTed wins"
	exit
}

#set up health
#values are z1[friendCrew,foeCrew,cannon,hull]z2[...]z3[...]
#both 12 long
$p1Health = 30,0,15,100,30,0,15,100,30,0,15,100
$p2Health = 30,0,15,100,30,0,15,100,30,0,15,100

#print out the damage report
function DamageReport($player){
	$health = $p2Health
	if ($player -eq 0) {
		$health = $p1Health
	}

	echo "	 Damage Report:"
	Start-Sleep -Seconds 1
	echo "		Bough"
	Start-Sleep -Seconds 1
	echo "Crew     Boarders   Cannons     Hull"
	$str = $health[0..3] -join "         "
	echo $str
	Start-Sleep -Seconds 1
	echo "		Mid"
	Start-Sleep -Seconds 1
	echo "Crew     Boarders   Cannons     Hull"
	$str = $health[4..7] -join "         "
	echo $str
	Start-Sleep -Seconds 1
	echo "		Stern"
	Start-Sleep -Seconds 1
	echo "Crew     Boarders   Cannons     Hull"
	$str = $health[8..11] -join "         "
	echo $str
	
}

#calculate number of cannons to fire given health value and zone
function fireCount($health, $zone) {
	$z = $zone * 4;
	$avc = $health[0+$z] - $health[1+$z]
	$can = $health[2+$z]
	if ($avc -lt 0) {
		return 0
	} elseif($avc -le $can) {
		return $avc
	}
	return $can
}

#reads parts of ship into zone numbers
function readZone($s) {
	if($s -eq "bough") {
		return 0
	}
	if($s -eq "mid") {
		return 1
	}
	if($s -eq "stern") {
		return 2
	}
	return -1
}

#handles adding float damage values to int number values
function addDmg($health, $dmg, $zone) {
	$z = $zone * 4
	for ($i = 0; $i -lt 3; $i++) {
		if ($dmg[$i] -is [float]) {
			$dec = $dmg[$i] % 1
			$seed = Get-Random -Minimum -0.5 -Maximum $dec
			if ($seed -ge 0) {
				$dmg[$i] += 1
			}
		}
	}
	
	$health[0+$z] -= [math]::Floor($dmg[0])
	$health[1+$z] -= [math]::Ceiling($dmg[0] / 1.5)
	$health[2+$z] -= [math]::Floor($dmg[1])
	$health[3+$z] -= [math]::Floor($dmg[2])
}

#checks for victory
#win codes are: 1/2 for no crew, 3/4 for hull breach
function checkWin($p1, $p2) {
	$1crew = 0
	$2crew = 0
	for ($i = 0; $i -lt 3; $i++){
		$z = 4*$i
		$1crew += $p1[0+$z] + $p2[1+$z]
		$2crew += $p2[0+$z] + $p1[1+$z]
		if ($p1[3+$z] -le 0) {
			return 4
		}
		if ($p2[3+$z] -le 0) {
			return 3
		}
	}
	
	if ($1crew -le 0) {
		return 2
	}
	if ($2crew -le 0) {
		return 1
	}
	return 0
}

#checks for skirmishing between boarded crew
function skirmish($p1, $p2) {
	for ($i = 0; $i -lt 3; $i++) {
		$z = $i*4
		if ($p1[1+$z] -gt 0) {
			$defenders = $p1[0+$z]
			$p1[0+$z] -= [math]::Ceiling($p1[1+$z] * 0.1)
			$p1[1+$z] -= [math]::Ceiling($defenders * 0.15)
		}
		if ($p2[1+$z] -gt 0) {
			$defenders = $p2[0+$z]
			$p2[0+$z] -= [math]::Ceiling($p2[1+$z] * 0.1)
			$p2[1+$z] -= [math]::Ceiling($defenders * 0.15)
		}
	}
}

#calculate damage from grapeshot given a specific zone
#dmg is returned in an array[crew,cannon,hull]
function dmgGrape($o, $z) {
	$offense = $p1Health
	$dmg = 0,0,0
	
	if ($o -eq 1) {
		$offense = $p2Health
	}
	
	$count = fireCount $offense $z
	#dmg to crew
	$dmg[0] = $count / 4
	#dmg to cannons
	$dmg[1] = $count / 4
	#dmg to hull
	$dmg[2] = $count / 10
	
	return $dmg
}

function dmgRound($o, $z) {
	$offense = $p1Health
	$dmg = 0,0,0
	
	if ($o -eq 1) {
		$offense = $p2Health
	}
	
	$count = fireCount $offense $z
	#dmg to crew
	$dmg[0] = $count / 10
	#dmg to cannons
	$dmg[1] = $count / 8
	#dmg to hull
	$dmg[2] = $count
	
	return $dmg
}

function dmgChain($o, $z) {
	$offense = $p1Health
	$dmg = 0,0,0
	
	if ($o -eq 1) {
		$offense = $p2Health
	}
	
	$count = fireCount $offense $z
	#dmg to crew
	$dmg[0] = $count / 2
	#dmg to cannons
	$dmg[1] = $count / 10
	#dmg to hull
	$dmg[2] = $count / 10
	
	return $dmg
}

function dmgBoard($o, $zone, $p1, $p2) {
	$offense = $p1
	$defense = $p2
	$z = $zone * 4
	
	if ($o -eq 1) {
		$offense = $p2
		$defense = $p1
	}
	
	$boarders = $offense[0+$z]
	$dmB = $defense[0+$z] * 0.1
	$dmD = $boarders * 0.15
	$decB = $dmB % 1
	$decD = $dmD % 1
	$seed = Get-Random -Minimum -0.5 -Maximum $decB
	if ($seed -ge 0) {
		$dmB += 1
	}
	$seed = Get-Random -Minimum -0.5 -Maximum $decD
	if ($seed -ge 0) {
		$dmD += 1
	}
	
	
	$offense[0+$z] = 0
	$defense[1+$z] = $boarders - [math]::Ceiling($dmB)
	$defense[0+$z] -= [math]::Ceiling($dmD)
	
}


while ($End -eq 0){
	$Action = "wait","wait"
	$Offense = 0
	$Defense = 0
	
	if ($Turn -eq 0) {
		echo "'$Name1' turn"
		Start-Sleep -Seconds 1
		DamageReport 0

		$Turn = 1
		$Offense = 0
		$Defense = 1
	} elseif ($Turn -eq 1) {
		echo "'$Name2' turn"
		Start-Sleep -Seconds 1
		DamageReport 1
		
		$Turn = 0
		$Offense = 1
		$Defense = 0
	}
	
	for($j = 0; $j -lt $AcNum; $j++) {
		$ac = $j + 1
		$Action[$j] = Read-Host -Prompt "choose action $ac"
	}
	$fired = -1
	
	for($i = 0; $i -lt $AcNum; $i++) {
		$zone = 0;
		$dmg = 0,0,0;
		$str = "";
		switch ($Action[$i]) {
			{$_ -eq "grape"} {$str = Read-Host -Prompt "Choose zone to fire grapeshot from";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								echo "A zone can only attack once per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $dmg = dmgGrape $Offense $zone; break}
			{$_ -eq "round"} {$str = Read-Host -Prompt "Choose zone to fire roundshot from";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								echo "A zone can only attack once per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $dmg = dmgRound $Offense $zone; break}
			{$_ -eq "chain"} {$str = Read-Host -Prompt "Choose zone to fire chainshot from";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								echo "A zone can only attack once per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $dmg = dmgChain $Offense $zone; break}
			{$_ -eq "board"} {$str = Read-Host -Prompt "Choose zone to board";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								echo "A zone can only attack once per turn"
								$i--; break
							  }
							  $fired = $zone;
							  dmgBoard $Offense $zone $p1Health $p2Health; break}
			{$_ -eq "help"}	 {echo "choose from: 'grape', 'chain', 'round', 'wait', 'board', 'move crew', or 'help'";
							  $Action[$i] = Read-Host -Prompt "choose a new action";
							  $i--; break}
			{$_ -eq "wait"}	 {break}
			default			 {$Action[$i] = Read-Host -Prompt "Action $i not recognized. Try again or type 'help' for command list";
							  $i--; break}
		}
		
		if ($Defense -eq 0) {
			addDmg $p1Health $dmg $zone
		} else {
			addDmg $p2Health $dmg $zone
		}
	}
	
	skirmish $p1Health $p2Health
	for ($i = 0; $i -lt 12; $i++) {
		if ($p1Health[$i] -lt 0) {
			$p1Health[$i] = 0;
		}
		if ($p2Health[$i] -lt 0) {
			$p2Health[$i] = 0;
		}
	}
	$End = checkWin $p1Health $p2Health
	$AcNum = 2;
}

if ($End -eq 1) {
	echo "$Name2 ran out of living crew, $Name1 wins!"
} elseif ($End -eq 2) {
	echo "$Name1 ran out of living crew, $Name2 wins!"
} elseif ($End -eq 3) {
	echo "$Name2's ship has sunk, $Name1 wins!"
} elseif ($End -eq 4) {
	echo "$Name1's ship has sunk, $Name2 wins!"
}

