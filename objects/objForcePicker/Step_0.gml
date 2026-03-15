if selected < 1 { selected = 1 }
if selected > maxDice { selected = maxDice }

if InputPressed(INPUT_UP) {
    selected--
    if selected < 1 { selected = maxDice }
}
if InputPressed(INPUT_DOWN) {
    selected++
    if selected > maxDice { selected = 1 }
}
