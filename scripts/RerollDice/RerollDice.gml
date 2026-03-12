/// @function RerollDice(player, selections)
/// @desc Reroll specific dice in a player's pool
/// @param player - player struct
/// @param selections - array of {pool, index} structs identifying which dice to reroll
function RerollDice(player, selections) {
	for (var i = 0; i < array_length(selections); i++) {
		var sel = selections[i]
		if player.dicepool[sel.pool][sel.index] != 0 {player.dicepool[sel.pool][sel.index] = irandom(5) + 1}
	}
}
