// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InitWeapons(){
	global.weaponlist = []
	
	//if file_exists("C:\Users\polyc\AppData\Roaming\PolychromeData\PsynergyImport.csv") == false{
	//	global.errormessage = "Import Failed! File not found."
	//	return undefined
	//}
	
	
	var weapon_grid = load_csv("WeaponImport.csv");
	
	for (var i = 1; i < ds_grid_height(weapon_grid); i++){
		var weapontext = string_replace_all(string(weapon_grid[# 10, i]) + " - " + string(weapon_grid[# 11, i]), "\\n", "\n")
		var tempweapon = {

			name: weapon_grid[# 0, i],
			alias: weapon_grid[# 1, i],
			type: weapon_grid[# 2, i],
			cursed: weapon_grid[# 3, i],
			melee: real(weapon_grid[# 4, i]),
			elemental: real(weapon_grid[# 5, i]),
			jupiter: real(weapon_grid[# 6, i]),
			mars: real(weapon_grid[# 7, i]),
			venus: real(weapon_grid[# 8, i]),
			mercury: real(weapon_grid[# 9, i]),
			text: weapontext,
			num: 1,
			onDraw: false,
			unleash: false
		}
		
		array_push(global.weaponlist,tempweapon)
		
	}
	
	ds_grid_destroy(weapon_grid)
}
