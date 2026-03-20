
global.charselect = false
CreateDicePool()

for (var i = 0; i < array_length(global.players); ++i) {
	
	var tempspells = variable_clone(global.players[i].spells)
	global.players[i].spells = []
	for (var j = 0; j < array_length(tempspells); ++j) {
	    LearnPsyByID(tempspells[j],i)
	}
	
	
}

StartDungeon(0)
room_goto_next()