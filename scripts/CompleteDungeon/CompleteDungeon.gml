function CompleteDungeon() {
	InjectLog("Dungeon Complete: " + global.dungeonlist[global.dungeon].name)

	// Stat growth (curves reference current dungeon index)
	for (var i = 0; i < array_length(global.players); i++) {
		StatUp(global.players[i])
	}

	// Reset all player inventories
	for (var i = 0; i < array_length(global.players); i++) {
		var _base = global.characterlist[global.players[i].charid]
		global.players[i].inventory = variable_clone(_base.inventory)
	}

	// Build boss item pool from itemcardlist
	var _bossPool = []
	for (var i = 0; i < array_length(global.itemcardlist); i++) {
		if (global.itemcardlist[i].type == "Boss") {
			array_push(_bossPool, i)
		}
	}

	// Draw 4 random boss items (with replacement)
	global.bossRewardQueue = []
	for (var i = 0; i < 4; i++) {
		var _pick = _bossPool[irandom(array_length(_bossPool) - 1)]
		array_push(global.bossRewardQueue, _pick)
	}

	global.inBossRewards = true
	global.pause = true
	_ShowNextBossReward()
}

/// Shows the next boss reward from the queue, or finishes if empty
function _ShowNextBossReward() {
	if (array_length(global.bossRewardQueue) == 0) {
		_FinishDungeonTransition()
		return
	}
	DeleteButtons()
	ClearOptions()
	DestroyAllBut()
	instance_create_depth(0, 0, 0, objBossRewardPicker)
}

/// Applies a boss item to the chosen player
function _ApplyBossItem(_item_id, _player_index) {
	var _item = global.itemcardlist[_item_id]
	var _p = global.players[_player_index]
	var _name = _item.name

	switch (_name) {
		case "Apple":
			_p.atk += 1
			_p.base_atk += 1
			InjectLog(_p.name + " gained +1 ATK!")
			break
		case "Cookie":
			_p.ppmax += 3
			_p.base_ppmax += 3
			InjectLog(_p.name + " gained +3 Max PP!")
			break
		case "Hard Nut":
			_p.def += 1
			_p.base_def += 1
			InjectLog(_p.name + " gained +1 DEF!")
			break
		case "Power Bread":
			_p.hpmax += 3
			_p.base_hpmax += 3
			_p.hp += 3
			InjectLog(_p.name + " gained +3 Max HP!")
			break
		case "Mint":
			_p.mint = true
			InjectLog(_p.name + " gained a permanent reroll!")
			break
		case "Lucky Medal":
			array_push(_p.inventory, _item_id)
			InjectLog(_p.name + " received " + _name + "!")
			break
		case "Orihalcon":
			array_push(_p.inventory, _item_id)
			InjectLog(_p.name + " received " + _name + "!")
			break
		case "Shiny Gem":
			InjectLog(_p.name + " gained a level!")
			// LevelUp spawns draft UI; on dismiss _DraftNext checks global.inBossRewards
			LevelUp(_player_index)
			exit  // Don't advance queue yet — LevelUp dismiss will call back
		case "Mystic Draught":
			InjectLog(_p.name + " drinks a Mystic Draught!")
			_StartMysticDraught(_player_index)
			exit  // Don't advance queue — spell picker dismiss will call back
	}

	// Advance to next reward
	_AdvanceBossRewardQueue()
}

/// Remove front of queue and show next
function _AdvanceBossRewardQueue() {
	if (array_length(global.bossRewardQueue) > 0) {
		array_delete(global.bossRewardQueue, 0, 1)
	}
	_ShowNextBossReward()
}

/// Mystic Draught: build list of upgradeable spells for this player, open draft
function _StartMysticDraught(_player_index) {
	var _p = global.players[_player_index]
	var _bases = []
	var _baseSet = ds_map_create()

	for (var i = 0; i < array_length(global.psynergylist); i++) {
		var _spell = global.psynergylist[i]
		var _base = _spell.base

		if ds_map_exists(_baseSet, _base) { continue }
		if _spell.character != "" and _spell.character != _p.name { continue }

		ds_map_add(_baseSet, _base, true)

		// Count stages the player knows
		var _stagesKnown = 0
		for (var j = 0; j < array_length(_p.spells); j++) {
			if global.psynergylist[_p.spells[j]].base == _base { _stagesKnown++ }
		}

		// Must know at least stage 1, and not be at max
		if _stagesKnown == 0 { continue }
		if _stagesKnown >= _spell.maxstage { continue }

		var _nextStage = _stagesKnown + 1
		var _id = FindPsyID(_base, _nextStage)
		if _id != 0 { array_push(_bases, _id) }
	}

	ds_map_destroy(_baseSet)

	if (array_length(_bases) == 0) {
		// No upgradeable spells — skip
		InjectLog("No spells to upgrade!")
		_AdvanceBossRewardQueue()
		return
	}

	// Reuse the PsynergyDraft object
	global.draftPool = _bases
	global.draftPlayerIndex = _player_index
	global.draftQueue = []  // Empty so _DraftNext finishes after one pick
	instance_create_depth(0, 0, 100, objPsynergyDraft)
}

/// Advances to the next dungeon after all boss rewards are assigned
function _FinishDungeonTransition() {
	global.inBossRewards = false
	global.pause = false
	DeleteButtons()
	DestroyAllBut()
	ClearOptions()

	if (global.dungeon + 1 < array_length(global.dungeonlist)) {
		StartDungeon(global.dungeon + 1)
		CreateOptions()
	} else {
		InjectLog("All dungeons cleared!")
		StartDungeon(0)
	}
}
