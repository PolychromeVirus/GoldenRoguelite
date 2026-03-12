function isSummonable(summon){
	// Count available djinn (ready OR spent) of each element across all players
	// Djinn in recovery (!ready && !spent) are NOT available
	var ready_venus = 0
	var ready_mars = 0
	var ready_jupiter = 0
	var ready_mercury = 0
	var ready_total = 0

	for (var p = 0; p < array_length(global.players); p++){
		var player = global.players[p]
		if variable_struct_exists(player, "djinn"){
			for (var d = 0; d < array_length(player.djinn); d++){
				var djinn = global.djinnlist[player.djinn[d]]
				if (djinn.ready or djinn.spent){
					ready_total++
					switch djinn.element{
						case "Venus": ready_venus++; break
						case "Mars": ready_mars++; break
						case "Jupiter": ready_jupiter++; break
						case "Mercury": ready_mercury++; break
					}
				}
			}
		}
	}

	// Charon: needs at least 2 ready djinn (1 pair) of any element
	if summon.name == "Charon"{
		return (ready_total >= 2)
	}

	// Standard: check each element cost
	if ready_venus < summon.venus { return false }
	if ready_mars < summon.mars { return false }
	if ready_jupiter < summon.jupiter { return false }
	if ready_mercury < summon.mercury { return false }
	return true
}
