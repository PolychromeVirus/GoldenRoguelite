function ProcessTownFinds() {
	if (array_length(global.townFindQueue) > 0) {
		var _find = global.townFindQueue[0]
		array_delete(global.townFindQueue, 0, 1)

		switch (_find) {
			case "level":
				InjectLog("Town Reward! Level Up!")
				LevelUp()
				break
			case "djinni":
				InjectLog("Town Reward! Djinni!")
				DjinnDraft()
				break
			case "summon":
				InjectLog("Town Reward! Summon!")
				SummonDraft()
				break
			case "choice":
				InjectLog("Town Reward! Choice Draw!")
				global.choiceDrawQueue = []
				for (var _p = 0; _p < array_length(global.players); _p++) {
					DrawCard(global.players[_p], true)
				}
				DiscardCard()
				ProcessChoiceDrawQueue()
				break
		}
		// Note: LevelUp/DjinnDraft/SummonDraft UIs call ProcessTownFinds() on dismiss
	} else {
		// All finds processed — open shop
		
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
		
	}
}
