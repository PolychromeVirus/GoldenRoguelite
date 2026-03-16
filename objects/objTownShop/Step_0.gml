if (selected < 0) { selected = 0 }
if (selected >= array_length(shoplist)) { selected = array_length(shoplist) - 1 }
if (selected < 0) { selected = 0 }

if InputPressed(INPUT_UP) {
    var _len = array_length(shoplist)
    if _len < 1 { exit }
    if selected == 0 { selected = _len - 1 }
    else { selected -= 1 }
}
if InputPressed(INPUT_DOWN) {
    var _len = array_length(shoplist)
    if _len < 1 { exit }
    if selected == _len - 1 { selected = 0 }
    else { selected += 1 }
}
