if !clickable { exit }

var _do_confirm = instance_position(mouse_x, mouse_y, objConfirm)

// Click on a djinn slot
var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)
var _cardW  = 320
var _cardH  = 575
var _gap    = floor((1536 - 4 * _cardW) / 5)
var _startY = 80
var _portraitSize = 192

for (var _pi = 0; _pi < array_length(global.players); _pi++) {
    if _pi == sourcePlayer { continue }
    var _cx = _gap + _pi * (_cardW + _gap)
    if _mx >= _cx and _mx < _cx + _cardW and _my >= _startY and _my < _startY + _cardH {
        var _dy     = _startY + _portraitSize + 70
        var _pDjinn = array_length(global.players[_pi].djinn)
        var _canGive = true
        var _postMin = 999
        for (var _pp = 0; _pp < array_length(global.players); _pp++) {
            var _pc = array_length(global.players[_pp].djinn)
            if _pp == sourcePlayer { _pc -= 1 }
            else if _pp == _pi    { _pc += 1 }
            _postMin = min(_postMin, _pc)
        }
        if (_pDjinn + 1) > _postMin + 1 { _canGive = false }
        var _maxSlot = _canGive ? _pDjinn : _pDjinn - 1
        for (var _si = 0; _si <= _maxSlot; _si++) {
            if _my >= _dy and _my < _dy + 48 {
                if _pi == selected and _si == targetSlot {
                    _do_confirm = true   // already highlighted slot — treat as confirm
                } else {
                    selected   = _pi
                    targetSlot = _si
                    MENUMOVE
                    exit
                }
                break
            }
            _dy += 48
        }
        break
    }
}

// Confirm trade
if _do_confirm { _confirm() }
