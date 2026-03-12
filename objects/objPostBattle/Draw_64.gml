// Dark overlay
draw_set_alpha(0.7)
draw_set_colour(c_black)
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false)
draw_set_alpha(1.0)

var _gw = display_get_gui_width()
var _gh = display_get_gui_height()
var _cx = _gw div 2
var _top = _gh * 0.15
var _s = 2 // text scale factor

// Header
draw_set_font(GoldenSunItalicBig)
draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_set_colour(#FFD700)
draw_text_transformed(_cx, _top, "BATTLE RESULTS", _s, _s, 0)

// Player rows
draw_set_font(GoldenSunItalic)
var _rowY = _top + 120
var _rowH = 140

for (var i = 0; i < array_length(global.players); i++) {
	var _p = global.players[i]
	var _y = _rowY + i * _rowH

	// Name
	draw_set_halign(fa_left)
	draw_set_colour(c_white)
	draw_text_transformed(_cx - 500, _y, _p.name, _s, _s, 0)

	// HP bar background
	var _barX = _cx - 100
	var _barW = 400
	var _barH = 32
	var _barY = _y + 8
	draw_set_colour(c_dkgray)
	draw_rectangle(_barX, _barY, _barX + _barW, _barY + _barH, false)

	// HP bar fill
	var _hpRatio = _p.hp / _p.hpmax
	if _hpRatio > 0.5 { draw_set_colour(c_green) }
	else if _hpRatio > 0.25 { draw_set_colour(c_yellow) }
	else { draw_set_colour(c_red) }
	if _p.hp > 0 {
		draw_rectangle(_barX, _barY, _barX + _barW * _hpRatio, _barY + _barH, false)
	}

	// HP text
	draw_set_colour(c_white)
	draw_set_halign(fa_right)
	draw_text_transformed(_barX + _barW + 120, _y+16, string(_p.hp) + "/" + string(_p.hpmax), _s, _s, 0)
	
	// PP bar background
	var _barX = _cx - 100
	var _barW = 400
	var _barH = 32
	var _barY = _y + 16+32
	draw_set_colour(c_dkgray)
	draw_rectangle(_barX, _barY, _barX + _barW, _barY + _barH, false)

	// PP bar fill
	var _ppRatio = _p.pp / _p.ppmax
	draw_set_colour(c_purple)
	if _p.pp > 0 {
		draw_rectangle(_barX, _barY, _barX + _barW * _ppRatio, _barY + _barH, false)
	}

	// PP text
	draw_set_colour(c_white)
	draw_set_halign(fa_right)
	draw_text_transformed(_barX + _barW + 120, _y+48+8, string(_p.pp) + "/" + string(_p.ppmax), _s, _s, 0)
	
	// Card drawn (with item sprite)
	draw_set_halign(fa_left)
	draw_set_colour(#CCCCCC)
	if i < array_length(draws) {
		var _drawInfo = draws[i]
		var _sprAlias = global.itemcardlist[_drawInfo.item_index].alias
		var _spr = asset_get_index(_sprAlias)
		var _sprX = _cx - 500
		var _textX = _sprX
		if _spr != -1 {
			draw_sprite_stretched(_spr, 0, _sprX, _y + 48, 48, 48)
			_textX = _sprX + 56
		}
		if _drawInfo.discarded{
			draw_text_transformed(_textX, _y + 56, "Drew: " + _drawInfo.card_name + " (Discarded, inventory full)", _s, _s, 0)
		}else{
			draw_text_transformed(_textX, _y + 56, "Drew: " + _drawInfo.card_name, _s, _s, 0)
		}
	}
}

// Gold earned
draw_set_halign(fa_center)
draw_set_colour(#FFD700)
var _goldY = _rowY + 4 * _rowH + 20
if (goldEarned == 0 && array_length(draws) == 0) {
	draw_text_transformed(_cx, _goldY, "Enemy fled!", _s, _s, 0)
} else {
	draw_text_transformed(_cx, _goldY, "Gold earned: +" + string(goldEarned), _s, _s, 0)
}

// Click prompt
draw_set_colour(#AAAAAA)
draw_text_transformed(_cx, _goldY + 100, "[ Click to continue ]", _s, _s, 0)

// Reset
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_colour(c_white)
