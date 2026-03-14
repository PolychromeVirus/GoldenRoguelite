draw_set_font(GoldenSun)
var _scale = display_get_gui_width() / 256
var _portSize = 32 * _scale         // 192 at 6x
var _subRow = _portSize / 4         // 48px per sub-row
var _iconSize = _subRow         // 40px icons
var _diceSize = round(_subRow * 0.5) // 24px dice squares
var _rows = [CREDIT1, CREDIT2, CREDIT3, CREDIT4]

for (var _i = 0; _i < array_length(global.players); _i++) {
    var _p = global.players[_i]
    var _ry = _rows[_i] * _scale
    var _rx = CREDITCOLUMN * _scale

    // --- Portrait ---
    draw_sprite_stretched(_p.portrait, 0, _rx, _ry, _portSize, _portSize)
    var _contentX = _rx + _portSize + 8

    // --- Sub-row 1: HP/PP ---
    var _y1 = _ry + 8
    draw_set_color(c_black)
    draw_text(_contentX + 2, _y1 + 2, "HP: " + string(_p.hpmax) + "  PP: " + string(_p.ppmax))
    draw_set_color(c_white)
    draw_text(_contentX, _y1, "HP: " + string(_p.hpmax) + "  PP: " + string(_p.ppmax))

    // --- Sub-row 2: ATK/DEF ---
    var _y2 = _ry + _subRow + 8
    draw_set_color(c_black)
    draw_text(_contentX + 2, _y2 + 2, "ATK: " + string(_p.atk) + "  DEF: " + string(_p.def))
    draw_set_color(c_white)
    draw_text(_contentX, _y2, "ATK: " + string(_p.atk) + "  DEF: " + string(_p.def))

    // --- Sub-row 3: Equipment + Dice ---
    var _y3 = _ry + _subRow * 2
    var _ex = _contentX

    // Weapon
    var _wspr = asset_get_index(global.itemcardlist[_p.weapon].alias)
    if (_wspr != -1) { draw_sprite_stretched(_wspr, 0, _ex, _y3, _iconSize, _iconSize) }
    _ex += _iconSize + 2

    // Armor x4
    for (var _a = 0; _a < 4; _a++) {
        var _aspr = Blank_Item
        if (_a < array_length(_p.armor) && _p.armor[_a] != -1) {
            var _t = asset_get_index(global.itemcardlist[_p.armor[_a]].alias)
            if (_t != -1) { _aspr = _t }
        }
        draw_sprite_stretched(_aspr, 0, _ex, _y3, _iconSize, _iconSize)
        _ex += _iconSize + 2
    }

    // Permanent upgrades
    if array_length(_p.permanent_upgrades) > 0 {
        _ex += 4
        for (var _u = 0; _u < array_length(_p.permanent_upgrades); _u++) {
            var _uspr = asset_get_index(global.itemcardlist[_p.permanent_upgrades[_u]].alias)
            if (_uspr != -1) {
                draw_sprite_stretched(_uspr, 0, _ex, _y3, _iconSize, _iconSize)
            }
            _ex += _iconSize + 2
        }
    }

    _ex += 8  // gap before dice

    // Dice pool: small colored squares, one per die
    var _pool_counts = [_p.melee, _p.venus, _p.mars, _p.jupiter, _p.mercury]
    var _pool_colors = [0x303030, global.c_venus, global.c_mars, global.c_jupiter, global.c_mercury]
    var _diceY = _y3 + (_iconSize - _diceSize) / 2  // vertically center dice with icons
    for (var _pool = 0; _pool < 5; _pool++) {
        for (var _d = 0; _d < _pool_counts[_pool]; _d++) {
            draw_set_color(_pool_colors[_pool])
            draw_rectangle(_ex, _diceY, _ex + _diceSize, _diceY + _diceSize, false)
            _ex += _diceSize + 2
        }
        if (_pool_counts[_pool] > 0) { _ex += 4 }
    }

    // --- Sub-row 4: Psynergy ---
    var _y4 = _ry + _subRow * 3
    var _px = _contentX

    for (var _j = 0; _j < array_length(_p.spells); _j++) {
        if (_p.spells[_j] < 0) { continue }
        var _sspr = asset_get_index(global.psynergylist[_p.spells[_j]].alias)
        if (_sspr != -1) {
            draw_sprite_stretched(_sspr, 0, _px, _y4, _iconSize, _iconSize)
            _px += _iconSize + 8
        }
    }

    for (var _j = 0; _j < array_length(_p.equip_spells); _j++) {
        if (_p.equip_spells[_j] < 0) { continue }
        var _sspr = asset_get_index(global.psynergylist[_p.equip_spells[_j]].alias)
        if (_sspr != -1) {
            draw_sprite_stretched(_sspr, 0, _px, _y4, _iconSize, _iconSize)
            _px += _iconSize + 2
        }
    }

}

