function OnMove(){
	
	var _oldidx = -1
	var _pidx = -1
	
	
	var _tar = global.dungeonFloors[global.floor-1].challenges
	for (var i = 0; i < array_length(_tar); ++i) {
	    if _tar[i].type == "puzzle"{_oldidx = i;
			_pidx = _tar[i].puzzle_index
			break}
	}
	
	if _pidx == -1 {InjectLog("But nothing happened...")
		return _pidx}
	
	var _cand = []
	
	for (i=0;i<array_length(global.puzzlelist);i++){
	
	if i != _pidx{array_push(_cand,i)}
	
	}
	
	var _puzz = _BuildRandomPuzzleChallenge(_cand)
	var _ch = _puzz.challenge
	var _ef = _puzz.effects
	
	global.floorChallenges[_oldidx] = _ch
	global.dungeonFloors[global.floor-1].challenges[_oldidx] = _ch
	
	global.floorEffects = _ef
	global.dungeonFloors[global.floor-1].effects = _ef
	
	InjectLog("You hear the sound of shifting stone")
}