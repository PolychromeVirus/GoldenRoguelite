draw_set_font(GoldenSun)
var offset = 4

// Background panel
var _panelx = 300
var _panely = 100
var _panelw = 960
var _panelh = 600
draw_set_alpha(0.9)
draw_set_color(c_black)
draw_roundrect(_panelx, _panely, _panelx + _panelw, _panely + _panelh, false)
draw_set_alpha(1)
draw_set_color(c_white)
draw_roundrect(_panelx, _panely, _panelx + _panelw, _panely + _panelh, true)

// Title
draw_set_halign(fa_center)
draw_set_color(c_white)
draw_text(_panelx + _panelw/2, _panely + 16, "Replace equipped armor?")
draw_set_halign(fa_left)

var _old = global.itemcardlist[old_item]
var _new = global.itemcardlist[new_item]

// Left side — current equipped
var _lx = _panelx + 40
var _ly = _panely + 60

draw_set_color(c_grey)
draw_text(_lx, _ly, "Currently Equipped:")
_ly += 32

if asset_get_index(_old.alias) != -1 {
	draw_sprite_stretched(asset_get_index(_old.alias), 0, _lx, _ly, 48, 48)
}
draw_set_color(global.c_important)
draw_text(_lx + 56, _ly + 8, _old.name)
_ly += 64
draw_set_color(c_white)
var _oldtext = _old.text
if string_length(_oldtext) > 180 { _oldtext = string_delete(_oldtext, 180, string_length(_oldtext) - 119) + "..." }
draw_text_ext(_lx, _ly, _oldtext, 32, 380)

// Arrow in center
draw_set_halign(fa_center)
draw_set_color(c_yellow)
draw_text(_panelx + _panelw/2, _panely + 140, ">>>")
draw_set_halign(fa_left)

// Right side — new item
var _rx = _panelx + _panelw/2 + 40
var _ry = _panely + 60

draw_set_color(c_grey)
draw_text(_rx, _ry, "New Item:")
_ry += 32

if asset_get_index(_new.alias) != -1 {
	draw_sprite_stretched(asset_get_index(_new.alias), 0, _rx, _ry, 48, 48)
}
draw_set_color(c_white)
draw_text(_rx + 56, _ry + 8, _new.name)
_ry += 64
draw_set_color(c_white)
var _newtext = _new.text
if string_length(_newtext) > 180 { _newtext = string_delete(_newtext, 180, string_length(_newtext) - 119) + "..." }
draw_text_ext(_rx, _ry, _newtext, 32, 380)