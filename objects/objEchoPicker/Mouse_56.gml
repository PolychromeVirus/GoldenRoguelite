if instance_position(mouse_x, mouse_y, objConfirm) {
	var _entry = allDjinn[selected]
	var _djinnID = _entry.djinnID
	var _djinni = global.djinnlist[_djinnID]

	if _djinni.ready {
		InjectLog("Djinn Echo unleashes " + _djinni.name + "!")
		instance_destroy(objQuarterMenu)
		instance_destroy()
		ClearOptions()
		UnleashDjinn(_djinnID, global.turn)
	} else if _djinni.spent {
		InjectLog(_djinni.name + " is set!")
		instance_destroy(objQuarterMenu)
		instance_destroy()
		ClearOptions()
		UnleashDjinn(_djinnID, global.turn)
	} else {
		InjectLog(_djinni.name + " is recovering!")
	}
}
