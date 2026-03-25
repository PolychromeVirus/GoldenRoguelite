/// LevelUp([playerIndex])
/// Call with no argument (or -1) to queue all 4 players. Pass a specific index to level up just that character.
function LevelUp(playerIndex = -1) {
	// Build the queue
	global.draftQueue = []
	
	if playerIndex == -1 {
		for (var i = 0; i < array_length(global.players); i++) {
			array_push(global.draftQueue, i)
		}
	} else {
		array_push(global.draftQueue, playerIndex)
	}

	_DraftNext()
}

/// Pops the next player from global.draftQueue and opens their draft (or ends if empty).
function _DraftNext() {
	if array_length(global.draftQueue) == 0 {
		
		
		
		if (global.inBossRewards) {
			_AdvanceBossRewardQueue()
		} else if (global.inTown) {
			ProcessTownFinds()
		} else {
			// Reveal: 10% chance of bonus level up when all drafts are done
			if !irandom(9) {
				var _cast = FindSpellCaster("Reveal")
				if _cast != -1 {
					SpellPrompt("Reveal", _cast,
						function() { LevelUp() },
						function() {}
					)
					return
				}
			}
			
		}
		return
	}
	
	
	
	
	var _idx = global.draftQueue[0]
	array_delete(global.draftQueue, 0, 1)
	var player = global.players[_idx]

	if player.learnsPsynergy {
		// Build draft pool: collect unique base spell names, resolve to next learnable stage
		var _bases = []
		var _baseSet = ds_map_create()

		for (var i = 0; i < array_length(global.psynergylist); i++) {
			var _spell = global.psynergylist[i]
			var _base = _spell.base

			// Skip if already collected this base
			if ds_map_exists(_baseSet, _base) { continue }

			// Skip character-locked spells belonging to other characters
			if _spell.character != "" and _spell.character != player.name { continue }

			ds_map_add(_baseSet, _base, true)

			// Count how many stages of this base the player already knows
			var _stagesKnown = 0
			for (var j = 0; j < array_length(player.spells); j++) {
				if global.psynergylist[player.spells[j]].base == _base {
					_stagesKnown++
				}
			}

			// If already at maxstage, exclude
			if _stagesKnown >= _spell.maxstage { continue }

			// Resolve the next stage ID
			var _nextStage = _stagesKnown + 1
			var _id = FindPsyID(_base, _nextStage)
			if _id != 0 {
				array_push(_bases, _id)
			}
		}

		ds_map_destroy(_baseSet)

		// Shuffle eligible spells (Fisher-Yates)
		var _len = array_length(_bases)
		if _len == 0{return}
		for (var i = _len - 1; i > 0; i--) {
			var j = irandom(i)
			var _tmp = _bases[i]
			_bases[i] = _bases[j]
			_bases[j] = _tmp
		}

		// Take up to 10
		var _poolSize = min(_len, 10)
		global.draftPool = []
		for (var i = 0; i < _poolSize; i++) {
			array_push(global.draftPool, _bases[i])
		}

		global.draftPlayerIndex = _idx
		PushMenu(objMenuCarousel, _BuildPsynergyDraftConfig())
	} else {
		// Non-psynergy character — placeholder for gimmick characters
		switch player.name {
			default: break
		}
		// Skip to next in queue
		_DraftNext()
	}
}
