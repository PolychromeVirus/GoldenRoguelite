if !variable_instance_exists(id, "text")    { text    = "" }
if !variable_instance_exists(id, "subtext") { subtext = "" }
if !variable_instance_exists(id, "buttons") { buttons = [] }

_btn_instances = []

_build_buttons = method(id, function() {
    DeleteButtons()
    _btn_instances = []
    var _n = array_length(buttons)
    // right-align buttons — last N slots of bottom row
    var _positions = [BUTTON2, BUTTON3, BUTTON4, BUTTON5]
    var _start = 4 - _n
    for (var _i = 0; _i < _n; _i++) {
        var _b = buttons[_i]
        var _img = variable_struct_exists(_b, "sprite") ? _b.sprite : yes
        var _inst = instance_create_depth(_positions[_start + _i], BOTTOMROW, 0, objButton2, { image: _img, text: _b.label })
        array_push(_btn_instances, _inst)
    }
    clickable = true
})

clickable = false