// --- Right column: run info ---
var _margin = CREDITCOLUMN * _scale   // 24px — mirrors left margin
var _rightX = display_get_gui_width() - _margin

// Collect all djinn across all players (deduplicated by index)
var _allDjinn = []
for (var _i = 0; _i < array_length(global.players); _i++) {
    var _pd = global.players[_i]
    for (var _j = 0; _j < array_length(_pd.djinn); _j++) {
        if !array_contains(_allDjinn, _pd.djinn[_j]) {
            array_push(_allDjinn, _pd.djinn[_j])
        }
    }
}

// Layout: start from top, flow downward
var _ry = CREDIT1 * _scale + 8
draw_set_halign(fa_right)

// Dungeon reached
var _dungeonName = global.dungeonlist[global.dungeon].name
var _txt = "Dungeon: " + _dungeonName
draw_set_color(c_black)
draw_text(_rightX + 2, _ry + 2, _txt)
draw_set_color(c_white)
draw_text(_rightX, _ry, _txt)
_ry += string_height("Dungeon: " + _dungeonName)

// Floor reached (within dungeon, 1-based, mod 9)
var _floorInDungeon = ((global.dungeonFloor - 1) mod 9) + 1
_txt = "Floor: " + string(_floorInDungeon)
draw_set_color(c_black)
draw_text(_rightX + 2, _ry + 2, _txt)
draw_set_color(c_white)
draw_text(_rightX, _ry, _txt)
_ry += string_height("Floor: " + string(_floorInDungeon))

// Summons known label
_txt = "Summons:"
draw_set_color(c_black)
draw_text(_rightX + 2, _ry + 2, _txt)
draw_set_color(c_white)
draw_text(_rightX, _ry, _txt)
_ry += 32

// Summon icons (right-justified row)
if array_length(global.knownSummons) > 0 {
    // Measure total width first to right-align
    var _summonCount = array_length(global.knownSummons)
    var _rowW = _summonCount * (_iconSize + 2) - 2
    var _sx = _rightX - _rowW
    for (var _i = 0; _i < _summonCount; _i++) {
        var _sspr = asset_get_index(global.summonlist[global.knownSummons[_i]].alias)
        if (_sspr != -1) {
            draw_sprite_stretched(_sspr, 0, _sx, _ry, _iconSize, _iconSize)
        }
        _sx += _iconSize + 2
    }
    _ry += _iconSize + 8
} else {
    _ry += 8
}

// Djinn label
_txt = "Djinn:"
draw_set_color(c_black)
draw_text(_rightX + 2, _ry + 2, _txt)
draw_set_color(c_white)
draw_text(_rightX, _ry, _txt)
_ry += string_height("Djinn:")
var _djinnmax = 8
var _djinncount = 0

// Djinn icons: vertical list, right-justified
for (var _i = 0; _i < array_length(_allDjinn); _i++) {
    var _djinn = global.djinnlist[_allDjinn[_i]]
    var _dspr = asset_get_index(_djinn.element + "_Djinni")
    if (_dspr != -1) {
        var _col = _djinncount div _djinnmax
	  var _row = _djinncount mod _djinnmax
	  var _dx = _rightX - _iconSize - _col * (_iconSize + 8 + 4)
	  var _dy = _ry + _row * (_iconSize + 8 + 2)
	  draw_sprite_stretched(_dspr, 0, _dx, _dy, _iconSize + 8, _iconSize + 8)
	  _djinncount += 1
    }
   
}

draw_set_halign(fa_left)
draw_set_color(c_white)
