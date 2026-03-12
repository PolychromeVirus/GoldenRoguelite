if instance_position(mouse_x, mouse_y, objConfirm) and clickable{
	if array_length(filteredSpells) > 0 {
		// Exhaust djinn now that a spell is confirmed
		ExhaustSummonDjinn(global.summonSpellPick.summonID)
		// Show summon splash
		if global.summonSpellPick.splash != -1 {
			instance_create_depth(0, 0, -100, objSummonSplash, { spr: global.summonSpellPick.splash })
		}
		DeleteButtons()
		CastSummonSpell(filteredSpells[selected], playerID)
	} else {
		InjectLog("No spells of this element available!")
	}
}
if instance_position(mouse_x, mouse_y, objCancel) and clickable{
	// Cancel — no djinn exhausted, return to options
	global.pause = false
	DeleteButtons()
	DestroyAllBut()
	ClearOptions()
	CreateOptions()
	instance_destroy()
}
