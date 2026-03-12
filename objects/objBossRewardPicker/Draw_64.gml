draw_set_font(GoldenSun)

var _cx = 400
var _cy = 300

// Title
var _title = "Boss Reward! (" + string(4 - array_length(global.bossRewardQueue) + 1) + " / 4)"
draw_set_color(c_black)
draw_text(_cx + 4, _cy + 4, _title)
draw_set_color(c_yellow)
draw_text(_cx, _cy, _title)
_cy += 40

// Item sprite
var _alias = item.alias
if (asset_get_index(_alias) != -1) {
	draw_sprite_stretched(asset_get_index(_alias), 0, _cx, _cy, 64, 64)
}

// Item name (beside sprite)
draw_set_color(c_black)
draw_text(_cx + 68 + 4, _cy + 16 + 4, item.name)
draw_set_color(c_white)
draw_text(_cx + 68, _cy + 16, item.name)
_cy += 80

// Item description
var _desc = item.text
draw_set_color(c_black)
draw_text_ext(_cx + 4, _cy + 4, _desc, 40, 660)
draw_set_color(c_white)
draw_text_ext(_cx, _cy, _desc, 40, 660)
_cy += string_height_ext(_desc, 40, 660) + 20

// Prompt
draw_set_color(c_black)
draw_text(_cx + 4, _cy + 4, "Choose a character:")
draw_set_color(global.c_important)
draw_text(_cx, _cy, "Choose a character:")
