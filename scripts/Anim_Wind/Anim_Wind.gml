function Anim_Wind() {
    // self = objAnimController instance
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

    _check_hit()

    // Spawn oscillating particles on target
    if _timer <= _HOLD and instance_exists(_target) {
        var _cx = _target.x
        var _cy = _target.y - _target.sprite_height / 2
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

    if _timer >= _TOTAL {
        _finish()
    }
}
