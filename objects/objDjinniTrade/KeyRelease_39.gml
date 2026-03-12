// Right arrow — cycle selected target, skip sourcePlayer
var _start = selected
do {
	if selected == array_length(global.players) - 1 { selected = 0 }
	else { selected += 1 }
} until (selected != sourcePlayer or selected == _start)

// Reset targetSlot to 0 when switching targets
targetSlot = 0
