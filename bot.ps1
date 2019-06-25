$wants = "","","","","","","","","","",""
#do a while loop that keeps running until two actions are chosen, if you get over 2000 runs though just wait

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
		} elseif ($ship.Health[$i] -gt $max) {
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
	
	$ship.reArm($pullZone, $zone2, $amnt)
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

function decide($ship) {
	$tuns = 0;
	$fired = 4;
	$i = 0
	while ($turns -lt 2) {
		$i++
		$rand = Get-Random -Minimum 0 -Maximum 100
		write-host $rand
		if ($rand -gt 90) {
			$str = $wanted[$i % 11]
			if ($str -eq "") {
				continue;
			}
			$comm = $str.Substring(0, $str.length - 1)
			$zone = $str.Substring($str.length - 1, 1)
			$z = transZone($zone)
			switch ($comm) {
				{$_ -eq "chain"} {$turns += determineRearm($ship, $z)
			}
		}
		if ($i -gt 200) {
			break;
		}
	}
}
