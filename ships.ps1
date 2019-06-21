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
			$Health[3+$z] += [math]::Ceiling($builders * 0.2)
			if ($Health[3+$z] -gt 100) {
				$Health[3+$z] = 100
			}
		}
		
		#retreating crew from boarding
		function retreat($ds, $zone, $amnt) {
			$ds.Health[1+($zone*4)] -= $amnt
			$incoming = $amnt - ([math]::Ceiling($ds.Health[0+($zone*4)] * $ds.CrewDmg))
			if ($incoming -lt 0) {
				return
			}
			$Health[0+($zone*4)] += $incoming
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
		
		function reference() {
			write-host "choose from: 'grape', 'chain', 'round', 'wait', 'board', 'move', 'retreat', 'repair', 'rearm', 'flame', 'brace', 'sail', or 'help'"
		}
		
		function help() {
			write-host "Standard Ship:"
			write-host "The average all-rounder ship. Comes with no particular strengths or weaknesses." 
			write-host "Actions:"
			write-host "Grape: fire grapeshot. Damage: --crew, /\cannons, \/hull"
			write-host "Chain: fire chainshot. Damage: /\crew, \/cannons, --hull"
			write-host "Round: fire roundshot. Damage: \/crew, /\cannons, --hull"
			write-host "Wait: skip an action"
			write-host "Board: board the enemy ship with your crew"
			write-host "Move: move your crew from one zone to another on a ship"
			write-host "Retreat: pull back boarders from the opponent's ship"
			write-host "Repair: order the crew to patch the hull in a zone"
			write-host "Rearm: order the crew to move cannons from one zone to another"
			write-host "Flame: order the crew to set fire to a zone"
			write-host "Brace: reduce incoming damage to a zone on the next turn"
			write-host "Sail: change the distance between the ships"
			write-host "Reference: get a quick list of commands to run in case you forget syntax"
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
		Export-ModuleMember -Function reference
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
		$Defense = 1.65
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
			$Health[3+$z] += [math]::Ceiling($builders * 0.2)
			if ($Health[3+$z] -gt 100) {
				$Health[3+$z] = 100
			}
		}
		
		#retreating crew from boarding
		function retreat($ds, $zone, $amnt) {
			$ds.Health[1+($zone*4)] -= $amnt
			$incoming = $amnt - ([math]::Ceiling($ds.Health[0+($zone*4)] * $ds.CrewDmg))
			if ($incoming -lt 0) {
				return
			}
			$Health[0+($zone*4)] += $incoming
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
		
		function reference() {
			write-host "choose from: 'grape', 'chain', 'round', 'wait', 'board', 'move', 'retreat', 'repair', 'rearm', 'flame', 'brace', 'sail', 'ram', or 'help'"
		}
		
		function help() {
			write-host "Ramming Ship:"
			write-host "The bow has been modified to ram enemy ships, with a thicker hull but no cannon ports and less room for crew"
			write-host "If you are at distance 1, you can ram the enemy for massive hull damage"
			write-host "Notice the mid and stern hulls are weaker, but contain an impressive number of cannon ports"
			write-host "Actions:"
			write-host "Grape: fire grapeshot. Damage: --crew, /\cannons, \/hull"
			write-host "Chain: fire chainshot. Damage: /\crew, \/cannons, --hull"
			write-host "Round: fire roundshot. Damage: \/crew, /\cannons, --hull"
			write-host "Wait: skip an action"
			write-host "Board: board the enemy ship with your crew"
			write-host "Move: move your crew from one zone to another on a ship"
			write-host "Retreat: pull back boarders from the opponent's ship"
			write-host "Repair: order the crew to patch the hull in a zone"
			write-host "Rearm: order the crew to move cannons from one zone to another"
			write-host "Flame: order the crew to set fire to a zone"
			write-host "Brace: reduce incoming damage to a zone on the next turn"
			write-host "Sail: change the distance between the ships"
			write-host "Reference: get a quick list of commands to run in case you forget syntax"
			write-host "Ram: move from distance 1 to 0, charging the enemy ship and dealing high hull damage to one zone"
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
		Export-ModuleMember -Function reference
    }
    return $ship
}

function makeUndeadShip() {
    
    $ship = New-Module -AsCustomObject -ScriptBlock {
        $Name = "init"
        $Health = 20,0,15,100,20,0,15,100,20,0,15,100
		$State = 0,0,0
		$CrewDmg = 0.1
		$StrucDmg = 0.1
		$HitRate = 0.5
		$Defense = 1.5
		$Code = 2
		
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
			write-host "your crew lands on the enemy ship and immediately crumbles to dust"
			$dmg = 0,0,0,0
			$Health[0+($zone*4)] -= $boarders
			
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
			$Health[3+$z] += [math]::Ceiling($builders * 0.2)
			if ($Health[3+$z] -gt 100) {
				$Health[3+$z] = 100
			}
		}
		
		#retreating crew from boarding
		function retreat($ds, $zone, $amnt) {
			write-host "your undead crew can't survive off-ship"
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
		
		function reference() {
			write-host "choose from: 'grape', 'chain', 'round', 'wait', 'board', 'move', 'retreat', 'repair', 'rearm', 'flame', 'brace', 'sail', 'resurrect', or 'help'"
		}
		
		function help() {
			write-host "Undead Ship:"
			write-host "The crew of this vessel are pulled straight from the bottom of the sea, and are expendable"
			write-host "Unfortunately their life force is tied to a cursed amulet on the ship, meaning they can never leave"
			write-host "If you begin to take casualties, you can 'ressurect' your crew to call them back from the depths"
			write-host "Actions:"
			write-host "Grape: fire grapeshot. Damage: --crew, /\cannons, \/hull"
			write-host "Chain: fire chainshot. Damage: /\crew, \/cannons, --hull"
			write-host "Round: fire roundshot. Damage: \/crew, /\cannons, --hull"
			write-host "Wait: skip an action"
			write-host "Move: move your crew from one zone to another on a ship"
			write-host "Repair: order the crew to patch the hull in a zone"
			write-host "Rearm: order the crew to move cannons from one zone to another"
			write-host "Flame: order the crew to set fire to a zone"
			write-host "Brace: reduce incoming damage to a zone on the next turn"
			write-host "Sail: change the distance between the ships"
			write-host "Reference: get a quick list of commands to run in case you forget syntax"
			write-host "Ressurect: revive some of the dead crew, works best if the crew is around half strength"
		}
		
		function resurrect($zone) {
			$amnt = [math]::Ceiling(([math]::Sin(0.157*$Health[0+($zone*4)])) * 10)
			if ($amnt -lt 1) {
				$amnt = 1
			}
			
			$Health[0+($zone*4)] += $amnt
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
		Export-ModuleMember -Function resurrect
		Export-ModuleMember -Function reference
    }
    return $ship
}

function makeVikingShip() {
    
    $ship = New-Module -AsCustomObject -ScriptBlock {
        $Name = "init"
        $Health = 35,0,0,70,35,0,0,70,35,0,0,70
		$State = 0,0,0
		$CrewDmg = 0.2
		$StrucDmg = 0.3
		$HitRate = 0.5
		$Defense = 2
		$Code = 3
		
		#moving cannons
		function reArm($zone1, $zone2, $amnt) {
			write-host "vikings do not have access to gunpowder"
		}
		
		#calculate number of cannons to fire given health value and zone
		function fireCount($zone) {
			write-host "vikings do not have access to gunpowder"
		}
		
		#boarding ships
		function board($ds, $boarders, $zone) {
			$offense = $Health
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
			$Health[3+$z] += [math]::Ceiling($builders * 0.2)
			if ($Health[3+$z] -gt 100) {
				$Health[3+$z] = 100
			}
		}
		
		#retreating crew from boarding
		function retreat($ds, $zone, $amnt) {
			$ds.Health[1+($zone*4)] -= $amnt
			$incoming = $amnt - ([math]::Ceiling($ds.Health[0+($zone*4)] * $ds.CrewDmg))
			if ($incoming -lt 0) {
				return
			}
			$Health[0+($zone*4)] += $incoming
		}
		
		#	DAMAGE FUNCTIONS
		#(this is damage dealt to enemy from your cannons)
		#calculate damage from grapeshot given a specific zone
		#dmg is returned in an array[crew,cannon,hull]
		function dmgGrape($z, $Dis) {
			write-host "vikings do not have access to gunpowder"
		}

		#damage from roundshot
		function dmgRound($z, $Dis) {
			write-host "vikings do not have access to gunpowder"
		}

		#damage from chainshot
		function dmgChain($z, $Dis) {
			write-host "vikings do not have access to gunpowder"
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
		
		function reference() {
			write-host "choose from: 'wait', 'board', 'move', 'retreat', 'repair', 'flame', 'brace', 'sail', 'arrows', or 'help'"
		}
		
		function help() {
			write-host "Viking Ship:"
			write-host "I know these guys are from a different time but they're just so cool I couldn't resist"
			write-host "The Viking longship is not nearly as heavily armored as other ships, watch your hull health"
			write-host "The Vikings do not have cannons, but they have bows that can be fired from distance 2 or closer"
			write-host "Viking crew members are a formidable force, dealing high damage to both crew and structures with above-average defense"
			write-host "Actions:"
			write-host "Wait: skip an action"
			write-host "Board: board the enemy ship with your crew"
			write-host "Move: move your crew from one zone to another on a ship"
			write-host "Retreat: pull back boarders from the opponent's ship"
			write-host "Repair: order the crew to patch the hull in a zone"
			write-host "Rearm: order the crew to move cannons from one zone to another"
			write-host "Flame: order the crew to set fire to a zone"
			write-host "Brace: reduce incoming damage to a zone on the next turn"
			write-host "Sail: change the distance between the ships"
			write-host "Reference: get a quick list of commands to run in case you forget syntax"
			write-host "Arrows: fire a volley of arrows from distance 2 or closer to deal damage to the enemy crew"
		}
		
		#range 2, similar to a skirmish in damage. does nothing to hull or cannons
		function dmgArrows($zone, $dship) {
			$dmg = 0,0,0,0
			$dmg[0] = [math]::Ceiling(($Health[0+$z] - $Health[1+$z]) * $CrewDmg * $HitRate)
			$dmg[1] = [math]::Ceiling(($Health[0+$z] - $Health[1+$z]) * $CrewDmg * $HitRate)
			if ($dmg[0] -lt 0) {
				$dmg[0] = 0
				$dmg[1] = 0
			}
			
			return $dmg
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
		Export-ModuleMember -Function dmgArrows
		Export-ModuleMember -Function reference
    }
    return $ship
}

function makeCursedShip() {
    
    $ship = New-Module -AsCustomObject -ScriptBlock {
        $Name = "init"
        $Health = 30,0,13,100,30,0,13,100,30,0,13,100
		$State = 0,0,0
		$CrewDmg = 0.1
		$StrucDmg = 0.1
		$HitRate = 0.8
		$Defense = 1.5
		$Code = 4
		$CannonMax = 13,13,13
		
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
			$Health[3+$z] += [math]::Ceiling($builders * 0.2)
			if ($Health[3+$z] -gt 100) {
				$Health[3+$z] = 100
			}
		}
		
		#retreating crew from boarding
		function retreat($ds, $zone, $amnt) {
			$ds.Health[1+($zone*4)] -= $amnt
			$incoming = $amnt - ([math]::Ceiling($ds.Health[0+($zone*4)] * $ds.CrewDmg))
			if ($incoming -lt 0) {
				return
			}
			$Health[0+($zone*4)] += $incoming
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
			
			for ($i = 0; $i -lt 4; $i++) {
				$dmg[$i] = [math]::Ceiling( (Get-Random(($dmg[$i] / 2), ($dmg[$i] * 2))) )
			}
			
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
			
			for ($i = 0; $i -lt 4; $i++) {
				$dmg[$i] = [math]::Ceiling( (Get-Random(($dmg[$i] / 2), ($dmg[$i] * 2))) )
			}
			
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
			
			for ($i = 0; $i -lt 4; $i++) {
				$dmg[$i] = [math]::Ceiling( (Get-Random(($dmg[$i] / 2), ($dmg[$i] * 2))) )
			}
			
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
		
		function reference() {
			write-host "choose from: 'grape', 'chain', 'round', 'wait', 'board', 'move', 'retreat', 'repair', 'rearm', 'flame', 'brace', 'sail', or 'help'"
		}
		
		function help() {
			write-host "Cursed Ship:"
			write-host "Nicknamed the 'lucky_13', the captain of this vessel bewitched the cannons"
			write-host "It backfired, however, and the cannons have a chance to either deal massive damage or none at all"
			write-host "Do you feel lucky?"
			write-host "Actions:"
			write-host "Grape: fire grapeshot. Damage: --crew, /\cannons, \/hull"
			write-host "Chain: fire chainshot. Damage: /\crew, \/cannons, --hull"
			write-host "Round: fire roundshot. Damage: \/crew, /\cannons, --hull"
			write-host "Wait: skip an action"
			write-host "Board: board the enemy ship with your crew"
			write-host "Move: move your crew from one zone to another on a ship"
			write-host "Retreat: pull back boarders from the opponent's ship"
			write-host "Repair: order the crew to patch the hull in a zone"
			write-host "Rearm: order the crew to move cannons from one zone to another"
			write-host "Flame: order the crew to set fire to a zone"
			write-host "Brace: reduce incoming damage to a zone on the next turn"
			write-host "Sail: change the distance between the ships"
			write-host "Reference: get a quick list of commands to run in case you forget syntax"
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
		Export-ModuleMember -Function reference
    }
    return $ship
}

function makeTurtleShip() {
    
    $ship = New-Module -AsCustomObject -ScriptBlock {
        $Name = "init"
        $Health = 35,0,3,150,35,0,10,150,35,0,3,150
		$State = 0,0,0
		$CrewDmg = 0.1
		$StrucDmg = 0.1
		$HitRate = 0.5
		$Defense = 5
		$Code = 5
		$CannonMax = 3,10,3
		
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
			$Health[2+$z] += [math]::Ceiling($builders * 0.2)
			if ($Health[2+$z] -gt $CannonMax[$zone]) {
				$Health[2+$z] = $CannonMax[$zone]
			}
		}
		
		#retreating crew from boarding
		function retreat($ds, $zone, $amnt) {
			$ds.Health[1+($zone*4)] -= $amnt
			$incoming = $amnt - ([math]::Ceiling($ds.Health[0+($zone*4)] * $ds.CrewDmg))
			if ($incoming -lt 0) {
				return
			}
			$Health[0+($zone*4)] += $incoming
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
			if ($name -eq "thicc" -or $name -eq "rotund") {
				write-host "hnngggg captain! I'm trying to sail away, but I'm dummy thicc, and the clap of my ass cheecks keeps alerting the pirates!"
			} else {
				write-host "your ship is too... big-boned to move"
			}
			
			return $Dis
		} 
		
		function reference() {
			write-host "choose from: 'grape', 'chain', 'round', 'wait', 'board', 'move', 'retreat', 'repair', 'rearm', 'flame', 'brace', 'guard', or 'help'"
		}
		
		function help() {
			write-host "Turtle Ship:"
			write-host "The thiccest boat on the seven seas, with a near-impenetrable hull and defensive measures that can ward off any cannon fire"
			write-host "The designers of the ship did not intend on it moving, however, and it changes course so slowly that it cannot move in combat"
			write-host "It can defend and fire from the same zone using the 'guard' command though"
			write-host "The hull is too thick to be patched on the fly, so the repair function fixes up cannons instead"
			write-host "Actions:"
			write-host "Grape: fire grapeshot. Damage: --crew, /\cannons, \/hull"
			write-host "Chain: fire chainshot. Damage: /\crew, \/cannons, --hull"
			write-host "Round: fire roundshot. Damage: \/crew, /\cannons, --hull"
			write-host "Wait: skip an action"
			write-host "Board: board the enemy ship with your crew"
			write-host "Move: move your crew from one zone to another on a ship"
			write-host "Retreat: pull back boarders from the opponent's ship"
			write-host "Repair: order the crew to patch the hull in a zone"
			write-host "Rearm: order the crew to move cannons from one zone to another"
			write-host "Flame: order the crew to set fire to a zone"
			write-host "Brace: reduce incoming damage to a zone on the next turn"
			write-host "Reference: get a quick list of commands to run in case you forget syntax"
			write-host "Guard: quickly set up defenses in a zone, so that the crew in that zone can still take another action"
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
		Export-ModuleMember -Function reference
    }
    return $ship
}

function readShip($name, $code) {
	
	if ($name -eq "Ram" -or $name -eq "hullbuster" -or $name -eq "hull buster") {
		write-host "you have chosen the ramming ship"
		$code = 1
		$ship = makeRammingShip
		$ship.Name = $name
		return $ship
	} if ($name -eq "ghost" -or $name -eq "undead" -or $name -eq "flying dutchman") {
		write-host "you have chosen the undead ship"
		$code = 2
		$ship = makeUndeadShip
		$ship.Name = $name
		return $ship
	} if ($name -eq "viking" -or $name -eq "raider" -or $name -eq "longship") {
		write-host "you have chosen the viking ship"
		$code = 3
		$ship = makeVikingShip
		$ship.Name = $name
		return $ship
	} if ($name -eq "cursed" -or $name -eq "lucky 13" -or $name -eq "lucky") {
		write-host "you have chosen the 'lucky' ship"
		$code = 4
		$ship = makeCursedShip
		$ship.Name = $name
		return $ship
	} if ($name -eq "thicc" -or $name -eq "ironsides" -or $name -eq "turtle" -or $name -eq "rotund") {
		write-host "you have chosen the turtle ship"
		$code = 5
		$ship = makeTurtleShip
		$ship.Name = $name
		return $ship
	} else {
		$ship = makeRegularShip
		$ship.Name = $name
		return $ship
	}
}
