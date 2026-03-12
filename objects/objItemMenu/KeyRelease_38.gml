var _len = (mode == 0) ? array_length(global.players[global.turn].inventory) : 1 + array_length(global.players[global.turn].armor)
if _len < 1 { exit }
if selected == 0{
	selected = _len - 1
}else{
	selected -= 1
}