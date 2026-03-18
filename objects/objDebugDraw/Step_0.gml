var _hovered = point_in_rectangle(mouse_x, mouse_y, x, y, x + 23, y + 23)

if _hovered && mouse_check_button_pressed(mb_left) && clickable {
    is_pressed  = true
    btn_scale   = BTN_PRESS_SCALE
}
if mouse_check_button_released(mb_left) {
    is_pressed = false
    btn_scale  = 1.0
}

if is_pressed {
    // hold — stay at snapped size
} else if _hovered {
    breath_t  += BTN_BREATH_SPEED
    btn_scale  = 1.0 + abs(sin(breath_t)) * BTN_BREATH_AMP
} else {
    breath_t  = 0
    btn_scale = 1.0
}
