if array_length(global.menu_stack) == 0 or global.menu_stack[array_length(global.menu_stack)-1] != id { exit }

// Mouse hover: select player card and djinn slot
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
        if _pi != selected { selected = _pi; targetSlot = 0 }
        // Hover over a djinn slot row
        var _dy    = _startY + _portraitSize + 70
        var _pDjinn = array_length(global.players[_pi].djinn)
        // check give slot availability (same logic as draw)
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
                targetSlot = _si
                break
            }
            _dy += 48
        }
        break
    }
}

if InputPressed(INPUT_LEFT) {
    var _start = selected
    do {
        if selected == 0 { selected = array_length(global.players) - 1 }
        else { selected -= 1 }
    } until (selected != sourcePlayer or selected == _start)
    targetSlot = 0
}
if InputPressed(INPUT_RIGHT) {
    var _start = selected
    do {
        if selected == array_length(global.players) - 1 { selected = 0 }
        else { selected += 1 }
    } until (selected != sourcePlayer or selected == _start)
    targetSlot = 0
}
if InputPressed(INPUT_UP) {
    var _djinnCount = array_length(global.players[selected].djinn)
    var _canGive = true
    var _postMin = 999
    for (var p = 0; p < array_length(global.players); p++) {
        var _pc = array_length(global.players[p].djinn)
        if p == sourcePlayer { _pc -= 1 }
        else if p == selected { _pc += 1 }
        _postMin = min(_postMin, _pc)
    }
    if (array_length(global.players[selected].djinn) + 1) > _postMin + 1 { _canGive = false }
    var _maxSlot = _canGive ? _djinnCount : _djinnCount - 1
    if targetSlot == 0 { targetSlot = _maxSlot }
    else { targetSlot -= 1 }
}
if InputPressed(INPUT_DOWN) {
    var _djinnCount = array_length(global.players[selected].djinn)
    var _canGive = true
    var _postMin = 999
    for (var p = 0; p < array_length(global.players); p++) {
        var _pc = array_length(global.players[p].djinn)
        if p == sourcePlayer { _pc -= 1 }
        else if p == selected { _pc += 1 }
        _postMin = min(_postMin, _pc)
    }
    if (array_length(global.players[selected].djinn) + 1) > _postMin + 1 { _canGive = false }
    var _maxSlot = _canGive ? _djinnCount : _djinnCount - 1
    if targetSlot >= _maxSlot { targetSlot = 0 }
    else { targetSlot += 1 }
}
