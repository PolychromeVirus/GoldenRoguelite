function ProcessChoiceDrawQueue() {
	if (array_length(global.choiceDrawQueue) > 0) {
		global.pause = true
		DestroyAllBut()
		DeleteButtons()
		ClearOptions()
		instance_create_depth(0, 0, 0, objChoiceDraw)
	} else {
		// Queue empty — process any onDraw effects (Elemental Star, Summon Tablet) first
		if (array_length(global.postBattleQueue) > 0) {
			ProcessPostBattleQueue()
		} else if (global.inTown) {
			ProcessTownFinds()
		} else {
			CreateOptions()
		}
	}
}
