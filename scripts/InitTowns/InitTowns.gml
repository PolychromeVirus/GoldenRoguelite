function InitTowns() {
	global.townlist = []

	var _grid = load_csv("TownsImport.csv")

	for (var i = 1; i < ds_grid_height(_grid); i++) {
		var _finds = []
		if (_grid[# 3, i] != "") { array_push(_finds, _grid[# 3, i]) }
		if (_grid[# 4, i] != "") { array_push(_finds, _grid[# 4, i]) }

		var _town = {
			chapter: real(_grid[# 0, i]),
			name: _grid[# 1, i],
			alias: _grid[# 2, i],
			finds: _finds,
			wpn_price: (_grid[# 5, i] != "") ? real(_grid[# 5, i]) : 0,
			arm_price: (_grid[# 6, i] != "") ? real(_grid[# 6, i]) : 0,
			itm_price: (_grid[# 7, i] != "") ? real(_grid[# 7, i]) : 0,
			art_price: (_grid[# 8, i] != "") ? real(_grid[# 8, i]) : 0,
			psy_price: (_grid[# 9, i] != "") ? real(_grid[# 9, i]) : 0,
			sum_price: (_grid[# 10, i] != "") ? real(_grid[# 10, i]) : 0,
			quote: (_grid[# 11, i] != "") ? string_replace_all(_grid[# 11, i], "\\n", "\n") : ""
		}

		array_push(global.townlist, _town)
	}

	ds_grid_destroy(_grid)
}
