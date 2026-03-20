if !clickable { exit }

for (var _i = 0; _i < array_length(_btn_instances); _i++) {
    var _inst = _btn_instances[_i]
    if instance_exists(_inst) and instance_position(mouse_x, mouse_y, _inst) {
        buttons[_i].on_click()
        exit
    }
}
