// Global left press — check confirm/cancel clicks and dice selection
var mx = device_mouse_x_to_gui(0)
var my = device_mouse_y_to_gui(0)

// Check confirm
if instance_exists(objConfirm) and instance_position(mouse_x, mouse_y, objConfirm) {
	var player = global.players[global.turn]
	var selections = []

	for (var i = 0; i < array_length(dice); i++) {
		if dice[i].selected {
			array_push(selections, { pool: dice[i].pool, index: dice[i].index })
		}
	}

	if array_length(selections) > 0 {
		RerollDice(player, selections)
		InjectLog(player.name + " rerolled " + string(array_length(selections)) + " dice!")
	}

	confirmed = true
	instance_destroy()
	DeleteButtons()
	CreateOptions()
	exit
}

// Check cancel
if instance_exists(objCancel) and instance_position(mouse_x, mouse_y, objCancel) {
	if objCancel.clickable {
		global.pendingPPCost = 0
		global.textdisplay = ""
		DestroyAllBut()
		CreateOptions()
		ClearOptions()
	}
	exit
}

// Check dice click (hit-test against GUI coordinates)
var dicesize = 44
var dicepad = 8
var startx = 50
var starty = 260

var cx = startx
for (var i = 0; i < array_length(dice); i++) {
	if mx >= cx and mx <= cx + dicesize and my >= starty and my <= starty + dicesize {
		if dice[i].selected {
			dice[i].selected = false
			selected_count--
		} else if selected_count < maxsel {
			dice[i].selected = true
			selected_count++
		}
		break
	}
	cx += dicesize + dicepad
}
