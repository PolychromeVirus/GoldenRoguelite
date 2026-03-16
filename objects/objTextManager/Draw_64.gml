if global.gameover {
    if global.gameover_timer < 180 {
        var _fade = 1 - (global.gameover_timer / 180)
        draw_set_alpha(_fade)
        draw_set_color(c_black)
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false)
        draw_set_alpha(1)
    }
    exit
}

// ── Scan menu stack for any carousel (occupies a half of the screen) ──────────
var _half_open    = false
var _half_side    = "left"   // side the menu occupies ("left" or "right")
var _show_compact = true     // false when a full-pane description is present (no room for compact HUD)
for (var _si = array_length(global.menu_stack) - 1; _si >= 0; _si--) {
    var _sinst = global.menu_stack[_si]
    if !instance_exists(_sinst) { continue }
    var _oi = _sinst.object_index
    if _oi == objMenuCarousel or _oi == objItemMenu or _oi == objTownShop {
        _half_open = true
        _half_side = variable_instance_exists(_sinst, "side") ? _sinst.side : "left"
        // Full description pane (half-screen) leaves no space for compact HUD
        if _oi == objTownShop { _show_compact = false; break }
        var _desc = variable_instance_exists(_sinst, "description") ? _sinst.description : "none"
        if _desc == "half" { _show_compact = false }
        break
    }
}

draw_set_font(GoldenSun)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

var offset = 4

// ── TOP BAR ───────────────────────────────────────────────────────────────────
var _targeting = (instance_number(objMonsterTarget) > 0)

