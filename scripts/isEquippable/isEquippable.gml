function isEquippable(item){
	var _player = global.players[global.turn]
	var itemtype = global.itemcardlist[item].type

	switch itemtype{
		case "Short Sword":
		case "Long Sword":
		case "Staff":
		case "Axe":
		case "Mace":
			// Check if player can wield this weapon type
			var _canEquip = false
			switch itemtype {
				case "Short Sword": _canEquip = _player.equipshort; break
				case "Long Sword": _canEquip = _player.equiplong; break
				case "Staff": _canEquip = _player.equipstaff; break
				case "Axe": _canEquip = _player.equipaxe; break
				case "Mace": _canEquip = _player.equipmace; break
			}
			if !_canEquip { return false }
			// Can't swap out a cursed weapon (unless in town)
			var _curWeapon = global.itemcardlist[_player.weapon]
			if ((_curWeapon.cursed == "TRUE" or _curWeapon.cursed == true) && !global.inTown) { return false }
			return true
			break

		case "Armor":
			var _itemSlot = global.itemcardlist[item].slot
			for (var i = 0; i < array_length(_player.armor); i++){
				if global.itemcardlist[_player.armor[i]].slot == _itemSlot {
					// Same slot occupied — allow swap unless existing piece is cursed (town overrides)
					var _existing = global.itemcardlist[_player.armor[i]]
					if ((_existing.cursed == "TRUE" or _existing.cursed == true) && !global.inTown) { return false }
					return true // Will trigger swap prompt
				}
			}
			// Empty slot — always allowed
			return true
			break
	}

	return false
}