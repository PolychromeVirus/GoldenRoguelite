/// Animation orchestrator — spawns all controllers at once with computed delays.
/// Created by AnimPlay() with a creation struct.
///
/// Required creation vars:
///   _layers       — array of layer structs from the caller
///   _packet       — aggression schema (or undefined)
///   _on_complete  — callback when all controllers are done
///   _default_targets — array of default targets (alive monsters)

_controllers = []
_total_count = 0
_done_count  = 0

// Cloud state (shared across all controllers)
_cloud_alpha  = 0
_cloud_hold   = 0
_cloud_fading = false

// Screen tint state (shared)
_screen_tint_active = false
_screen_tint_color  = c_white
_screen_tint_alpha  = 0
_screen_tint_timer  = 0
_screen_tint_hold   = 0
_screen_tint_fade   = 20
_screen_tint_peak   = 6
_screen_tint_max    = 0.4

/// Set screen tint overlay (called by controllers)
SetScreenTint = method(id, function(_col, _alpha, _hold, _fade) {
    _screen_tint_active = true
    _screen_tint_color  = _col
    _screen_tint_max    = _alpha
    _screen_tint_hold   = _hold
    _screen_tint_fade   = _fade ?? 20
    _screen_tint_timer  = 0
    _screen_tint_alpha  = 0
})

/// Called by each controller when it finishes
ControllerDone = method(id, function(_ctrl) {
    _done_count++
    if _done_count >= _total_count {
        // All controllers done — wait for cloud fade if needed
        if _cloud_alpha > 0 {
            // Defer completion until cloud fades
        } else {
            _complete()
        }
    }
})

_completed = false
_complete = method(id, function() {
    if _completed { return }
    _completed = true
    _on_complete()
    instance_destroy()
})

// --- Spawn controllers from layers ---

// Estimate duration for a step type (used for sequence mode layer offsets)
_estimate_duration = method(id, function(_step) {
    var _type = _step.type
    switch (_type) {
        case "burst":
            var _windup = (_step[$ "windup"] ?? true) ? (_step[$ "windup_duration"] ?? 12) : 0
            return max(_step[$ "duration"] ?? 30, _windup + 18)
        case "cloud":
            var _spawn = _step[$ "spawn"] ?? 8
            var _hold  = _step[$ "cloud_hold"] ?? 60
            return _spawn + _hold
        case "flash":
            return _step[$ "hold"] ?? 20
        case "pillar":
            var _hold = _step[$ "hold"] ?? 40
            var _fade = _step[$ "fade"] ?? 50
            var _ling = _step[$ "linger"] ?? 40
            return _hold + _fade + _ling
        case "fire":
        case "drizzle":
            var _hold = _step[$ "hold"] ?? 60
            var _ling = _step[$ "linger"] ?? 40
            return _hold + _ling
        case "wind":
            var _hold = _step[$ "hold"] ?? 60
            var _ling = _step[$ "linger"] ?? 30
            return _hold + _ling
        case "meteor":
            return _step[$ "duration"] ?? 120
        case "sprite":
            var _spr = _step[$ "spr"]
            if !is_undefined(_spr) {
                var _total = sprite_get_number(_spr)
                var _spd = _step[$ "speed"] ?? 1
                var _hold = _step[$ "hold"] ?? 20
                return _total * _spd + _hold
            }
            return 60
        case "ray":
            var _hold = _step[$ "hold"] ?? 40
            var _ling = _step[$ "linger"] ?? 30
            return _hold + _ling
        default:
            return 60
    }
})

var _layer_offset = 0

