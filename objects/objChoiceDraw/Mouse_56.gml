if (instance_position(mouse_x, mouse_y, objConfirm)) {
	if (array_length(choices) > 0 && selected >= 0 && selected < array_length(choices)) {
		var _chosen = choices[selected]
		var _item = global.itemcardlist[_chosen]

		// Give chosen card to player
		if (array_length(draw_player.inventory) < 5 && !_item.onDraw) {
			array_push(draw_player.inventory, _chosen)
			InjectLog(draw_player.name + " chose " + _item.name)
		} else if (_item.onDraw) {
			array_push(global.postBattleQueue, { type: "onDraw", item: _chosen, player: draw_player })
			InjectLog(draw_player.name + " chose " + _item.name)
		} else {
			// Inventory full — discard
			array_push(global.discard, _chosen)
			InjectLog(draw_player.name + " chose " + _item.name + " but their inventory was full!")
		}

		// Return unchosen cards to deck and shuffle
		for (var i = 0; i < array_length(choices); i++) {
			if (i != selected) {
				array_push(global.deck, choices[i])
			}
		}
		global.deck = array_shuffle(global.deck)

		// Remove this entry from queue
		array_delete(global.choiceDrawQueue, 0, 1)

		// Continue queue or finish
		DeleteButtons()
		DestroyAllBut()
		ClearOptions()
		ProcessChoiceDrawQueue()
		instance_destroy()
	}
}

// Cancel — skip without picking (return all 3 to deck)
if (instance_position(mouse_x, mouse_y, objCancel)) {
	for (var i = 0; i < array_length(choices); i++) {
		array_push(global.deck, choices[i])
	}
	global.deck = array_shuffle(global.deck)

	array_delete(global.choiceDrawQueue, 0, 1)

	DeleteButtons()
	DestroyAllBut()
	ClearOptions()
	ProcessChoiceDrawQueue()
	instance_destroy()
}
