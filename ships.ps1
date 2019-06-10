
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
		
		#	DAMAGE FUNCTIONS
		#(this is damage dealt to enemy from your cannons)
		#calculate damage from grapeshot given a specific zone
		#dmg is returned in an array[crew,cannon,hull]
		function dmgGrape($z, $Dis) {
			$dmg = 0,0,0
			
			$count = fireCount $z
			#dmg to crew
			$dmg[0] = $count / (3+($Dis / 1.5))
			#dmg to cannons
			$dmg[1] = $count / (3+($Dis / 1.5))
			#dmg to hull
			$dmg[2] = $count / (9+($Dis / 1.5))
			
			return $dmg
		}

		#damage from roundshot
		function dmgRound($z, $Dis) {
			$dmg = 0,0,0
			
			$count = fireCount $z
			#dmg to crew
			$dmg[0] = $count / (9+($Dis / 1.5))
			#dmg to cannons
			$dmg[1] = $count / (7+($Dis / 1.5))
			#dmg to hull
			$dmg[2] = $count / (0.5+($Dis / 1.5))
			
			return $dmg
		}

		#damage from chainshot
		function dmgChain($z, $Dis) {
			$dmg = 0,0,0
			
			$count = fireCount $z
			#dmg to crew
			$dmg[0] = $count / (1+($Dis / 1.5))
			#dmg to cannons
			$dmg[1] = $count / (9+($Dis / 1.5))
			#dmg to hull
			$dmg[2] = $count / (5+($Dis / 1.5))
			
			return $dmg
		}

		#damage from fire
		function dmgFire {
			$dmg = 5,2,10
			return $dmg
		}
		
		#boarding ships
		function board($ds, $boarders, $zone) {
			$offense = $health
			$defense = $ds.Health
			$z = $zone * 4
			$state = ($defense[0+$z] * 0.1) * $ds.State[$zone]
			if ($state -lt 0) {
				$state = 0
			}
			
			$dmB = ($defense[0+$z] * 0.1) + $state
			$dmD = ($boarders * 0.15) - $state
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
			$defense[1+$z] += ($boarders - [math]::Ceiling($dmB))
			$defense[0+$z] -= [math]::Ceiling($dmD)
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
			$Health[0+($zone*4)] += $amnt - ([math]::Ceiling($ds.Health[0+($zone*4)] * 0.1))
			$ds.Health[1+($zone*4)] -= $amnt
		}
		
		#defending from boarding
		function defBoard($zone){
			$State[$zone] = 2
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
			echo "choose from: 'grape', 'chain', 'round', 'wait', 'board', 'move', 'retreat', 'repair', 'rearm', 'flame', 'defend', 'sail', or 'help'"
		}

        Export-ModuleMember -Variable Name
        Export-ModuleMember -Variable Health
		Export-ModuleMember -Variable State
		Export-ModuleMember -Variable CrewDmg
		Export-ModuleMember -Variable StrucDmg
		Export-ModuleMember -Variable HitRate
		Export-ModuleMember -Variable MissRate
		Export-ModuleMember -Function fireCount
		Export-ModuleMember -Function dmgRound
		Export-ModuleMember -Function dmgChain
		Export-ModuleMember -Function dmgGrape
		Export-ModuleMember -Function dmgFire
		Export-ModuleMember -Function board
		Export-ModuleMember -Function rebuild
		Export-ModuleMember -Function retreat
		Export-ModuleMember -Function defBoard
		Export-ModuleMember -Function sail
		Export-ModuleMember -Function help
    }
    return $ship
}

function readShip($name) {
	if ($name -eq "some string") {
		#return a special snowflake
	} else {
		$ship = makeRegularShip
		$ship.Name = $name
		return $ship
	}
}
