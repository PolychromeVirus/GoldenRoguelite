/// @function HandleVictory()
/// @desc Called from all victory paths. Checks for Catch prompt, then runs CombatCleanup + objPostBattle.
function HandleVictory() {
	global.attackQueue = []
	InjectLog("Combat Victory!")
	global.firstPlayer = global.turn
	global.inCombat = false
	global.catchBonus = -1

	var _catch_caster = FindSpellCaster("Catch")
	if (_catch_caster >= 0) {
		// Defer prompt to next frame so objMonsterTarget Destroy doesn't wipe it
		global._pendingCatchCaster = _catch_caster
		instance_create_depth(0, 0, 0, TurnDelay, { wait: 1, on_complete: function() {
			var _cc = global._pendingCatchCaster
			instance_create_depth(0, 0, -100, objSpellPrompt, {
				spell_name: "Catch",
				caster_index: _cc,
				on_confirm: method({ cc: _cc }, function() {
					global.catchBonus = cc
					global.pause = false
					CombatCleanup()
					ClearOptions()
					instance_create_depth(0, 0, -10, objPostBattle)
				}),
				on_decline: function() {
					global.pause = false
					CombatCleanup()
					ClearOptions()
					instance_create_depth(0, 0, -10, objPostBattle)
				}
			})
		}})
	} else {
		global.pause = false
		CombatCleanup()
		ClearOptions()
		instance_create_depth(0, 0, -10, objPostBattle)
	}
}

// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function CombatCleanup(){
	// Restore overworld background — use boss background on final floor
	var _bg_layer = layer_background_get_id(layer_get_id("Background"))
	var _dun = global.dungeonlist[global.dungeon]
	var _is_boss_floor = (global.dungeonFloor == array_length(global.dungeonFloors))
	var _dun_bg = _is_boss_floor ? _dun.boss_background : _dun.background
	layer_background_sprite(_bg_layer, _dun_bg)

	RollArmorBreaks()

	global.darken = false
	global.postBattleDraws = []
	global.postBattleQueue = []
	global.passiveEffects = []
	for (var i=0; i< array_length(global.players); i++){
		var curr = global.players[i]
		if (!global.noHealOnCombatEnd) {
			curr.hp += 1
			if curr.hp > curr.hpmax{curr.hp = curr.hpmax}
			curr.pp += 1
			if curr.pp > curr.ppmax{curr.pp = curr.ppmax}
		}

		ClearAllTokens(curr)
		
		// Recover spent djinn (spent → ready), in-recovery djinn stay
		for (var _d = 0; _d < array_length(curr.djinn); _d++) {
			var _dj = global.djinnlist[curr.djinn[_d]]
			if _dj.spent and _dj.starts_ready{
				_dj.ready = true
				_dj.spent = false
			}else if _dj.spent and !_dj.starts_ready{
				_dj.ready = false
				_dj.spent = true
			}
			_dj.just_unleashed = false
		}

		if (!global.enemyFled) {
			var _itemIndex = global.deck[0]
			var _cardData = DrawCard(curr)
			var _cardName = _cardData[0]
			var _discarded = _cardData[1]
			array_push(global.postBattleDraws, {player_index: i, card_name: _cardName, item_index: _itemIndex, discarded: _discarded})
		}
	}
	if (!global.enemyFled) {
		DiscardCard()

		// Catch bonus: extra card draw for the caster
		if (global.catchBonus >= 0) {
			var _cc = global.catchBonus
			var _extraIndex = global.deck[0]
			var _extraData = DrawCard(global.players[_cc])
			var _extraName = _extraData[0]
			var _extraDisc = _extraData[1]
			array_push(global.postBattleDraws, {player_index: _cc, card_name: _extraName, item_index: _extraIndex, discarded: _extraDisc})
			global.catchBonus = -1
		}
	}
	global.enemyFled = false
}