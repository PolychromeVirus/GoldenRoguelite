if selected > array_length(global.characterlist)-1{
	selected = array_length(global.characterlist)-1
}
if selected < 0{
	selected = 0
}

if InputPressed(INPUT_UP) {
    if selected == 0 { selected = array_length(global.characterlist) - 1 }
    else { selected -= 1 }
    starter_selected = 0
}
if InputPressed(INPUT_DOWN) {
    if selected == array_length(global.characterlist) - 1 { selected = 0 }
    else { selected += 1 }
    starter_selected = 0
}
if InputPressed(INPUT_LEFT) {
    var _starters = global.characterlist[selected].starters
    if array_length(_starters) > 0 {
        starter_selected = (starter_selected - 1 + array_length(_starters)) mod array_length(_starters)
    }
}
if InputPressed(INPUT_RIGHT) {
    var _starters = global.characterlist[selected].starters
    if array_length(_starters) > 0 {
        starter_selected = (starter_selected + 1) mod array_length(_starters)
    }
}
if InputPressed(INPUT_CONFIRM) {
	CONFIRMSOUND
    global.players[selector] = variable_clone(global.characterlist[selected])
    var _p = global.players[selector]
    if array_length(_p.starters) > 0 {
        array_push(_p.spells, _p.starters[starter_selected])
    }
    global.pause = false
    instance_destroy(objCharMenu)
}