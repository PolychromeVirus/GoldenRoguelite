if selected > array_length(allDjinn) - 1 { selected = array_length(allDjinn) - 1 }
if selected < 0 { selected = 0 }

if InputPressed(INPUT_UP) {
    if selected == 0 { selected = array_length(allDjinn) - 1 }
    else { selected -= 1 }
}
if InputPressed(INPUT_DOWN) {
    if selected == array_length(allDjinn) - 1 { selected = 0 }
    else { selected += 1 }
}
