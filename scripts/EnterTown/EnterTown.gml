function EnterTown(town_index) {
	global.currentTown = town_index
	global.inTown = true
	global.pause = true
	var _town = global.townlist[town_index]

	// Set town background
	var _bg_layer = layer_background_get_id(layer_get_id("Background"))
	layer_background_sprite(_bg_layer, World_Map)

	// Auto-heal all players
	for (var i = 0; i < array_length(global.players); i++) {
		var _p = global.players[i]
		_p.hp = _p.hpmax
		_p.pp = _p.ppmax
		_p.poison = false
		_p.venom = false
		// Auto-repair broken armor
		for (var j = 0; j < array_length(_p.broken_armor); j++) {
			if (_p.broken_armor[j]) {
				InjectLog(_p.name + "'s " + global.itemcardlist[_p.armor[j]].name + " repaired!")
				_p.broken_armor[j] = false
			}
		}
		
		for (var k = 0; k<array_length(_p.djinn);k++){
			global.djinnlist[_p.djinn[k]].ready = true
			global.djinnlist[_p.djinn[k]].spent = false
		
		}
		
	}
	InjectLog("Arrived at " + _town.name + ". All adepts healed!")

	// Rebuild dice pools after repair
	CreateDicePool()

	// Free finds (only if not already visited this run)
	if (!array_contains(global.townVisited, _town.name)) {
		array_push(global.townVisited, _town.name)
		global.townFindQueue = []
		for (var f = 0; f < array_length(_town.finds); f++) {
			array_push(global.townFindQueue, _town.finds[f])
		}
		ProcessTownFinds()
	} else {
		// Already visited � go straight to shop TODO: towns can't be revisited
		DeleteButtons()
		CreateOptions()
	}
}
