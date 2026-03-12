itemId = global.bossRewardQueue[0]
item = global.itemcardlist[itemId]

DeleteButtons()

// Character portrait buttons (quick character picker pattern)
var _btn_objs = [objButton2, objButton3, objButton4, objButton5]
for (var _p = 0; _p < array_length(global.players); _p++) {
	var _spr = { image: global.players[_p].portrait, text: global.players[_p].name, boss_player: _p }
	instance_create_depth(BUTTON1 + (_p * 28), BOTTOMROW, 0, _btn_objs[_p], _spr)
}
