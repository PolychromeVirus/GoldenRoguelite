var _player = global.players[global.turn]

var _clicked = instance_position(mouse_x, mouse_y, objButton2)
if _clicked != noone and _clicked.object_index == objButton2 {
	if mode == 1 {
		// === EQUIPMENT MODE — Unequip ===
		if selected == 0 {
			InjectLog("You must always have a weapon equipped!")
		} else {
			var _armorIdx = selected - 1
			var _armorItem = _player.armor[_armorIdx]
			var _item = global.itemcardlist[_armorItem]

			if (_item.cursed == "TRUE" or _item.cursed == true) {
				InjectLog("This item is cursed and cannot be removed!")
			} else if array_length(_player.inventory) >= 5 {
				InjectLog("Inventory is full!")
			} else {
				array_delete(_player.armor, _armorIdx, 1)
				array_push(_player.inventory, _armorItem)
				CreateDicePool()
				if !global.inCombat{_player.dicepool = RollDice(_player)}
				selected = clamp(selected, 0, array_length(_player.armor))
			}
		}
	} else {
		// === INVENTORY MODE — Equip ===
		var _inv = _player.inventory
		if array_length(_inv) >= 1 {
			if selected >= array_length(_inv) { selected = array_length(_inv) - 1 }
			var SelectedItem = _inv[selected]

			if isEquippable(SelectedItem) {
				if global.itemcardlist[SelectedItem].type != "Armor" {
					var equippedweapon = string(_player.weapon)
					_player.weapon = SelectedItem
					array_delete(_player.inventory, selected, 1)
					array_push(_player.inventory, equippedweapon)
					CreateDicePool()
					if global.inCombat {
						ClearOptions()
						global.pause = false
						instance_destroy()
						instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
					}_player.dicepool = RollDice(_player)
				} else {
					var _itemSlot = global.itemcardlist[SelectedItem].slot
					var _conflictIdx = -1
					for (var i = 0; i < array_length(_player.armor); i++) {
						if global.itemcardlist[_player.armor[i]].slot == _itemSlot {
							_conflictIdx = i
							break
						}
					}

					if _conflictIdx >= 0 {
						instance_create_depth(0, 0, -100, objSwapPrompt, {
							new_item: SelectedItem,
							old_item: _player.armor[_conflictIdx],
							armor_index: _conflictIdx,
							inv_slot: selected
						})
					} else {
						if array_length(_player.armor) < 4 {
							array_push(_player.armor, SelectedItem)
						}
						array_delete(_player.inventory, selected, 1)
						CreateDicePool()
						if global.inCombat {
							ClearOptions()
							global.pause = false
							instance_destroy()
							instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
						}_player.dicepool = RollDice(_player)
					}
				}
			}
		}
	}
	
}

if mode == 0 {
	var _inv = _player.inventory
	if array_length(_inv) >= 1 {
		if selected >= array_length(_inv) { selected = array_length(_inv) - 1 }
		var SelectedItem = _inv[selected]

		if instance_position(mouse_x,mouse_y,objConfirm){
			if global.itemcardlist[SelectedItem].type == "Healing" or global.itemcardlist[SelectedItem].type == "Battle" or global.itemcardlist[SelectedItem].name == "Lucky Medal"{
				ClearOptions()
				DeleteButtons()
				OnUse(SelectedItem,selected,_player)
				instance_destroy()
			}
		}

		if instance_position(mouse_x,mouse_y,objButton3){
			var type = global.itemcardlist[SelectedItem].type
			var name = global.itemcardlist[SelectedItem].name
			if type != "Healing" and type != "Battle"{
				if global.inTown and name == "Orihalcon"{global.gold += 50}else if global.inTown{
					
					var _eoleo = false
					for (var e = 0; e < array_length(global.players); ++e) {
					    if global.players[e].name == "Eoleo" {_eoleo = true}
					}
					global.gold += _eoleo ? 5 : 2
					}
				
			}
			if array_length(_player.inventory) > 0{array_delete(_player.inventory,selected,1)}
		}

		if instance_position(mouse_x,mouse_y,objButton4){
			var _struct = variable_clone(global.AggressionSchema)
			_struct.trade = true
			_struct.target = "ally"
			_struct.itemid = SelectedItem
			_struct.slot = selected
			ClearOptions()
			instance_create_depth(0,TARGETHEIGHT,0,objCharTarget,_struct)
			instance_destroy()
		}
	}
}

if instance_position(mouse_x,mouse_y,objButton6) or instance_position(mouse_x,mouse_y,objButton7) or instance_position(mouse_x,mouse_y,objButton8){
	global.turn = instance_position(mouse_x,mouse_y,all).index
}

if instance_position(mouse_x,mouse_y,objButton5){
	if mode == 0 {
		mode = 1
		selected = 0
	} else if mode == 1 {
		mode = 0
		selected = 0
	}
}