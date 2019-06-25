$wants = "","","","","","","","","","",""
#do a while loop that keeps running until two actions are chosen, if you get over 200 runs though just wait

#handles adding float damage values to int number values
function addDmg($Dship, $dmg, $zone, $os) {
	$z = $zone * 4
	$state = ($Dship.Defense * $Dship.State[$zone]) + 1
	$health = $Dship.Health
	
	if ($dmg[0] -ne 0) {
		$health[0+$z] -= [math]::Ceiling( (Get-Random -Minimum (($dmg[0] * $os.HitRate) / $state) -Maximum ($dmg[0] / ($state * $os.HitRate))) )
	}
	if ($dmg[1] -ne 0) {
		$health[1+$z] -= [math]::Ceiling( (Get-Random -Minimum (($dmg[1] * $os.HitRate) / $state) -Maximum ($dmg[1] / ($state * $os.HitRate))) )
	}
	if ($dmg[2] -ne 0) {
		$health[2+$z] -= [math]::Floor( (Get-Random -Minimum (($dmg[2] * $os.HitRate) / $state) -Maximum ($dmg[2] / ($state * $os.HitRate))) )
	}
	if ($dmg[3] -ne 0) {
		$health[3+$z] -= [math]::Ceiling( (Get-Random -Minimum (($dmg[3] * $os.HitRate) / $state) -Maximum ($dmg[3] / ($state * $os.HitRate))) )
	}
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

function checkStatus($mShip, $eShip, $dis) {
	$i = 0;
	#enemy crew check
	$c1 = $eShip.Health[0];
	$c2 = $eShip.Health[4];
	$c3 = $eShip.Health[8];
	if ($c1 -ge $c2 -and $c1 -ge $c3) {
		$wants[$i] = "chainB";
		$i++;
	} elseif ($c2 -ge $c1 -and $c2 -ge $c3) {
		$wants[$i] = "chainM";
		$i++;
	} elseif ($c3 -ge $c1 -and $c3 -ge $c2) {
		$wants[$i] = "chainS";
		$i++;
	}
	#enemy hull check
	$h1 = $eShip.Health[3];
	$h2 = $eShip.Health[7];
	$h3 = $eShip.Health[11];
	if ($h1 -le $h2 -and $h1 -le $h3) {
		$wants[$i] = "roundB";
		$i++;
	} elseif ($h2 -le $h1 -and $h2 -le $h3) {
		$wants[$i] = "roundM";
		$i++;
	} elseif ($h3 -le $h2 -and $h3 -le $h1) {
		$wants[$i] = "roundS";
		$i++;
	}
	#enemy cannon check
	$ca1 = $eShip.Health[2];
	$ca2 = $eShip.Health[6];
	$ca3 = $eShip.Health[10];
	if ($ca1 -ge $ca2 -and $ca1 -ge $ca3) {
		$wants[$i] = "grapeB";
		$i++;
	} elseif ($ca2 -ge $ca1 -and $ca2 -ge $ca3) {
		$wants[$i] = "grapeM";
		$i++;
	} elseif ($ca3 -ge $ca1 -and $ca3 -ge $ca2) {
		$wants[$i] = "grapeS";
		$i++;
	}
	#boarding and sailing check
	$ec = $eShip.Health[0] + $eShip.Health[4] + $eShip.Health[8];
	$mc = $mShip.Health[0] + $mShip.Health[4] + $mShip.Health[8];
	if ($mc -ge ($ec * 1.5)) {
		if ($dis -eq 0) {
			if ($c1 -le $c2 -and $c1 -le $c3) {
				$wants[$i] = "boardB";
				$i++;
			} elseif ($c2 -le $c1 -and $c2 -le $c3) {
				$wants[$i] = "boardM";
				$i++;
			} elseif ($c3 -le $c1 -and $c3 -le $c2) {
				$wants[$i] = "boardS";
				$i++;
			}
		} else {
			$wants[$i] = "sailA"
			$i++;
		}
		
	} elseif ($ec -ge ($mc * 1.5)) {
		$wants[$i] = "sailP"
		$i++;
	}
	#repair check
	if ($mShip.State[0] -lt 0) {
		$wants[$i] = "repairB"
		$i++;
	} elseif ($mShip.State[1] -lt 0) {
		$wants[$i] = "repairM"
		$i++;
	} elseif ($mShip.State[2] -lt 0) {
		$wants[$i] = "repairS"
		$i++;
	}
	#brace check
	if ($dis -lt 3) {
		if ($mShip.Health[3] -lt 25) {
			$wants[$i] = "braceB"
			$i++
		} elseif ($mShip.Health[7] -lt 25) {
			$wants[$i] = "braceM"
			$i++
		} elseif ($mShip.Health[11] -lt 25) {
			$wants[$i] = "braceS"
			$i++
		}
	}
	#retreat check
	$b1 = $eShip.Health[1]
	$b2 = $eShip.Health[5]
	$b3 = $eShip.Health[9]
	if ($c1 -gt $b1 -and $b1 -gt 0) {
		if ($dis -eq 0) {
			$wants[$i] = "retreatB"
			$i++
		}
	}
	if ($c2 -gt $b2 -and $b2 -gt 0) {
		if ($dis -eq 0) {
			$wants[$i] = "retreatM"
			$i++
		}
	}
	if ($c3 -gt $b3 -and $b3 -gt 0) {
		if ($dis -eq 0) {
			$wants[$i] = "retreatS"
			$i++
		}
	}
	#flame check
	if ($b1 -gt 0) {
		$wants[$i] = "flameB"
		$i++
	} elseif ($b2 -gt 0) {
		$wants[$i] = "flameM"
		$i++
	} elseif ($b3 -gt 0) {
		$wants[$i] = "flameS"
		$i++
	}
}

function determineRearm($ship, $z) {
	$cur = $ship.Health(2 + (4*$z))
	
	if ($cur -ge 11) {
		return 0
	}
	
	$other = 1,1,1
	$other[$z] = 0
	$max = 0;
	$pullZone = -1;
	for ($i = 0; $i -lt 3; i++) {
		if (other[$i] -eq 0) {
			continue;
		} elseif ($ship.Health[2+(4*$i)] -gt $max) {
			$max = $ship.Health[2+(4*$i)]
			$pullZone = $i
		}
	}
	
	$amnt = $max
	
	if ($max -eq 0) {
		return 0
	} elseif (($max + $cur) -gt $ship.CannonMax[$pullZone]) {
		$amnt = $ship.CannonMax[$pullZone] - $cur
	}
	
	$ship.reArm($pullZone, $z, $amnt)
	write-host "bot decides to rearm"
	return 1
}

function determineMove($ship, $z) {
	$cur = $ship.Health(0 + (4*$z))
	$other = 1,1,1
	$other[$z] = 0
	$max = 0;
	$pullZone = -1;
	for ($i = 0; $i -lt 3; i++) {
		if (other[$i] -eq 0) {
			continue;
		} elseif ($ship.Health[4*$i] -gt $max) {
			$max = $ship.Health[4*$i]
			$pullZone = $i
		}
	}
	
	$amnt = $max
	
	if ($max -eq 0) {
		return 0
	}
	
	crewMove($ship.Health, $ship.Health, 0, $amnt, $pullZone, $z)
	write-host "bot decides to move crew"
	return 1
}

function transZone($zone) {
	if ($zone -eq "B" -or $zone -eq "A") {
		return 0;
	} elseif ($zone -eq "M" -or $zone -eq "P") {
		return 1;
	} elseif ($zone -eq "S") {
		return 2;
	}
}

function decide($ship, $Dship, $dis) {
	$turns = 2;
	$fired = 4;
	$i = 0
	$dmg = 0,0,0,0
	while ($turns -gt 0) {
		$i++
		$rand = Get-Random -Minimum 0 -Maximum 100
		write-host $rand
		if ($rand -gt 90) {
			$str = $wanted[$i % 11]
			if ($str -eq "") {
				continue;
			}
			$comm = $str.Substring(0, $str.length - 1)
			$zone = transZone($str.Substring($str.length - 1, 1))
			switch ($comm) {
				{$_ -eq "chain"} {	if ($turns -eq 2) {
										$turns -= determineRearm($ship, $zone)
									} elseif ($ship.Health[2+($z*4)] -eq 0) {
										break;
									}
									$turns -= 1
									write-host "bot decides to fire chainshot"
									$dmg = $ship.dmgChain($zone, $dis); break}
				{$_ -eq "round"} {	if ($turns -eq 2) {
										$turns -= determineRearm($ship, $zone)
									} elseif ($ship.Health[2+($z*4)] -eq 0) {
										break;
									}
									$turns -= 1
									write-host "bot decides to fire roundshot"
									$dmg = $ship.dmgRound($zone, $dis); break}
				{$_ -eq "grape"} {	if ($turns -eq 2) {
										$turns -= determineRearm($ship, $zone)
									} elseif ($ship.Health[2+($z*4)] -eq 0) {
										break;
									}
									$turns -= 1
									write-host "bot decides to fire roundshot"
									$dmg = $ship.dmgGrape($zone, $dis); break}
				{$_ -eq "board"} {	if ($turns -eq 2) {
										$turns -= determineMove($ship, $zone)
									} elseif ($ship.Health[0+($z*4)] -eq 0) {
										break;
									}
									$turns -= 1
									write-host "bot decides to board"
									$dmg = $ship.board($Dship, $ship.Health[0+(4*$zone)], $zone)
									addDmg($Dship, $dmg, $zone, $ship)
									$dmg = 0,0,0,0; break}
				{$_ -eq "sail"} {	$turns -= 1
									write-host "bot decides to sail"
									$dis = $ship.sail
			}
			
			addDmg($Dship, $dmg, $zone, $ship)
		}
		if ($i -gt 1000) {
			write-host "bot decides to wait for the rest of the turn"
			
			break;
		}
	}
	
	return $dis
}
