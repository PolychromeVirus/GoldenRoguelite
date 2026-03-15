// No carousel bounds checking needed — 2x2 grid is fixed
var _num = array_length(global.players)
kbd_selected = clamp(kbd_selected, 0, _num - 1)

var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)
if _mx != _prev_mx or _my != _prev_my { using_kbd = false }
_prev_mx = _mx
_prev_my = _my

if InputPressed(INPUT_LEFT)  { if (kbd_selected mod 2) == 1 { kbd_selected--; using_kbd = true } }
if InputPressed(INPUT_RIGHT) { if (kbd_selected mod 2) == 0 and kbd_selected + 1 < _num { kbd_selected++; using_kbd = true } }
if InputPressed(INPUT_UP)    { if kbd_selected >= 2 { kbd_selected -= 2; using_kbd = true } }
if InputPressed(INPUT_DOWN)  { if kbd_selected + 2 < _num { kbd_selected += 2; using_kbd = true } }

if InputPressed(INPUT_CONFIRM) {
	CONFIRMSOUND
    use_kbd_selected = true
    selected = kbd_selected
    event_perform(ev_mouse, ev_global_right_release)
}
