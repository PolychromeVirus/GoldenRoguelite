if !clickable { exit }

if instance_exists(objConfirm) and instance_position(mouse_x, mouse_y, objConfirm) {
    on_confirm(value)
}
