function InitPuzzles() {
	global.puzzlelist = []

	var _grid = load_csv("PuzzleImport.csv")

	for (var i = 1; i < ds_grid_height(_grid); i++) {
		var _puzzle = {
			name: _grid[# 0, i],
			spell_alias: _grid[# 1, i],
			disarm_text: string_replace_all(_grid[# 2, i], "\\n", "\n"),
			reward_text: string_replace_all(_grid[# 3, i], "\\n", "\n"),
			trap: (_grid[# 4, i] == "TRUE")
		}
		array_push(global.puzzlelist, _puzzle)
	}

	ds_grid_destroy(_grid)
}
