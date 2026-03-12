// Filter player's spells to matching element, resolve each to max stage
playerID = global.summonSpellPick.playerID
var element = global.summonSpellPick.element
var caster = global.players[playerID]

filteredSpells = []    // original spell IDs (base stage the player knows)
maxSpellIDs = []       // resolved max stage spell IDs for display + preview

var allSpells = caster.spells
for (var i = 0; i < array_length(allSpells); i++) {
	var sp = global.psynergylist[allSpells[i]]
	if sp.element != element { continue }

	// Find max stage of this spell's base
	var maxSpell = sp
	var maxIdx = allSpells[i]
	for (var s = 0; s < array_length(global.psynergylist); s++) {
		var candidate = global.psynergylist[s]
		if candidate.base == sp.base and candidate.stage > maxSpell.stage {
			maxSpell = candidate
			maxIdx = s
		}
	}

	// Avoid duplicates (multiple stages of same base in player's list)
	var _dup = false
	for (var d = 0; d < array_length(maxSpellIDs); d++) {
		if maxSpellIDs[d] == maxIdx { _dup = true; break }
	}
	if _dup { continue }

	array_push(filteredSpells, allSpells[i])
	array_push(maxSpellIDs, maxIdx)
}

// Build a fake all-6s pool for damage preview
var savedPool = caster.dicepool
var fakePool = []
for (var i = 0; i < 5; i++) {
	var sub = []
	for (var j = 0; j < array_length(savedPool[i]); j++) {
		array_push(sub, 6)
	}
	array_push(fakePool, sub)
}
fakeDicePool = fakePool

selected = 0
DeleteButtons()
ClearOptions()
instance_create_depth(sprite_width, sprite_height/2, 0, objQuarterMenu)

instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel)

var sprite = { image: yes, text: "Cast" }
instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite)

alarm_set(0,1)