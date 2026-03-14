// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InitChars(){
	var psy_grid = load_csv("CharacterImport.csv")
	global.characterlist = []
	
	for (var i = 2; i < ds_grid_height(psy_grid); ++i) {
		if psy_grid[# 0, i] == "" { continue }
	    var tempchar = {
			charid: i-2,
			name : psy_grid[# 0,i],
			class: psy_grid[# 1, i],
			text: string_replace_all(psy_grid[# 36, i], "\\n", "\n"),
			element: psy_grid[# 2, i],
			weakness: psy_grid[# 3, i],
			portrait: asset_get_index(psy_grid[# 4, i]),
			hpmax: real(psy_grid[# 5, i]),
			hp: real(psy_grid[# 5, i]),
			ppmax: real(psy_grid[# 7, i]),
			pp: 3,
			ppinc: 1,
			atk: real(psy_grid[# 9, i]),
			def: real(psy_grid[# 10, i]),
			atkmod: 0,
			atkmod_fresh: false,
			defmod_fresh: false,
			defmod: 0,
			curve: real(psy_grid[# 11, i]),//1 = fighter, 2 = all-rounder, 3=magician
			
			equipshort: psy_grid[# 12, i] == "x",
			equiplong: psy_grid[# 13, i] == "x",
			equipstaff: psy_grid[# 14, i] == "x",
			equipaxe: psy_grid[# 15, i] == "x",
			equipmace: psy_grid[# 16, i] == "x",
			
			spells: [FindPsyID(psy_grid[# 17, i], 0)],
			equip_spells: [],
			starters: [FindPsyID(psy_grid[# 18, i], 0), FindPsyID(psy_grid[# 19, i], 0)],
			
			inventory: [FindItemID(psy_grid[# 20, i])],
			weapon: FindItemID(psy_grid[# 21, i]),
			armor: [FindItemID(psy_grid[# 22, i])],
			
			melee: 0,
			venus: 0,
			mars: 0,
			jupiter: 0,
			mercury: 0,
			
			vres: 0,
			mares: 0,
			jres: 0,
			meres: 0,
			
			djinn: [],
			
			learnsPsynergy: psy_grid[# 29, i] != "FALSE",
			
			vbonus: 0,
			mabonus:  0,
			jbonus:  0,
			mebonus:  0,
			meleebonus:  0,
			
			ppdiscount: GetReal(psy_grid[# 35, i]),
			matk_ratio: 0,
			matk_only: false,
			
			poison: false,
			stun: 0,
			sleep: false,
			psyseal: false,
			venom: false,
			delude: false,
			haunt: 0,

			rootTokens: 0,
			regen: 0,
			regheal: 0,
			halfheal: false,
			cloak: false,
			cloaking: 5,

			reflect: false,
			aegiscurse: false,

			extraTurns: 0,
			rerolls: [],
			broken_armor: [],
			dicepool: [[], [], [], [], []],
			delaydata: {},
			onAttack: [],
			onRoll: {},
			planetary: {active: false, dam: 0, element: "venus"},
			heal_flash: 0,
			flash_timer: 0,
			cloak_fresh: false
			
		}
		if tempchar.portrait == -1{tempchar.portrait = Aaron_Jerra}
		if tempchar.starters[0] == -1{tempchar.starters = []}
		if tempchar.spells[0] == -1{tempchar.spells = []}
		if tempchar.armor[0] == -1{ tempchar.armor = []}
		if tempchar.inventory[0] == -1{ tempchar.inventory = []}
		if tempchar.weapon == -1{ tempchar.weapon = FindItemID("Short Sword")}
		if psy_grid[# 28, i] != ""{tempchar.djinn = [FindDjinnID(psy_grid[# 28, i])]}
		
		if tempchar.name == "Omega"{tempchar.matk_ratio = 1;tempchar.matk_only = true}
		
		tempchar.base_atk   = tempchar.atk
		tempchar.base_def   = tempchar.def
		tempchar.base_ppinc = tempchar.ppinc
		tempchar.base_hpmax = tempchar.hpmax
		tempchar.base_ppmax = tempchar.ppmax
		tempchar.base_ppdiscount = tempchar.ppdiscount
		
		//debug clause
		if tempchar.ppmax == 9999{tempchar.pp = 9999}
		
		array_push(global.characterlist,tempchar)
		
		
		
	}
	
	
	
}


