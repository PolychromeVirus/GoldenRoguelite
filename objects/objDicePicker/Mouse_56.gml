if !clickable { exit }

var _mx      = device_mouse_x_to_gui(0)
var _my      = device_mouse_y_to_gui(0)
var _dicesize = 52
var _dicepad  = 10
var _startx   = 50
var _starty   = 350

// Confirm button
if instance_exists(objConfirm) and instance_position(mouse_x, mouse_y, objConfirm) {
    if max_select == 1 {
        on_confirm([dice[kbd_selected]])
    } else {
        var _sel = []
        for (var _i = 0; _i < array_length(dice); _i++) {
            if dice[_i].selected { array_push(_sel, dice[_i]) }
        }
        on_confirm(_sel)
    }
    exit
}

// Die click
var _cx = _startx
for (var _i = 0; _i < array_length(dice); _i++) {
    if _mx >= _cx and _mx < _cx + _dicesize and _my >= _starty and _my < _starty + _dicesize {
        if max_select == 1 {
            kbd_selected = _i
        } else {
            if dice[_i].selected {
                dice[_i].selected = false
                selected_count--
            } else if selected_count < max_select {
                dice[_i].selected = true
                selected_count++
            }
        }
        break
    }
    _cx += _dicesize + _dicepad
}
