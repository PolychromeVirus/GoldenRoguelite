var _starters = global.characterlist[selected].starters
if array_length(_starters) > 0 {
	starter_selected = (starter_selected + 1) mod array_length(_starters)
}