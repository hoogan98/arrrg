
# Below you will find a function that creates a unique
# module that can then be used as an "object" with it's own unique
# variable states and functions

# Forgive me Lord Bill Gates, for I have sinned
function makeRegularShip() {
    $ship = New-Module -AsCustomObject -ScriptBlock {
        [string]$ShipName = "Regular Ship"
        [int]$script:DebugCount = 0

        function SpecialAction() {
            echo "Special Action!";
            $script:DebugCount++
        }

        Export-ModuleMember -Variable ShipName
        Export-ModuleMember -Variable DebugCount
        Export-ModuleMember -Function SpecialAction
    }
    return $ship
}

$ship2 = makeRegularShip
$ship3 = makeRegularShip

# Variable tests
echo $ship2.ShipName
echo $ship2.DebugCount
$ship2.SpecialAction()
echo $ship2.DebugCount
$ship2.SpecialAction()
echo $ship2.DebugCount
echo $ship3.DebugCount
