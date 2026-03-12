// objRerollPicker Create — flatten dice pool into selectable list
var player = global.players[global.turn]
var dpool = player.dicepool

// mode comes from the creation struct (passed via instance_create_depth)
// mode: "partial" = pick any number, "single" = pick 1
if mode == "single" {
	maxsel = 1
} else {
	maxsel = 999  // unlimited for partial
}

// Flatten dicepool into display list
dice = []
var pool_colors = [0x303030, #ffe45f, #ff8585, #e7abff, #a6c9ff]

for (var p = 0; p < array_length(dpool); p++) {
	var pool = dpool[p]
	for (var i = 0; i < array_length(pool); i++) {
		array_push(dice, {
			pool: p,
			index: i,
			pip: pool[i],
			col: pool_colors[p],
			selected: false
		})
	}
}
show_debug_message("dice count: " + string(array_length(dice)))

selected_count = 0
confirmed = false

// Store the reroll entry so we can return it on cancel
reroll_entry = { mode: mode, uses: uses, source: source, expires: expires }

// Spawn confirm + cancel buttons
instance_create_depth(BUTTON3, BOTTOMROW, 0, objConfirm)
instance_create_depth(BUTTON5, BOTTOMROW, 0, objCancel)
