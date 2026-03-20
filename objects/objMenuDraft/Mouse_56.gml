if !clickable { exit }

var _len = array_length(items)
if _len < 1 { exit }

// Confirm button
if instance_position(mouse_x, mouse_y, objConfirm) {
	var _filtered = !is_undefined(filter) and filter(selected)
	if !_filtered {
		clickable = false
		CONFIRMSOUND
		on_confirm(selected, items[selected])
	}
	exit
}

// Click on a panel (GUI coordinates)
var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)
var _bw = 440
switch _len {
	case 2: _bw = 600; break
	case 3: _bw = 440; break
	case 4: _bw = 320; break
}
var _gap = floor((1536 - _len * _bw) / (_len + 1))
var _top = 80
var _bh  = box_height

for (var i = 0; i < _len; i++) {
	var _cx = _gap + i * (_bw + _gap)
	if _mx >= _cx and _mx < _cx + _bw
	and _my >= _top and _my < _top + _bh {
		if i == selected {
			var _filtered = !is_undefined(filter) and filter(i)
			if !_filtered {
				clickable = false
				CONFIRMSOUND
				on_confirm(selected, items[selected])
			}
		} else {
			selected = i
			using_kbd = false
			MENUMOVE
		}
		exit
	}
}
