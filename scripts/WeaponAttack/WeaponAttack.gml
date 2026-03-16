// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function WeaponAttack(unleash = true, attack = true, splash = -1){
	if instance_exists(objStatDisplay) { objStatDisplay.viewPlayer = global.turn }

	if attack and instance_number(objMonsterTarget) > 0 {
		DeleteButtons()
		exit
	}
	var _struct = variable_clone(global.AggressionSchema)
	if attack{
		DestroyAllBut()
		DeleteButtons()
	}
	var player      = global.players[global.turn]
	var weapon_type = global.itemcardlist[player.weapon].type
	var _atkmod = variable_clone(player.atkmod)
	
	if player.name == "Garet" or player.name == "Tyrell"{
	
		_atkmod *= 2
	
	}
	
	var dam         = player.matk_only ? QueryDice(player, "melee", "charge") : QueryDice(player, "melee", "charge") + player.atk + _atkmod
	if weapon_type != "Staff"{dam+=QueryDice(player, "elemental", "charge")}
	if weapon_type == "Mace"{dam+=QueryDice(player, "all","charge")}
	
	global.pendingPPCost = 0
	var _type = _struct.dmgtype
	var _num = _struct.num
	
	if player.name == "Flint" or player.name == "Cannon" or player.name == "Sleet" or player.name == "Waft"{
	
		dam = QueryDice(player, "all","charge") + player.atk + player.atkmod
		_type = string_lower(player.element)
	
	
	}
	

	var _unleash = CheckUnleash(player)

	var _statuses = _struct.statuses
	
	
	
	
	if _unleash.active and unleash{
		dam += _unleash.dam_bonus
		if _unleash.double_atk { dam += player.atk + player.atkmod }
		if _unleash.name == "Swift Blade" { dam *= 3 }
		if _unleash.convert_element != "" { _type = _unleash.convert_element }
		if _unleash.num > 1 { _num = _unleash.num }
		_statuses = _unleash.statuses
		if attack{InjectLog(_unleash.name + " unleashed!")}
	}
	
	
	
	_struct.dam = dam;_struct.num = _num; _struct.dmgtype = _type; _struct.statuses = _statuses
	_struct.unleash = _unleash
	
	_struct.splash = splash
	_struct.source = "attack"
	if player.name == "Piers"{_struct.statuses.inflict_mark = true}
	if player.name == "Eddy"{_struct.statuses.inflict_defdown += 1}
	if attack{SelectTargets(_struct)}

	return _struct
}

/// @func QueueOnAttack()
/// @desc After a weapon attack resolves, check if the caster has onAttack effects and queue follow-ups
function QueueOnAttack() {
	var _player = global.players[global.turn]
	if (!is_array(_player.onAttack) || array_length(_player.onAttack) == 0) {return}

	for (var _i = 0; _i < array_length(_player.onAttack); _i++) {
		var _effect = _player.onAttack[_i]

		// Condition check (e.g. "two6" = need two 6s in dice pool)
		if (variable_struct_exists(_effect, "condition")) {
			if (_effect.condition == "two6") {
				var _flat = []
				for (var _pi = 0; _pi < 5; _pi++) {
					for (var _di = 0; _di < array_length(_player.dicepool[_pi]); _di++) {
						array_push(_flat, _player.dicepool[_pi][_di])
					}
				}
				var _sixes = 0
				for (var _si = 0; _si < array_length(_flat); _si++) {
					if (_flat[_si] == 6) _sixes++
				}
				if (_sixes < 2) continue
			}
		}

		var _follow = variable_clone(global.AggressionSchema)
		_follow.caster = _player
		_follow.source = "onAttack"
		_follow.dam = 0

		// Copy effect fields onto the follow-up struct
		var _keys = variable_struct_get_names(_effect)
		for (var _ki = 0; _ki < array_length(_keys); _ki++) {
			var _k = _keys[_ki]
			if (_k == "condition") continue
			variable_struct_set(_follow, _k, _effect[$ _k])
		}

		InjectLog(_player.name + "'s equipment activates!")
		array_push(global.attackQueue, _follow)
	}
}
