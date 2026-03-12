/// @desc Build flat list of all party djinn for Djinn Echo unleash
DeleteButtons()
instance_create_depth(sprite_width,sprite_height/2,0,objQuarterMenu)// Build list of {djinnID, ownerIndex} for all djinn across all players

allDjinn = []
for (var _p = 0; _p < array_length(global.players); _p++) {
	for (var _d = 0; _d < array_length(global.players[_p].djinn); _d++) {
		array_push(allDjinn, { djinnID: global.players[_p].djinn[_d], ownerIndex: _p })
	}
}

selected = 0

var sprite = { image: Djinni, text: "Unleash" }
instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite)
instance_create_depth(BUTTONRIGHT1, BOTTOMROW, 0, objCancel)
