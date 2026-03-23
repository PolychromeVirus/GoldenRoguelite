function Anim_Pillar_Tick() {
    var _step       = _queue[_qi]
    var _HOLD       = _step[$ "hold"] ?? 40
    var _FADE       = _step[$ "fade"] ?? 50
    var _LINGER     = _step[$ "linger"] ?? 40
    // Find max delay across all consecutive pillars for total duration
    var _max_delay  = 0
    for (var _dq = _qi; _dq < array_length(_queue); _dq++) {
        if _queue[_dq].type != "pillar" { break }
        var _dd = _queue[_dq][$ "delay"] ?? 0
        if _dd > _max_delay { _max_delay = _dd }
    }
    var _TOTAL      = _max_delay + _HOLD + _FADE + _LINGER
    var _embers     = _step[$ "embers"] ?? false
    var _outer_w    = _step[$ "outer_w"] ?? 32
    var _ember_count = _step[$ "ember_count"] ?? 5
    var _ember_trail = _step[$ "ember_trail"] ?? 8
    var _ember_scl   = _step[$ "ember_scl"] ?? 1
    var _ember_w     = _step[$ "ember_w"] ?? _outer_w
    var _ember_life   = _step[$ "ember_life"] ?? 40
    var _ember_linger = _step[$ "ember_linger"] ?? 0
    var _fire_overlay = _step[$ "fire_overlay"] ?? false
    var _fire_rate    = _step[$ "fire_rate"] ?? 2
    var _fire_w       = _step[$ "fire_w"] ?? (_outer_w / 2)

    _check_hit()

    // Spawn embers while pillar is visible + ember_linger after
    if _embers and _timer <= _max_delay + _HOLD + _FADE + _ember_linger {
        for (var _q = _qi; _q < array_length(_queue); _q++) {
            var _s = _queue[_q]
            if _s.type != "pillar" { break }
            if _timer < (_s[$ "delay"] ?? 0) { continue }
            var _t   = _s.target
            var _tx  = _t.x
            var _ty  = _t.y
            var _hw  = _ember_w / 2
            repeat (_ember_count) {
                var _ox = irandom_range(-_hw, _hw)
                instance_create_depth(
                    _tx + _ox, _ty,
                    100, objParticle, {
                        vx:   -0.1 + random(0.2),
                        vy:   -(0.15 + random(0.3)),
                        grav: 0,
                        life: _ember_life + irandom(20),
                        col:  _col,
                        scl:  1 + irandom(_ember_scl),
                        trail: _ember_trail,
                        spr:  sprCirclePart,
                    })
            }
        }
    }

    // Fire overlay — thin trailless rising particles that reach the top
    if _fire_overlay and _timer <= _max_delay + _HOLD + _FADE {
        for (var _q = _qi; _q < array_length(_queue); _q++) {
            var _s = _queue[_q]
            if _s.type != "pillar" { break }
            if _timer < (_s[$ "delay"] ?? 0) { continue }
            var _t  = _s.target
            var _tx = _t.x
            var _ty = _t.y
            var _fhw = _fire_w / 2
            repeat (_fire_rate) {
                var _ox = irandom_range(-_fhw, _fhw)
                instance_create_depth(
                    _tx + _ox, _ty,
                    100, objParticle, {
                        vx:   -0.05 + random(0.1),
                        vy:   -(1.0 + random(1.5)),
                        grav: -0.01,
                        life: 300,
                        col:  _col,
                        scl:  1 + irandom(1),
                        trail: 0,
                        die_y: 0,
                        spr:  sprCirclePart,
                    })
            }
        }
    }

    // Drizzle overlay — tiny falling particles within the pillar width
    var _drizzle_overlay = _step[$ "drizzle_overlay"] ?? false
    var _drizzle_rate    = _step[$ "drizzle_rate"] ?? 3
    var _drizzle_w       = _step[$ "drizzle_w"] ?? _outer_w
    if _drizzle_overlay and _timer <= _max_delay + _HOLD + _FADE {
        for (var _q = _qi; _q < array_length(_queue); _q++) {
            var _s = _queue[_q]
            if _s.type != "pillar" { break }
            if _timer < (_s[$ "delay"] ?? 0) { continue }
            var _t  = _s.target
            var _dhw = (_s[$ "drizzle_w"] ?? _drizzle_w) / 2
            repeat (_drizzle_rate) {
                instance_create_depth(
                    _t.x + irandom_range(-_dhw, _dhw), 0,
                    100, objParticle, {
                        vx:   0,
                        vy:   0.2 + random(0.2),
                        grav: 0.02,
                        life: 300,
                        col:  _col,
                        scl:  1,
                        trail: 0,
                        spr:  sprCirclePart,
                    })
            }
        }
    }

    // Advance logic
    var _stagger = _step[$ "stagger"] ?? undefined
    if is_undefined(_stagger) {
        // Simultaneous: find last consecutive pillar, skip all at once
        var _last_pillar = _qi
        while _last_pillar < array_length(_queue) - 1 and _queue[_last_pillar + 1].type == "pillar" {
            _last_pillar++
        }
        if _timer >= _TOTAL {
            _qi = _last_pillar
            _next_step()
        }
    } else {
        // Staggered: advance after stagger frames (last target gets full duration)
        var _is_last = (_qi >= array_length(_queue) - 1) or (_queue[_qi + 1].type != "pillar")
        var _end = _is_last ? _TOTAL : _stagger
        if _timer >= _end {
            _next_step()
        }
    }
}

