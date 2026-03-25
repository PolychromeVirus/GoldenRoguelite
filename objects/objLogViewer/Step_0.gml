var _top = array_length(global.menu_stack) > 0 ? global.menu_stack[array_length(global.menu_stack)-1] : noone
if _top != id { exit }

var _n          = array_length(global.log)
var _max_scroll = max(0, _n - _visible_lines)

if InputPressed(INPUT_UP)   { scroll_offset = min(scroll_offset + 1, _max_scroll) }
if InputPressed(INPUT_DOWN) { scroll_offset = max(scroll_offset - 1, 0) }

var _wheel = mouse_wheel_up() - mouse_wheel_down()
if _wheel != 0 { scroll_offset = clamp(scroll_offset + _wheel, 0, _max_scroll) }

if InputPressed(INPUT_DEBUG){

	var _dplay = global.players[0]

	_dplay.djinn = [FindDjinnID("Flint"),FindDjinnID("Granite"),FindDjinnID("Forge"),FindDjinnID("Flash"),FindDjinnID("Waft"),FindDjinnID("Gust"),FindDjinnID("Fizz"),FindDjinnID("Spritz")]
	_dplay.weapon = FindItemID("Great Axe")
	_dplay.base_ppmax = 9999
	_dplay.pp = 9999
	_dplay.base_hpmax = 9999
	_dplay.hp = 9999

		for (var i = 0; i < array_length(global.psynergylist); ++i) {
		    array_push(_dplay.spells,i)
		}
		for (var j = 0; j < array_length(global.summonlist); ++j) {
		    array_push(global.knownSummons,j)
		}
	CreateDicePool()
	global.players[1] = variable_clone(global.players[0])
	global.players[2] = variable_clone(global.players[0])
	global.players[3] = variable_clone(global.players[0])
	global.players[1].portrait = Armor_Shopkeeper
	global.players[2].portrait = Item_Shopkeeper
	global.players[3].portrait = Weapon_Shopkeeper
	global.players[1].name = "Debug 2"
	global.players[2].name = "Debug 3"
	global.players[3].name = "Debug 4"
	
	global.players[0].portrait = Aaron_Jerra
	global.players[0].name = "Debug 1"
	
	
	InjectLog("Debug Mode Activated")
}