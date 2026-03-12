// Confirm trade
if instance_position(mouse_x, mouse_y, objConfirm) {
	var _source = global.players[sourcePlayer]
	var _target = global.players[selected]
	var _djinnName = global.djinnlist[sourceDjinn].name

	if targetSlot < array_length(_target.djinn) {
		// Swap: exchange djinn between players
		var _targetDjinnID = _target.djinn[targetSlot]
		var _targetDjinnName = global.djinnlist[_targetDjinnID].name

		// Perform the swap
		_source.djinn[sourceSlot] = _targetDjinnID
		_target.djinn[targetSlot] = sourceDjinn

		InjectLog(_source.name + " traded " + _djinnName + " for " + _target.name + "'s " + _targetDjinnName + "!")
	} else {
		// Give: one-way transfer
		array_delete(_source.djinn, sourceSlot, 1)
		array_push(_target.djinn, sourceDjinn)

		InjectLog(_source.name + " gave " + _djinnName + " to " + _target.name + "!")
	}

	// Rebuild dice pools for affected players
	CreateDicePool()

	DeleteButtons()
	instance_destroy()
}
