
# Below you will find a function that creates a unique
# module that can then be used as an "object" with it's own unique
# variable states and functions

# Forgive me Lord Bill Gates, for I have sinned
function makeRegularShip() {
    
    $ship = New-Module -AsCustomObject -ScriptBlock {
        $Name = "init"
        $Health = 30,0,15,100,30,0,15,100,30,0,15,100
		$State = 0,0,0
		$CrewDmg = 0.1
		$StrucDmg = 0.1
		$HitRate = 0.5
		$MissRate = 0.5
		$Defense = 1.5
		
		$Code = 0
		
		#moving cannons
		function reArm($zone1, $zone2, $amnt) {
			if ((Health[2+($zone2*4)] + $amnt) -gt 15) {
				return -1
			}
			
			$Health[2+($zone1*4)] -= $amnt
			$Health[0+($zone1*4)] -= $amnt
			$Health[2+($zone2*4)] += $amnt
			$Health[0+($zone2*4)] += $amnt
			return 0
		}
		
		#calculate number of cannons to fire given health value and zone
		function fireCount($zone) {
			$z = $zone * 4;
			$avc = $Health[0+$z] - $Health[1+$z]
			$can = $Health[2+$z]
			if ($avc -lt 0) {
				return 0
			} elseif($avc -le $can) {
				return $avc
			}
			return $can
		}
		
		#boarding ships
		function board($ds, $boarders, $zone) {
			$offense = $health
			$defense = $ds.Health
			$dmg = 0,0,0,0
			$z = $zone * 4
			$state = ($ds.Defense * $ds.State[$zone]) + 1
			
			$dmB = $defense[0+$z] * (0.1 * $state)
			$dmD = $boarders * (0.15 / $state)
			if ($dmD -lt 0) {
				$dmD = 0
			}
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
			
			$offense[0+$z] -= $boarders
			$defense[1+$z] += $boarders
			$dmg[1] = [math]::Ceiling($dmB)
			$dmg[0] = [math]::Ceiling($dmD)
			
			return $dmg
		}
		
		#repairing hull
		function rebuild($zone) {
			$builders = $Health[0+(4*$zone)] - $Health[1+(4*$zone)]
			if ($builders -le 0) {
				return
			}
			if ($State[$zone] -lt 0) {
				$State[$zone] = 0
				return
			}
			$z = 4 * $zone
			$Health[3+$z] += [math]::Ceiling($builders * 0.15)
			if ($Health[3+$z] -gt 100) {
				$Health[3+$z] = 100
			}
		}
		
		#retreating crew from boarding
		function retreat($ds, $zone, $amnt) {
			$Health[0+($zone*4)] += $amnt - ([math]::Ceiling($ds.Health[0+($zone*4)] * $ds.CrewDmg))
			$ds.Health[1+($zone*4)] -= $amnt
		}
		
		#	DAMAGE FUNCTIONS
		#(this is damage dealt to enemy from your cannons)
		#calculate damage from grapeshot given a specific zone
		#dmg is returned in an array[crew,cannon,hull]
		function dmgGrape($z, $Dis) {
			$dmg = 0,0,0,0
			
			$count = fireCount $z
			#dmg to crew
			$dmg[0] = $count / (3+($Dis / 1.5))
			$dmg[1] = $dmg[0]
			#dmg to cannons
			$dmg[2] = $count / (3+($Dis / 1.5))
			#dmg to hull
			$dmg[3] = $count / (9+($Dis / 1.5))
			
			return $dmg
		}

		#damage from roundshot
		function dmgRound($z, $Dis) {
			$dmg = 0,0,0,0
			
			$count = fireCount $z
			#dmg to crew
			$dmg[0] = $count / (9+($Dis / 1.5))
			$dmg[1] = $dmg[0]
			#dmg to cannons
			$dmg[2] = $count / (7+($Dis / 1.5))
			#dmg to hull
			$dmg[3] = $count / (0.5+($Dis / 1.5))
			
			return $dmg
		}

		#damage from chainshot
		function dmgChain($z, $Dis) {
			$dmg = 0,0,0,0
			
			$count = fireCount $z
			#dmg to crew
			$dmg[0] = $count / (1+($Dis / 1.5))
			$dmg[1] = $dmg[0]
			#dmg to cannons
			$dmg[2] = $count / (9+($Dis / 1.5))
			#dmg to hull
			$dmg[3] = $count / (5+($Dis / 1.5))
			
			return $dmg
		}

		#damage from fire
		function dmgFire {
			$dmg = 5,5,2,10
			return $dmg
		}
		
		#moving ship
		function sail($dir, $Dis) {
			if($dir -eq 0) {
				$Dis -= 1
			}
			if ($dir -eq 1) {
				$Dis += 1
			}
			if($Dis -lt 0){
				$Dis = 0
			}
			return $Dis
		}
		
		function help() {
			echo "choose from: 'grape', 'chain', 'round', 'wait', 'board', 'move', 'retreat', 'repair', 'rearm', 'flame', 'brace', 'sail', or 'help'"
		}

        Export-ModuleMember -Variable Name
        Export-ModuleMember -Variable Health
		Export-ModuleMember -Variable State
		Export-ModuleMember -Variable CrewDmg
		Export-ModuleMember -Variable StrucDmg
		Export-ModuleMember -Variable HitRate
		Export-ModuleMember -Variable MissRate
		Export-ModuleMember -Variable Defense
		Export-ModuleMember -Variable Code
		Export-ModuleMember -Function fireCount
		Export-ModuleMember -Function dmgRound
		Export-ModuleMember -Function dmgChain
		Export-ModuleMember -Function dmgGrape
		Export-ModuleMember -Function dmgFire
		Export-ModuleMember -Function board
		Export-ModuleMember -Function rebuild
		Export-ModuleMember -Function retreat
		Export-ModuleMember -Function sail
		Export-ModuleMember -Function help
		Export-ModuleMember -Function reArm
    }
    return $ship
}

