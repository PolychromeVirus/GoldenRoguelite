/// @func ElementColor(element_str)
/// @desc Return the global constant containing a given element's colour. White for normal/damage. (lowercase)
function ElementColor(element_str) {
	switch string_lower(element_str) {
		case "venus":   return global.c_venus
		case "mars":    return global.c_mars
		case "jupiter": return global.c_jupiter
		case "mercury": return global.c_mercury
		case "melee":   return c_white
		default:        return c_white
	}
}

function SelectTargets(struct){
	//passes through aggression struct
	
	struct.caster = global.players[global.turn]
	struct.dmgtype = string_lower(struct.dmgtype)
	
	if struct.caster.name == "Ivan" or struct.caster.name == "Karis"{
			StructMerge(struct.statuses,{locked: true}, false)
		}
	// Range 12 = target all enemies, skip the targeter
	if struct.num >= 12 and struct.target == "enemy" {
		var _monsters = []
		var _count = instance_number(objMonster)
		for (var _i = 0; _i < _count; _i++) {
			array_push(_monsters, instance_find(objMonster, _i))
		}
		struct.targets = _monsters
		// Deduct deferred PP cost (from CastSpell)
		if variable_global_exists("pendingPPCost") and global.pendingPPCost > 0 {
			global.players[global.pendingPPCaster].pp -= global.pendingPPCost
			global.pendingPPCost = 0
		}
		
		
		
		ApplyDamageToTargets(struct)
		return
	}
	if struct.num >= 4 and struct.target == "ally"{
		if struct.healing > 0 and (struct.caster.name == "Mia" or struct.caster.name == "Rief"){
			struct.healing += 1
		}
		for (var j = 0; j < array_length(global.players); ++j) {
			var _party_heal = struct.healing
			if (global.players[j].halfheal and _party_heal > 0) { _party_heal = floor(_party_heal / 2) }
			if _party_heal > 0 and (global.players[j].hp > 0 or struct.dmgtype == "mercury"){global.players[j].hp = min(global.players[j].hp + _party_heal, global.players[j].hpmax)}
		}
		instance_create_depth(0,0,0,TurnDelay,{wait: 30, on_complete: function(){NextTurn()}})
		return
	}
	if global.lastselected != -1{struct.selected = global.lastselected}

	if struct.target == "enemy" {instance_create_depth(0,0,0,objMonsterTarget, struct)}else{
		instance_create_depth(0,TARGETHEIGHT,0,objCharTarget, struct)}
}

/// @function ApplyDamageToTargets(struct)
/// @desc Apply damage + statuses to an array of monster instances, then check victory or NextTurn.
function ApplyDamageToTargets(struct) {
	global.textdisplay = ""
	
	
	DoDamage(struct)
	
	// Check victory
	var _any_alive = false
	var _count = instance_number(objMonster)
	for (var j = 0; j < _count; j++) {
		if instance_find(objMonster, j).monsterHealth != 0 {
			_any_alive = true
			break
		}
	}

	if _any_alive {
		global.inCombat = true
		global.pause = false
		NextTurn()
	} else {
		InjectLog("Combat Victory!")
		global.firstPlayer = global.turn
		global.inCombat = false
		global.pause = false
		CombatCleanup()
		ClearOptions()
		instance_create_depth(0, 0, -10, objPostBattle)
	}
}


