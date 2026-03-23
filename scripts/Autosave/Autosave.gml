function Autosave(){
	if global.charselect or global.inCombat { exit }  // never save during character select or combat

	var _f = file_text_open_write("Save.txt")
	
	var _save = {
		players: global.players,
		charselect: global.charselect,
		gold: global.gold,
		postBattleQueue: global.postBattleQueue,
		knownSummons: global.knownSummons,
		deck: global.deck,
		discard: global.discard,
		floor: global.floor,
		dungeon: global.dungeon,
		dungeonFloor: global.dungeonFloor,
		floorChallenges: global.floorChallenges,
		defeatedMiniBosses: global.defeatedMiniBosses,
		townVisited: global.townVisited,
		dungeonFloors: global.dungeonFloors,
		hpcurse: global.hpcurse,
		rescurse: global.rescurse,
		atkcurse: global.atkcurse,
		inTown: global.inTown,
		currentTown: global.currentTown,
		floorRequired: global.floorRequired,
		floorEffects: global.floorEffects,
		floorName: global.floorName,
		artifactlist: global.artifactlist,
		genBGM: global.genBGM
	}
	
	
	
	file_text_write_string(_f, json_stringify(_save))
	
	file_text_close(_f)

	with (objTextManager) { save_flash = 180 }
}