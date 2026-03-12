randomize()
global.inCombat = true
ClearOptions()
DeleteButtons()
DestroyAllBut()
CreateOptions()

// Find first uncompleted combat challenge and use its troop
var _troop = undefined
global.activeChallengeIndex = -1
for (var _ci = 0; _ci < array_length(global.floorChallenges); _ci++) {
	if (!global.floorChallenges[_ci].completed && global.floorChallenges[_ci].type != "puzzle") {
		_troop = global.floorChallenges[_ci].troop
		global.activeChallengeIndex = _ci
		break
	}
}
StartCombat(_troop)
global.pause = false