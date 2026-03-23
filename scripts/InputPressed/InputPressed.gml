function InputPressed(action) {
    var _pad = 0
    var _gp = gamepad_is_connected(_pad)
    switch (action) {
        case INPUT_CONFIRM: return keyboard_check_pressed(ord("Z"))  || (_gp && gamepad_button_check_pressed(_pad, gp_face1))
        case INPUT_CANCEL:  return keyboard_check_pressed(ord("X")) || (_gp && gamepad_button_check_pressed(_pad, gp_face2))
        case INPUT_UP:      return keyboard_check_pressed(vk_up)     || (_gp && gamepad_button_check_pressed(_pad, gp_padu))
        case INPUT_DOWN:    return keyboard_check_pressed(vk_down)   || (_gp && gamepad_button_check_pressed(_pad, gp_padd))
        case INPUT_LEFT:    return keyboard_check_pressed(vk_left)   || (_gp && gamepad_button_check_pressed(_pad, gp_padl))
        case INPUT_RIGHT:   return keyboard_check_pressed(vk_right)  || (_gp && gamepad_button_check_pressed(_pad, gp_padr))
        case INPUT_INFO:    return keyboard_check_pressed(ord("L"))  || (_gp && gamepad_button_check_pressed(_pad, gp_face3))
        case INPUT_TAB:     return keyboard_check_pressed(vk_tab)    || (_gp && gamepad_button_check_pressed(_pad, gp_shoulderl))
        case INPUT_LOG:     return keyboard_check_pressed(ord("G"))  || (_gp && gamepad_button_check_pressed(_pad, gp_shoulderr))
        case INPUT_SAVE:    return keyboard_check_pressed(ord("S"))
		case INPUT_DEBUG:   return keyboard_check_pressed(ord("Q"))
    }
    return false
}
