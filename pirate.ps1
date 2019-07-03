
# 3 zones: bow, mid, stern
# 4 health nums: crew, boarders, cannons, hull
# As a quick overview, this file contains a few system functions that are independant of the ships and a big switch statement that reads
# user input.  It imports a class that contains all the ship functions called ships.ps1, and writes some data to a file called 'turn.txt'
# that the gui uses to draw the ships.

# add in ideas that I never got around to:
#more ships with special stats
# firebreather: shoots fire, but has a chance to set fire to self and has only 1 type of shot aside from it
# engineer: crew gets damage/accuracy bonus from cannons, repairs faster, fights horribly
# maginot ship: 45 guns and crew in mid, literally nothing on the bow or stern. Impenetrable defense, non?
# officer ship: few but really experienced crew

# IF YOU MOVE THESE FILES CHANGE THESE VARIABLES HERE AND ALSO UPDATE THE GUI:
. .\ships.ps1
$turnLoc = ".\turn.txt"
# It's really in your best interest to just keep everything in its current place

$tutorial = Read-Host -Prompt "Do you know how to play? [y]es or [n]o"

if ($tutorial -eq "n" -or $tutorial -eq "no") {
	write-host "Hello, thanks for playing my dude."
	write-host "This is a two-player turn-based game about pirate ships."
	write-host ""
	start-sleep -seconds 3
	write-host "If you didn't look at the Readme, you should so you can actually run the game and see the UI."
	write-host ""
	start-sleep -seconds 3
	write-host "players take turns taking two different actions"
	write-host "To display the actions your ship can take type 'reference' when your turn comes around."
	write-host "Players can also type 'help' to see information about what their particular ship can do."
	write-host ""
	start-sleep -seconds 3
	write-host "You can win by either killing off the other player's crew,"
	write-host "or by reducing one of their hull zones to zero and sinking their ship."
	write-host "Be wary though, if the enemy ship is too close when you sink it"
	write-host "the crew will abandon ship and board yours."
	write-host ""
	start-sleep -seconds 3
	write-host "The first step is to choose/name your ship."
	write-host "Typing in any old name will give you the Standard ship,"
	write-host "which is a good all-rounder with no glaring weaknesses."
	write-host ""
	start-sleep -seconds 3
	write-host "if you get tired of using the standard, however, there are some more exotic options."
	write-host "type the names: 'Ram', 'Ghost', or 'viking' to try out some other ships."
	write-host ""
	start-sleep -seconds 3
	write-host "The tutorial will pick up again after you have named your ships."
	write-host ""
	start-sleep -seconds 5
	
}

$tutorial = Read-Host -Prompt "Do you want to play against a bot? [y]es or [n]o"


#set up names / meta stuff
#ship codes: 0 = reg; 1 = ram; 2 = undead
$End = 0;
$Abandoned = 0;
$cpu2 = 0

$Name1 = Read-Host -Prompt "Input name for p1's ship"
$p1Ship = readShip($Name1)

if ($tutorial -eq "y" -or $tutorial -eq "yes") {
	$cpu2 = 1
	$Name2 = "rob"
} else {
	$Name2 = Read-Host -Prompt "Input name for p2's ship"
}

$p2Ship = readShip($Name2)

$Turn = 0;
$AcNum = 1;
$Distance = 1
Add-Content -Path $turnLoc -Value "init"



