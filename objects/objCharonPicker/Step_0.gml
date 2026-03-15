if selected < 1 { selected = 1 }
if selected > maxPairs { selected = maxPairs }

if InputPressed(INPUT_UP) {
    selected--
    if selected < 1 { selected = maxPairs }
}
if InputPressed(INPUT_DOWN) {
    selected++
    if selected > maxPairs { selected = 1 }
}
