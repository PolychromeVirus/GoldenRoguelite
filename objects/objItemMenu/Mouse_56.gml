var _slen = array_length(global.menu_stack)
if _slen == 0 or global.menu_stack[_slen - 1] != id { exit }

var _player = global.players[global.turn]

var _clicked = instance_position(mouse_x, mouse_y, objButton2)
if _clicked != noone and _clicked.object_index == objButton2 { _do_action(_clicked) }

if mode == 0 {
    if instance_position(mouse_x, mouse_y, objConfirm)  { _do_action(instance_position(mouse_x, mouse_y, objConfirm)) }
    if instance_position(mouse_x, mouse_y, objButton3)  { _do_action(instance_position(mouse_x, mouse_y, objButton3)) }
    if instance_position(mouse_x, mouse_y, objButton4)  { _do_action(instance_position(mouse_x, mouse_y, objButton4)) }
}

if instance_position(mouse_x,mouse_y,objButton6) or instance_position(mouse_x,mouse_y,objButton7) or instance_position(mouse_x,mouse_y,objButton8){
	global.turn = instance_position(mouse_x,mouse_y,all).index
}

if instance_position(mouse_x,mouse_y,objButton5){
	if mode == 0 {
		mode = 1
		selected = 0
	} else if mode == 1 {
		mode = 0
		selected = 0
	}
}