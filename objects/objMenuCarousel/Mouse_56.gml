if !clickable { exit }

var _len = array_length(items)

// Confirm button click
if instance_position(mouse_x, mouse_y, objConfirm) and !read_only and _len > 0 {
    var _filtered = !is_undefined(filter) and filter(selected)
    if !_filtered {
        CONFIRMSOUND
        on_confirm(selected, items[selected])
    }
    exit
}

// Info button click
var _info_btn = instance_position(mouse_x, mouse_y, objButton2)
if _info_btn != noone and _info_btn.object_index == objButton2 and !is_undefined(on_info) and _len > 0 {
    on_info(selected, items[selected])
    exit
}

// Click on list item to select (and double-click to confirm)
if _len < 1 { exit }

var _vertpad  = 54
var _center_y = 300
var _list_x   = (side == "left") ? 50 : 820
var _list_w   = 760

for (var i = 0; i < _len; i++) {
    if abs(i - selected) > 6 { continue }
    var _dy = _center_y + (i - selected) * _vertpad
    if mouse_y >= _dy - _vertpad/2 and mouse_y < _dy + _vertpad/2
    and mouse_x >= _list_x and mouse_x < _list_x + _list_w {
        if i == selected and !read_only {
            var _filtered = !is_undefined(filter) and filter(selected)
            if !_filtered {
                CONFIRMSOUND
                on_confirm(selected, items[selected])
            }
        } else {
            selected = i
            MENUMOVE
        }
        exit
    }
}