function makeRammingShip() {
    
    $ship = New-Module -AsCustomObject -ScriptBlock {
        $Name = "init"
        $Health = 15,0,0,150,30,0,20,75,30,0,20,75
		$State = 0,0,0
		$CrewDmg = 0.1
		$StrucDmg = 0.1
		$HitRate = 0.5
		$MissRate = 0.5
		$Defense = 1.5
		$Code = 1
		$CannonMax = 0,20,20
		
		#calculate number of cannons to fire given health value and zone
		function fireCount($zone) {
			$z = $zone * 4;
			$avc = $Health[0+$z] - $Health[1+$z]
			$can = $Health[2+$z]
			if ($avc -lt 0) {
				return 0
			} elseif($avc -le $can) {
				return $avc
			}
			return $can
		}
		
		#boarding ships
		function board($ds, $boarders, $zone) {
			$offense = $health
			$defense = $ds.Health
			$dmg = 0,0,0,0
			$z = $zone * 4
			$state = ($ds.Defense * $ds.State[$zone]) + 1
			
			$dmB = $defense[0+$z] * (0.1 * $state)
			$dmD = $boarders * (0.15 / $state)
			if ($dmD -lt 0) {
				$dmD = 0
			}
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
			
			$offense[0+$z] -= $boarders
			$defense[1+$z] += $boarders
			$dmg[1] = [math]::Ceiling($dmB)
			$dmg[0] = [math]::Ceiling($dmD)
			
			return $dmg
		}
		
		#repairing hull
		function rebuild($zone) {
			$builders = $Health[0+(4*$zone)] - $Health[1+(4*$zone)]
			if ($builders -le 0) {
				return
			}
			if ($State[$zone] -lt 0) {
				$State[$zone] = 0
				return
			}
			$z = 4 * $zone
			$Health[3+$z] += [math]::Ceiling($builders * 0.15)
			if ($Health[3+$z] -gt 100) {
				$Health[3+$z] = 100
			}
		}
		
		#retreating crew from boarding
		function retreat($ds, $zone, $amnt) {
			$Health[0+($zone*4)] += $amnt - ([math]::Ceiling($ds.Health[0+($zone*4)] * $ds.CrewDmg))
			$ds.Health[1+($zone*4)] -= $amnt
		}
		
		#	DAMAGE FUNCTIONS
		#(this is damage dealt to enemy from your cannons)
		#calculate damage from grapeshot given a specific zone
		#dmg is returned in an array[crew,cannon,hull]
		function dmgGrape($z, $Dis) {
			$dmg = 0,0,0,0
			
			$count = fireCount $z
			#dmg to crew
			$dmg[0] = $count / (3+($Dis / 1.5))
			$dmg[1] = $dmg[0]
			#dmg to cannons
			$dmg[2] = $count / (3+($Dis / 1.5))
			#dmg to hull
			$dmg[3] = $count / (9+($Dis / 1.5))
			
			return $dmg
		}

		#damage from roundshot
		function dmgRound($z, $Dis) {
			$dmg = 0,0,0,0
			
			$count = fireCount $z
			#dmg to crew
			$dmg[0] = $count / (9+($Dis / 1.5))
			$dmg[1] = $dmg[0]
			#dmg to cannons
			$dmg[2] = $count / (7+($Dis / 1.5))
			#dmg to hull
			$dmg[3] = $count / (0.5+($Dis / 1.5))
			
			return $dmg
		}

		#damage from chainshot
		function dmgChain($z, $Dis) {
			$dmg = 0,0,0,0
			
			$count = fireCount $z
			#dmg to crew
			$dmg[0] = $count / (1+($Dis / 1.5))
			$dmg[1] = $dmg[0]
			#dmg to cannons
			$dmg[2] = $count / (9+($Dis / 1.5))
			#dmg to hull
			$dmg[3] = $count / (5+($Dis / 1.5))
			
			return $dmg
		}

		#damage from fire
		function dmgFire {
			$dmg = 5,5,2,10
			return $dmg
		}
		
		#moving ship
		function sail($dir, $Dis) {
			if($dir -eq 0) {
				$Dis -= 1
			}
			if ($dir -eq 1) {
				$Dis += 1
			}
			if($Dis -lt 0){
				$Dis = 0
			}
			return $Dis
		}
		
		function help() {
			write-host "choose from: 'grape', 'chain', 'round', 'wait', 'board', 'move', 'retreat', 'repair', 'rearm', 'flame', 'brace', 'sail', 'ram', or 'help'"
		}
		
		function dmgRam() {
			$Health[3] -= ([math]::Ceiling((Get-Random -Minimum 20 -Maximum 30)))
			$dmg = 5,5,2,40
			return $dmg
		}
		
		#moving cannons
		function reArm($zone1, $zone2, $amnt) {
			if (($Health[2+($zone2*4)] + $amnt) -gt $CannonMax[$zone2]) {
				return -1
			}
			
			$Health[2+($zone1*4)] -= $amnt
			$Health[0+($zone1*4)] -= $amnt
			$Health[2+($zone2*4)] += $amnt
			$Health[0+($zone2*4)] += $amnt
			return 0
		}

        Export-ModuleMember -Variable Name
        Export-ModuleMember -Variable Health
		Export-ModuleMember -Variable State
		Export-ModuleMember -Variable CrewDmg
		Export-ModuleMember -Variable StrucDmg
		Export-ModuleMember -Variable HitRate
		Export-ModuleMember -Variable MissRate
		Export-ModuleMember -Variable Defense
		Export-ModuleMember -Variable Code
		Export-ModuleMember -Function fireCount
		Export-ModuleMember -Function dmgRound
		Export-ModuleMember -Function dmgChain
		Export-ModuleMember -Function dmgGrape
		Export-ModuleMember -Function dmgFire
		Export-ModuleMember -Function board
		Export-ModuleMember -Function rebuild
		Export-ModuleMember -Function retreat
		Export-ModuleMember -Function sail
		Export-ModuleMember -Function help
		Export-ModuleMember -Function dmgRam
		Export-ModuleMember -Function reArm
    }
    return $ship
}

function readShip($name, $code) {
	
	if ($name -eq "Ram" -or $name -eq "hullbuster" -or $name -eq "hull_buster") {
		write-host "you have chosen the ramming ship"
		$code = 1
		$ship = makeRammingShip
		$ship.Name = $name
		return $ship
	} else {
		$ship = makeRegularShip
		$ship.Name = $name
		return $ship
	}
}
