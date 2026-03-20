function ProcessPostBattleQueue() {
	if array_length(global.postBattleQueue) > 0 {
		var _event = global.postBattleQueue[0]
		array_delete(global.postBattleQueue, 0, 1)
		var _name = global.itemcardlist[_event.item].name
		// Execute the onDraw effect
		OnUse(_event.item, -1, _event.player)
		// Elemental Star and Summon Tablet spawn draft UIs which call ProcessPostBattleQueue on dismiss.
		// All other effects (coins, psynergy stone) continue immediately.
		if _name != "Elemental Star" and _name != "Summon Tablet" {
			ProcessPostBattleQueue()
		}
	} else {
		// Mark the fought challenge as completed
		if (global.activeChallengeIndex >= 0 && global.activeChallengeIndex < array_length(global.floorChallenges)) {
			var _ch = global.floorChallenges[global.activeChallengeIndex]
			_ch.completed = true
			if (_ch.unique && _ch.override_name != "") {
				array_push(global.defeatedMiniBosses, _ch.override_name)
			}
			global.activeChallengeIndex = -1
		}
		// Mini-boss set drops (djinn bosses, mimics)
		if array_length(global.miniBossDrops) > 0 {
			var _drop = global.miniBossDrops[0]
			array_delete(global.miniBossDrops, 0, 1)
			if _drop == "djinn_draft" {
				DjinnDraft()
			} else if _drop == "choice_draw" {
				array_push(global.choiceDrawQueue, { player: global.players[0] })
				array_push(global.choiceDrawQueue, { player: global.players[1] })
				array_push(global.choiceDrawQueue, { player: global.players[2] })
				array_push(global.choiceDrawQueue, { player: global.players[3] })
				ProcessChoiceDrawQueue()
			}
			return
		}
		CreateOptions()
		Autosave()
	}
}
