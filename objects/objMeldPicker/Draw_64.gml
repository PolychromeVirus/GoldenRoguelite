draw_set_font(GoldenSun)

var drawx = 50
var drawy = 300
var offset = 4
var vertpad = 54
var vertcent = drawy

for (var _i = 0; _i < array_length(weapons); _i++) {
	var _w = weapons[_i]
	var draw = true

	drawy = 300
	if _i == selected { drawy = 300 }
	else if _i < selected {
		drawy = vertcent - (vertpad * (selected - _i))
	} else if _i > selected {
		drawy = vertcent + (vertpad * (_i - selected))
	}

	if _i - selected > 6 { draw = false }
	if selected - _i > 5 { draw = false }

	// Item icon
	if asset_get_index(_w.alias) != -1 and draw {
		draw_sprite_stretched(asset_get_index(_w.alias), 0, drawx, drawy, 48, 48)
	}

	if draw {
		var _col = (_i == selected) ? c_yellow : c_white

		// Weapon name
		draw_set_color(c_black)
		draw_text(drawx + 72 + offset, drawy + offset + 8, _w.weapon_name)
		draw_set_color(_col)
		draw_text(drawx + 72, drawy + 8, _w.weapon_name)

		// Damage preview
		draw_set_color(c_black)
		draw_text(drawx + 400 + offset, drawy + 12 + offset, string(_w.dam))
		draw_set_color(c_white)
		draw_text(drawx + 400, drawy + 12, string(_w.dam))
	}
}

draw_set_color(c_white)