for (var _li = 0; _li < array_length(_layers); _li++) {
    var _layer = _layers[_li]
    var _mode  = _layer[$ "mode"] ?? "simultaneous"
    var _step  = variable_clone(_layer)

    // Remove layer-level meta fields from the step so Anim_* scripts don't see them
    // (mode, targets, target, delay, overlap, stagger_delay are layer concerns)

    // Determine layer offset
    if _li > 0 {
        if _layer[$ "overlap"] ?? false {
            // Overlap: same offset as previous layer
            // _layer_offset stays the same
        } else if !is_undefined(_layer[$ "delay"]) {
            // Explicit delay from time 0
            _layer_offset = _layer[$ "delay"]
        } else {
            // Default: chain after previous layer's estimated end
            // _layer_offset was already advanced below
        }
    }

    // Resolve targets for this layer
    var _targets
    if !is_undefined(_layer[$ "target"]) {
        // Single mode — one specific target
        _targets = [_layer.target]
    } else if !is_undefined(_layer[$ "targets"]) {
        _targets = _layer.targets
    } else {
        _targets = _default_targets
    }

    var _stagger_delay = _layer[$ "stagger_delay"] ?? 15

    // Spawn controllers based on mode
    if _mode == "shared" {
        // One controller, positioned at middle target, hits all
        var _mid = _targets[floor((array_length(_targets) - 1) / 2)]
        var _pkt = undefined
        if !is_undefined(_packet) {
            _pkt = variable_clone(_packet)
            _pkt.targets = _targets
        }
        var _ctrl = instance_create_depth(0, 0, -150, objAnimController, {
            _parent:      id,
            _step:        _step,
            _target:      _mid,
            _delay:       _layer_offset,
            _packet:      _pkt,
            _all_targets: _targets,
        })
        array_push(_controllers, _ctrl)
        _total_count++
    } else if _mode == "single" {
        // One controller for one specific target
        var _tgt = _layer[$ "target"] ?? _targets[0]
        var _pkt = undefined
        if !is_undefined(_packet) {
            _pkt = variable_clone(_packet)
            _pkt.targets = [_tgt]
        }
        var _ctrl = instance_create_depth(0, 0, -150, objAnimController, {
            _parent:      id,
            _step:        _step,
            _target:      _tgt,
            _delay:       _layer_offset,
            _packet:      _pkt,
            _all_targets: [_tgt],
        })
        array_push(_controllers, _ctrl)
        _total_count++
    } else {
        // simultaneous, stagger, sequence — one controller per target
        for (var _ti = 0; _ti < array_length(_targets); _ti++) {
            var _tgt = _targets[_ti]
            var _ctrl_delay = _layer_offset
            if _mode == "stagger" {
                _ctrl_delay += _ti * _stagger_delay
            } else if _mode == "sequence" {
                _ctrl_delay += _ti * _estimate_duration(_step)
            }
            // simultaneous: _ctrl_delay = _layer_offset + 0

            var _pkt = undefined
            if !is_undefined(_packet) {
                _pkt = variable_clone(_packet)
                _pkt.targets = [_tgt]
            }
            var _ctrl = instance_create_depth(0, 0, -150, objAnimController, {
                _parent:      id,
                _step:        variable_clone(_step),
                _target:      _tgt,
                _delay:       _ctrl_delay,
                _packet:      _pkt,
                _all_targets: _targets,
            })
            array_push(_controllers, _ctrl)
            _total_count++
        }
    }

    // Advance layer_offset for next layer (default: chain sequentially)
    var _layer_dur = _estimate_duration(_step)
    if _mode == "stagger" {
        _layer_dur += (array_length(_targets) - 1) * _stagger_delay
    } else if _mode == "sequence" {
        _layer_dur *= array_length(_targets)
    }
    // Only advance if the next layer doesn't have explicit delay or overlap
    if _li < array_length(_layers) - 1 {
        var _next = _layers[_li + 1]
        if !(_next[$ "overlap"] ?? false) and is_undefined(_next[$ "delay"]) {
            _layer_offset += _layer_dur
        }
    }
}

// If no controllers were spawned, complete immediately
if _total_count == 0 {
    _on_complete()
    instance_destroy()
}
