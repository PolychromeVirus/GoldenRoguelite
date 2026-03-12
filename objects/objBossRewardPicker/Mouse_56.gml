var _btn = instance_position(mouse_x, mouse_y, objButton2)
if (_btn != noone && variable_struct_exists(_btn, "boss_player")) {
	var _pi = _btn.boss_player
	DeleteButtons()
	_ApplyBossItem(itemId, _pi)
	instance_destroy()
}
