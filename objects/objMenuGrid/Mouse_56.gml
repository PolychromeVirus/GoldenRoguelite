if !clickable { exit }

var _num = array_length(global.players)
var _mx  = device_mouse_x_to_gui(0)
var _my  = device_mouse_y_to_gui(0)

for (var _i = 0; _i < _num; _i++) {
    var _col = _i mod 2
    var _row = _i div 2
    var _cx  = gridX + _col * cellW
    var _cy  = gridY + _row * cellStrideY

    if _mx >= _cx and _mx < _cx + cellW and _my >= _cy and _my < _cy + cellH {
        var _filtered = !is_undefined(filter) and filter(_i)
        if !_filtered {
            CONFIRMSOUND
            on_confirm(_i)
        }
        exit
    }
}
