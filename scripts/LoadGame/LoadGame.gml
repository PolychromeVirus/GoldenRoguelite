function LoadGame(){
	if file_exists("Save.txt"){
		var _f = file_text_open_read("Save.txt")
		var _info = file_text_read_string(_f)
		file_text_close(_f)
		var _save = json_parse(_info)
		
		var names = variable_struct_get_names(_save);
		for (var i = 0; i < array_length(names); i++)
		{
		    var key = names[i];
    
		    if (variable_global_exists(key))
		    {
		        variable_global_set(key, variable_struct_get(_save, key));
		    }
		}
		
		
		//global.players = _save[0]
		//global.charselect = _save[1]
		//global.gold = _save[2]
		//global.postBattleQueue = _save[3]
		//global.knownSummons = _save[4]
		//global.deck = _save[5]
		//global.discard = _save[6]
		//global.floor = _save[7]

		//global.dungeon = _save[8]
		//global.dungeonFloor = _save[9]
		//global.floorChallenges = _save[10]
		//global.defeatedMiniBosses = _save[11]
		//global.onFloor = _save[12]
		//global.townVisited = _save[13]
		//global.dungeonFloors = _save[14]
		
		//global.hpcurse = _save[15]
		//global.rescurse = _save[16]
		//global.atkcurse = _save[17]
		
		// Reload dungeon troops for current dungeon
		if (array_length(global.dungeonlist) > global.dungeon) {
			var _dun = global.dungeonlist[global.dungeon]
			global.dungeonTroops = LoadTroopCSV(string_replace_all(_dun.name, " ", "_") + "_Troops.csv")
		}

		// Backfill base stats for old saves
		for (var _bi = 0; _bi < array_length(global.players); _bi++) {
			var _bp = global.players[_bi]
			if !variable_struct_exists(_bp, "base_hpmax") { _bp.base_hpmax = _bp.hpmax }
			if !variable_struct_exists(_bp, "base_ppmax") { _bp.base_ppmax = _bp.ppmax }
			if !variable_struct_exists(_bp, "base_ppdiscount") { _bp.base_ppdiscount = _bp.ppdiscount }
		}

		// Old saves without pre-generated floors: build them now
		if (array_length(global.dungeonFloors) == 0 && array_length(global.dungeonlist) > global.dungeon) {
			_PreGenerateFloors(global.dungeonlist[global.dungeon])
		}
		
		global.genbackground = global.dungeonlist[global.dungeon].background
		
		array_shuffle(global.deck)
		room_goto_next()
		
	}
}