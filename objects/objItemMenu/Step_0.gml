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

	bottom_buttons = []
	if mode == 0 {
		// Inventory buttons
		var sprite = {image: yes, hovertext: "Use"}
		array_push(bottom_buttons, instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite))

		sprite = {image: Fight, text: "Equip"}
		array_push(bottom_buttons, instance_create_depth(BUTTON2, BOTTOMROW, 0, objButton2, sprite))

		if global.inTown {
			sprite = {image: Sell, text: "Sell/Discard"}
			array_push(bottom_buttons, instance_create_depth(BUTTON3, BOTTOMROW, 0, objButton3, sprite))
		} else if !global.inCombat {
			sprite = {image: Silver_Password, text: "Discard"}
			array_push(bottom_buttons, instance_create_depth(BUTTON3, BOTTOMROW, 0, objButton3, sprite))
		}
		if !global.inCombat {
			sprite = {image: Switch, text: "Give"}
			array_push(bottom_buttons, instance_create_depth(BUTTON4, BOTTOMROW, 0, objButton4, sprite))
		}

		array_push(bottom_buttons, instance_create_depth(BUTTON5, BOTTOMROW, 0, objCancel))

		sprite = {image: Artifacts, text: "Equipment"}
		instance_create_depth(OPTION1, TOPROW, 0, objButton5, sprite)
	} else {
		// Equipment buttons
		var sprite = {image: Fight, text: "Unequip"}
		array_push(bottom_buttons, instance_create_depth(BUTTON1, BOTTOMROW, 0, objButton2, sprite))

		array_push(bottom_buttons, instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel))

		sprite = {image: Buy, text: "Inventory"}
		instance_create_depth(OPTION1, TOPROW, 0, objButton5, sprite)
	}
	btn_selected = 0

	// Portrait buttons (both modes, out of combat only)
	if !global.inCombat {
		instance_create_depth(OPTION2, TOPROW, 0, objButton6, {image: global.players[others[0]].portrait, text: "Switch to " + global.players[others[0]].name, index: others[0]})
		instance_create_depth(OPTION3, TOPROW, 0, objButton7, {image: global.players[others[1]].portrait, text: "Switch to " + global.players[others[1]].name, index: others[1]})
		instance_create_depth(OPTION4, TOPROW, 0, objButton8, {image: global.players[others[2]].portrait, text: "Switch to " + global.players[others[2]].name, index: others[2]})
	}

	lastmode = mode
	otherslast = variable_clone(others)
}

// Keyboard / gamepad navigation
var _ilen = (mode == 0) ? array_length(global.players[global.turn].inventory) : 1 + array_length(global.players[global.turn].armor)
if InputPressed(INPUT_UP) and _ilen > 0 {
    selected = (selected == 0) ? _ilen - 1 : selected - 1
}
if InputPressed(INPUT_DOWN) and _ilen > 0 {
    selected = (selected == _ilen - 1) ? 0 : selected + 1
}
if InputPressed(INPUT_TAB) {
    mode = (mode == 0) ? 1 : 0
    selected = 0
}
var _blen = array_length(bottom_buttons)
if _blen > 0 {
    if InputPressed(INPUT_LEFT) {
        btn_selected = (btn_selected == 0) ? _blen - 1 : btn_selected - 1
    }
    if InputPressed(INPUT_RIGHT) {
        btn_selected = (btn_selected == _blen - 1) ? 0 : btn_selected + 1
    }
    btn_selected = clamp(btn_selected, 0, _blen - 1)
    // Highlight selected bottom button
    for (var _bi = 0; _bi < _blen; _bi++) {
        if instance_exists(bottom_buttons[_bi]) {
            bottom_buttons[_bi].image_blend = (_bi == btn_selected) ? c_ltgray : c_white
        }
    }
    if InputPressed(INPUT_CONFIRM) and clickable {
        with (bottom_buttons[btn_selected]) {
            event_perform(ev_mouse, ev_left_press)
        }
    }
}
