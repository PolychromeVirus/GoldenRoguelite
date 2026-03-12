if instance_position(mouse_x, mouse_y, objConfirm) {
	var selspell = global.psynergylist[draftPool[selected]]
	LearnPsy(selspell.base, draftPlayer)
	instance_destroy()
	DestroyAllBut()
	_DraftNext()
	Autosave()
}
