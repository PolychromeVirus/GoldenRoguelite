draw_set_font(GoldenSun)

var cx = 400
var cy = 300
var offset = 4

draw_set_color(c_black)
draw_text(cx + offset, cy + offset, "Pairs to spend: " + string(selected) + " / " + string(maxPairs))
draw_set_color(c_white)
draw_text(cx, cy, "Pairs to spend: " + string(selected) + " / " + string(maxPairs))

draw_set_color(c_black)
draw_text(cx + offset, cy + 40 + offset, "Targets to down: " + string(selected))
draw_set_color(c_red)
draw_text(cx, cy + 40, "Targets to down: " + string(selected))

draw_set_color(c_black)
draw_text(cx + offset, cy + 80 + offset, "Djinn consumed: " + string(selected * 2))
draw_set_color(c_yellow)
draw_text(cx, cy + 80, "Djinn consumed: " + string(selected * 2))

draw_set_color(c_white)
