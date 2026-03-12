global.players[selector] = variable_clone(global.characterlist[selected])
var _p = global.players[selector]
if array_length(_p.starters) > 0 {
	array_push(_p.spells, _p.starters[starter_selected])
}
global.pause = false
instance_destroy(objCharMenu)