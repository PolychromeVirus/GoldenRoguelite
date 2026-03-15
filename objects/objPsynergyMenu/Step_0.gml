var _spells = global.players[global.turn].spells
var _len = array_length(_spells)
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
    PsyLookup(_spells[selected])
}
if InputPressed(INPUT_CONFIRM) and clickable {
    if global.psynergylist[_spells[selected]].cost <= global.players[global.turn].pp {
		CONFIRMSOUND
        ClearOptions()
        CastSpell(_spells[selected], global.turn)
    } else { InjectLog("Not enough PP to cast this!") 
		audio_play_sound()}
}
