var _btn = instance_position(mouse_x, mouse_y, objButton2)
if _btn == noone { _btn = instance_position(mouse_x, mouse_y, objCancel) }
if _btn != noone
   and variable_instance_exists(_btn, "_owner_id") and _btn._owner_id == id
   and variable_instance_exists(_btn, "_cb")
   and _btn.clickable
{
	var _cb = _btn._cb
	PopMenu()
	_cb()
}
