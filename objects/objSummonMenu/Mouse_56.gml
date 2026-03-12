if instance_position(mouse_x,mouse_y,objConfirm){
	var _summonID = global.knownSummons[selected]
	if isSummonable(global.summonlist[_summonID]){
		DeleteButtons()
		CastSummon(_summonID,global.turn)
	}else{InjectLog("Not enough djinn to summon this!")}
}
var _clicked = instance_position(mouse_x,mouse_y,objButton2)
if _clicked != noone and _clicked.object_index == objButton2 {
	// Placeholder for summon info lookup
}
