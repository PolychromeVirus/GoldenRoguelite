var _top = array_length(global.menu_stack) > 0 ? global.menu_stack[array_length(global.menu_stack)-1] : noone
if _top != id or !clickable { exit }

var _n = array_length(buttons)
if _n == 0 { exit }

if InputPressed(INPUT_LEFT) {
    keyboard_sel--
    if keyboard_sel < 0 { keyboard_sel = _n - 1 }
}
if InputPressed(INPUT_RIGHT) {
    keyboard_sel++
    if keyboard_sel >= _n { keyboard_sel = 0 }
}

if InputPressed(INPUT_CONFIRM) {
    buttons[keyboard_sel].on_click()
    exit
}

if InputPressed(INPUT_CANCEL) {
    for (var _i = 0; _i < _n; _i++) {
        var _b = buttons[_i]
        if variable_struct_exists(_b, "sprite") and _b.sprite == no {
            CANCELSOUND
            _b.on_click()
            exit
        }
    }
    // No cancel button defined — do nothing
}
