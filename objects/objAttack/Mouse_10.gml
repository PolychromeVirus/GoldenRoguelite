var player      = global.players[global.turn]

var dam         = WeaponAttack(true,false).dam
var _unleash = CheckUnleash(player)
if _unleash.active {
	hovertext = "Attack - " + string(dam) + " [" + _unleash.name + "]"
} else {
	hovertext = "Attack - " + string(dam)
}

if player.name == "Kraden"{hovertext = "Attack - " + string(player.atk + player.atkmod) + " [PP]"}