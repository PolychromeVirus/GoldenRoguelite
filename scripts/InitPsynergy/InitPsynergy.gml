
function InitPsynergy(){
	global.psynergylist = []
	
	//if file_exists("C:\Users\polyc\AppData\Roaming\PolychromeData\PsynergyImport.csv") == false{
	//	global.errormessage = "Import Failed! File not found."
	//	return undefined
	//}
	
	
	var psy_grid = load_csv("PsynergyImport.csv");
	
	for (var i = 1; i < ds_grid_height(psy_grid); i++){
		var temppsy = {
			element: psy_grid[# 0, i],
			name: psy_grid[# 1, i],
			cost: real(psy_grid[# 3, i]),
			range: psy_grid[# 4, i],
			targetType: psy_grid[# 5, i],
			stage: real(psy_grid[# 6, i]),
			maxstage: real(psy_grid[# 7, i]),
			base: psy_grid[# 8, i],
			damage: psy_grid[# 10, i],
			alias: psy_grid[# 2, i],
			text: string_replace_all(psy_grid[# 13, i],"\\n","\n"),
			character: psy_grid[# 12, i],
			mode: psy_grid[# 9, i] == ""? "battle" : psy_grid[# 9, i],
		}
		
		array_push(global.psynergylist,temppsy)
		
	}
	
	ds_grid_destroy(psy_grid)
}