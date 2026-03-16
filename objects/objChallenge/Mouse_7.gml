var _ch = global.floorChallenges[challenge_index]

// Can't click completed challenges
if (_ch.completed) { exit }

// Combat or boss challenge — start fight
if (_ch.type == "combat" or _ch.type == "boss") {
	randomize()
	global.inCombat = true
	global.onFloor = true
	global.activeChallengeIndex = challenge_index
	ClearOptions()
	DeleteButtons()
	DestroyAllBut()
	CreateOptions()
	StartCombat(_ch.troop)
}

// Puzzle challenge — show puzzle prompt
if (_ch.type == "puzzle") {
	PuzzlePrompt(_ch.puzzle_index, challenge_index)
}
