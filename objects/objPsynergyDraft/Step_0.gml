if InputPressed(INPUT_UP) {
    if selected == 0 { selected = array_length(draftPool) - 1 }
    else { selected -= 1 }
}
if InputPressed(INPUT_DOWN) {
    if selected == array_length(draftPool) - 1 { selected = 0 }
    else { selected += 1 }
}
if InputPressed(INPUT_CONFIRM) {
	CONFIRMSOUND
    var selspell = global.psynergylist[draftPool[selected]]
    LearnPsy(selspell.base, draftPlayer)
    instance_destroy()
    _DraftNext()
}
