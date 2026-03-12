if clickable{
	if instance_exists(objCharMenu) {
		var _starters = global.characterlist[objCharMenu.selected].starters
		if array_length(_starters) > 0 {
			PsyLookup(_starters[objCharMenu.starter_selected])
			clickable=false
			alarm_set(0,1)
		} else {
			PsyLookup(0)
			clickable=false
			alarm_set(0,1)
		}
	} else {
		PsyLookup(0)
		clickable=false
		alarm_set(0,1)
	}
}