if global.charselect == false and !_targeting {

    var _guiW        = display_get_gui_width()
    var _portraitFull = 144
    var _scale        = 0.79
    var _portraitSize = round(_portraitFull * _scale)
    var _portraitOffset = (_portraitFull - _portraitSize) / 2
    var _portraitGap  = 2
    var _margin       = 3
    var _endMargin    = 15
    var _barH         = 16
    var _nameH        = string_height("HP:")

    if _half_open and _show_compact {
        // ── COMPACT MODE: single current-player cell ──────────────────────────
        var _hw = sprite_get_width(HalfMenu)   // half the screen width in room px → GUI at 6x
        // Position compact HUD on the side NOT occupied by the carousel
        var _cell_x = (_half_side == "left") ? (_hw * 6) : 0

        draw_sprite_ext(HUDsmall, 0, _cell_x, 0, 6, 6, 0, c_white, 1)

        var _p    = global.players[global.turn]
        var _colX = _cell_x + _margin + 12
        var _infoX = _colX + _portraitFull + _portraitGap

        // Portrait
        var _alpha = (_p.hp > 0) ? 1 : 0.5
        draw_sprite_stretched_ext(_p.portrait, 0,
            _colX + _portraitOffset+6, _portraitOffset+21,
            _portraitSize, _portraitSize, c_white, _alpha)

        // Heal flash
        if _p.heal_flash > 0 {
            draw_set_alpha(_p.heal_flash / 12)
            draw_set_colour(c_lime)
            draw_rectangle(_colX + _portraitOffset, _portraitOffset,
                           _colX + _portraitOffset + _portraitSize,
                           _portraitOffset + _portraitSize, false)
            draw_set_alpha(1)
            _p.heal_flash--
        }

        // Damage flash
        if _p.flash_timer > 0 {
            gpu_set_blendmode(bm_add)
            draw_sprite_stretched_ext(_p.portrait, 0,
                _colX + _portraitOffset, _portraitOffset,
                _portraitSize, _portraitSize, c_red, _p.flash_timer / 12)
            gpu_set_blendmode(bm_normal)
            _p.flash_timer--
        }

        // Bars + text
        var hpdiff = _p.hp  / _p.hpmax
        var ppdiff = _p.pp  / _p.ppmax
        var _barW  = sprite_get_width(HUDsmall) * 6 - _portraitFull - _portraitGap - 52 - 32
        var _portBot  = _portraitFull - 1 - _portraitOffset - 6
        var _ppBarY   = _portBot - _barH+18
        var _ppTextY  = _ppBarY - _nameH / 2 + 5
        var _hpBarY   = _ppTextY - _barH - 8
        var _hpTextY  = _hpBarY - _nameH / 2 + 5
        var _nameY    = _hpTextY - (_ppTextY - _hpTextY)

        draw_set_color(c_black)
        draw_text(_infoX + offset, _nameY + offset, _p.name)
        draw_set_color(c_white)
        draw_text(_infoX, _nameY, _p.name)

        draw_rectangle_color(_infoX, _hpBarY, _infoX + _barW, _hpBarY + _barH, c_red, c_red, c_red, c_red, false)
        draw_rectangle_color(_infoX, _hpBarY, _infoX + (_barW * hpdiff), _hpBarY + _barH, c_blue, c_blue, c_blue, c_blue, false)
        var _hptext = string(_p.hp) + "/" + string(_p.hpmax) + " HP"
        draw_set_color(c_black)
        draw_text(_infoX + offset, _hpTextY + offset, _hptext)
        draw_set_color(c_white)
        draw_text(_infoX, _hpTextY, _hptext)

        draw_rectangle_color(_infoX, _ppBarY, _infoX + _barW, _ppBarY + _barH, c_red, c_red, c_red, c_red, false)
        draw_rectangle_color(_infoX, _ppBarY, _infoX + (_barW * ppdiff), _ppBarY + _barH, c_blue, c_blue, c_blue, c_blue, false)
        var _pptext = string(_p.pp) + "/" + string(_p.ppmax) + " PP"
        draw_set_color(c_black)
        draw_text(_infoX + offset, _ppTextY + offset, _pptext)
        draw_set_color(c_white)
        draw_text(_infoX, _ppTextY, _pptext)

        // Status tokens
        var _tokenX = _infoX + string_width(_p.name) + 2
        var _tokenY = _nameY + 6
        if _p.atkmod < 0 { draw_sprite_stretched(attack_down,  0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if _p.defmod < 0 { draw_sprite_stretched(defense_down, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if _p.atkmod > 0 { draw_sprite_stretched(attack_up,    0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if _p.defmod > 0 { draw_sprite_stretched(defense_up,   0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if _p.poison      { draw_sprite_stretched(Poison,       0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if _p.venom       { draw_sprite_stretched(Poison,       0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if _p.stun > 0    { draw_sprite_stretched(Bolt,         0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if _p.sleep       { draw_sprite_stretched(Sleep,        0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if _p.rootTokens > 0 { draw_sprite_stretched(Growth,   0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if _p.regen       { draw_sprite_stretched(Ply,          0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if _p.cloak       { draw_sprite_stretched(Cloak,        0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if array_length(_p.rerolls) > 0 { draw_sprite_stretched(Lucky_Medal1503, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
        if variable_struct_exists(_p.delaydata, "revive") and _p.delaydata.revive { draw_sprite_stretched(Revive, 0, _tokenX, _tokenY, 24, 24) }

    } else {
        // ── FULL MODE: all players ────────────────────────────────────────────
        var _colW  = (_guiW - _margin - _endMargin) / array_length(global.players)
        var _barW  = _colW - _portraitFull - _portraitGap - 40

        draw_sprite(topbar, 0, 0, 0)

        for (var i = 0; i < array_length(global.players); i++) {
            var _p    = global.players[i]
            var _colX = _margin + i * _colW
            var _infoX = _colX + _portraitFull + _portraitGap
            var texty = 3

            // Portrait
            if _p.hp > 0 { draw_sprite_stretched_ext(_p.portrait, 0, _colX + _portraitOffset, texty + _portraitOffset, _portraitSize, _portraitSize, c_white, 1) }
            else          { draw_sprite_stretched_ext(_p.portrait, 0, _colX + _portraitOffset, texty + _portraitOffset, _portraitSize, _portraitSize, c_white, .5) }

            // Heal flash
            if _p.heal_flash > 0 {
                draw_set_alpha(_p.heal_flash / 12)
                draw_set_colour(c_lime)
                draw_rectangle(_colX + _portraitOffset, texty + _portraitOffset,
                               _colX + _portraitOffset + _portraitSize,
                               texty + _portraitOffset + _portraitSize, false)
                draw_set_alpha(1.0)
                _p.heal_flash--
            }

            // Damage flash
            if _p.flash_timer > 0 {
                gpu_set_blendmode(bm_add)
                draw_sprite_stretched_ext(_p.portrait, 0, _colX + _portraitOffset, texty + _portraitOffset,
                                          _portraitSize, _portraitSize, c_red, _p.flash_timer / 12)
                gpu_set_blendmode(bm_normal)
                _p.flash_timer--
            }

            var hpdiff = _p.hp / _p.hpmax
            var ppdiff = _p.pp / _p.ppmax

            var _portBot  = texty + _portraitFull - 1 - _portraitOffset - 6
            var _ppBarY   = _portBot - _barH
            var _ppTextY  = _ppBarY - _nameH / 2 + 5
            var _hpBarY   = _ppTextY - _barH - 8
            var _hpTextY  = _hpBarY - _nameH / 2 + 5
            var _nameY    = _hpTextY - (_ppTextY - _hpTextY)

            draw_set_color(c_black)
            draw_text(_infoX + offset, _nameY + offset, _p.name)
            draw_set_color(c_white)
            draw_text(_infoX, _nameY, _p.name)

            draw_rectangle_color(_infoX, _hpBarY, _infoX + _barW, _hpBarY + _barH, c_red, c_red, c_red, c_red, false)
            draw_rectangle_color(_infoX, _hpBarY, _infoX + (_barW * hpdiff), _hpBarY + _barH, c_blue, c_blue, c_blue, c_blue, false)
            var _hptext = string(_p.hp) + "/" + string(_p.hpmax) + " HP"
            draw_set_color(c_black)
            draw_text(_infoX + offset, _hpTextY + offset, _hptext)
            draw_set_color(c_white)
            draw_text(_infoX, _hpTextY, _hptext)

            draw_rectangle_color(_infoX, _ppBarY, _infoX + _barW, _portBot, c_red, c_red, c_red, c_red, false)
            draw_rectangle_color(_infoX, _ppBarY, _infoX + (_barW * ppdiff), _portBot, c_blue, c_blue, c_blue, c_blue, false)
            var _pptext = string(_p.pp) + "/" + string(_p.ppmax) + " PP"
            draw_set_color(c_black)
            draw_text(_infoX + offset, _ppTextY + offset, _pptext)
            draw_set_color(c_white)
            draw_text(_infoX, _ppTextY, _pptext)

            // Status tokens
            var _tokenX = _infoX + string_width(_p.name) + 2
            var _tokenY = _nameY + 6
            if _p.atkmod < 0 { draw_sprite_stretched(attack_down,  0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if _p.defmod < 0 { draw_sprite_stretched(defense_down, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if _p.atkmod > 0 { draw_sprite_stretched(attack_up,    0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if _p.defmod > 0 { draw_sprite_stretched(defense_up,   0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if _p.poison      { draw_sprite_stretched(Poison,       0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if _p.venom       { draw_sprite_stretched(Poison,       0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if _p.stun > 0    { draw_sprite_stretched(Bolt,         0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if _p.sleep       { draw_sprite_stretched(Sleep,        0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if _p.rootTokens > 0 { draw_sprite_stretched(Growth,   0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if _p.regen       { draw_sprite_stretched(Ply,          0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if _p.cloak       { draw_sprite_stretched(Cloak,        0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if array_length(_p.rerolls) > 0 { draw_sprite_stretched(Lucky_Medal1503, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
            if variable_struct_exists(_p.delaydata, "revive") and _p.delaydata.revive { draw_sprite_stretched(Revive, 0, _tokenX, _tokenY, 24, 24) }
            draw_sprite(topframe, 0, 0, 0)
        }
    }
}

// ── OVERWORLD: floor challenge progress ───────────────────────────────────────
// Exit unless a half-menu is open (compact mode needs to show dice for out-of-combat spells)
if !global.inCombat and !_half_open {
    if !global.pause and array_length(global.floorChallenges) > 0 and !global.inTown {
        var _done = 0
        for (var _ci = 0; _ci < array_length(global.floorChallenges); _ci++) {
            if global.floorChallenges[_ci].completed { _done++ }
        }
        draw_set_font(GoldenSun)
        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        var _tx = 36
        var _ty = 195
        var _met = (_done >= global.floorRequired)
        var _floor_text     = (global.floorName != "") ? global.floorName : ("Floor " + string(global.dungeonFloor))
        var _challenge_text = "Challenges: " + string(_done) + " / " + string(global.floorRequired)
        var _line_h = string_height("A")
        draw_sprite(secondbar, 0, 0, 0)
        draw_set_color(c_black)
        draw_text(_tx + offset, _ty + offset, _floor_text)
        draw_set_color(c_white)
        draw_text(_tx, _ty, _floor_text)
        draw_set_color(c_black)
        draw_text(_tx + offset, _ty + _line_h + offset, _challenge_text)
        draw_set_color(_met ? c_lime : c_white)
        draw_text(_tx, _ty + _line_h, _challenge_text)
    }
    exit
}

if !global.inCombat and global.turnPhase == "enemy" { exit }
if global.gameover { exit }

// ── DICE DISPLAY ──────────────────────────────────────────────────────────────
var dpool = global.players[global.turn].dicepool
if array_length(dpool) == 0 { exit }
if global.pause and !isCombatMenu() and !_half_open { exit }

var player = global.players[global.turn]
var charge = GetChargedDice(player)
var cmap   = charge.charged_map

var _pipbonus = 0
if array_contains(player.armor, FindItemID("Guardian Ring")) { _pipbonus += 1 }
if array_contains(player.armor, FindItemID("Fairy Ring"))    { _pipbonus -= 1 }

var dicesize = 44
var dicepad  = 5
var groupgap = 10

// Layout depends on whether a carousel/item menu is occupying a half
var startx, starty, _dice_wrap, _eq_infoX, _eq_y
if _half_open and _show_compact {
    var _cell_x   = (_half_side == "left") ? (sprite_get_width(HalfMenu) * 6) : 0
    var _hud_w    = sprite_get_width(HUDsmall) * 6
    _eq_infoX     = _cell_x + _hud_w + 8              // right of HUDsmall
    _eq_y         = 8                                  // top-aligned, stacks vertically
    startx        = _eq_infoX + 32 + 4 + 8            // right of equipment column
    starty        = 8
    _dice_wrap    = 6
} else {
    startx     = 36
    starty     = 170
    _dice_wrap = 999
    _eq_infoX  = 0
    _eq_y      = 0
}

if isCombatMenu() and !_half_open {
    startx    = 800
    starty    = 75
    _eq_infoX = 0
    _eq_y     = 0
}

var pool_colors  = [0x303030, #ffe45f, #ff8585, #e7abff, #a6c9ff]
var pool_outline = [0x101010, #F87000, #801010, #602060, #104060]

var cx       = startx
var cy       = starty
var _col_idx = 0   // tracks position within current row for wrapping
draw_set_font(GoldenSun)

for (var p = 0; p < array_length(dpool); p++) {
    var pool     = dpool[p]
    var pool_row = cmap[p]
    if array_length(pool) == 0 { continue }

    for (var i = 0; i < array_length(pool); i++) {
        // Wrap to next row after _dice_wrap dice
        if _col_idx > 0 and (_col_idx mod _dice_wrap) == 0 {
            cx       = startx
            cy      += dicesize + dicepad
        }

        var pip        = clamp(pool[i] + _pipbonus, 0, 6)
        var is_charged = pool_row[i]
        var col        = pool_colors[p]

        if !is_charged {
            var r = (col & 0xFF)
            var g = ((col >> 8) & 0xFF)
            var b = ((col >> 16) & 0xFF)
            col = make_color_rgb(floor(r * 0.45), floor(g * 0.45), floor(b * 0.45))
        }

        draw_rectangle_color(cx, cy, cx+dicesize, cy+dicesize, col, col, col, col, false)

        if is_charged {
            draw_rectangle_color(cx-2, cy-2, cx+dicesize+2, cy+dicesize+2,
                c_white, c_white, c_white, c_white, true)
        } else {
            draw_rectangle_color(cx, cy, cx+dicesize, cy+dicesize,
                make_color_rgb(60,60,60), make_color_rgb(60,60,60),
                make_color_rgb(60,60,60), make_color_rgb(60,60,60), true)
        }

        var numstr = string(pip)
        var tx = cx + floor((dicesize - string_width(numstr))  / 2) + 3
        var ty = cy  + floor((dicesize - string_height(numstr)) / 2) + 3

        if is_charged and pip != 0 {
            draw_set_color(pool_outline[p])
            draw_text(tx + offset, ty, numstr)
            draw_text(tx - offset, ty, numstr)
            draw_text(tx, ty + offset, numstr)
            draw_text(tx, ty - offset, numstr)
        }
        draw_set_color(c_white)
        if pip != 0 { draw_text(tx, ty, numstr) }

        cx += dicesize + dicepad
        _col_idx++
    }
    if !_half_open { cx += groupgap }
}

// Equipment strip — compact mode only
if _half_open and _show_compact {
    var _pl   = global.players[global.turn]
    var _eqx  = _eq_infoX
    var _eqy  = _eq_y
    var _eqsz = 32
    var _eqpad = 4

    // Vertical array to the right of the compact HUD
    var _wspr = asset_get_index(global.itemcardlist[_pl.weapon].alias)
    if _wspr != -1 { draw_sprite_stretched(_wspr, 0, _eqx, _eqy, _eqsz, _eqsz) }
    else            { draw_sprite_stretched(Blank_Item, 0, _eqx, _eqy, _eqsz, _eqsz) }
    _eqy += _eqsz + _eqpad

    for (var _ai = 0; _ai < 4; _ai++) {
        var _aspr = -1
        if _ai < array_length(_pl.armor) {
            _aspr = asset_get_index(global.itemcardlist[_pl.armor[_ai]].alias)
        }
        if _aspr != -1 { draw_sprite_stretched(_aspr, 0, _eqx, _eqy, _eqsz, _eqsz) }
        else            { draw_sprite_stretched(Blank_Item, 0, _eqx, _eqy, _eqsz, _eqsz) }
        _eqy += _eqsz + _eqpad
    }
}

// ── PASSIVE VISUALIZER ────────────────────────────────────────────────────────
var _pvx = 16
var _pvy = 160
draw_set_halign(fa_center)
draw_set_font(GoldenSun)
for (var i = 0; i < array_length(global.passiveEffects); i++) {
    draw_sprite_stretched(global.passiveEffects[i].sprite, 0, _pvx, _pvy, 64, 64)
    if global.passiveEffects[i].countdown != -1 {
        draw_set_color(c_black)
        draw_text(_pvx + 16 + 4, _pvy + 36 + 4, string(global.passiveEffects[i].countdown))
        draw_set_color(c_white)
        draw_text(_pvx + 16, _pvy + 36, string(global.passiveEffects[i].countdown))
        _pvx += 100
    }
}
draw_set_halign(fa_left)

draw_set_color(c_white)
draw_text(0, 0, string(global.errormessage))