function Anim_Pillar_Draw() {
    var _step    = _queue[_qi]
    var _HOLD    = _step[$ "hold"] ?? 40
    var _FADE    = _step[$ "fade"] ?? 50
    var _FADE_IN = _step[$ "fade_in"] ?? 6
    var _core_w  = _step[$ "core_w"] ?? 20
    var _outer_w = _step[$ "outer_w"] ?? 32

    // Fade in, hold, fade out
    var _alpha = 1
    if _timer < _FADE_IN {
        _alpha = _timer / _FADE_IN
    } else if _timer > _HOLD {
        _alpha = 1 - ((_timer - _HOLD) / _FADE)
    }
    _alpha = clamp(_alpha, 0, 1)

    var _half_outer = _outer_w / 2
    var _half_core  = _core_w / 2

    // Draw pillars — all targets if simultaneous, single if staggered
    var _stagger = _step[$ "stagger"] ?? undefined
    gpu_set_blendmode(bm_add)
    var _q_end = is_undefined(_stagger) ? array_length(_queue) : _qi + 1
    for (var _q = _qi; _q < _q_end; _q++) {
        var _s = _queue[_q]
        if _s.type != "pillar" { break }
        // Per-pillar delay support
        var _pdelay = _s[$ "delay"] ?? 0
        if _timer < _pdelay { continue }
        var _pt = _timer - _pdelay
        var _phold = _s[$ "hold"] ?? _HOLD
        var _pfade = _s[$ "fade"] ?? _FADE
        var _pfade_in = _s[$ "fade_in"] ?? _FADE_IN
        var _p_ow = _s[$ "outer_w"] ?? _outer_w
        var _p_cw = _s[$ "core_w"] ?? _core_w
        // Per-pillar alpha
        var _pa = 1
        if _pt < _pfade_in { _pa = _pt / _pfade_in }
        else if _pt > _phold { _pa = 1 - ((_pt - _phold) / _pfade) }
        _pa = clamp(_pa, 0, 1)
        var _tx     = _s.target.x
        var _foot_y = _s.target.y
        var _pho = _p_ow / 2
        var _phc = _p_cw / 2

        // Outer glow
        draw_set_alpha(_pa * 0.6)
        draw_set_color(_col)
        draw_rectangle(_tx - _pho, 0, _tx + _pho - 1, _foot_y, false)

        // Core — near white
        draw_set_alpha(_pa)
        draw_set_color(merge_color(_col, c_white, 0.7))
        draw_rectangle(_tx - _phc, 0, _tx + _phc - 1, _foot_y, false)
    }

    draw_set_alpha(1)
    gpu_set_blendmode(bm_normal)
}
