function StatUp(char){
	var _cur = char.curve

	switch _cur{
		case 1://offensive/ravager curve
			var _hp = (global.dungeon == 0) ? 10 : 5
			char.base_hpmax += _hp
			char.base_ppmax += 5
			char.base_atk += 1
			break
		case 2://all-rounder curve
			var _hp = (global.dungeon == 0) ? 7 : 5
			var _pp = (global.dungeon == 0) ? 7 : 5
			char.base_hpmax += _hp
			char.base_ppmax += _pp
			if global.dungeon == 0 or global.dungeon == 2 {char.base_atk += 1}
			break
		case 3://mage curve
			var _pp = (global.dungeon == 0) ? 10 : 5
			char.base_hpmax += 5
			char.base_ppmax += _pp
			if global.dungeon == 1 {char.base_atk += 1}
			break
	}

	// Apply base to current and restore resources
	char.hpmax = char.base_hpmax
	char.ppmax = char.base_ppmax
	char.atk = char.base_atk
	char.hp = char.hpmax
	char.pp = char.ppmax
}
