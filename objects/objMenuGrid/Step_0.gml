if array_length(global.menu_stack) == 0 or global.menu_stack[array_length(global.menu_stack)-1] != id { exit }

var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)
if _mx != _prev_mx or _my != _prev_my { using_kbd = false }
_prev_mx = _mx
_prev_my = _my

var _num = array_length(global.players)
kbd_selected = clamp(kbd_selected, 0, _num - 1)

if InputPressed(INPUT_LEFT)  { if (kbd_selected mod 2) == 1 { kbd_selected--; using_kbd = true; MENUMOVE } }
if InputPressed(INPUT_RIGHT) { if (kbd_selected mod 2) == 0 and kbd_selected + 1 < _num { kbd_selected++; using_kbd = true; MENUMOVE } }
if InputPressed(INPUT_UP)    { if kbd_selected >= 2 { kbd_selected -= 2; using_kbd = true; MENUMOVE } }
if InputPressed(INPUT_DOWN)  { if kbd_selected + 2 < _num { kbd_selected += 2; using_kbd = true; MENUMOVE } }

if InputPressed(INPUT_CONFIRM) and clickable {
    var _filtered = !is_undefined(filter) and filter(kbd_selected)
    if !_filtered {
        CONFIRMSOUND
        on_confirm(kbd_selected)
    }
}
