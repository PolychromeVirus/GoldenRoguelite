// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InitArmor(){
	global.armorlist = []
	
	//if file_exists("C:\Users\polyc\AppData\Roaming\PolychromeData\PsynergyImport.csv") == false{
	//	global.errormessage = "Import Failed! File not found."
	//	return undefined
	//}
	
	
	var armor_grid = load_csv("ArmorImport.csv");
	
	for (var i = 1; i < ds_grid_height(armor_grid); i++){
		// Parse break_die from @[dNbreak] tag in text
		var _text = armor_grid[# 4, i]
		var _break_die = 0
		var _bpos = string_pos("break]", _text)
		if (_bpos > 0) {
			// Find the @[d before break] — scan backwards for "d"
			var _search = string_copy(_text, 1, _bpos - 1)
			var _dpos = string_last_pos("@[d", _search)
			if (_dpos > 0) {
				var _numstr = string_copy(_text, _dpos + 3, _bpos - _dpos - 3)
				_break_die = real(_numstr)
			}
		}

		var temparmor = {
			name: armor_grid[# 0, i],
			alias: armor_grid[# 1, i],
			slot: armor_grid[# 2, i],
			cursed: armor_grid[# 3, i] == "TRUE",
			text: string_replace_all(armor_grid[# 4, i],"\\n","\n"),
			num: 1,
			type: "Armor",
			onDraw: false,
			break_die: _break_die
		}
		
		array_push(global.armorlist,temparmor)
		
	}
	
	ds_grid_destroy(armor_grid)
}