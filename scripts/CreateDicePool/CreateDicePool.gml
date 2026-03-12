// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function CreateDicePool(){
	for (var i = 0; i < array_length(global.players); i++){
		
		var currplayer = global.players[i]
		var weapon = global.itemcardlist[currplayer.weapon]
		var _native = currplayer.venus
		var _swap = false
		
		switch currplayer.name{
			case "Flint":
				_native = currplayer.venus
				_swap = true
				break
			case "Cannon":
				_native = currplayer.mars
				_swap = true
				break
			case "Waft":
				_native = currplayer.jupiter
				_swap = true
				break
			case "Sleet":
				_native = currplayer.mercury
				_swap = true
				break
			
				
		}
		
		currplayer.melee = 0
		currplayer.venus = 0
		currplayer.mars = 0
		currplayer.jupiter = 0
		currplayer.mercury = 0
		currplayer.cursed = false
		
		var _res = ""
		var _element = CheckPassive("_element")
		var _elementBoost = 0
		if _element != undefined{
			_elementBoost = _element.countdown
			
		}
		var _melee = CheckPassive("_melee")
		var _meleeBoost = 0
		if _melee != undefined{
			_meleeBoost = _melee.countdown
		}
		
		switch currplayer.element{
			case "Venus":
				currplayer.venus += 1
				currplayer.venus += weapon.elemental
				currplayer.venus += _elementBoost
				if currplayer.name == "Himi"{currplayer.venus += 1}
				_res = "vres"
				break
			case "Mars":
				currplayer.mars += 1
				currplayer.mars += weapon.elemental
				currplayer.mars += _elementBoost
				if currplayer.name == "Jenna"{currplayer.mars += 1}
				_res = "mares"
				break
			case "Jupiter":
				currplayer.jupiter += 1
				currplayer.jupiter += weapon.elemental
				currplayer.jupiter += _elementBoost
				_res = "jres"
				break
			case "Mercury":
				currplayer.mercury += 1
				currplayer.mercury += weapon.elemental
				currplayer.mercury += _elementBoost
				if currplayer.name == "Kai"{currplayer.mercury += 1}
				_res = "meres"
				break
		}
		
		currplayer.melee += weapon.melee
		currplayer.melee += _meleeBoost
		currplayer.venus += weapon.venus
		currplayer.mars += weapon.mars
		currplayer.jupiter += weapon.jupiter
		currplayer.mercury += weapon.mercury
		
		if currplayer.name == "Sean"{currplayer.melee += 1}
		if currplayer.name == "Sveta"{currplayer.melee += 1}
		
		
		var _warRingID = FindItemID("War Ring")
		var _warIdx = array_get_index(currplayer.armor, _warRingID)
		if (_warIdx >= 0 && !(_warIdx < array_length(currplayer.broken_armor) && currplayer.broken_armor[_warIdx])) {
			currplayer.melee += 1
		}

		for(var j = 0; j < array_length(currplayer.djinn); j++){
			if (global.djinnlist[currplayer.djinn[j]].ready || global.djinnlist[currplayer.djinn[j]].spent){
				switch global.djinnlist[currplayer.djinn[j]].element{
					case "Venus":
						currplayer.venus += 1
						break
					case "Mars":
						currplayer.mars += 1
						break
					case "Jupiter":
						currplayer.jupiter += 1
						break
					case "Mercury":
						currplayer.mercury += 1
						break
				}
			}
		}
		if currplayer.name == "Kraden"{currplayer.melee = 0
			currplayer.venus += 1
			currplayer.mars += 1
			currplayer.jupiter += 1
			currplayer.mercury += 1}
		if _swap{
		var _poolstore = variable_clone(currplayer.melee)
		currplayer.melee = variable_clone(currplayer.venus)
		currplayer.melee += variable_clone(currplayer.mars)
		currplayer.melee += variable_clone(currplayer.jupiter)
		currplayer.melee += variable_clone(currplayer.mercury)
		
		_native = _poolstore + 1
		
		switch currplayer.name{
			case "Flint":
				currplayer.venus = _native
				currplayer.mars = 0
				currplayer.jupiter = 0
				currplayer.mercury = 0
				break
			case "Cannon":
				currplayer.mars = _native
				currplayer.venus = 0
				currplayer.jupiter = 0
				currplayer.mercury = 0
				break
			case "Waft":
				currplayer.jupiter = _native
				currplayer.mars = 0
				currplayer.venus = 0
				currplayer.mercury = 0
				break
			case "Sleet":
				currplayer.mercury = _native
				currplayer.mars = 0
				currplayer.jupiter = 0
				currplayer.venus = 0
				break
		}
		}
		
		// Reset stats to base values before applying equipment
		currplayer.atk   = currplayer.base_atk
		currplayer.def   = currplayer.base_def
		currplayer.ppinc = currplayer.base_ppinc
		currplayer.hpmax = currplayer.base_hpmax
		currplayer.ppmax = currplayer.base_ppmax
		currplayer.ppdiscount = currplayer.base_ppdiscount
		currplayer.vres  = 0
		currplayer.mares = 0
		currplayer.jres  = 0
		currplayer.meres = 0
		
		if _res != ""{
			struct_set(currplayer,_res,max(floor(struct_get(currplayer,string_lower(currplayer.element)) / 2),1)) 
		}
		// Remove previously equipment-granted spells
		if variable_struct_exists(currplayer, "equip_spells") {
			for (var es = array_length(currplayer.equip_spells) - 1; es >= 0; es--) {
				var _idx = array_get_index(currplayer.spells, currplayer.equip_spells[es])
				if _idx >= 0 { array_delete(currplayer.spells, _idx, 1) }
			}
		}
		currplayer.equip_spells = []
		currplayer.onAttack = []

		for(var q=0;q<array_length(currplayer.armor);q++){
			// Skip broken armor entirely
			if (q < array_length(currplayer.broken_armor) && currplayer.broken_armor[q]) { continue }
			var arm = global.itemcardlist[currplayer.armor[q]]
			if (arm.cursed == true || arm.cursed == "TRUE") { currplayer.cursed = true }
			var itemcode = GetEquipInfo(arm.name, currplayer)
			// Remove array fields before key loop so StructMerge doesn't overwrite them
			var _equip_onAttack = itemcode[$ "onAttack"]
			variable_struct_remove(itemcode, "onAttack")
			variable_struct_remove(itemcode, "onDraw")
			variable_struct_remove(itemcode, "onRoll")
			var keys = variable_struct_get_names(itemcode)
			for (var l = array_length(keys)-1; l >= 0; l--) {
			    var k = keys[l];

				if k == "grants_spell" {
					var _sid = FindPsyID(itemcode[$ k], 1)
					if _sid >= 0 and !array_contains(currplayer.spells, _sid) {
						array_push(currplayer.spells, _sid)
						array_push(currplayer.equip_spells, _sid)
					}
				} else { StructMerge(currplayer,itemcode, false) }

				}

			// Concatenate onAttack effects from this armor piece
			if is_array(_equip_onAttack) {
				for (var _oai = 0; _oai < array_length(_equip_onAttack); _oai++) {
					array_push(currplayer.onAttack, _equip_onAttack[_oai])
				}
			} else if is_struct(_equip_onAttack) && variable_struct_names_count(_equip_onAttack) > 0 {
				array_push(currplayer.onAttack, _equip_onAttack)
			}
			}
		}

		// Clamp current HP/PP to new max (in case equipment changed max)
		if currplayer.hp > currplayer.hpmax { currplayer.hp = currplayer.hpmax }
		if currplayer.pp > currplayer.ppmax { currplayer.pp = currplayer.ppmax }
		

}
