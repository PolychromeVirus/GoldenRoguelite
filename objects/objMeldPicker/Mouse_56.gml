if instance_exists(objConfirm) and instance_position(mouse_x, mouse_y, objConfirm) {
	var _chosen = weapons[selected]
	var _caster = global.players[global.turn]

	// Temporarily swap weapon (charge rules + unleash come from borrowed weapon)
	var _original_weapon = _caster.weapon
	_caster.weapon = _chosen.weapon_id

	DeleteButtons()
	instance_destroy()
	WeaponAttack(true, true)

	// Restore original weapon
	_caster.weapon = _original_weapon
}

if instance_exists(objCancel) and instance_position(mouse_x, mouse_y, objCancel) {
	if objCancel.clickable {
		global.pendingPPCost = 0
		global.textdisplay = ""
		DestroyAllBut()
		CreateOptions()
		ClearOptions()
	}
}
