var offset = 4

// Outside combat: show floor challenge progress
if !global.inCombat and !global.pause{
	if (array_length(global.floorChallenges) > 0 && !global.inTown) {
		var _done = 0
		for (var _ci = 0; _ci < array_length(global.floorChallenges); _ci++) {
			if (global.floorChallenges[_ci].completed) _done++
		}
		draw_set_font(GoldenSun)
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		var _tx = 36
		var _ty = 195
		var _met = (_done >= global.floorRequired)
		var _floor_text = (global.floorName != "") ? global.floorName : ("Floor " + string(global.dungeonFloor))
		var _challenge_text = "Challenges: " + string(_done) + " / " + string(global.floorRequired)
		var _line_h = string_height("A")
		// Determine widest line for background box
		var _max_w = max(string_width(_floor_text), string_width(_challenge_text))
		// Draw black background rectangle
		
		draw_sprite(secondbar,0,0,0)
		
		//draw_set_color(c_black)
		//draw_rectangle(0, _ty - 4, _tx + _max_w + 8, _ty + _line_h * 2 + 4, false)
		// Floor label
		draw_set_color(c_black)
		draw_text(_tx + offset, _ty + offset, _floor_text)
		draw_set_color(c_white)
		draw_text(_tx, _ty, _floor_text)
		// Challenge counter (shadow + colored text)
		draw_set_color(c_black)
		draw_text(_tx+offset, _ty+_line_h+offset, _challenge_text)
		draw_set_color(_met ? c_lime : c_white)
		draw_text(_tx, _ty+_line_h, _challenge_text)
	}
	exit
}
if global.turnPhase == "enemy" {exit}
if global.gameover {exit}
var dpool = global.players[global.turn].dicepool
if array_length(dpool) == 0 { exit }
if global.pause and !isCombatMenu(){exit}

var player  = global.players[global.turn]
var charge  = GetChargedDice(player)
var cmap    = charge.charged_map

// Apply Guardian/Fairy Ring pip bonus for display
var _pipbonus = 0
if array_contains(player.armor, FindItemID("Guardian Ring")){ _pipbonus += 1 }
if array_contains(player.armor, FindItemID("Fairy Ring")){ _pipbonus -= 1 }

// Layout: bottom-left area, above the action buttons (which sit at y~124)
var dicesize = 44
var dicepad  = 5
var groupgap = 10
var startx   = 36
var starty   = 170  // adjust to taste - well below the portrait area

if isCombatMenu(){
	startx = 800
	starty = 75
}

// Element display names, colors (BGR in GML), pool indices
//pool_names  = ["Melee",   "Venus",    "Mars",     "Jupiter",  "Mercury"]
var pool_colors = [0x303030,  #ffe45f,   #ff8585,   #e7abff,   #a6c9ff]
var pool_outline = [0x101010,  #F87000,   #801010,   #602060,   #104060]

var cx = startx

draw_set_font(GoldenSun)

for (var p = 0; p < array_length(dpool); p++) {
	var pool     = dpool[p]
	var pool_row = cmap[p]
	if array_length(pool) == 0 { continue }

	for (var i = 0; i < array_length(pool); i++) {
		var pip        = clamp(pool[i] + _pipbonus, 0, 6)
		var is_charged = pool_row[i]
		var col        = pool_colors[p]

		// Dim uncharged dice slightly
		if !is_charged {
			var r = (col & 0xFF)
			var g = ((col >> 8) & 0xFF)
			var b = ((col >> 16) & 0xFF)
			col = make_color_rgb(floor(r * 0.45), floor(g * 0.45), floor(b * 0.45))
		}

		// Die fill
		draw_rectangle_color(cx, starty, cx+dicesize, starty+dicesize, col, col, col, col, false)

		// Border: bright white glow if charged, near-black if not
		if is_charged {
			draw_rectangle_color(cx-2, starty-2, cx+dicesize+2, starty+dicesize+2,
				c_white, c_white, c_white, c_white, true)
		} else {
			draw_rectangle_color(cx, starty, cx+dicesize, starty+dicesize,
				make_color_rgb(60,60,60), make_color_rgb(60,60,60),
				make_color_rgb(60,60,60), make_color_rgb(60,60,60), true)
		}

		// Pip number, centered
		var numstr   = string(pip)
		var tx = cx + floor((dicesize - string_width(numstr))  / 2)+3
		var ty = starty + floor((dicesize - string_height(numstr)) / 2)+3

		if is_charged and pip != 0{
			draw_set_color(pool_outline[p])
			draw_text(tx+offset, ty, numstr)
			draw_text(tx-offset, ty, numstr)
			draw_text(tx, ty+offset, numstr)
			draw_text(tx, ty-offset, numstr)
		}
		draw_set_color(c_white)
		if pip != 0 {draw_text(tx, ty, numstr)}

		cx += dicesize + dicepad
	}
	cx += groupgap
}
