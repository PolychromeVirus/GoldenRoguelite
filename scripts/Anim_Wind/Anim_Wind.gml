function Anim_Wind() {
    var _step       = _queue[_qi]
    var _HOLD       = _step[$ "hold"] ?? 60
    var _LINGER     = _step[$ "linger"] ?? 30
    var _TOTAL      = _HOLD + _LINGER
    var _rate       = _step[$ "rate"] ?? 3
    var _amp        = _step[$ "amp"] ?? 1.2
    var _amp_var    = _step[$ "amp_var"] ?? 0.4
    var _osc_speed  = _step[$ "osc_speed"] ?? 0.08
    var _osc_y_amt  = _step[$ "osc_y"] ?? 0.3
    var _life       = _step[$ "life"] ?? 60
    var _life_var   = _step[$ "life_var"] ?? 20
    var _scl        = _step[$ "scl"] ?? 1
    var _scl_var    = _step[$ "scl_var"] ?? 1
    var _trail      = _step[$ "trail"] ?? 8
    var _spread_x   = _step[$ "spread_x"] ?? 10
    var _spread_y   = _step[$ "spread_y"] ?? 10
    var _stagger    = _step[$ "stagger"] ?? undefined

    _check_hit()

    // Gather targets
    var _targets = []
    if is_undefined(_stagger) {
        for (var _q = _qi; _q < array_length(_queue); _q++) {
            if _queue[_q].type != "wind" { break }
            array_push(_targets, _queue[_q].target)
        }
    } else {
        array_push(_targets, _step.target)
    }

    // Spawn oscillating particles
    if _timer <= _HOLD {
        for (var _ti = 0; _ti < array_length(_targets); _ti++) {
            var _t  = _targets[_ti]
            var _cx = _t.x
            var _cy = _t.y - _t.sprite_height / 2
            repeat (_rate) {
                var _phase = random(2 * pi)
                var _a = _amp + random(_amp_var) - _amp_var / 2
                instance_create_depth(
                    _cx + irandom_range(-_spread_x, _spread_x),
                    _cy + irandom_range(-_spread_y, _spread_y),
                    100, objParticle, {
                        vx:       0,
                        vy:       0,
                        grav:     0,
                        life:     _life + irandom(_life_var),
                        col:      _col,
                        scl:      _scl + irandom(_scl_var),
                        trail:    _trail,
                        spr:      sprCirclePart,
                        osc_amp:  _a,
                        osc_speed: _osc_speed + random(0.02),
                        osc_phase: _phase,
                        osc_y:    _osc_y_amt,
                    })
            }
        }
    }

    // Complete
    var _is_last = (_qi >= array_length(_queue) - 1) or _queue[_qi + 1].type != "wind"
    if is_undefined(_stagger) {
        if _timer >= _TOTAL {
            while _qi < array_length(_queue) - 1 {
                if _queue[_qi + 1].type != "wind" { break }
                _qi++
            }
            _next_step()
        }
    } else {
        var _end = _is_last ? _TOTAL : _stagger
        if _timer >= _end {
            _next_step()
        }
    }
}
