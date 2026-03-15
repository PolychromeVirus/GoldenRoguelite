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
