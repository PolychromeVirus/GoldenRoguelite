
function InitDjinn(){
	global.djinnlist = []
	
	//if file_exists("C:\Users\polyc\AppData\Roaming\PolychromeData\PsynergyImport.csv") == false{
	//	global.errormessage = "Import Failed! File not found."
	//	return undefined
	//}
	
	
	var djinn_grid = load_csv("DjinnImport.csv");
	
	for (var i = 1; i < ds_grid_height(djinn_grid); i++){
		var tempdjinn = {
			element: djinn_grid[# 0, i],
			name: djinn_grid[# 1, i],
			text: string_replace_all(djinn_grid[# 2, i], "\\n", "\n"),
			chapter: djinn_grid[# 3, i],
			starts_ready: real(djinn_grid[# 4, i]),
			can_recover: real(djinn_grid[# 5, i]),
			ready: real(djinn_grid[# 4, i]) == 1,
			spent: real(djinn_grid[# 4, i]) == 0,
			just_unleashed: false
		}
		
		array_push(global.djinnlist,tempdjinn)
		
	}
	
	ds_grid_destroy(djinn_grid)
}