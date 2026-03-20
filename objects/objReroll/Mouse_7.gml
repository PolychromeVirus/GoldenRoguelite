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
	var _player = global.players[global.turn]
	PushMenu(objDicePicker, {
		dice:          BuildDiceArray(_player, "all"),
		max_select:    (entry.mode == "single") ? 1 : 999,
		confirm_label: "Reroll",
		title:         "Click dice to reroll",
		on_confirm:    method({ pl: _player }, function(sel) {
			if array_length(sel) > 0 {
				RerollDice(pl, sel)
				InjectLog(pl.name + " rerolled " + string(array_length(sel)) + " dice!")
			}
			PopMenu()
		}),
	})
}
