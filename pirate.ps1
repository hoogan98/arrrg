# 3 zones: bough, mid, stern
# 3 health nums: crew, cannons, hull
# 2 actions per turn, choose from: move crew(zone to zone, same ship), board (ship to ship, same zone), fire cannon[chain(/\crew,-cannon,\/hull),round(\/crew,-cannon,/\hull),grape(-crew,/\cannon,\/hull), 
# thanks to christopher johnson for the ship image: https://asciiart.website/index.php?art=transportation/nautical	

# add ins:
#more ships with special stats
# fast ship? can flee once per turn for free
# undead crew: crew heals, but can't board
# boarder: ship has inwards facing cannons (always on defense no matter what), can move crew for free and has hella crew
# firebreather: shoots fire, but has a chance to set fire to self and has only 1 type of shot aside from it
# engineer: crew gets damage/accuracy bonus from cannons, repairs faster, fights horribly
# ironsides: 200 hull, can't repair hull, high crew, can't move
# viking ship, fast with no cannons but real good boarders probably not, no balance
# ramming ship - can ram, but weak hull in mid and stern, also no front cannons but 20 in the mid and back
# french ship that surrenders immediately
# maginot ship: 45 guns in mid
#print out a description of the commands when you call help
#store name, state, max cannons per zone, and health as a field in the ship type
#brace to decrease damage

#current job(s)
#get a system for choosing a specialty ship running

. .\ships.ps1

#set up names / meta stuff
$End = 0;
$Name1 = Read-Host -Prompt "Input name for p1's ship"
$Name2 = Read-Host -Prompt "Input name for p2's ship"
$Turn = 0;
$AcNum = 1;
$Distance = 1
$p1Ship = readShip($Name1)
$p2Ship = readShip($Name2)
Add-Content -Path .\turn.txt -Value "init"



#the name dreadPirateTed wins automatically
if ($Name1 -eq "dreadPirateTed" -or $Name2 -eq "dreadPirateTed") {
	echo
    echo "dreadPirateTed wins"
	echo
	exit
} elseif ($Name1 -eq $Name2) {
	echo
	echo "that's gonna be confusing, but alright then"
	echo
}

