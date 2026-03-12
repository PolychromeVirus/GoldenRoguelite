// Trade button (objButton2) — open djinn trade screen
var _clicked = instance_position(mouse_x,mouse_y,objButton2)
if _clicked != noone and _clicked.object_index == objButton2 {
	var djinnID = global.players[global.turn].djinn[selected]
	var params = {sourceDjinn: djinnID, sourcePlayer: global.turn, sourceSlot: selected}
	DeleteButtons()
	instance_create_depth(0,0,0,objDjinniTrade,params)
	instance_destroy()
	exit
}

if instance_position(mouse_x,mouse_y,objConfirm){
	var djinnID = global.players[global.turn].djinn[selected]
	var djinni = global.djinnlist[djinnID]

	if djinni.ready {
		ClearOptions()
		UnleashDjinn(djinnID, global.turn)
		global.djinnlist[djinnID].spent = true
		InjectLog("Unleashes " + djinni.name + "!")
	} else {
		if djinni.spent {
			ClearOptions()
			UnleashDjinn(djinnID, global.turn)
			InjectLog(djinni.name + " is set!")
		} else {
			InjectLog(djinni.name + " is recovering!")
		}
	}
}