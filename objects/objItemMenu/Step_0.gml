if mode == 0 {
	// Inventory mode
	if selected > array_length(global.players[global.turn].inventory)-1{
		selected = array_length(global.players[global.turn].inventory)-1
	}
	if selected < 0{
		selected = 0
	}

	if array_length(global.players[global.turn].inventory) < 1{instance_destroy(objQuarterMenu)}else{

		if instance_number(objQuarterMenu) < 1{
			instance_create_depth(sprite_width,sprite_height/2,0,objQuarterMenu)
		}

	}
} else {
	// Equipment mode: weapon + armor
	var _equiplen = 1 + array_length(global.players[global.turn].armor)
	if selected > _equiplen - 1 { selected = _equiplen - 1 }
	if selected < 0 { selected = 0 }

	if instance_number(objQuarterMenu) < 1{
		instance_create_depth(sprite_width,sprite_height/2,0,objQuarterMenu)
	}
}

// Rebuild others list
others = []
for (var i = 0; i < array_length(global.players); ++i) {
    if i != global.turn { array_push(others, i) }
}

// Rebuild buttons when mode or others changes
var _needsRebuild = (mode != lastmode) or !array_equals(others, otherslast)

if _needsRebuild {
	DeleteButtons()

	if mode == 0 {
		// Inventory buttons
		instance_create_depth(BUTTON5, BOTTOMROW, 0, objCancel)

		var sprite = {image: yes, hovertext: "Use"}
		instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite)

		sprite = {image: Fight, text: "Equip"}
		instance_create_depth(BUTTON2, BOTTOMROW, 0, objButton2, sprite)

		if global.inTown {
			sprite = {image: Sell, text: "Sell/Discard"}
			instance_create_depth(BUTTON3, BOTTOMROW, 0, objButton3, sprite)
		} else if !global.inCombat {
			sprite = {image: Silver_Password, text: "Discard"}
			instance_create_depth(BUTTON3, BOTTOMROW, 0, objButton3, sprite)
		}
		if !global.inCombat {
			sprite = {image: Switch, text: "Give"}
			instance_create_depth(BUTTON4, BOTTOMROW, 0, objButton4, sprite)
		}

		sprite = {image: Artifacts, text: "Equipment"}
		instance_create_depth(OPTION1, TOPROW, 0, objButton5, sprite)
	} else {
		// Equipment buttons
		instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel)

		var sprite = {image: Fight, text: "Unequip"}
		instance_create_depth(BUTTON1, BOTTOMROW, 0, objButton2, sprite)

		sprite = {image: Buy, text: "Inventory"}
		instance_create_depth(OPTION1, TOPROW, 0, objButton5, sprite)
	}

	// Portrait buttons (both modes, out of combat only)
	if !global.inCombat {
		instance_create_depth(OPTION2, TOPROW, 0, objButton6, {image: global.players[others[0]].portrait, text: "Switch to " + global.players[others[0]].name, index: others[0]})
		instance_create_depth(OPTION3, TOPROW, 0, objButton7, {image: global.players[others[1]].portrait, text: "Switch to " + global.players[others[1]].name, index: others[1]})
		instance_create_depth(OPTION4, TOPROW, 0, objButton8, {image: global.players[others[2]].portrait, text: "Switch to " + global.players[others[2]].name, index: others[2]})
	}

	lastmode = mode
	otherslast = variable_clone(others)
}