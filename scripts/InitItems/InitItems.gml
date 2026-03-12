// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InitItems(){
	global.itemlist = []
	
	//if file_exists("C:\Users\polyc\AppData\Roaming\PolychromeData\PsynergyImport.csv") == false{
	//	global.errormessage = "Import Failed! File not found."
	//	return undefined
	//}
	
	
	var item_grid = load_csv("ItemImport.csv");
	
	for (var i = 1; i < ds_grid_height(item_grid); i++){
		var tempitem = {
			name: item_grid[# 0, i],
			alias: item_grid[# 1, i],
			type: item_grid[# 2, i],
			text: string_replace_all(item_grid[# 3, i],"\\n","\n"),
			num: item_grid[# 4, i],
			onDraw: item_grid[# 5, i] == "TRUE"
		}
		
		array_push(global.itemlist,tempitem)
		
	}
	
	ds_grid_destroy(item_grid)
}