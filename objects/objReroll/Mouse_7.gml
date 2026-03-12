// Reroll button click — pop first reroll entry and act on it
var player = global.players[global.turn]
if array_length(player.rerolls) <= 0 { exit }

var entry = player.rerolls[0]
array_delete(player.rerolls, 0, 1)

if entry.mode == "full" {
	// Full pool reroll — reroll immediately
	player.dicepool = RollDice(player)
	InjectLog(player.name + "'s dice swirl!")
	DeleteButtons()
	CreateOptions()
} else {
	// Partial or single — open the picker
	DeleteButtons()
	instance_create_depth(0, 0, 0, objRerollPicker, {
		mode: entry.mode,
		uses: entry.uses,
		source: entry.source,
		expires: entry.expires
	})
}
