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
		// Reveal: 10% chance of bonus djinn draft when all queues are empty
		if !irandom(9) and array_length(global.menu_stack) == 0 and array_length(global.choiceDrawQueue) == 0 {
			var _cast = FindSpellCaster("Reveal")
			if _cast != -1 {
				SpellPrompt("Reveal", _cast,
					function() { DjinnDraft() },
					function() {}
				)
				return
			}
		}
		CreateOptions()
		Autosave()
	}
}
