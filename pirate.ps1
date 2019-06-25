
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
. .\bot.ps1
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
	write-host "Have fun, and feel free to add / remove stuff from the program."
	write-host ""
	start-sleep -seconds 5
	
}

#set up names / meta stuff
#ship codes: 0 = reg; 1 = ram; 2 = undead
$End = 0;
$Abandoned = 0;

$Name1 = Read-Host -Prompt "Input name for p1's ship"
$p1Ship = readShip($Name1)

$Name2 = Read-Host -Prompt "Input name for p2's ship"
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
			addDmg($floating, $dmg, $i, $sunk)
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

	if ($AcNum -eq 1) {
		invoke-expression 'cmd /c start powershell -Command { .\gui.ps1}'
		$str = Read-Host -Prompt "choose starting distance between ships"
		try {$dis = [int]$str}
		catch {write-host "non-integer detected, setting to default distance"; $dis = 4}
		if ($str -eq "10") {
			$dis = 10
		}
	}
	
	for($j = 0; $j -lt $AcNum; $j++) {
		$ac = $j + 1
		$Action[$j] = Read-Host -Prompt "choose action $ac"
	}
	$fired = -1
	
	for($i = 0; $i -lt $AcNum; $i++) {
		$zone = 0;
		$dmg = 0,0,0,0;
		$str = "";
		
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
							  $mov = [int]$str
							  $str = Read-Host -Prompt "Choose zone to move from";
							  $zone1 = readZone($str);
							  $str = Read-Host -Prompt "Choose zone to move to";
							  $zone2 = readZone($str);
							  $str = Read-Host -Prompt "Choose number of crew to move"
							  $amnt = [int]$str
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
							  crewMove($Oship.Health, $Dship.Health, $mov, $amnt, $zone1, $zone2)
							  DamageReport $dis $Oship $Dship; break}
			{$_ -eq "board"} {$str = Read-Host -Prompt "Choose zone to board";
							  $zone = readZone($str);
							  $str = Read-Host -Prompt "Choose number of crew to board"
							  $amnt = [int]$str
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
								$Action[$i] = Read-Host -Prompt "choose a new action";
								$i--; break
							  }
							  if ($Dship.Health[3+(4*$zone)] -eq 0) {
								write-host "the ship has sunk... Your crew just jumped into the ocean"
								$Oship.Health[0+(4*$zone)] -= $amnt
							  } else {
								$dmg = $Oship.board($Dship, $amnt, $zone)
								addDmg($Dship, $dmg, $zone, $Oship)
								$dmg = 0,0,0,0
							  }
							  DamageReport $dis $Oship $Dship; break}
		{$_ -eq "retreat"} 	 {$str = Read-Host -Prompt "Choose zone to pull boarders from";
							  $zone = readZone($str);
							  $str = Read-Host -Prompt "Choose number of crew to retreat"
							  $amnt = [int]$str
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone"
								$i--; break
							  }
							  if ($dis -ne 0) {
								write-host "not close enough to enemy ship to pull back boarders"
								$Action[$i] = Read-Host -Prompt "choose a new action";
								$i--; break
							  }
							  if (($amnt -lt 0) -or ($amnt -gt $Dship.Health[1+($zone*4)])) {
								write-host "Choose a real number of crew members to retreat";
								$i--; break
							  }
							  if ($Dship.Health[3+(4*$zone)] -eq 0) {
								write-host "the ship has sunk... Your crew just jumped into the ocean"
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
							  $amnt = [int]$str
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
								$Action[$i] = Read-Host -Prompt "choose a new action"
								$i--; break
							  }
							  DamageReport $dis $Oship $Dship; break}
			{$_ -eq "flame"} {$str = Read-Host -Prompt "enter '0' to set fire on your ship and '1' to set fire on the enemy ship"
							  $fr = [int]$str
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
							  $dir = [int]$str;
							  if ($dir -ne 0 -and $dir -ne 1){
								write-host "choose either '0' or '1' to determine which direction to sail, I'm tired of making string reading functions"
								$i--; break
							  }
							  $dis = $Oship.sail($dir, $dis)
							  if ($dis -gt 10) {
								write-host "10 is the max distance"
								$dis = 10
								$Action[$i] = Read-Host -Prompt "choose a new action";
								$i--; break
							  }
							  DamageReport $dis $Oship $Dship; break}
	{$_ -eq "reference"}	 {$Oship.ref;
							  $Action[$i] = Read-Host -Prompt "choose a new action";
							  $i--; break}
			{$_ -eq "help"}	 {$Oship.help;
							  $Action[$i] = Read-Host -Prompt "choose a new action";
							  $i--; break}
			{$_ -eq "wait"}	 {break}
			default			 {$Action[$i] = Read-Host -Prompt "Action $i not recognized. Try again or type 'reference' for command list";
							  $i--; break}
			{$_ -eq "ram"}	 {$str = Read-Host -Prompt "Choose zone to ram";
							  $zone = readZone($str)
							  if ($zone -lt 0){
								write-host "choose from 'bow', 'mid', and 'stern' for the zone";
								$i--; break
							  }
							  if ($Oship.Code -ne 1) {
								$Action[$i] = Read-Host -Prompt "Your ship is not cool enough to pull this move. Try again or type 'reference' for command list";
								$i--; break
							  }
							  if ($dis -ne 1) {
								$Action[$i] = Read-Host -Prompt "You need to be at distance 1 to ram";
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
								$Action[$i] = Read-Host -Prompt "Your ship is not cool enough to pull this move. Try again or type 'reference' for command list";
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
								$Action[$i] = Read-Host -Prompt "Your ship is not cool enough to pull this move. Try again or type 'reference' for command list";
								$i--; break
							  }
							  if ($dis -gt 2) {
								$Action[$i] = Read-Host -Prompt "Your arrows have a range of 2, choose a new action";
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
								$Action[$i] = Read-Host -Prompt "Your ship is not cool enough to pull this move. Try again or type 'reference' for command list";
								$i--; break
							  }
							  defBoard $Oship $zone; break}
		}
		
		addDmg($Dship, $dmg, $zone, $Oship)
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
