if !array_contains(global.menu_stack, id) { exit }
if !visible {exit}
draw_sprite_ext(HalfMenuMiddleSelector, 0, (side == "right") ? 768 : 0, 0, 6, 6, 0, c_white, 1)
if description == "quarter" {
    var _hw = sprite_get_width(HalfMenu) * 6
    var _hh = sprite_get_height(HalfMenu) * 6
    draw_sprite_ext(QuarterMenu, 0, _hw, _hh / 2, 6, 6, 0, c_white, 1)
} else if description == "half" {
    var _desc_x = (side == "left") ? sprite_get_width(HalfMenu) * 6 : 0
    draw_sprite_ext(HalfMenu, 0, _desc_x, 0, 6, 6, 0, c_white, 1)
}
draw_set_font(GoldenSun)

var _offset  = 4
var _vertpad = 54
var _len     = array_length(items)

// Layout: list on one half, description pane on the other
// HalfMenuMiddleSelector at 6x = 768 wide; right side starts at x=768
var _ox       = (side == "right") ? 768 + 50 : 50   // list content origin x
var _oy       = 50                                    // list content origin y
var _list_x   = _ox
var _desc_x   = (side == "left") ? 768 + 50 : 50
var _center_y = _oy + 250
var _desc_y   = (description == "half") ? _oy : _oy + 360

// How many items to show above/below the selected row
var _show_above = (title != "") ? 4 : 5
var _show_below = 5

// Title
if title != "" {
    draw_set_color(c_black)
    draw_text(_list_x + _offset, _oy + _offset, title)
    draw_set_color(c_yellow)
    draw_text(_list_x, _oy, title)
}

// List items
for (var i = 0; i < _len; i++) {
    var _item = items[i]
    var _dy   = _center_y + (i - selected) * _vertpad

    if (selected - i) > _show_above { continue }
    if (i - selected) > _show_below { continue }

    var _filtered = false
    try { _filtered = !is_undefined(filter) and filter(i) } catch (_e) { _filtered = true }
    var _col = _filtered ? c_grey : (variable_struct_exists(_item, "color") ? _item.color : c_white)

    var _ix = _list_x
    if variable_struct_exists(_item, "element") and _item.element != "" {
        var _espr = asset_get_index(_item.element + "_Star_Clean")
        if _espr != -1 {
            draw_sprite_stretched(_espr, 0, _ix, _dy + 4, 40, 40)
            _ix += 48
        }
    }
    if variable_struct_exists(_item, "sprite") and _item.sprite != -1 {
        var _spr   = _item.sprite
        var _scale = max(1, floor(48 / sprite_get_width(_spr)))
        var _size  = sprite_get_width(_spr) * _scale
        draw_sprite_ext(_spr, 0, _ix, _dy, _scale, _scale, 0, c_white, 1)
        _ix += _size + 8
    }

    draw_set_color(c_black)
    draw_text(_ix + _offset, _dy + 8 + _offset, _item.name)
    draw_set_color(_col)
    draw_text(_ix, _dy + 8, _item.name)

    var _panel_w = sprite_get_width(HalfMenuMiddleSelector) * 6
    var _pad_r   = 48
    var _right_x = (side == "right") ? _panel_w * 2 - _pad_r : _panel_w - _pad_r
    if variable_struct_exists(_item, "right_sprite") and _item.right_sprite != -1 {
        var _rspr = _item.right_sprite
        var _rh   = 32
        var _rw   = round(_rh * sprite_get_width(_rspr) / sprite_get_height(_rspr))
        draw_sprite_stretched(_rspr, 0, _right_x - _rw, _dy + 11, _rw, _rh)
        _right_x -= _rw + 8
    }
    if variable_struct_exists(_item, "detail") and _item.detail != "" {
        var _dcol = (variable_struct_exists(_item, "detail_color")) ? _item.detail_color : _col
        draw_set_halign(fa_right)
        draw_set_color(c_black)
        draw_text(_right_x + _offset, _dy + 8 + _offset, _item.detail)
        draw_set_color(_dcol)
        draw_text(_right_x, _dy + 8, _item.detail)
        draw_set_halign(fa_left)
    }
}

// Description pane content for selected item
if description != "none" and _len > 0 {
    if !is_undefined(draw_pane) {
        draw_pane(selected, items[selected])
    } else {
        var _sel = items[selected]
        if variable_struct_exists(_sel, "desc") and _sel.desc != "" {
            var _text = _sel.desc
            //draw_set_color(c_black)
            //draw_text_ext(_desc_x + _offset, _desc_y + _offset, _text, 40, 660)
            //draw_set_color(c_white)
            //draw_text_ext(_desc_x, _desc_y, _text, 40, 660)
			draw_rich_text(_desc_x,_desc_y,_text,660,4,GoldenSun,40)
        }
    }
}
