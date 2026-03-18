function InitGlobalVars(){
	global.darken = false
	global.textdisplay = ""
	global.option_buttons = []
	global.challenge_buttons = []
	global.menu_stack = []
	global.turn = 0
	global.errormessage = ""
	global.genbackground = Sol_Sanctum
	global.genBGM = BGM_Mercury_Lighthouse
	global.pause = false
	global.hpcurse = 0
	global.rescurse = 0
	global.atkcurse = 0
	audio_group_load(BossThemes)
	audio_group_load(BattleThemes)
	audio_group_load(BGM)
	var _gain = 0.2
	audio_group_set_gain(BossThemes,   _gain, 0)
	audio_group_set_gain(BattleThemes, _gain, 0)
	audio_group_set_gain(BGM,          _gain, 0)
	
	#macro INPUT_CONFIRM  0
	#macro INPUT_CANCEL   1
	#macro INPUT_UP       2
	#macro INPUT_DOWN     3
	#macro INPUT_LEFT     4
	#macro INPUT_RIGHT    5
	#macro INPUT_INFO     6
	#macro INPUT_TAB      7

	#macro BOTTOMROW 124
	#macro TOPROW 32
	
	#macro BUTTON1 36
	#macro BUTTON2 64
	#macro BUTTON3 92
	#macro BUTTON4 120
	#macro BUTTON5 148
	
	#macro BUTTONRIGHT1 200
	#macro BUTTONRIGHT2 228
	
	#macro OPTION1 132
	#macro OPTION2 160
	#macro OPTION3 188
	#macro OPTION4 216
	
	#macro PORTRAITROW 1
	
	#macro PORTRAIT1 1
	#macro PORTRAIT2 384/6
	#macro PORTRAIT3 763/6
	#macro PORTRAIT4 1142/6
	
	#macro CREDITCOLUMN 4

	#macro CREDIT1 4
	#macro CREDIT2 40
	#macro CREDIT3 76
	#macro CREDIT4 112
	
	
	
	#macro BTN_BREATH_SPEED  0.04
	#macro BTN_BREATH_AMP   0.10
	#macro BTN_PRESS_SCALE  0.82
	#macro BTN_EASE_OUT     0.2

	#macro CONFIRMSOUND audio_stop_sound(MenuPositive);audio_play_sound(MenuPositive,0,0)
	#macro CANCELSOUND audio_stop_sound(MenuNegative);audio_play_sound(MenuNegative,0,0)
	#macro MENUMOVE audio_stop_sound(MenuMove);audio_play_sound(MenuMove,0,0)
	#macro HITSOUND audio_play_sound(DamageSound,0,0)
	#macro BIGHIT audio_play_sound(TargetedBigHit,0,0)
	#macro BIGHITMULT audio_play_sound(BigHit,0,0)
	#macro SUMMONHIT audio_play_sound(VeryBigHit,0,0)
	#macro INFLICT audio_play_sound(InflictStatus,0,0)

	global.floor = 1
	global.dungeon = 0
	global.dungeonFloor = 1
	global.dungeonTroops = []
	global.dungeonFloors = []
	global.floorChallenges = []
	global.onFloor = false
	global.floorName = ""
	global.defeatedMiniBosses = []
	global.floorEffects = []
	global.floorRequired = 1
	global.activeChallengeIndex = -1
	global.noHealOnCombatEnd = false
	global.cloakActive = false
	global.currentTown = -1
	global.townVisited = []
	global.townFindQueue = []
	global.artifactlist = []
	

	global.players = [variable_clone(global.characterlist[0]),
					variable_clone(global.characterlist[1]),
					variable_clone(global.characterlist[2]),
					variable_clone(global.characterlist[3])]

	for(var i=0; i<array_length(global.players); i++){
		if array_length(global.players[i].starters) > 0{
			array_push(global.players[i].spells,global.players[i].starters[0])
		
		
		}
	}

	// Snapshot base stats so equipment can reset before re-applying

	global.charselect = true
	global.gold = 0
	global.camwidth = 1536
	global.gameover = false
	global.gameover_timer = 0
	global.inCombat = false
	global.inTown = false
	global.inBossRewards = false
	global.bossRewardQueue = []
	global.turnPhase = "player"
	global.firstPlayer = 0
	global.playersActed = 0
	global.justSummoned = false
	global.catchBonus = -1

	global.c_venus = #ffe45f
	global.c_mars = #ff8585
	global.c_jupiter = #e7abff
	global.c_mercury = #a6c9ff
	global.c_normal = #ffffff
	global.c_important = #9dff83
	global.c_weapons = #ff8585
	global.c_armor = #ffe45f
	global.c_psynergy = #e7abff
	global.c_summon = #e7abff
	global.c_menu = #006080

	global.lastselected = -1
	global.passiveEffects = []
	global.daedalusCascade = false
	global.postBattleQueue = []
	global.choiceDrawQueue = []
	global.knownSummons = []
	global.postBattleDraws = []
	global.enemyFled = false
	global.miniBossDrops = []
	global.goldAtCombatStart = 0

	global.AggressionSchema = {target: "enemy", num: 1, dam: 0, repeater: 0, dmgtype: "normal", unleash: {}, onConfirm: {}, splash: -1, 
	pierce: false, slash: false, targetlist: [], caster: global.players[0], statuses: {}, selected: 0, source: "init",
	healing: 0,healingratio:0,revive: false,removepoison: false,removebad: false,removebuffs: false,defup: 0,atkup: 0,rootTokens: 0,regen: 0,regheal: 0,aegiscurse: false,cloak: false,delayed: false, itemid: -1, slot: -1, troop : [], locked: true}
	global.AggressionSchema.unleash = {
			active: false,
			name: "",
			dam_bonus: 0,
			element: "",
			num: 1,
			statuses: {},
			heal_hp_ratio: 0,
			heal_pp_ratio: 0,
			heal_hp_flat: 0,
			heal_pp_flat: 0,
			splash_ratio: 0,
			splash_element: "normal",
			double_atk: false,
			convert_element: "",
			instant_kill: false,
			repeater: 0,
		}
		global.AggressionSchema.onConfirm = variable_clone(global.AggressionSchema.unleash)
		show_debug_message("Program Directory: " + program_directory)
		show_debug_message("Cache Directory: " + cache_directory)
}
