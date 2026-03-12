/// @desc Receives struct: { spell_name, caster_index, on_confirm, on_decline }
var _psyID = FindPsyID(spell_name, 0)
pp_cost = global.psynergylist[_psyID].cost
caster_name = global.players[caster_index].name

global.pause = true
DeleteButtons()

var _confirmSprite = { image: yes, text: "Yes" }
instance_create_depth(BUTTON3, BOTTOMROW, 0, objConfirm, _confirmSprite)
instance_create_depth(BUTTON5, BOTTOMROW, 0, objButton2, { image: no, hovertext: "No" })
