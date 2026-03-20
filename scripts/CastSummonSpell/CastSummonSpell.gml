/// @function CastSummonSpell(spellID, playerID)
/// @desc Execute a spell with maxed dice (all 6s, all charged) for four-cost summons
function CastSummonSpell(spellID, playerID) {
	var spell = global.psynergylist[spellID]
	var caster = global.players[playerID]

	// Don't deduct PP — temporarily zero cost so CastSpell doesn't deduct
	// Find max stage version of this spell's base
	var maxSpell = spell
	for (var s = 0; s < array_length(global.psynergylist); s++) {
		var candidate = global.psynergylist[s]
		if candidate.base == spell.base and candidate.stage > maxSpell.stage {
			maxSpell = candidate
		}
	}

	// Find max spell's index in psynergylist
	var maxIdx = -1
	for (var s = 0; s < array_length(global.psynergylist); s++) {
		if global.psynergylist[s] == maxSpell { maxIdx = s; break }
	}

	// Temporarily replace dice pool with all-6s
	var savedPool = caster.dicepool
	var fakePool = []
	for (var i = 0; i < 5; i++) {
		var sub = []
		for (var j = 0; j < array_length(savedPool[i]); j++) {
			array_push(sub, 6)
		}
		array_push(fakePool, sub)
	}
	caster.dicepool = fakePool

	// Temporarily zero PP cost
	var savedCost = maxSpell.cost
	maxSpell.cost = 0

	CastSpell(maxIdx, playerID)

	// Restore
	maxSpell.cost = savedCost
	caster.dicepool = savedPool

	// stack cleared by NextTurn via CastSpell
}
