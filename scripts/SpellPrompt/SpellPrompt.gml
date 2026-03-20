/// @function SpellPrompt(spell_name, caster_index, on_confirm, on_decline)
/// @desc Push a centred prompt asking the player to cast a spell.
///       PP is deducted and the cast is logged on confirm.
function SpellPrompt(spell_name, caster_index, on_confirm, on_decline) {
	var _psyID   = FindPsyID(spell_name, 0)
	var _pp_cost = global.psynergylist[_psyID].cost
	var _cname   = global.players[caster_index].name
	PushMenu(objMenuPrompt, {
		lines: [
			{ text: _cname + ": Cast " + spell_name + "?", color: c_white },
			{ text: "(Cost: " + string(_pp_cost) + " PP)",  color: c_yellow },
		],
		buttons: [
			{
				label:   "Yes",
				sprite:   yes,
				on_click: method(
					{ ci: caster_index, cost: _pp_cost, sn: spell_name, cb: on_confirm },
					function() {
						global.players[ci].pp -= cost
						InjectLog(global.players[ci].name + " casts " + sn + "!")
						cb()
					}
				),
			},
			{ label: "No", sprite: no, on_click: on_decline },
		],
	})
}
