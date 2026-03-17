/// @func DrawCharCell(player_index, cx, cy, greyed, hovered)
/// @desc Draw one character panel at (cx, cy). Used by objMenuGrid and stat displays.
function DrawCharCell(player_index, cx, cy, greyed, hovered) {
    var _p           = global.players[player_index]
    var portraitSize = 128
    var barW         = 200
    var itemSize     = 32
    var cellW        = 500
    var _offset      = 4

    draw_set_font(GoldenSun)

    // Background highlight
    if hovered and !greyed {
        draw_set_alpha(0.15)
        draw_set_color(c_white)
        draw_rectangle(cx, cy, cx + cellW - 4, cy + 196, false)
        draw_set_alpha(1.0)
    }

    // Portrait
    if _p.portrait != -1 {
        if greyed { draw_set_alpha(0.4) }
        draw_sprite_stretched(_p.portrait, 0, cx, cy, portraitSize, portraitSize)

        if variable_struct_exists(_p, "heal_flash") and _p.heal_flash > 0 {
            gpu_set_blendmode(bm_add)
            draw_set_color(c_lime)
            draw_set_alpha(0.4)
            draw_rectangle(cx, cy, cx + portraitSize, cy + portraitSize, false)
            draw_set_alpha(1.0)
            gpu_set_blendmode(bm_normal)
        }
        if variable_struct_exists(_p, "flash_timer") and _p.flash_timer > 0 {
            gpu_set_blendmode(bm_add)
            draw_set_color(c_red)
            draw_set_alpha(0.4)
            draw_rectangle(cx, cy, cx + portraitSize, cy + portraitSize, false)
            draw_set_alpha(1.0)
            gpu_set_blendmode(bm_normal)
        }
        draw_set_alpha(1.0)
    }

    // Name
    var _bx     = cx + portraitSize + 8
    var _name_y = cy + 4
    draw_set_color(c_black)
    draw_text(_bx + _offset, _name_y + _offset, _p.name)
    draw_set_color(greyed ? c_grey : c_white)
    draw_text(_bx, _name_y, _p.name)

    // HP bar
    var _text_h  = string_height("HP")
    var _barH    = 16
    var _hp_text = string(_p.hp) + "/" + string(_p.hpmax) + " HP"
    var _hpTextY = _name_y + _text_h + 8
    var _hpBarY  = _hpTextY + _text_h - _barH - 4
    var _hp_ratio = (_p.hpmax > 0) ? _p.hp / _p.hpmax : 0
    draw_rectangle_color(_bx, _hpBarY, _bx + barW, _hpBarY + _barH, c_red, c_red, c_red, c_red, false)
    var _hp_fill = greyed ? c_grey : c_blue
    draw_rectangle_color(_bx, _hpBarY, _bx + barW * _hp_ratio, _hpBarY + _barH, _hp_fill, _hp_fill, _hp_fill, _hp_fill, false)
    draw_set_color(c_black)
    draw_text(_bx + _offset, _hpTextY + _offset, _hp_text)
    draw_set_color(greyed ? c_grey : c_white)
    draw_text(_bx, _hpTextY, _hp_text)

    // PP bar
    var _pp_text = string(_p.pp) + "/" + string(_p.ppmax) + " PP"
    var _ppTextY = _hpBarY + _barH + 8
    var _ppBarY  = _ppTextY + _text_h - _barH - 4
    var _pp_ratio = (_p.ppmax > 0) ? _p.pp / _p.ppmax : 0
    draw_rectangle_color(_bx, _ppBarY, _bx + barW, _ppBarY + _barH, c_red, c_red, c_red, c_red, false)
    var _pp_fill = greyed ? c_grey : c_blue
    draw_rectangle_color(_bx, _ppBarY, _bx + barW * _pp_ratio, _ppBarY + _barH, _pp_fill, _pp_fill, _pp_fill, _pp_fill, false)
    draw_set_color(c_black)
    draw_text(_bx + _offset, _ppTextY + _offset, _pp_text)
    draw_set_color(greyed ? c_grey : c_white)
    draw_text(_bx, _ppTextY, _pp_text)

    // ATK / DEF stats
    var _stat_x   = _bx + barW + 10
    var _atkmod_display = variable_struct_exists(_p, "atkmod") ? _p.atkmod : 0
    if (_p.name == "Garet" or _p.name == "Tyrell") { _atkmod_display *= 2 }
    var _atk_total = _p.atk + _atkmod_display
    var _def_total = _p.def + (variable_struct_exists(_p, "defmod") ? _p.defmod : 0)
    var _atk_str  = "ATK " + string(_atk_total)
    var _def_str  = "DEF " + string(_def_total)
    draw_set_color(c_black)
    draw_text(_stat_x + _offset, _hpTextY + _offset, _atk_str)
    var _atk_col = greyed ? c_grey : c_white
    if !greyed and variable_struct_exists(_p, "atkmod") {
        if _p.atkmod > 0 { _atk_col = c_lime }
        else if _p.atkmod < 0 { _atk_col = c_red }
    }
    draw_set_color(_atk_col)
    draw_text(_stat_x, _hpTextY, _atk_str)
    draw_set_color(c_black)
    draw_text(_stat_x + _offset, _ppTextY + _offset, _def_str)
    var _def_col = greyed ? c_grey : c_white
    if !greyed and variable_struct_exists(_p, "defmod") {
        if _p.defmod > 0 { _def_col = c_lime }
        else if _p.defmod < 0 { _def_col = c_red }
    }
    draw_set_color(_def_col)
    draw_text(_stat_x, _ppTextY, _def_str)

    // Equipment row
    var _ex = cx
    var _ey = cy + portraitSize + _barH

    var _wspr = asset_get_index(global.itemcardlist[_p.weapon].alias)
    if _wspr != -1 {
        if greyed { draw_set_alpha(0.4) }
        draw_sprite_stretched(_wspr, 0, _ex, _ey, itemSize, itemSize)
        draw_set_alpha(1.0)
    }
    _ex += itemSize + 2

    for (var _a = 0; _a < 4; _a++) {
        var _aspr = Blank_Item
        if _a < array_length(_p.armor) and _p.armor[_a] != -1 {
            _aspr = asset_get_index(global.itemcardlist[_p.armor[_a]].alias)
            if _aspr == -1 { _aspr = Blank_Item }
        }
        if greyed { draw_set_alpha(0.4) }
        draw_sprite_stretched(_aspr, 0, _ex, _ey, itemSize, itemSize)
        draw_set_alpha(1.0)
        _ex += itemSize + 2
    }

    _ex += 8

    for (var _v = 0; _v < 5; _v++) {
        var _ispr = Blank_Item
        if _v < array_length(_p.inventory) and _p.inventory[_v] != -1 {
            _ispr = asset_get_index(global.itemcardlist[_p.inventory[_v]].alias)
            if _ispr == -1 { _ispr = Blank_Item }
        }
        if greyed { draw_set_alpha(0.4) }
        draw_sprite_stretched(_ispr, 0, _ex, _ey, itemSize, itemSize)
        draw_set_alpha(1.0)
        _ex += itemSize + 2
    }

    // Status icons — same row as equipment, continuing from inventory
    _ex += 8
    var _iconSize = 28

    if variable_struct_exists(_p, "atkmod") and _p.atkmod != 0 {
        draw_sprite_stretched(_p.atkmod > 0 ? attack_up : attack_down, 0, _ex, _ey, _iconSize, _iconSize)
        _ex += _iconSize + 2
    }
    if variable_struct_exists(_p, "defmod") and _p.defmod != 0 {
        draw_sprite_stretched(_p.defmod > 0 ? defense_up : defense_down, 0, _ex, _ey, _iconSize, _iconSize)
        _ex += _iconSize + 2
    }

    var _statarray = GetStatus(_p)
    for (var _j = 0; _j < array_length(_statarray); _j++) {
        draw_sprite_stretched(_statarray[_j], 0, _ex, _ey, _iconSize, _iconSize)
        _ex += _iconSize + 2
    }

    if variable_struct_exists(_p, "rootTokens") and _p.rootTokens > 0 {
        draw_sprite_stretched(Growth, 0, _ex, _ey, _iconSize, _iconSize)
        _ex += _iconSize + 2
    }
    if variable_struct_exists(_p, "regen") and _p.regen > 0 {
        draw_sprite_stretched(Ply, 0, _ex, _ey, _iconSize, _iconSize)
        _ex += _iconSize + 2
    }
    if variable_struct_exists(_p, "cloak") and _p.cloak {
        draw_sprite_stretched(Cloak, 0, _ex, _ey, _iconSize, _iconSize)
        _ex += _iconSize + 2
    }

    draw_set_color(c_white)
}
