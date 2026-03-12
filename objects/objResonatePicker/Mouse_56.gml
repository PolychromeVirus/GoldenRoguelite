if instance_exists(btn_range) and instance_position(mouse_x, mouse_y, btn_range) {
	AddPassive("_Resonate", res_countdown, Resonate, "Resonate", { mode: "range", amount: res_value }, res_caster_idx)
	InjectLog(res_caster_name + " casts Resonate! (+" + string(res_value) + " range)")
	global.players[res_caster_idx].pp -= res_cost
	global.pendingPPCost = 0
	DeleteButtons()
	global.pause = false
	NextTurn()
	instance_destroy()
}

if instance_exists(btn_damage) and instance_position(mouse_x, mouse_y, btn_damage) {
	AddPassive("_Resonate", res_countdown, Resonate, "Resonate", { mode: "damage", amount: res_value }, res_caster_idx)
	InjectLog(res_caster_name + " casts Resonate! (+" + string(res_value) + " damage)")
	global.players[res_caster_idx].pp -= res_cost
	global.pendingPPCost = 0
	DeleteButtons()
	global.pause = false
	NextTurn()
	instance_destroy()
}