#the name dreadPirateTed wins automatically
if ($Name1 -eq "dreadPirateTed" -or $Name2 -eq "dreadPirateTed") {
	write-host
    write-host "dreadPirateTed wins, as always"
	write-host
	start-sleep -Seconds 5
	exit
} elseif ($Name1 -eq $Name2) {
	write-host
	write-host "that's gonna be confusing, but alright then"
	write-host
}
#	BOT FUNCTIONS
function checkStatus($mShip, $eShip, $dis, $wants, $abandoned) {
	$i = 0;
	$a = 0;
	$mcannon = $mShip.Health[2] + $mShip.Health[6] + $mShip.Health[10];
	#enemy crew check
	$c1 = $eShip.Health[0];
	$c2 = $eShip.Health[4];
	$c3 = $eShip.Health[8];
	#enemy hull check
	$h1 = $eShip.Health[3];
	$h2 = $eShip.Health[7];
	$h3 = $eShip.Health[11];
	#enemy cannon check
	$ca1 = $eShip.Health[2];
	$ca2 = $eShip.Health[6];
	$ca3 = $eShip.Health[10];
	#crew count
	$ec = $eShip.Health[0] + $eShip.Health[4] + $eShip.Health[8];
	$mc = $mShip.Health[0] + $mShip.Health[4] + $mShip.Health[8] + $eShip.Health[1] + $eShip.Health[5] + $eShip.Health[9];
	#boarder count
	$b1 = $eShip.Health[1]
	$b2 = $eShip.Health[5]
	$b3 = $eShip.Health[9]
	
	if ($abandoned -ne 0 -and $mc -eq 0) {
		$a = 1
	}
	
	if ($abandoned -eq 0) {

		if ($mcannon -ge 10) {
			if (!($eShip.Code -eq 2 -and $mc -gt ($ec * 1.3))) {
				if ($c1 -ge $c2 -and $c1 -ge $c3) {
					$wants[$i] = "chainB";
					$i++;
				}
				if ($c2 -ge $c1 -and $c2 -ge $c3) {
					$wants[$i] = "chainM";
					$i++;
				}
				if ($c3 -ge $c1 -and $c3 -ge $c2) {
					$wants[$i] = "chainS";
					$i++;
				}
			}

			if ($h1 -le $h2 -and $h1 -le $h3) {
				$wants[$i] = "roundB";
				$i++;
			}
			if ($h2 -le $h1 -and $h2 -le $h3) {
				$wants[$i] = "roundM";
				$i++;
			}
			if ($h3 -le $h2 -and $h3 -le $h1) {
				$wants[$i] = "roundS";
				$i++;
			}
			
			if (!(($ca1 + $ca2 + $ca3) -lt 6)) {
				if ($ca1 -ge $ca2 -and $ca1 -ge $ca3) {
					$wants[$i] = "grapeB";
					$i++;
				}
				if ($ca2 -ge $ca1 -and $ca2 -ge $ca3) {
					$wants[$i] = "grapeM";
					$i++;
				}
				if ($ca3 -ge $ca1 -and $ca3 -ge $ca2) {
					$wants[$i] = "grapeS";
					$i++;
				}
			}
		}
		#boarding and sailing check
		if (($mc -ge ($ec * 1.3) -or $mcannon -le 10) -and $eShip.Code -ne 2) {
			if ($dis -eq 0 -and $eShip.Code -ne 3) {
				if ($c1 -le $c2 -and $c1 -le $c3) {
					$wants[$i] = "boardB";
					$i++;
				}
				if ($c2 -le $c1 -and $c2 -le $c3) {
					$wants[$i] = "boardM";
					$i++;
				}
				if ($c3 -le $c1 -and $c3 -le $c2) {
					$wants[$i] = "boardS";
					$i++;
				}
			} else {
				$wants[$i] = "sailA"
				$i++;
			}
			
		} elseif (($ec -ge ($mc * 1.3) -or $eShip.Code -eq 3) -and $dis -lt 4 -and $eShip.Code -ne 2) {
			$wants[$i] = "sailP"
			$i++;
		}
		#ramming ship check
		if (($dis -eq 2 -or $dis -eq 1) -and $eShip.Code -eq 1) {
			$wants[$i] = "sailP"
			$i++
		}
		#brace check
		if ($dis -eq 0) {
			if ($mShip.Health[3] -lt 50 -or $c1 -ge 30) {
				$wants[$i] = "braceB"
				$i++
			} if ($mShip.Health[7] -lt 50 -or $c2 -ge 30) {
				$wants[$i] = "braceM"
				$i++
			} if ($mShip.Health[11] -lt 50 -or $c3 -ge 30) {
				$wants[$i] = "braceS"
				$i++
			}
		}
		#retreat check
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
	write-host $wants
	return $wants
}

function determineRearm($ship, $z) {
	$cur = $ship.Health[2 + (4*$z)]
	
	if ($cur -ge 11) {
		return
	}
	
	$other = 1,1,1
	$other[$z] = 0
	$max = 0;
	$pullZone = -1;
	for ($i = 0; $i -lt 3; $i++) {
		$m = [math]::min($ship.Health[2+(4*$i)], $ship.Health[0+(4*$i)])
		if ($other[$i] -eq 0) {
			continue;
		} elseif ($m -gt $max) {
			$max = $m;
			$pullZone = $i;
		}
	}
	
	$amnt = $max
	
	if ($max -eq 0) {
		return
	} elseif (($max + $cur) -gt $ship.CannonMax[$pullZone]) {
		$amnt = $ship.CannonMax[$pullZone] - $cur
	}
	
	$ship.reArm($pullZone, $z, $amnt)
	write-host "rob decides to rearm"
	return 1
}

function determineMove($ship, $z) {
	$cur = $ship.Health[0 + (4*$z)]
	$other = 1,1,1
	$other[$z] = 0
	$max = 0;
	$pullZone = -1;
	for ($i = 0; $i -lt 3; $i++) {
		if ($other[$i] -eq 0) {
			continue;
		} elseif ($ship.Health[4*$i] -gt $max) {
			$max = $ship.Health[4*$i]
			$pullZone = $i
		}
	}
	
	$amnt = $max
	
	if ($max -eq 0) {
		return;
	}
	
	crewMove $ship.Health $ship.Health 0 $amnt $pullZone $z
	write-host "rob decides to move crew"
	return 1
}

function moveToMin($ship, $zone) {
	$amnt = $ship.Health[1+(4*$zone)]
	
	$other = 1,1,1
	$other[$zone] = 0
	$min = 1000;
	$newZone = -1;
	for ($i = 0; $i -lt 3; $i++) {
		if ($other[$i] -eq 0) {
			continue;
		} elseif ($ship.Health[(4*$i)] -lt $min) {
			$min = $ship.Health[4*$i]
			$newZone = $i
		}
	}
	
	write-host "rob decides to move"
	crewMove $ship.Health $ship.Health 1 $amnt $zone $newZone
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

function decide($ship, $Dship, $dis, $wants) {
	$turns = 2;
	$fired = 4;
	$i = 0
	$k = 0
	$dmg = 0,0,0,0
	while ($turns -gt 0) {
		$i++
		$k++
		if ($k -gt 21) {
			$k = 0;
		}
		$rand = Get-Random -Minimum 0 -Maximum 100
		if ($rand -gt 90) {
			$str = $wants[$k]
			if ($str -eq "") {
				if ($ship.Health[1] -gt 0) {
					$turns--
					determineMove $ship 0
				} elseif ($ship.Health[5] -gt 0) {
					$turns--
					determineMove $ship 1
				} elseif ($ship.Health[9] -gt 0) {
					$turns--
					determineMove $ship 2
				}
				
				if ($ship.State[0] -lt 0) {
					$turns--
					if ($ship.Health[0] -eq 0) {
						determineMove $ship 0
					} else {
						$ship.Rebuild(0)
					}
				} elseif ($ship.State[1] -lt 0) {
					$turns--
					if ($ship.Health[4] -eq 0) {
						determineMove $ship 1
					} else {
						$ship.Rebuild(1)
					}
				} elseif ($ship.State[2] -lt 0) {
					$turns--
					if ($ship.Health[8] -eq 0) {
						determineMove $ship 2
					} else {
						$ship.Rebuild(2)
					}
				}
				continue;
			}
			$comm = $str.Substring(0, $str.length - 1)
			$zone = transZone $str.Substring($str.length - 1, 1) 
			switch ($comm) {
				{$_ -eq "chain"} {	if ($turns -eq 2) {
										$num = (determineRearm $ship $zone)
										if (! ($num -eq $null)) {
											$turns--;
										}
										if ($ship.Health[0+($z*4)] -eq 0) {
											determineMove $ship $z
											$turns--
										}
									} elseif ($ship.Health[2+($z*4)] -eq 0) {
										break;
									}
									if ($ship.Health[0+($z*4)] -eq 0) {
										break;
									}
									if ($zone -eq $fired) {
										break;
									}
									$turns -= 1
									$fired = $zone
									write-host "rob decides to fire chainshot " $zone
									$dmg = $ship.dmgChain($zone, $dis); break}
				{$_ -eq "round"} {	if ($turns -eq 2) {
										$num = (determineRearm $ship $zone)
										if (! ($num -eq $null)) {
											$turns--;
										}
										if ($ship.Health[0+($z*4)] -eq 0) {
											determineMove $ship $z
											$turns--
										}
									} elseif ($ship.Health[2+($z*4)] -eq 0) {
										break;
									}
									if ($ship.Health[0+($z*4)] -eq 0) {
										break;
									}
									if ($zone -eq $fired) {
										break;
									}
									$turns -= 1
									$fired = $zone
									write-host "rob decides to fire roundshot " $zone
									$dmg = $ship.dmgRound($zone, $dis); break}
				{$_ -eq "grape"} {	if ($turns -eq 2) {
										$num = (determineRearm $ship $zone)
										if (! ($num -eq $null)) {
											$turns--;
										}
										if ($ship.Health[0+($z*4)] -eq 0) {
											determineMove $ship $z
											$turns--
										}
									} elseif ($ship.Health[2+($z*4)] -eq 0) {
										break;
									}
									if ($ship.Health[0+($z*4)] -eq 0) {
										break;
									}
									if ($zone -eq $fired) {
										break;
									}
									$turns -= 1
									$fired = $zone
									write-host "rob decides to fire grapeshot " $zone
									$dmg = $ship.dmgGrape($zone, $dis); break}
				{$_ -eq "board"} {	if ($turns -eq 2) {
										$num = (determineMove $ship $zone)
										if (! ($num -eq $null)) {
											$turns--;
										}
									} elseif ($ship.Health[0+($z*4)] -eq 0) {
										break;
									}
									if ($zone -eq $fired) {
										break;
									}
									$turns -= 1
									$fired = $zone
									write-host "rob decides to board " $zone
									$dmg = $ship.board($Dship, $ship.Health[0+(4*$zone)], $zone)
									addDmg $Dship $dmg $zone $ship
									$dmg = 0,0,0,0; break}
				{$_ -eq "sail"} {	$turns -= 1
									write-host "rob decides to sail " $zone
									$dis = $ship.sail($zone, $dis)
									if ($dis -eq 0 -and $turns -gt 0) {
										$c1 = $Dship.Health[0];
										$c2 = $Dship.Health[4];
										$c3 = $Dship.Health[8];
										if ($c1 -le $c2 -and $c1 -le $c3) {
											$wants[$k] = "boardB";
										}
										if ($c2 -le $c1 -and $c2 -le $c3) {
											$wants[$k] = "boardM";
										}
										if ($c3 -le $c1 -and $c3 -le $c2) {
											$wants[$k] = "boardS";
										}
									}; break}
				{$_ -eq "brace"} {	if ($zone -eq $fired) {
										break;
									}
									$turns -= 1
									$fired = $zone
									write-host "rob decides to brace " $zone
									defBoard $ship $zone; break}
			{$_ -eq "retreat"} {	if ($zone -eq $fired) {
										break;
									}
									$turns -= 1
									$fired = $zone
									write-host "rob decides to retreat " $zone
									$ship.retreat($Dship, $zone, $Dship.Health[1 + (4*$zone)]); break}
				{$_ -eq "flame"} {	if ($turns -eq 1) {
										break;
									}
									$turns -= 2
									write-host "rob decides to start a fire " $zone
									$Dship.State[$zone] = -1
									moveToMin $Dship $zone
									break}
			}
			addDmg $Dship $dmg $zone $ship
			$dmg = 0,0,0,0
		}
		if ($i -gt 1000) {
			write-host "rob decides to wait for the rest of the turn"
			
			break;
		}
	}
	
	return $dis
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
		Clear-Content -Path $turnLoc
		$str = ($os.Health -join ",") + "," + ($os.State -join ",") + "," + $os.Code + " " + $os.Name
		Add-Content -Path $turnLoc -Value $str
	} catch {
		Clear-Content -Path $turnLoc
		$str = ($os.Health -join ",") + "," + ($os.State -join ",") + " " + $os.Name
		Add-Content -Path $turnLoc -Value $str
	}
	
	write-host "Damage Report:"
    write-host ("{0,-37} |$Dis| {1,37}" -f $os.Name, $ds.Name)
	Start-Sleep -Seconds 1
	write-host "                                     bow"
	Start-Sleep -Seconds 1
	write-host "Crew     Boarders   Cannons     Hull  |$Dis|  Crew     Boarders   Cannons     Hull"
	$str = ($os.Health[0..3] -join "         ") + "   |$Dis|  " +  ($ds.Health[0..3] -join "         ")
	write-host $str
	Start-Sleep -Seconds 1
	write-host "                                     Mid"
	Start-Sleep -Seconds 1
	write-host "Crew     Boarders   Cannons     Hull  |$Dis|  Crew     Boarders   Cannons     Hull"
	$str = ($os.Health[4..7] -join "         ") + "   |$Dis|  " + ($ds.Health[4..7] -join "         ")
	write-host $str
	Start-Sleep -Seconds 1
	write-host "                                     Stern"
	Start-Sleep -Seconds 1
	write-host "Crew     Boarders   Cannons     Hull  |$Dis|  Crew     Boarders   Cannons     Hull"
	$str = ($os.Health[8..11] -join "         ") + "   |$Dis|  " + ($ds.Health[8..11] -join "         ")
	write-host $str
}

#reads parts of ship into zone numbers
function readZone($s) {
	if($s -eq "bow") {
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
function addDmg($Dship, $dmg, $zone, $os) {
	$HitRate = $os.HitRate
	$z = $zone * 4
	$s = $Dship.State[$zone]
	if ($s -lt 0) {
		$s = 0
	}
	$state = ($Dship.Defense * $s) + 1
	$health = $Dship.Health
	
	if ($dmg[0] -ne 0) {
		$d1 = ([math]::Ceiling( (Get-Random -Minimum (($dmg[0] * $HitRate) / $state) -Maximum (($dmg[0] * (1+$HitRate)) / $state) )))
		$health[0+$z] -= $d1
		write-host "crew dmg: " $d1
	}
	if ($dmg[1] -ne 0) {
		$d2 = ([math]::Ceiling( (Get-Random -Minimum (($dmg[1] * $HitRate) / $state) -Maximum (($dmg[1] * (1+$HitRate)) / $state)) ))
		$health[1+$z] -= $d2
		write-host "boarder dmg: " $d2
	}
	if ($dmg[2] -ne 0) {
		$d3 = ([math]::Floor( (Get-Random -Minimum (($dmg[2] * $HitRate) / $state) -Maximum (($dmg[2] * (1+$HitRate)) / $state)) ))
		$health[2+$z] -= $d3
		write-host "cannon dmg: " $d3
	}
	if ($dmg[3] -ne 0) {
		$d4 = ([math]::Ceiling( (Get-Random -Minimum (($dmg[3] * $HitRate) / $state) -Maximum (($dmg[3] * (1+$HitRate)) / $state))) )
		$health[3+$z] -= $d4
		write-host "hull dmg: " $d4
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

#checks for victory
#win codes are: 1/2 for no crew, 3/4 for hull breach
function checkWin($p1, $p2, $ab) {
	$1crew = 0
	$2crew = 0
	for ($i = 0; $i -lt 3; $i++){
		$z = 4*$i
		$1crew += $p1[0+$z] + $p2[1+$z]
		$2crew += $p2[0+$z] + $p1[1+$z]
		if ($p1[3+$z] -le 0 -and $ab -ne 4) {
			return 4
		}
		if ($p2[3+$z] -le 0 -and $ab -ne 3) {
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
	for ($i = 0; $i -lt 12; $i++) {
		if ($Os.Health[$i] -lt 0) {
			$Os.Health[$i] = 0;
		}
		if ($Ds.Health[$i] -lt 0) {
			$Ds.Health[$i] = 0;
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
			$dmg = $os.dmgFire()
			$os.Health[0+$z] -= $dmg[0]
			$os.Health[1+$z] -= $dmg[1]
			$os.Health[2+$z] -= $dmg[2]
			$os.Health[3+$z] -= $dmg[3]
		}
		if ($ds.State[$i] -eq -1) {
			$dmg = $ds.dmgFire()
			$ds.Health[0+$z] -= $dmg[0]
			$ds.Health[1+$z] -= $dmg[1]
			$ds.Health[2+$z] -= $dmg[2]
			$ds.Health[3+$z] -= $dmg[3]
		}
		if ($os.State[$i] -gt 0) {
			$os.State[$i]--
		}
		if ($ds.State[$i] -gt 0) {
			$ds.State[$i]--
		}
	}
	for ($i = 0; $i -lt 12; $i++) {
		if ($os.Health[$i] -lt 0) {
			$os.Health[$i] = 0;
		}
		if ($ds.Health[$i] -lt 0) {
			$ds.Health[$i] = 0;
		}
	}
}

#defending from boarding
function defBoard($os, $zone){
	$os.State[$zone] = 2
}

#endgame abandon ship stuff
function abandonShip($sunk, $floating, $dis) {
	$i = 0
	$str = $sunk.Name
	write-host "$str has sunk!"
	write-host "				ABANDON SHIP"
	write-host
	
	for ($i = 0; $i -lt 3; $i++) {
		$z = 4*$i
		$sunk.Health[2+$z] = 0
		$sunk.Health[3+$z] = 0
		if ($dis -eq 0) {
			$floating.retreat($sunk, $i, $sunk.Health[1+$z])
			$dmg = $sunk.board($floating, $sunk.Health[0+$z], $i)
			addDmg $floating $dmg $i $sunk
			$dmg = 0,0,0,0
		} else {
			$sunk.Health[0+$z] = 0
			$sunk.Health[1+$z] = 0
		}
	}
	DamageReport $dis $floating $sunk
	skirmish $floating $sunk
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
        write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		write-host ("{0,37}'s turn" -f $Oship.Name)
		Start-Sleep -Seconds 1
	} elseif ($Turn -eq 1) {
		$Turn = 0
		$Oship = $p2Ship
		$Dship = $p1Ship
        write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		write-host ("{0,37}'s turn" -f $Oship.Name)
		Start-Sleep -Seconds 1
	}

	DamageReport $dis $Oship $Dship
	
	if ($tutorial -eq "n" -or $tutorial -eq "no") {
		start-sleep -seconds 3
		write-host "On the lines above, you should see a 'Damage Report'"
		write-host ""
		start-sleep -seconds 3
		write-host "One of these is printed at the start of each turn,"
		write-host "or after a player takes a movement-related action."
		write-host ""
		start-sleep -seconds 3
		write-host "Have fun, and feel free to add / remove stuff from the program."
		write-host ""
		start-sleep -seconds 5
	}
	
	if ($cpu2 -eq 1 -and $Oship.Name -eq "rob") {
		$wants = "","","","","","","","","","","","","","","","","","","","","",""
		$wants = checkStatus $Oship $Dship $dis $wants $Abandoned
		$dis = decide $Oship $Dship $dis $wants
	}

	if ($AcNum -eq 1) {
		invoke-expression 'cmd /c start powershell -Command { .\gui.ps1}'
		$str = Read-Host -Prompt "choose starting distance between ships (choose from 2 to 8)"
		try {$dis = [int]$str}
		catch {write-host "non-integer detected, setting to default distance"; $dis = 4}
		if ($dis -gt 8 -or $dis -lt 2) {
			write-host "Distance must be between 8 and 2, setting to default value"
			$dis = 4
		}
	}
	
	$fired = -1
	
	for($i = 0; $i -lt $AcNum; $i++) {
		if ($cpu2 -eq 1 -and $Oship.Name -eq "rob") {
			continue;
		}
		$zone = 0;
		$dmg = 0,0,0,0;
		$str = "";
		
		$ac = $i + 1
		$Action[$i] = Read-Host -Prompt "choose action $ac"
		
		switch ($Action[$i]) {
			{$_ -eq "grape"} {$str = Read-Host -Prompt "Choose zone to fire grapeshot from";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								write-host "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $dmg = $Oship.dmgGrape($zone, $dis); break}
			{$_ -eq "round"} {$str = Read-Host -Prompt "Choose zone to fire roundshot from";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								write-host "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $dmg = $Oship.dmgRound($zone, $dis); break}
			{$_ -eq "chain"} {$str = Read-Host -Prompt "Choose zone to fire chainshot from";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								write-host "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $dmg = $Oship.dmgChain($zone, $dis); break}
			{$_ -eq "move"}	 {$str = Read-Host -Prompt "enter '0' to move crew on your ship and '1' to move boarded crew"
							  try {$mov = [int]$str}
							  catch {write-host "choose either '0' or '1' to determine which ship to move crew on, I'm tired of making string reading functions"
									 $i--; break}
							  $str = Read-Host -Prompt "Choose zone to move from";
							  $zone1 = readZone($str);
							  $str = Read-Host -Prompt "Choose zone to move to";
							  $zone2 = readZone($str);
							  $str = Read-Host -Prompt "Choose number of crew to move"
							  try {$amnt = [int]$str}
							  catch {write-host "enter a number for the amount of crew to move"
									 $i--; break}
							  if ($mov -ne 0 -and $mov -ne 1) {
								write-host "choose either '0' or '1' to determine which ship to move crew on, I'm tired of making string reading functions"
								$i--; break
							  }
							  if ($zone1 -lt 0 -or $zone2 -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if ($mov -eq 0) {
								if (($amnt -lt 0) -or ($amnt -gt $Oship.Health[0+($zone1*4)])) {
									write-host "Choose a real number of crew members to move";
									$i--; break
								}
							  }
							  if ($mov -eq 1) {
								if (($amnt -lt 0) -or ($amnt -gt $Dship.Health[1+($zone1*4)])) {
									write-host "Choose a real number of crew members to move";
									$i--; break
								}
							  }
							  crewMove $Oship.Health $Dship.Health $mov $amnt $zone1 $zone2
							  DamageReport $dis $Oship $Dship; break}
			{$_ -eq "board"} {$str = Read-Host -Prompt "Choose zone to board";
							  $zone = readZone($str);
							  $str = Read-Host -Prompt "Choose number of crew to board"
							  try {$amnt = [int]$str}
							  catch {write-host "enter a number for the amount of crew to board"
									 $i--; break}
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if (($amnt -lt 0) -or ($amnt -gt $Oship.Health[0+($zone*4)])) {
								write-host "Choose a real number of crew members to board";
								$i--; break
							  }
							  if ($dis -ne 0) {
								write-host "not close enough to enemy ship to initiate boarding"
								$i--; break
							  }
							  if ($Dship.Health[3+(4*$zone)] -eq 0) {
								write-host "the ship has sunk... Your crew just jumped into the ocean"
								$Oship.Health[0+(4*$zone)] -= $amnt
							  } else {
								$dmg = $Oship.board($Dship, $amnt, $zone)
								addDmg $Dship $dmg $zone $Oship
								$dmg = 0,0,0,0
							  }
							  DamageReport $dis $Oship $Dship; break}
		{$_ -eq "retreat"} 	 {$str = Read-Host -Prompt "Choose zone to pull boarders from";
							  $zone = readZone($str);
							  $str = Read-Host -Prompt "Choose number of crew to retreat"
							  try {$amnt = [int]$str}
							  catch {write-host "enter a number for the amount of crew to retreat"
									 $i--; break}
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($dis -ne 0) {
								write-host "not close enough to enemy ship to pull back boarders"
								$i--; break
							  }
							  if (($amnt -lt 0) -or ($amnt -gt $Dship.Health[1+($zone*4)])) {
								write-host "Choose a real number of crew members to retreat";
								$i--; break
							  }
							  if ($Dship.Health[3+(4*$zone)] -eq 0) {
								write-host "your ship has sunk... Your crew just jumped into the ocean"
								$Oship.Health[1+(4*$zone)] -= $amnt
							  } else {
								$Oship.retreat($Dship, $zone, $amnt)
							  }
							  DamageReport $dis $Oship $Dship; break}
			{$_ -eq "repair"}{$str = Read-Host -Prompt "Choose zone to repair";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								write-host "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $Oship.rebuild($zone); break}
			{$_ -eq "rearm"} {$str = Read-Host -Prompt "Choose zone to move from";
							  $zone1 = readZone($str);
							  $str = Read-Host -Prompt "Choose zone to move to";
							  $zone2 = readZone($str);
							  $str = Read-Host -Prompt "Choose number of cannons to move"
							  try {$amnt = [int]$str}
							  catch {write-host "enter a number for the amount of cannons to move"
									 $i--; break}
							  if ($zone1 -lt 0 -or $zone2 -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if ($amnt -gt $Oship.Health[2+($zone1*4)] -or $amnt -lt 0) {
								write-host "choose a real number of cannons to move"
							  }
							  $crewNum = $Oship.Health[0+($zone1*4)]
							  if ($crewNum -lt $amnt) {
								write-host "$crewNum crew can't move $amnt cannons"
								$i--; break
							  }
							  $success = $Oship.reArm($zone1, $zone2, $amnt)
							  if ($success -lt 0) {
								write-host "that zone can't hold that many cannons"
								$i--; break
							  }
							  DamageReport $dis $Oship $Dship; break}
			{$_ -eq "flame"} {$str = Read-Host -Prompt "enter '0' to set fire on your ship and '1' to set fire on the enemy ship"
							  try {$fr = [int]$str}
							  catch {write-host "choose either '0' or '1' to determine which ship to set on fire, I'm tired of making string reading functions"
									 $i--; break}
							  $str = Read-Host -Prompt "Choose zone to burn";
							  $zone = readZone($str);
							  if ($fr -ne 0 -and $fr -ne 1) {
								write-host "choose either '0' or '1' to determine which ship to set on fire, I'm tired of making string reading functions"
								$i--; break
							  }
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if ($fr -eq 0) {
								if ($Oship.Health[0+($zone*4)] -lt 1) {
									write-host "There is no crew at that zone";
									$i--; break
								}
								startFire $Oship.State $zone
							  }
							  if ($fr -eq 1) {
								if ($Dship.Health[1+($zone*4)] -lt 1) {
									write-host "There is no crew at that zone";
									$i--; break
								}
								startFire $Dship.State $zone
							  }; break}
			{$_ -eq "brace"} {$str = Read-Host -Prompt "Choose zone to brace";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($zone -eq $fired){
								write-host "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  defBoard $Oship $zone; break}
			{$_ -eq "sail"}	 {$str = Read-Host -Prompt "Type '0' to approach and '1' to pull back";
							  try {$dir = [int]$str}
							  catch {write-host "choose either '0' or '1' to determine which ship to set on fire, I'm tired of making string reading functions"
									 $i--; break}
							  if ($dir -ne 0 -and $dir -ne 1){
								write-host "choose either '0' or '1' to determine which direction to sail, I'm tired of making string reading functions"
								$i--; break
							  }
							  $dis = $Oship.sail($dir, $dis)
							  if ($dis -gt 10) {
								write-host "10 is the max distance"
								$dis = 10
								$i--; break
							  }
							  DamageReport $dis $Oship $Dship; break}
	{$_ -eq "reference"}	 {$str = $Oship.ref();
							  write-host $str
							  write-Host "choose a new action";
							  $i--; break}
			{$_ -eq "help"}	 {$str = $Oship.halp();
							  write-host $str
							  $i--; break}
			{$_ -eq "wait"}	 {break}
			default			 {write-host "Action $i not recognized. Try again or type 'reference' for command list";
							  $i--; break}
			{$_ -eq "ram"}	 {$str = Read-Host -Prompt "Choose zone to ram";
							  $zone = readZone($str)
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if ($Oship.Code -ne 1) {
								write-host "Your ship is not cool enough to pull this move. Try again or type 'reference' for command list";
								$i--; break
							  }
							  if ($dis -ne 1) {
								write-host "You need to be at distance 1 to ram";
								$i--; break
							  }
							  if ($zone -eq $fired){
								write-host "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $dis--
							  $dmg = $Oship.dmgRam(); break}
	{$_ -eq "resurrect"}	 {$str = Read-Host -Prompt "Choose zone to revive crew on";
							  $zone = readZone($str)
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if ($Oship.Code -ne 2) {
								write-host "Your ship is not cool enough to pull this move. Try again or type 'reference' for command list";
								$i--; break
							  }
							  $Oship.resurrect($zone)
							  DamageReport $dis $Oship $Dship; break}
		{$_ -eq "arrows"}	 {$str = Read-Host -Prompt "Choose zone to fire arrows from";
							  $zone = readZone($str)
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if ($Oship.Code -ne 3) {
								write-host "Your ship is not cool enough to pull this move. Try again or type 'reference' for command list";
								$i--; break
							  }
							  if ($dis -gt 2) {
								write-host "Your arrows have a range of 2, choose a new action";
								$i--; break
							  }
							  if ($zone -eq $fired){
								write-host "A zone can only do one non-movement action per turn"
								$i--; break
							  }
							  $fired = $zone;
							  $dmg = $Oship.dmgArrows($zone, $Dship); break}
		{$_ -eq "guard"}	 {$str = Read-Host -Prompt "Choose zone to guard";
							  $zone = readZone($str);
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($Oship.Code -ne 5) {
								write-host "Your ship is not cool enough to pull this move. Try again or type 'reference' for command list";
								$i--; break
							  }
							  defBoard $Oship $zone; break}
		}
		addDmg $Dship $dmg $zone $Oship
		$dmg = 0,0,0,0
	}
	
	skirmish $Oship $Dship
	checkState $Oship $Dship
	
	$End = checkWin $p1Ship.Health $p2Ship.Health $Abandoned
	$Distance = $dis
	$AcNum = 2;

	if ($Abandoned -eq $End) {
		$End = 0
	}
	
	#winning print-outs
	if ($End -eq 1) {
		write-host ""
		write-host ""
		write-host "$Name2 ran out of living crew, $Name1 wins!"
		write-host "final status"
		DamageReport $dis $Oship $Dship
		Start-Sleep -seconds 10
	} elseif ($End -eq 2) {
		write-host ""
		write-host ""
		write-host "$Name1 ran out of living crew, $Name2 wins!"
		write-host "final status"
		DamageReport $dis $Oship $Dship
		Start-Sleep -seconds 10
	} elseif ($End -eq 3) {
		if (($dis -eq 0 -or $p1Ship.Health[1] -gt 0 -or $p1Ship.Health[5] -gt 0 -or $p1Ship.Health[9] -gt 0) -and $Abandoned -ne 3) {
			abandonShip $p2Ship $p1Ship $dis
			$End = 0
			$Abandoned = 3
			continue
		}
		if ($Abandoned -ne 0) {
			write-host "both ships are now underwater..."
			write-host "everyone died, nobody wins.  Congratulations you animals."
			continue
		}
		write-host ""
		write-host ""
		write-host "$Name2 has sunk, $Name1 wins!"
		write-host "final status"
		DamageReport $dis $Oship $Dship
		Start-Sleep -seconds 10
	} elseif ($End -eq 4) {
		if (($dis -eq 0 -or $p2Ship.Health[1] -gt 0 -or $p2Ship.Health[5] -gt 0 -or $p2Ship.Health[9] -gt 0) -and $Abandoned -ne 4) {
			abandonShip $p1Ship $p2Ship $dis
			$End = 0
			$Abandoned = 4
			continue
		}
		if ($Abandoned -ne 0) {
			write-host "both ships are now underwater..."
			write-host "everyone died, nobody wins.  Congratulations you animals."
			continue
		}
		write-host ""
		write-host ""
		write-host "$Name1 has sunk, $Name2 wins!"
		write-host "final status"
		DamageReport $dis $Oship $Dship
		Start-Sleep -seconds 10
	}
}

#clean-up
Clear-Content -Path $turnLoc
Add-Content -Path $turnLoc -Value "stop"
Start-Sleep -Seconds 5
Remove-Item -Path $turnLoc
