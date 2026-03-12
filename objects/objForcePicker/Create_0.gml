/// @desc Force picker — choose how many elemental dice to spend (3 PP each)
var _caster = global.players[global.pendingPPCaster]
var _cost_per = 3 - _caster.ppdiscount
if _cost_per < 1 { _cost_per = 1 }
costPer = _cost_per

// Count total elemental dice
totalElem = QueryDice(_caster, "elemental", "affinity")

// Max dice the caster can afford
maxDice = min(totalElem, floor(_caster.pp / costPer))

if maxDice <= 0 {
	InjectLog("Not enough PP for Force!")
	global.pause = false
	global.pendingPPCost = 0
	DeleteButtons()
	instance_destroy()
	instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
	exit
}

selected = 1

// Gather all elemental pip values sorted descending (for damage preview)
elemPips = []
for (var _pool = POOL_VENUS; _pool <= POOL_MERCURY; _pool++) {
	var _dice = _caster.dicepool[_pool]
	for (var _d = 0; _d < array_length(_dice); _d++) {
		array_push(elemPips, _dice[_d])
	}
}
array_sort(elemPips, false) // descending

DeleteButtons()
instance_create_depth(BUTTON3, BOTTOMROW, 0, objConfirm, { image: yes, text: "Cast" })
instance_create_depth(BUTTON5, BOTTOMROW, 0, objCancel)