#	SYSTEM FUNCTIONS
#print out the damage report
function DamageReport($Dis, $os, $ds){
	for ($i = 0; $i -lt 12; $i++) {
		if ($os.Health[$i] -lt 0) {
			$os.Health[$i] = 0;
		}
		if ($ds.Health[$i] -lt 0) {
			$ds.Health[$i] = 0;
		}
	}
	
	#Alan Turing is probably rolling in his grave because of the next few lines
	try {
		Clear-Content -Path .\turn.txt
		$str = ($os.Health -join ",") + "," + ($os.State -join ",") + " " + $os.Name
		Add-Content -Path .\turn.txt -Value $str
	} catch {
		Clear-Content -Path .\turn.txt
		$str = ($os.Health -join ",") + "," + ($os.State -join ",") + " " + $os.Name
		Add-Content -Path .\turn.txt -Value $str
	}
	
	echo "Damage Report:"
    echo ("{0,-37} |$Dis| {1,37}" -f $os.Name, $ds.Name)
	Start-Sleep -Seconds 1
	echo "                                     Bough"
	Start-Sleep -Seconds 1
	echo "Crew     Boarders   Cannons     Hull  |$Dis|  Crew     Boarders   Cannons     Hull"
	$str = ($os.Health[0..3] -join "         ") + "   |$Dis|  " +  ($ds.Health[0..3] -join "         ")
	echo $str
	Start-Sleep -Seconds 1
	echo "                                     Mid"
	Start-Sleep -Seconds 1
	echo "Crew     Boarders   Cannons     Hull  |$Dis|  Crew     Boarders   Cannons     Hull"
	$str = ($os.Health[4..7] -join "         ") + "   |$Dis|  " + ($ds.Health[4..7] -join "         ")
	echo $str
	Start-Sleep -Seconds 1
	echo "                                     Stern"
	Start-Sleep -Seconds 1
	echo "Crew     Boarders   Cannons     Hull  |$Dis|  Crew     Boarders   Cannons     Hull"
	$str = ($os.Health[8..11] -join "         ") + "   |$Dis|  " + ($ds.Health[8..11] -join "         ")
	echo $str
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
function addDmg($health, $dmg, $zonel, $os) {
	$z = $zone * 4
	
	if ($dmg[0] -ne 0) {
		$health[0+$z] -= [math]::Ceiling( (Get-Random -Minimum ($dmg[0] * $os.MissRate) -Maximum ($dmg[0] * (1 + $os.HitRate))) )
		$health[1+$z] -= [math]::Floor( (Get-Random -Minimum ($dmg[0] * $os.MissRate) -Maximum ($dmg[0] * (1 + $os.HitRate))) )
	}
	if ($dmg[1] -ne 0) {
		$health[2+$z] -= [math]::Floor( (Get-Random -Minimum ($dmg[1] * $os.MissRate) -Maximum ($dmg[1] * (1 + $os.HitRate))) )
	}
	if ($dmg[2] -ne 0) {
		$health[3+$z] -= [math]::Ceiling( (Get-Random -Minimum ($dmg[2] * $os.MissRate) -Maximum ($dmg[2] * (1 + $os.HitRate))) )
	}
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
function skirmish($Os, $Ds) {
	for ($i = 0; $i -lt 3; $i++) {
		$z = $i*4
		if ($Os.Health[1+$z] -gt 0) {
			$defenders = $Os.Health[0+$z]
			if ($defenders -eq 0) {
				$Os.Health[2+$z] -= [math]::Ceiling($Os.Health[1+$z] * ($Ds.StrucDmg / 2))
				$Os.Health[3+$z] -= [math]::Ceiling($Os.Health[1+$z] * $Ds.StrucDmg)
			}
			$Os.Health[0+$z] -= [math]::Ceiling($Os.Health[1+$z] * $Ds.CrewDmg)
			$Os.Health[1+$z] -= [math]::Ceiling($defenders * ($Os.CrewDmg * 1.5))
		}
		if ($Ds.Health[1+$z] -gt 0) {
			$defenders = $Ds.Health[0+$z]
			if ($defenders -eq 0) {
				$Ds.Health[2+$z] -= [math]::Ceiling($Ds.Health[1+$z] * ($Os.StrucDmg / 2))
				$Ds.Health[3+$z] -= [math]::Ceiling($Ds.Health[1+$z] * $Os.StrucDmg)
			}
			$Ds.Health[0+$z] -= [math]::Ceiling($Ds.Health[1+$z] * $Os.CrewDmg)
			$Ds.Health[1+$z] -= [math]::Ceiling($defenders * ($Ds.CrewDmg * 1.5))
		}
	}
}

#activates fire in a zone
function startFire($state, $zone){
	$state[$zone] = -1;
}

#checks for states of various zones (0 = normal, -1 = on fire, 0+ = defended
function checkState($os, $ds) {
	for($i = 0; $i -lt 3; $i++) {
		$z = 4*$i
		$dmg = 0,0,0
		if ($os.State[$i] -eq -1) {
			$dmg = $os.dmgFire
			addDmg $o $dmg $i
		}
		if ($ds.State[$i] -eq -1) {
			$dmg = $ds.dmgFire
			addDmg $d $dmg $i
		}
		if ($os.State[$i] -gt 0) {
			$os.State[$i]--
		}
		if ($ds.State[$i] -gt 0) {
			$ds.State[$i]--
		}
	}
}

#	MOVEMENT FUNCTIONS
#moving cannons
function reArm($os, $zone1, $zone2, $amnt) {
	if (($os.Health[2+($zone2*4)] + $amnt) -gt 15) {
		return -1
	}
	
	$os.Health[2+($zone1*4)] -= $amnt
	$os.Health[0+($zone1*4)] -= $amnt
	$os.Health[2+($zone2*4)] += $amnt
	$os.Health[0+($zone2*4)] += $amnt
	return 0
}

#moving crew
function crewMove($Offense, $Defense, $mov, $amnt, $zone1, $zone2) {
	if ($mov -eq 0){
		$Offense[0+($zone1*4)] -= $amnt
		$Offense[0+($zone2*4)] += $amnt
	}
	if ($mov -eq 1){
		$Defense[1+($zone1*4)] -= $amnt
		$Defense[1+($zone2*4)] += $amnt
	}
}

#	MASTER CONTROL
while ($End -eq 0){
	$Action = "wait","wait"
	$Oship = $p1Ship
	$Dship = $p2Ship
	$dis = $Distance
	
	if ($Turn -eq 0) {
		$Turn = 1
		$Oship = $p1Ship
		$Dship = $p2Ship
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		echo ("{0,37}'s turn" -f $Oship.Name)
		Start-Sleep -Seconds 1
	} elseif ($Turn -eq 1) {
		$Turn = 0
		$Oship = $p2Ship
		$Dship = $p1Ship
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		echo ("{0,37}'s turn" -f $Oship.Name)
		Start-Sleep -Seconds 1
	}

	DamageReport $dis $Oship $Dship

	if ($AcNum -eq 1) {
		invoke-expression 'cmd /c start powershell -Command { .\gui.ps1}'
		$str = Read-Host -Prompt "choose starting distance between ships"
		$dis = [int]$str
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
								echo "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $dmg = $Oship.dmgGrape($zone, $dis); break}
			{$_ -eq "round"} {$str = Read-Host -Prompt "Choose zone to fire roundshot from";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								echo "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $dmg = $Oship.dmgRound($zone, $dis); break}
			{$_ -eq "chain"} {$str = Read-Host -Prompt "Choose zone to fire chainshot from";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								echo "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $dmg = $Oship.dmgChain($zone, $dis); break}
			{$_ -eq "move"}	 {$str = Read-Host -Prompt "enter '0' to move crew on your ship and '1' to move boarded crew"
							  $mov = [int]$str
							  $str = Read-Host -Prompt "Choose zone to move from";
							  $zone1 = readZone($str);
							  $str = Read-Host -Prompt "Choose zone to move to";
							  $zone2 = readZone($str);
							  $str = Read-Host -Prompt "Choose number of crew to move"
							  $amnt = [int]$str
							  if ($mov -ne 0 -and $mov -ne 1) {
								echo "choose either '0' or '1' to determine which ship to move crew on, I'm tired of making string reading functions"
								$i--; break
							  }
							  if ($zone1 -lt 0 -or $zone2 -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if ($mov -eq 0) {
								if (($amnt -lt 0) -or ($amnt -gt $Oship.Health[0+($zone1*4)])) {
									echo "Choose a real number of crew members to move";
									$i--; break
								}
							  }
							  if ($mov -eq 1) {
								if (($amnt -lt 0) -or ($amnt -gt $Dship.Health[1+($zone1*4)])) {
									echo "Choose a real number of crew members to move";
									$i--; break
								}
							  }
							  crewMove $Oship.Health $Dship.Health $mov $amnt $zone1 $zone2
							  DamageReport $dis $Oship $Dship; break}
			{$_ -eq "board"} {$str = Read-Host -Prompt "Choose zone to board";
							  $zone = readZone($str);
							  $str = Read-Host -Prompt "Choose number of crew to board"
							  $amnt = [int]$str
							  if ($zone -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if (($amnt -lt 0) -or ($amnt -gt $Oship.Health[0+($zone*4)])) {
								echo "Choose a real number of crew members to board";
								$i--; break
							  }
							  if ($dis -ne 0) {
								echo "not close enough to enemy ship to initiate boarding"
								$Action[$i] = Read-Host -Prompt "choose a new action";
								$i--; break
							  }
							  $Oship.board($Dship, $amnt, $zone)
							  DamageReport $dis $Oship $Dship; break}
		{$_ -eq "retreat"} 	 {$str = Read-Host -Prompt "Choose zone to pull boarders from";
							  $zone = readZone($str);
							  $str = Read-Host -Prompt "Choose number of crew to retreat"
							  $amnt = [int]$str
							  if ($zone -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($dis -ne 0) {
								echo "not close enough to enemy ship to pull back boarders"
								$Action[$i] = Read-Host -Prompt "choose a new action";
								$i--; break
							  }
							  if (($amnt -lt 0) -or ($amnt -gt $Dship.Health[1+($zone*4)])) {
								echo "Choose a real number of crew members to retreat";
								$i--; break
							  }
							  $Oship.retreat($Dship, $zone, $amnt)
							  DamageReport $dis $Oship $Dship; break}
			{$_ -eq "repair"}{$str = Read-Host -Prompt "Choose zone to repair";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								echo "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $Oship.rebuild($zone); break}
			{$_ -eq "rearm"} {$str = Read-Host -Prompt "Choose zone to move from";
							  $zone1 = readZone($str);
							  $str = Read-Host -Prompt "Choose zone to move to";
							  $zone2 = readZone($str);
							  $str = Read-Host -Prompt "Choose number of cannons to move"
							  $amnt = [int]$str
							  if ($zone1 -lt 0 -or $zone2 -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if ($amnt -gt $Oship.Health[2+($zone1*4)] -or $amnt -lt 0) {
								echo "choose a real number of cannons to move"
							  }
							  $crewNum = $Oship.Health[0+($zone1*4)]
							  if ($crewNum -lt $amnt) {
								echo "$crewNum crew can't move $amnt cannons"
								$i--; break
							  }
							  $success = reArm $Oship $zone1 $zone2 $amnt
							  if ($success -lt 0) {
								echo "the $zone2 can't hold that many cannons"
								$i--; break
							  }
							  DamageReport $dis $Oship $Dship; break}
			{$_ -eq "flame"} {$str = Read-Host -Prompt "enter '0' to set fire on your ship and '1' to set fire on the enemy ship"
							  $fr = [int]$str
							  $str = Read-Host -Prompt "Choose zone to burn";
							  $zone = readZone($str);
							  if ($fr -ne 0 -and $fr -ne 1) {
								echo "choose either '0' or '1' to determine which ship to set on fire, I'm tired of making string reading functions"
								$i--; break
							  }
							  if ($zone -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if ($fr -eq 0) {
								if ($Oship.Health[0+($zone*4)] -lt 1) {
									echo "There is no crew at that zone";
									$i--; break
								}
								startFire $Os.State $zone
							  }
							  if ($fr -eq 1) {
								if ($Dship.Health[1+($zone*4)] -lt 1) {
									echo "There is no crew at that zone";
									$i--; break
								}
								startFire $Dship.State $zone
							  }; break}
			{$_ -eq "defend"}{$str = Read-Host -Prompt "Choose zone to defend";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								echo "choose from 'bough', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								echo "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $Oship.defBoard($zone); break}
			{$_ -eq "sail"}	 {$str = Read-Host -Prompt "Type '0' to approach and '1' to pull back";
							  $dir = [int]$str;
							  if ($dir -ne 0 -and $dir -ne 1){
								echo "choose either '0' or '1' to determine which direction to sail, I'm tired of making string reading functions"
								$i--; break
							  }
							  $dis = $Oship.sail($dir, $dis)
							  DamageReport $dis $Oship $Dship; break}
			{$_ -eq "help"}	 {$Oship.help;
							  $Action[$i] = Read-Host -Prompt "choose a new action";
							  $i--; break}
			{$_ -eq "wait"}	 {break}
			default			 {$Action[$i] = Read-Host -Prompt "Action $i not recognized. Try again or type 'help' for command list";
							  $i--; break}
		}
		
		addDmg $Dship.Health $dmg $zone $Oship
	}
	
	skirmish $Oship $Dship
	checkState $Oship $Dship
	
	$End = checkWin $Oship.Health $Dship.Health
	$Distance = $dis
	$AcNum = 2;
	#winning print-outs
	if ($End -eq 1) {
		echo
		echo
		echo "$Name2 ran out of living crew, $Name1 wins!"
		echo "final status"
		DamageReport $dis $Oship $Dship
		Start-Sleep -seconds 10
	} elseif ($End -eq 2) {
		echo
		echo
		echo "$Name1 ran out of living crew, $Name2 wins!"
		echo "final status"
		DamageReport $dis $Oship $Dship
		Start-Sleep -seconds 10
	} elseif ($End -eq 3) {
		echo
		echo
		echo "$Name2's ship has sunk, $Name1 wins!"
		echo "final status"
		DamageReport $dis $Oship $Dship
		Start-Sleep -seconds 10
	} elseif ($End -eq 4) {
		echo
		echo
		echo "$Name1's ship has sunk, $Name2 wins!"
		echo "final status"
		DamageReport $dis $Oship $Dship
		Start-Sleep -seconds 10
	}
}

#clean-up
Clear-Content -Path .\turn.txt
Add-Content -Path .\turn.txt -Value "stop"
Start-Sleep -Seconds 5
Remove-Item -Path .\turn.txt
