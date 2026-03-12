function DifficultyUp(_forced_curse = -1){

	var _curse = (_forced_curse >= 0) ? _forced_curse : irandom(2)

	switch _curse{
		case 0:
			global.hpcurse += 1
			break
		case 1:
			global.rescurse += 1
			break
		case 2:
			global.atkcurse += 1
			break
	}

	if _curse == 0 {InjectLog("Difficulty is increasing... (More Health)")}
	if _curse == 1 {InjectLog("Difficulty is increasing... (Higher Resistance)")}
	if _curse == 2 {InjectLog("Difficulty is increasing... (More Damage)")}

}
