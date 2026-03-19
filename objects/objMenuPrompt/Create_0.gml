/// Config: {
///   lines:   array of { text, color }  — long lines are auto word-wrapped
///   buttons: array of { label, sprite, on_click }
/// }
if !variable_instance_exists(id, "lines")   { lines   = [] }
if !variable_instance_exists(id, "buttons") { buttons = [{sprite: no, label: "[DEBUG] Cancel"}] }

_spr_w = sprite_get_width(QuarterMenu)  * 6   // 768
_spr_h = sprite_get_height(QuarterMenu) * 6   // 360
spr_x  = (display_get_gui_width()  - _spr_w) / 2
spr_y  = (display_get_gui_height() - _spr_h) / 2

_build_buttons = function() {
	DeleteButtons()
	var _n = array_length(buttons)
	if _n == 0 { exit }
	// Centre the buttons in the room (room is 256 wide)
	var _spacing = 28
	var _start_x = 128 - (_n - 1) * _spacing / 2
	for (var _i = 0; _i < _n; _i++) {
		var _btn  = buttons[_i]
		var _obj  = objButton2
		var _inst = instance_create_depth(
			_start_x + _i * _spacing, BOTTOMROW, 0,
			_obj,
			{ image: _btn.sprite, hovertext: _btn.label }
		)
		_inst._cb       = _btn.on_click
		_inst._owner_id = id
	}
}
