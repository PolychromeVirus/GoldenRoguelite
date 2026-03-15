if InputPressed(INPUT_LEFT) {
    if phase == 0 {
        if selected == 0 { selected = array_length(djinnPool) - 1 }
        else { selected -= 1 }
    } else {
        var _minDjinn = 999
        for (var p = 0; p < array_length(global.players); p++) {
            _minDjinn = min(_minDjinn, array_length(global.players[p].djinn))
        }
        var _start = selected
        do {
            if selected == 0 { selected = array_length(global.players) - 1 }
            else { selected -= 1 }
        } until (array_length(global.players[selected].djinn) < _minDjinn + 2 or selected == _start)
    }
}
if InputPressed(INPUT_RIGHT) {
    if phase == 0 {
        if selected == array_length(djinnPool) - 1 { selected = 0 }
        else { selected += 1 }
    } else {
        var _minDjinn = 999
        for (var p = 0; p < array_length(global.players); p++) {
            _minDjinn = min(_minDjinn, array_length(global.players[p].djinn))
        }
        var _start = selected
        do {
            if selected == array_length(global.players) - 1 { selected = 0 }
            else { selected += 1 }
        } until (array_length(global.players[selected].djinn) < _minDjinn + 2 or selected == _start)
    }
}
if InputPressed(INPUT_CONFIRM) {
	CONFIRMSOUND
    if phase == 0 {
        chosenDjinn = djinnPool[selected]
        phase = 1
        selected = 0
        var _minDjinn = 999
        for (var p = 0; p < array_length(global.players); p++) {
            _minDjinn = min(_minDjinn, array_length(global.players[p].djinn))
        }
        while (selected < array_length(global.players) and array_length(global.players[selected].djinn) >= _minDjinn + 2) {
            selected++
        }
        if selected >= array_length(global.players) { selected = 0 }
    } else {
        var _minDjinn = 999
        for (var p = 0; p < array_length(global.players); p++) {
            _minDjinn = min(_minDjinn, array_length(global.players[p].djinn))
        }
        if array_length(global.players[selected].djinn) < _minDjinn + 2 {
            array_push(global.players[selected].djinn, chosenDjinn)
            InjectLog(global.players[selected].name + " received " + global.djinnlist[chosenDjinn].name + "!")
            global.pause = false
            DeleteButtons()
            DestroyAllBut()
            ClearOptions()
            if (global.inTown) { ProcessTownFinds() } else { ProcessPostBattleQueue() }
            CreateDicePool()
            instance_destroy()
        }
    }
}
