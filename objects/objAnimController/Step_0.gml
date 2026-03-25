// Only tick on animation frames (synced to global._anim_clock)
if global._anim_clock != 0 { return }

// Wait for delay to expire
if !_started {
    _delay -= ANIM_TICK
    if _delay > 0 { return }
    _started = true
    _load_anim()
}

_timer += ANIM_TICK
_tick()
_fire_subs()

var _gain2 = _step[$ "sfx_gain"] ?? 1

// Barrage sfx — plays on a repeating interval
var _barrage_sfx = _step[$ "sfx_barrage"]
if !is_undefined(_barrage_sfx) {
    var _interval = _step[$ "sfx_barrage_interval"] ?? 15
    var _barrage_start = _step[$ "sfx_barrage_delay"] ?? 0
    if _timer >= _barrage_start and (_timer - _barrage_start) mod _interval < ANIM_TICK {
        audio_stop_sound(_barrage_sfx)
        audio_play_sound(_barrage_sfx, 0, 0, _gain2)
        // Barrage flash — brief white flash + sustain hurt sprite on each hit
        if _step[$ "barrage_flash"] ?? false {
            for (var _i = 0; _i < array_length(_all_targets); _i++) {
                var _t = _all_targets[_i]
                if instance_exists(_t) {
                    _t.damage_timer = _interval + 5
                    _t.flash_timer  = 4
                }
            }
        }
    }
}

// Fade lingering sprite
if !is_undefined(_fade_spr) {
    _fade_alpha -= 0.03 * ANIM_TICK
    if _fade_alpha <= 0 { _fade_alpha = 0 }
}
