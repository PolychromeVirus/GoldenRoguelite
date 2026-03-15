var _len = array_length(global.knownSummons)
if selected > _len - 1 { selected = _len - 1 }
if selected < 0 { selected = 0 }

if _len < 1 {
	instance_destroy(objQuarterMenu)
} else {
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
if InputPressed(INPUT_CONFIRM) {
    var _summonID = global.knownSummons[selected]
    if isSummonable(global.summonlist[_summonID]) {
		CONFIRMSOUND
        DeleteButtons()
        CastSummon(_summonID, global.turn)
    } else { InjectLog("Not enough djinn to summon this!") }
}
