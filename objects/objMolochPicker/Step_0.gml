if selected < 1 { selected = 1 }
if selected > maxNum { selected = maxNum }

if InputPressed(INPUT_UP) {
    selected--
    if selected < 1 { selected = maxNum }
}
if InputPressed(INPUT_DOWN) {
    selected++
    if selected > maxNum { selected = 1 }
}
