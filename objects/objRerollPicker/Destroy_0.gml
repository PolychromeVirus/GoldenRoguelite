// If not confirmed, push the reroll entry back so it's not wasted
if !confirmed {
	var player = global.players[global.turn]
	array_insert(player.rerolls, 0, reroll_entry)
}
instance_destroy(objQuarterMenu)
