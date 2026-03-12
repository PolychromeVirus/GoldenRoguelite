function InitSummon(){
	global.summonlist = []

	var summon_grid = load_csv("SummonImport.csv");

	for (var i = 1; i < ds_grid_height(summon_grid); i++){
		// Handle empty djinn cost cells as 0
		var _v = summon_grid[# 3, i]
		var _m = summon_grid[# 4, i]
		var _j = summon_grid[# 5, i]
		var _me = summon_grid[# 6, i]
		var _range = summon_grid[# 7, i]

		var tempsummon = {
			name: summon_grid[# 0, i],
			alias: summon_grid[# 1, i],
			element: summon_grid[# 2, i],
			venus: (_v == "" ? 0 : real(_v)),
			mars: (_m == "" ? 0 : real(_m)),
			jupiter: (_j == "" ? 0 : real(_j)),
			mercury: (_me == "" ? 0 : real(_me)),
			range: (_range == "x" or _range == "" ? 0 : real(_range)),
			targetType: summon_grid[# 8, i],
			base: summon_grid[# 9, i],
			text: string_replace_all(summon_grid[# 10, i], "\\n", "\n")
		}

		array_push(global.summonlist, tempsummon)
	}

	ds_grid_destroy(summon_grid)
}
