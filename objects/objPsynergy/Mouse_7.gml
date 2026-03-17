if array_length(global.menu_stack) > 0 { exit }
if global.players[global.turn].psyseal { exit }

ClearOptions()

var _player = global.players[global.turn]
var _spells  = _player.spells
var _items   = []

for (var i = 0; i < array_length(_spells); i++) {
    var _s      = global.psynergylist[_spells[i]]
    var _detail = ""
    if global.inCombat and array_length(_player.dicepool) > 0 {
        var _prev = CalcPreview("spell", _spells[i], _player)
        if _prev.description != "" and _prev.description != "?" { _detail = _prev.description }
    }
    var _desc = _s.text
    if string_length(_desc) > 170 { _desc = string_delete(_desc, 170, string_length(_desc) - 169) + "..." }
    array_push(_items, {
        name:         _s.name + " - " + string(_s.cost) + " PP",
        element:      _s.element,
        sprite:       asset_get_index(_s.alias),
        right_sprite: asset_get_index("range_" + _s.range),
        detail:       _detail,
        desc:         _desc,
        data:         { spell_index: _spells[i] },
    })
}

var _turn = global.turn
PushMenu(objMenuCarousel, {
    items:         _items,
    description:   "quarter",
    confirm_label: "Cast",
    filter: method({ spells: _spells }, function(i) {
        return !isCastable(global.psynergylist[spells[i]], global.players[global.turn])
    }),
    draw_pane: method({ turn: _turn }, function(sel, item) {
        var _descx = 820
        var _descy = 411
        var _offset = 4
        var _text = item.desc
        draw_set_color(c_black)
        draw_text_ext(_descx + _offset, _descy + _offset, _text, 40, 660)
        draw_set_color(c_white)
        draw_text_ext(_descx, _descy, _text, 40, 660)
        if global.inCombat and array_length(global.players[turn].dicepool) > 0 {
            var _dp = CalcPreview("spell", item.data.spell_index, global.players[turn])
            if _dp.description != "" and _dp.description != "?" {
                var _detail = ""
                var _dcol   = c_white
                if _dp.heal > 0 {
                    _detail = "~" + string(_dp.heal) + " HP"
                    _dcol   = make_color_rgb(80, 220, 80)
                } else {
                    _detail = "~" + string(_dp.dam) + " " + _dp.element + " Damage"
                    switch _dp.element {
                        case "Venus":   _dcol = global.c_venus;   break
                        case "Mars":    _dcol = global.c_mars;    break
                        case "Jupiter": _dcol = global.c_jupiter; break
                        case "Mercury": _dcol = global.c_mercury; break
                    }
                }
                var _dy = _descy + string_height_ext(_text, 40, 660) + 8
                draw_set_color(c_black)
                draw_text(_descx + _offset, _dy + _offset, _detail)
                draw_set_color(_dcol)
                draw_text(_descx, _dy, _detail)
            }
        }
    }),
    on_confirm: method({ turn: _turn, spells: _spells }, function(i, item) {
        if !isCastable(global.psynergylist[item.data.spell_index], global.players[turn]) {
            InjectLog("Not enough PP to cast this!")
            return
        }
        CastSpell(item.data.spell_index, turn)
    }),
    on_info: method({ spells: _spells }, function(i, item) {
        PushMenu(objMenuLibrary, {
            entries:     array_map(global.psynergylist, function(s) { return { name: s.name, spell: s } }),
            start_index: spells[i],
            draw_entry:  function(entry, idx) {
                var _s      = entry.spell
                var _drawx  = 50
                var _drawy  = 120
                var _offset = 4
                var _picsize = 128

                if _s.character != "" {
                    var _charpic = asset_get_index(_s.character)
                    if _charpic == -1 { _charpic = Unidentified }
                    draw_sprite_stretched(_charpic, 0, 1536 - _drawx - _picsize, _drawy, _picsize, _picsize)
                }

                draw_sprite_stretched(asset_get_index(_s.element + "_Star"), 0, _drawx + 16, _drawy, 32, 32)
                draw_set_color(c_black)
                draw_text(_drawx + 72 + _offset, _drawy + _offset, _s.element + " - " + string(_s.cost) + " PP")
                draw_set_color(c_white)
                draw_text(_drawx + 72, _drawy, _s.element + " - " + string(_s.cost) + " PP")

                _drawy += 72
                draw_sprite_stretched(asset_get_index(_s.alias), 0, _drawx, _drawy, 64, 64)
                draw_sprite_stretched(asset_get_index("range_" + _s.range), 0, _drawx + 72, _drawy + 8, 128, 43)

                var _stagetext = "Stage " + string(_s.stage)
                if _s.stage > 1 { _stagetext += " (Evolves from " + _s.base + ")" }
                draw_set_color(c_black)
                draw_text(_drawx + 144 + _offset, _drawy + 20 + _offset, _stagetext)
                draw_set_color(c_white)
                draw_text(_drawx + 144, _drawy + 20, _stagetext)

                _drawy += 108
                draw_set_color(c_black)
                draw_text_ext(_drawx + _offset, _drawy + _offset, _s.text, 50, 1400)
                draw_set_color(c_white)
                draw_text_ext(_drawx, _drawy, _s.text, 50, 1400)
            },
        })
    }),
    info_label: "Details",
})
