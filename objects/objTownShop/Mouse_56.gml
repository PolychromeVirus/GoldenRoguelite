if (!clickable) { exit }

// Character pick mode for psynergy
if (psy_pending >= 0) {
	var _picked = -1
	var _btn = instance_position(mouse_x, mouse_y, objButton2)
	if (_btn != noone && variable_instance_exists(_btn, "psy_player")) {
		_picked = _btn.psy_player
	}

	if (_picked >= 0) {
		var _entry = shoplist[psy_pending]
		var _player = global.players[_picked]
		if (array_contains(_player.spells, _entry.id)) {
			InjectLog(_player.name + " already knows " + _entry.name + "!")
		} else {
			array_push(_player.spells, _entry.id)
			global.gold -= _entry.price
			InjectLog(_player.name + " learned " + _entry.name + "!")

			_entry.count--
			if (_entry.count <= 0) {
				array_delete(shoplist, psy_pending, 1)
				if (selected >= array_length(shoplist)) { selected = array_length(shoplist) - 1 }
			}
			psy_pending = -1
			// Restore shop buttons
			DeleteButtons()
			var sprite = {image: Buy, text: "Buy"}
			instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite)
			instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel)
		}
	}

	// Cancel out of pick mode
	if (instance_position(mouse_x, mouse_y, objCancel)) {
		psy_pending = -1
		DeleteButtons()
		var sprite = {image: Buy, text: "Buy"}
		instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite)
		instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel)
	}
	exit
}

// Buy
if instance_position(mouse_x, mouse_y, objConfirm) { _do_buy() }

// Leave is handled by objCancel.Mouse_7 → on_cancel() + PopMenu() + CANCELSOUND