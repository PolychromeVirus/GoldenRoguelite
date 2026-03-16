if array_length(global.menu_stack) == 0 or global.menu_stack[array_length(global.menu_stack)-1] != id { exit }
// Mouse/keyboard mode switching
var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)
if _mx != _prev_mx or _my != _prev_my {
    using_kbd = false
    _prev_mx  = _mx
    _prev_my  = _my
}

var _len = array_length(items)
if _len < 1 { exit }

if selected < 0        { selected = 0 }
if selected >= _len    { selected = _len - 1 }

var _scroll_up   = mouse_wheel_up()
var _scroll_down = mouse_wheel_down()
if InputPressed(INPUT_UP) or _scroll_up {
    using_kbd = !_scroll_up
    selected  = (selected == 0) ? _len - 1 : selected - 1
    if !_scroll_up { MENUMOVE }
}
if InputPressed(INPUT_DOWN) or _scroll_down {
    using_kbd = !_scroll_down
    selected  = (selected == _len - 1) ? 0 : selected + 1
    if !_scroll_down { MENUMOVE }
}

if InputPressed(INPUT_CONFIRM) and clickable and !read_only {
    var _filtered = !is_undefined(filter) and filter(selected)
    if !_filtered {
        CONFIRMSOUND
        on_confirm(selected, items[selected])
    }
}

if InputPressed(INPUT_INFO) and clickable and !is_undefined(on_info) {
    on_info(selected, items[selected])
}
