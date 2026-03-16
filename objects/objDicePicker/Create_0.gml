if !variable_instance_exists(id, "dice")          { dice          = [] }
if !variable_instance_exists(id, "max_select")    { max_select    = 1 }
if !variable_instance_exists(id, "confirm_label") { confirm_label = "Select" }
if !variable_instance_exists(id, "title")         { title         = "" }
if !variable_instance_exists(id, "on_confirm")    { on_confirm    = function(s) {} }
if !variable_instance_exists(id, "on_cancel")     { on_cancel     = function() { PopMenu() } }

// Mark each die as not selected
for (var _i = 0; _i < array_length(dice); _i++) {
    dice[_i].selected = false
}

selected_count = 0
kbd_selected   = 0  // used for single-select keyboard nav; also hover fallback

if !variable_instance_exists(id, "corner") { corner = "bottomleft" }

var _spr_w = sprite_get_width(ThreeQuarterMenu)  * 6
var _spr_h = sprite_get_height(ThreeQuarterMenu) * 6
var _gui_w = 1536
var _btn_y = objPortrait.y * 6  // 720 — flush with top of portrait bar
switch corner {
    case "topleft":     spr_x = 0;              spr_y = 0;              break
    case "topright":    spr_x = _gui_w - _spr_w; spr_y = 0;              break
    case "bottomleft":  spr_x = 0;              spr_y = _btn_y - _spr_h; break
    case "bottomright": spr_x = _gui_w - _spr_w; spr_y = _btn_y - _spr_h; break
    default:            spr_x = 0;              spr_y = 0;              break
}

_build_buttons = method(id, function() {
    instance_create_depth(BUTTON3, BOTTOMROW, 0, objConfirm, { image: yes, text: confirm_label })
    instance_create_depth(BUTTON5, BOTTOMROW, 0, objCancel)
    clickable = true
})
clickable = false
