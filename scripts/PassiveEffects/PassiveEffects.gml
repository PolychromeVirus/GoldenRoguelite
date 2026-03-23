
//damage_cap_1 - all damage capped at 1
//damage_half - final damage halved
//_mud - reduces enemy move roll index (ExecuteMonsterTurn)
//_vine - skips attempt targeting (RunEnemyPhase)
//_DjinnEcho - djinni effects from range 1 > 3 (UnleashDjinn)
//_Resonate - increase damage or range of multi-target spells (CastSpell + objResonatePicker)
//_melee - increase all melee pools by amt (CreateDicePool, used by Kindle)
//_element - increase player's own element pool by amt (CreateDicePool, used by Steam)


function AddPassive(effect, countdown, sprite, source, data, casterID = global.turn) {
	for (var _i = 0; _i < array_length(global.passiveEffects); _i++) {
		if global.passiveEffects[_i].effect == effect {
			if countdown != -1 { global.passiveEffects[_i].countdown += countdown }
			show_debug_message("AddPassive: stacked " + effect + " (countdown=" + string(global.passiveEffects[_i].countdown) + ")")
			return
		}
	}
	var passive = {
		effect: effect,
		countdown: countdown,
		sprite: sprite,
		source: source,
		data: data,
		casterID: casterID,
		fresh: true
	}
	array_push(global.passiveEffects, passive)
	show_debug_message("AddPassive: " + effect + " from " + source + " (countdown=" + string(countdown) + ")")
}

/// @function TickPassives()
/// @desc Tick regen effects, decrement countdowns, remove expired passives
function TickPassives() {
	// Tick regen effects before decrementing
	for (var i = 0; i < array_length(global.passiveEffects); i++) {
		var p = global.passiveEffects[i]
		if p.effect == "regen" {
			var amt = variable_struct_exists(p.data, "amount") ? p.data.amount : 1
			for (var j = 0; j < array_length(global.players); j++) {
				if global.players[j].hp > 0 {
					var _regen_amt = amt
					if (global.players[j].halfheal and _regen_amt > 0) { _regen_amt = floor(_regen_amt / 2) }
					global.players[j].hp = min(global.players[j].hp + _regen_amt, global.players[j].hpmax)
				}
			}
			InjectLog("Regen heals party for " + string(amt) + "!")
		}
	}

	// Decrement countdowns and remove expired
	for (var i = array_length(global.passiveEffects) - 1; i >= 0; i--) {
		var p = global.passiveEffects[i]
		if p.countdown == -1 { continue } // permanent
		p.countdown--
		if p.countdown <= 0 {
			InjectLog(p.effect + " from " + p.source + " wore off!")
			array_delete(global.passiveEffects, i, 1)
		}
	}
}

function TickPassiveForChar(char) {
	//Tick down passives owned by the chosen player (end of round is calculated as this player's turn)
	for (var i = array_length(global.passiveEffects) - 1; i >= 0; i--) {
	    if global.passiveEffects[i].casterID == char {
			var p = global.passiveEffects[i]
			if p.countdown == -1 { continue } // permanent
			if p.fresh { p.fresh = false; continue } // skip turn applied
			p.countdown--
			if p.countdown <= 0 {
				InjectLog(p.effect + " from " + p.source + " wore off!")
				array_delete(global.passiveEffects, i, 1)
			}
		}
	}
	var _char = global.players[char]
	//clear effects controlled by outgoing player
	if _char.cloaking < 5 and !_char.cloak_fresh{
		global.players[_char.cloaking].cloak = false
		InjectLog(global.players[_char.cloaking].name + " became visible!")
		_char.cloaking = 5
	}else if _char.cloaking < 5 and _char.cloak_fresh{_char.cloak_fresh = false}

}

/// @function CheckPassive(effect)
/// @desc Returns first matching passive struct, or undefined
function CheckPassive(effect) {
	for (var i = 0; i < array_length(global.passiveEffects); i++) {
		if global.passiveEffects[i].effect == effect {
			return global.passiveEffects[i]
		}
	}
	return undefined
}

/// @function CheckPassiveAll(effect)
/// @desc Returns array of ALL matching passives (for stacking)
function CheckPassiveAll(effect) {
	var result = []
	for (var i = 0; i < array_length(global.passiveEffects); i++) {
		if global.passiveEffects[i].effect == effect {
			array_push(result, global.passiveEffects[i])
		}
	}
	return result
}

/// @function RemovePassive(effect, source)
/// @desc Remove passives by effect+source. If source="", remove all of that effect.
function RemovePassive(effect, source) {
	for (var i = array_length(global.passiveEffects) - 1; i >= 0; i--) {
		var p = global.passiveEffects[i]
		if p.effect == effect {
			if source == "" or p.source == source {
				array_delete(global.passiveEffects, i, 1)
			}
		}
	}
}


