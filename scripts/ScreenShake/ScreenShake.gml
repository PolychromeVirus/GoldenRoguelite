/// @desc Trigger a screen shake that decays over time.
/// @param {real} intensity   Max pixel offset (e.g. 4 for mild, 10 for heavy)
/// @param {real} [duration]  Frames to shake (default 15)
function ScreenShake(intensity, duration) {
    global.shake_intensity = intensity
    global.shake_timer     = duration ?? 15
    global.shake_max       = duration ?? 15
}

/// @desc Apply camera shake offset. Call once per frame (e.g. in objTextManager Step).
function _ProcessShake() {
    if global.shake_timer <= 0 { return }

    global.shake_timer--
    var _t = global.shake_timer / global.shake_max  // 1→0 decay
    var _mag = global.shake_intensity * _t
    var _ox = irandom_range(-_mag, _mag)
    var _oy = irandom_range(-_mag, _mag)

    var _cam = view_camera[0]
    camera_set_view_pos(_cam, _ox, _oy)

    // Reset on last frame
    if global.shake_timer <= 0 {
        camera_set_view_pos(_cam, 0, 0)
    }
}
