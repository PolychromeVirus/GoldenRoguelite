// objRerollPicker Draw GUI — render selectable dice on the half-menu panel
var dicesize = 44
var dicepad = 8
var drawx = 50
var drawy = 260

draw_set_font(GoldenSun)

// Title text
draw_set_color(c_white)
draw_text(drawx, drawy - 30, "Click dice to reroll")

//var pool_names = ["Melee", "Venus", "Mars", "Jupiter", "Mercury"]
var cx = drawx
var cy = drawy

for (var i = 0; i < array_length(dice); i++) {
	var d = dice[i]
	var col = d.col

	// Brighten selected, dim unselected
	if !d.selected {
		var r = (col & 0xFF)
		var g = ((col >> 8) & 0xFF)
		var b = ((col >> 16) & 0xFF)
		col = make_color_rgb(floor(r * 0.45), floor(g * 0.45), floor(b * 0.45))
	}

	// Die fill
	draw_rectangle_color(cx, cy, cx + dicesize, cy + dicesize, col, col, col, col, false)

	// Border: yellow highlight if selected, dark if not
	if d.selected {
		draw_rectangle_color(cx - 2, cy - 2, cx + dicesize + 2, cy + dicesize + 2,
			c_yellow, c_yellow, c_yellow, c_yellow, true)
	} else {
		draw_rectangle_color(cx, cy, cx + dicesize, cy + dicesize,
			make_color_rgb(60, 60, 60), make_color_rgb(60, 60, 60),
			make_color_rgb(60, 60, 60), make_color_rgb(60, 60, 60), true)
	}

	// Pip number centered
	var numstr = string(d.pip)
	var tx = cx + floor((dicesize - string_width(numstr)) / 2)
	var ty = cy + floor((dicesize - string_height(numstr)) / 2)

	draw_set_color(c_black)
	draw_text(tx + 4, ty + 4, numstr)
	draw_set_color(d.selected ? c_white : make_color_rgb(140, 140, 140))
	draw_text(tx, ty, numstr)

	cx += dicesize + dicepad
}

// Selection count below dice
var label = string(selected_count) + " selected"
if maxsel < 999 {
	label = string(selected_count) + "/" + string(maxsel) + " selected"
}
draw_set_color(c_white)
draw_text(drawx, cy + dicesize + 10, label)
