var _chosenID = summonPool[selected]
array_push(global.knownSummons, _chosenID)
InjectLog("Learned summon: " + global.summonlist[_chosenID].name + "!")
global.pause = false
DeleteButtons()
DestroyAllBut()
ClearOptions()
if (global.inTown) { ProcessTownFinds() } else { ProcessPostBattleQueue() }
instance_destroy()
