/// @function FindSpellCaster(spell_name)
/// @desc Returns index of first alive player who has the spell and can afford PP. Returns -1 if none.
function FindSpellCaster(spell_name){
	var _psyID = FindPsyID(spell_name, 0)
	if (_psyID < 0) { return -1 }
	var _spell = global.psynergylist[_psyID]
	for (var _i = 0; _i < array_length(global.players); _i++){
		var _p = global.players[_i]
		if (_p.hp <= 0) { continue }
		if (_p.pp < _spell.cost) { continue }
		if (array_contains(_p.spells, _psyID) || array_contains(_p.equip_spells, _psyID)){
			return _i
		}
	}
	return -1
}
