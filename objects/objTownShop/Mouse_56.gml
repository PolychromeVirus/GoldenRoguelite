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
if (instance_position(mouse_x, mouse_y, objConfirm)) {
	if (array_length(shoplist) > 0 && selected >= 0 && selected < array_length(shoplist)) {
		var _entry = shoplist[selected]

		if (global.gold < _entry.price) {
			InjectLog("Not enough gold!")
		} else {
			var _bought = false

			switch (_entry.category) {
				case "Item":
				case "Weapon":
				case "Armor":
					// Find first player with a free inventory slot
					var _target = -1
					for (var _p = 0; _p < array_length(global.players); _p++) {
						if (array_length(global.players[_p].inventory) < 5) {
							_target = _p
							break
						}
					}
					if (_target == -1) {
						InjectLog("All inventories are full!")
					} else {
						array_push(global.players[_target].inventory, _entry.id)
						var _dIdx = array_get_index(global.discard, _entry.id)
						if (_dIdx >= 0) { array_delete(global.discard, _dIdx, 1) }
						_bought = true
						InjectLog(global.players[_target].name + " received " + _entry.name)
					}
					break

				case "Artifact":
					// Same as Weapon but artifacts don't come from discard pile
					var _target = -1
					for (var _p = 0; _p < array_length(global.players); _p++) {
						if (array_length(global.players[_p].inventory) < 5) {
							_target = _p
							break
						}
					}
					if (_target == -1) {
						InjectLog("All inventories are full!")
					} else {
						array_push(global.players[_target].inventory, _entry.id)
						_bought = true
						InjectLog(global.players[_target].name + " received " + _entry.name)
					}
					break

				case "Psynergy":
					// Enter character pick mode
					psy_pending = selected
					DeleteButtons()
					var _btn_objs = [objButton2, objButton3, objButton4, objButton5]
					for (var _p = 0; _p < array_length(global.players); _p++) {
						var _pi = global.players[_p]
						var _spr = { image: _pi.portrait, text: _pi.name, psy_player: _p }
						instance_create_depth(BUTTON1 + (_p * 28), BOTTOMROW, 0, _btn_objs[_p], _spr)
					}
					instance_create_depth(BUTTON5, BOTTOMROW, 0, objCancel)
					break

				case "Summon":
					if (array_contains(global.knownSummons, _entry.id)) {
						InjectLog("Already know this summon!")
					} else {
						array_push(global.knownSummons, _entry.id)
						_bought = true
					}
					break
			}

			if (_bought) {
				global.gold -= _entry.price
				InjectLog("Bought " + _entry.name + " for " + string(_entry.price) + "g")

				// Update shop entry
				_entry.count--
				if (_entry.count <= 0) {
					array_delete(shoplist, selected, 1)
					if (selected >= array_length(shoplist)) { selected = array_length(shoplist) - 1 }
				}
			}
		}
	}
}

// Leave
if (instance_position(mouse_x, mouse_y, objCancel)) {
	global.inTown = false
	global.currentTown = -1
	global.pause = false

	// Restore overworld background to dungeon default
	var _bg_layer = layer_background_get_id(layer_get_id("Background"))
	var _dun_bg = global.dungeonlist[global.dungeon].background
	layer_background_sprite(_bg_layer, _dun_bg)
	DeleteButtons()
	instance_destroy()
	CreateOptions()
}