draw_set_font(GoldenSun)

var cx = 400
var cy = 300
var offset = 4

// Dice count
draw_set_color(c_black)
draw_text(cx + offset, cy + offset, "Dice to use: " + string(selected) + " / " + string(maxDice))
draw_set_color(c_white)
draw_text(cx, cy, "Dice to use: " + string(selected) + " / " + string(maxDice))

// PP cost
var _pp = selected * costPer
draw_set_color(c_black)
draw_text(cx + offset, cy + 40 + offset, "PP cost: " + string(_pp))
draw_set_color(c_yellow)
draw_text(cx, cy + 40, "PP cost: " + string(_pp))

// Damage preview (sum of top N pips)
var _dam = 0
for (var _i = 0; _i < selected; _i++) {
	_dam += elemPips[_i]
}
draw_set_color(c_black)
draw_text(cx + offset, cy + 80 + offset, "Damage: " + string(_dam))
draw_set_color(c_red)
draw_text(cx, cy + 80, "Damage: " + string(_dam))

draw_set_color(c_white)
