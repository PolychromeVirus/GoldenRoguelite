if !array_contains(global.menu_stack, id) { exit }
draw_sprite_ext(TestMenu, 0, 0, 0, 6, 6, 0, c_white, 1)
draw_set_font(GoldenSun)
var _offset = 4
var _len    = array_length(items)
if _len < 1 { exit }

// Panel dimensions
var _bw = 440
switch _len {
	case 2: _bw = 600; break
	case 3: _bw = 440; break
	case 4: _bw = 320; break
}
var _bh  = box_height
var _gap = (_len > 0) ? floor((1536 - _len * _bw) / (_len + 1)) : 0
var _top = 80

// Title
if title != "" {
	draw_set_color(c_black)
	draw_text(50 + _offset, 30 + _offset, title)
	draw_set_color(c_yellow)
	draw_text(50, 30, title)
}

for (var i = 0; i < _len; i++) {
	var _item     = items[i]
	var _cx       = _gap + i * (_bw + _gap)
	var _cy       = _top
	var _filtered = !is_undefined(filter) and filter(i)

	// Background
	var _bgcol = _filtered ? make_color_rgb(40, 20, 20) : #006080
	if i == selected and !_filtered { _bgcol = #005870 }
	draw_rectangle_color(_cx, _cy, _cx + _bw, _cy + _bh, _bgcol, _bgcol, _bgcol, _bgcol, false)

	// Selection border
	if i == selected and !_filtered {
		draw_rectangle_color(_cx - 3, _cy - 3, _cx + _bw + 3, _cy + _bh + 3, c_white, c_white, c_white, c_white, true)
		draw_rectangle_color(_cx - 2, _cy - 2, _cx + _bw + 2, _cy + _bh + 2, c_white, c_white, c_white, c_white, true)
	} else {
		draw_rectangle_color(_cx, _cy, _cx + _bw, _cy + _bh, _bgcol, _bgcol, _bgcol, _bgcol, true)
	}

	// Custom or generic panel content
	if !is_undefined(draw_item) {
		draw_item(i, _item, _cx, _cy, _bw, _bh)
	} else {
		// Generic: icon centered at top, name below, desc below that
		if variable_struct_exists(_item, "sprite") and _item.sprite != -1 {
			var _spr   = _item.sprite
			var _scale = max(1, floor(96 / sprite_get_width(_spr)))
			var _sz    = sprite_get_width(_spr) * _scale
			draw_sprite_ext(_spr, 0, _cx + _bw / 2 - _sz / 2, _cy + 16, _scale, _scale, 0, c_white, 1)
		}
		var _nameX = _cx + _bw / 2 - string_width(_item.name) / 2
		draw_set_color(c_black)
		draw_text(_nameX + _offset, _cy + 124 + _offset, _item.name)
		draw_set_color(_filtered ? c_gray : c_white)
		draw_text(_nameX, _cy + 124, _item.name)
		if variable_struct_exists(_item, "desc") and _item.desc != "" {
			draw_set_color(c_black)
			draw_text_ext(_cx + 20 + _offset, _cy + 170 + _offset, _item.desc, 36, _bw - 40)
			draw_set_color(c_ltgray)
			draw_text_ext(_cx + 20, _cy + 170, _item.desc, 36, _bw - 40)
		}
	}
}
