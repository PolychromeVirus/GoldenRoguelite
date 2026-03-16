if array_length(global.menu_stack) == 0 or global.menu_stack[array_length(global.menu_stack)-1] != id { exit }
var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)
if _mx != _prev_mx or _my != _prev_my {
	using_kbd = false
	_prev_mx  = _mx
	_prev_my  = _my
}

var _len = array_length(items)
if _len < 1 { exit }

// Hover selection in mouse mode
if !using_kbd {
	var _bw = 440
	switch _len {
		case 2: _bw = 600; break
		case 3: _bw = 440; break
		case 4: _bw = 320; break
	}
	var _gap = floor((1536 - _len * _bw) / (_len + 1))
	var _top = 80
	var _bh  = box_height
	for (var _hi = 0; _hi < _len; _hi++) {
		var _cx = _gap + _hi * (_bw + _gap)
		if _mx >= _cx and _mx < _cx + _bw
		and _my >= _top and _my < _top + _bh {
			if _hi != selected { selected = _hi }
			break
		}
	}
}

if selected < 0      { selected = 0 }
if selected >= _len  { selected = _len - 1 }

var _scroll_up   = mouse_wheel_up()
var _scroll_down = mouse_wheel_down()
if InputPressed(INPUT_LEFT) or _scroll_up {
	using_kbd = !_scroll_up
	selected  = (selected == 0) ? _len - 1 : selected - 1
	if !_scroll_up { MENUMOVE }
}
if InputPressed(INPUT_RIGHT) or _scroll_down {
	using_kbd = !_scroll_down
	selected  = (selected == _len - 1) ? 0 : selected + 1
	if !_scroll_down { MENUMOVE }
}

if InputPressed(INPUT_CONFIRM) and clickable {
	var _filtered = !is_undefined(filter) and filter(selected)
	if !_filtered {
		clickable = false
		CONFIRMSOUND
		on_confirm(selected, items[selected])
	}
}
