if InputPressed(INPUT_LEFT) {
    if selected == 0 { selected = array_length(summonPool) - 1 }
    else { selected -= 1 }
}
if InputPressed(INPUT_RIGHT) {
    if selected == array_length(summonPool) - 1 { selected = 0 }
    else { selected += 1 }
}
if InputPressed(INPUT_CONFIRM) {
	CONFIRMSOUND
    var _chosenID = summonPool[selected]
    array_push(global.knownSummons, _chosenID)
    InjectLog("Learned summon: " + global.summonlist[_chosenID].name + "!")
    global.pause = false
    DeleteButtons()
    DestroyAllBut()
    ClearOptions()
    if (global.inTown) { ProcessTownFinds() } else { ProcessPostBattleQueue() }
    instance_destroy()
}
