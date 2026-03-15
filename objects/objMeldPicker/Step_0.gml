if selected < 0 { selected = 0 }
if selected > array_length(weapons) - 1 { selected = array_length(weapons) - 1 }

if InputPressed(INPUT_UP) {
    selected--
    if selected < 0 { selected = array_length(weapons) - 1 }
}
if InputPressed(INPUT_DOWN) {
    selected++
    if selected > array_length(weapons) - 1 { selected = 0 }
}
