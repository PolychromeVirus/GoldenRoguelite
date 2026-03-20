draw_set_font(GoldenSun)

// Background
draw_sprite_ext(TestMenu, 0, 0, 0, 6, 6, 0, c_white, 1)

// Title
draw_set_color(c_white)
var _guiW   = display_get_gui_width()
var _guiH   = 720
var _cen = display_get_gui_width() / 2
var _title  = "Party Status"

var _titw = string_width(_title) / 2


var c = global.c_menu

draw_rectangle_colour(_cen-_titw, 0,_cen + _titw, string_height(_title)+9,c,c,c,c,false)

draw_rich_text((_guiW / 2) - (string_width(_title) / 2), 0, _title,1000)

//draw_set_colour(c_black)
//draw_text(_guiW / 2, 0, _title)
//draw_set_colour(c_white)
//draw_text(_guiW / 2, 0, _title)
draw_set_halign(fa_left)

var _pad    = 47
var _gap    = 10
var _top    = 50
var _slotW  = (_guiW - _pad * 2 - _gap) / 2
var _slotH  = floor((_guiH - _top - _pad - _gap) / 2)
var _cellW   = 500
var _iconSz  = 32
var _equipSz = 32
var _starSz  = 24
var _offset  = 4

var _elements = [
    { res_field: "vres",  die_field: "venus",   col: global.c_venus,   spr: Venus_Star   },
    { res_field: "mares", die_field: "mars",    col: global.c_mars,    spr: Mars_Star    },
    { res_field: "jres",  die_field: "jupiter", col: global.c_jupiter, spr: Jupiter_Star },
    { res_field: "meres", die_field: "mercury", col: global.c_mercury, spr: Mercury_Star },
]

for (var _i = 0; _i < array_length(global.players); _i++) {
    var _p  = global.players[_i]
    var _cx = _pad + (_i mod 2) * (_slotW + _gap)
    var _cy = _top + (_i div 2) * (_slotH + _gap)

    DrawCharCell(_i, _cx, _cy, false, false)

    // --- Element column (right of DrawCharCell) ---
    var _ex = _cx + _cellW - 15
    var _ey = _cy + 10
    for (var _e = 0; _e < 4; _e++) {
        var _el  = _elements[_e]
        var _res = variable_struct_get(_p, _el.res_field)
        var _die = variable_struct_get(_p, _el.die_field)
        var _mod = max(1, _die div 2)
        draw_sprite_stretched(_el.spr, 0, _ex, _ey+4, _starSz, _starSz)
        var _txt = "RES " + string(_res) + " | " + string(_mod)
        var _tx  = _ex + _starSz + 12
        draw_set_color(c_black)
        draw_text(_tx + _offset, _ey + _offset, _txt)
        draw_set_color(_el.col)
        draw_text(_tx, _ey, _txt)
        _ey += _starSz + 8
    }

    // --- Weapon proficiency row (immediately under equipment row: cy+144+32+4) ---
    var _wpTypes = [
        { spr: Short_Sword,  can: _p.equipshort },
        { spr: Long_Sword,   can: _p.equiplong  },
        { spr: Battle_Axe,   can: _p.equipaxe   },
        { spr: Mace,         can: _p.equipmace  },
        { spr: Wooden_Stick, can: _p.equipstaff },
    ]
    var _wpx = _cx
    var _wpy = _cy + 180
    for (var _w = 0; _w < 5; _w++) {
        draw_set_alpha(_wpTypes[_w].can ? 1.0 : 0.2)
        draw_sprite_stretched(_wpTypes[_w].spr, 0, _wpx, _wpy, _equipSz, _equipSz)
        draw_set_alpha(1)
        _wpx += _equipSz + 4
	}

    // --- Spell icons ---
    var _spx = _cx
    var _spy = _wpy + _equipSz + 4
    for (var _s = 0; _s < array_length(_p.spells); _s++) {
        var _sspr = asset_get_index(global.psynergylist[_p.spells[_s]].alias)
        if _sspr == -1 { continue }
        draw_sprite_stretched(_sspr, 0, _spx, _spy, _iconSz, _iconSz)
        _spx += _iconSz + 3
        if _spx > _cx + _slotW - _iconSz { break }
    }
	
	// --- Djinn row ---
    var _djx = _cx
    var _djy = _spy + _iconSz + 4
    for (var _d = 0; _d < array_length(_p.djinn); _d++) {
        var _dj  = global.djinnlist[_p.djinn[_d]]
        var _spr = asset_get_index(_dj.element + "_Star_Clean")
        if _spr == -1 { _spr = Djinni }
        draw_set_alpha(_dj.ready ? 1.0 : 0.35)
        draw_sprite_stretched(_spr, 0, _djx, _djy, _iconSz, _iconSz)
        draw_set_alpha(1)
        _djx += _iconSz + 3
    }
	
	
}

draw_set_alpha(1)
draw_set_color(c_white)
