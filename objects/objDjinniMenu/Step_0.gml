var _djinn = global.players[global.turn].djinn
var _len = array_length(_djinn)
if selected > _len - 1 { selected = _len - 1 }
if selected < 0 { selected = 0 }

if _len < 1 { instance_destroy(objQuarterMenu) } else {
	if instance_number(objQuarterMenu) < 1 {
		instance_create_depth(sprite_width, sprite_height/2, 0, objQuarterMenu)
	}
}

if _len < 1 { exit }

if InputPressed(INPUT_UP) {
    selected = (selected == 0) ? _len - 1 : selected - 1
}
if InputPressed(INPUT_DOWN) {
    selected = (selected == _len - 1) ? 0 : selected + 1
}
if InputPressed(INPUT_INFO) {
    // placeholder for djinn info lookup
}
if InputPressed(INPUT_CONFIRM) {
    var _djinnID = _djinn[selected]
    var _djinni = global.djinnlist[_djinnID]
	CONFIRMSOUND
    if _djinni.ready {
        ClearOptions()
        UnleashDjinn(_djinnID, global.turn)
        global.djinnlist[_djinnID].spent = true
        InjectLog("Unleashes " + _djinni.name + "!")
    } else {
        if _djinni.spent {
            ClearOptions()
            UnleashDjinn(_djinnID, global.turn)
            InjectLog(_djinni.name + " is set!")
        } else {
            InjectLog(_djinni.name + " is recovering!")
        }
    }
}
