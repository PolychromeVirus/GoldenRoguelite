/// @desc Pick an adept's weapon to use for Meld attack
DeleteButtons()

selected = 0

// Build list of weapon options from all players
weapons = []
var _caster = global.players[global.turn]
var _original = _caster.weapon
for (var _p = 0; _p < array_length(global.players); _p++) {
	var _pl = global.players[_p]
	var _wep = global.itemcardlist[_pl.weapon]
	// Preview damage with this weapon
	_caster.weapon = _pl.weapon
	var _preview = WeaponAttack(true, false)
	array_push(weapons, { weapon_id: _pl.weapon, weapon_name: _wep.name, alias: _wep.alias, dam: _preview.dam })
}
_caster.weapon = _original

var sprite = { image: yes, text: "Attack" }
instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite)
instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel)
