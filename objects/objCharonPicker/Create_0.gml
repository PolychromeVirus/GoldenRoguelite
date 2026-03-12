// Count total ready djinn across all players
var total_ready = 0
for (var p = 0; p < array_length(global.players); p++) {
	var pl = global.players[p]
	if variable_struct_exists(pl, "djinn") {
		for (var d = 0; d < array_length(pl.djinn); d++) {
			var _dj = global.djinnlist[pl.djinn[d]]
			if (_dj.ready or _dj.spent) {
				total_ready++
			}
		}
	}
}

// Count eligible (non-boss) targets
var _eligible = 0
var _mcount = instance_number(objMonster)
for (var i = 0; i < _mcount; i++) {
	var inst = instance_find(objMonster, i)
	if inst.monsterHealth > 0 and !inst.boss {
		_eligible++
	}
}

// Clamp max pairs to both djinn budget and eligible targets
maxPairs = min(floor(total_ready / 2), _eligible)

// If no valid targets at all, cancel immediately
if maxPairs <= 0 {
	InjectLog("No monsters for Charon to target!")
	global.pause = false
	DeleteButtons()
	instance_destroy()
	instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
	exit
}

selected = 1

var button1 = 36
var buttonno = 64

instance_create_depth(buttonno, 124, 0, objCancel)

var sprite = { image: Psynergy, text: "Summon" }
instance_create_depth(button1, 124, 0, objConfirm, sprite)
