var _player = global.players[global.turn]

if instance_position(mouse_x, mouse_y, objConfirm) {
	// Perform the swap
	var _oldArmor = _player.armor[armor_index]

	// Remove old armor from equipped, add to inventory
	array_delete(_player.armor, armor_index, 1)
	array_push(_player.inventory, _oldArmor)

	// Remove new armor from inventory, add to equipped
	array_delete(_player.inventory, inv_slot, 1)
	array_push(_player.armor, new_item)

	CreateDicePool()
	ClearOptions()

	if global.inCombat {
		global.pause = false
		instance_destroy()
		instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
	} else {
		CreateOptions()
		instance_create_depth(0, 0, 0, objItemMenu)
		instance_destroy()
	}
}

if instance_position(mouse_x, mouse_y, objCancel) {
	ClearOptions()
	CreateOptions()
	instance_create_depth(0, 0, 0, objItemMenu)
	instance_destroy()
}