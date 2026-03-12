
function InitMonsters(){
	global.monsterlist = []
	
	var mon_grid = load_csv("MonsterImport.csv");
	
	for (var i = 1; i < ds_grid_height(mon_grid); i++){
		var tempitem = {
			name: mon_grid[# 1, i],
			alias: asset_get_index(mon_grid[# 2, i]),
			element: mon_grid[# 0, i],
			maxhp: real(mon_grid[# 3, i]),
			monsterHealth: real(mon_grid[# 3, i]),
			weakness: mon_grid[# 4, i],
			boss: mon_grid[# 5, i] == "TRUE",
			poison: false,
			venom: false,
			stun: 0,
			sleep: false,
			delude: false,
			psyseal: false,
			atk:0,
			res:1,
			atkmod: 0,
			defmod: 0,
			atkmod_fresh: false,
			defmod_fresh: false,
			haunt: 0,
			lose_turn: false,
			locked: false,
			extra: false,
			mark: false,
		}
		if tempitem.alias == -1{tempitem.alias = Acid_Maggot}
		array_push(global.monsterlist,tempitem)
		
	}
	
	ds_grid_destroy(mon_grid)
}