function QueueAnim(type, element, target, opts) {
    var _step      = variable_clone(opts ?? {})
    _step.type     = type
    _step.element  = element
    _step.target   = target
    array_push(global.animQueue, _step)
}

/// @desc Queue a pending animation step for the current spell (applied per-target by objMonsterTarget).
///       Can be called multiple times to chain steps (e.g. pillar then burst).
/// @param {string} type        "burst" | "cloud" | "fire" | "drizzle" | "pillar" | "flash" | "meteor" | "sprite"
/// @param {string} element     "venus" | "mars" | "jupiter" | "mercury" | "none" | "normal" | "melee"
/// @param {struct} opts        Optional fields depending on type:
///   ALL:       fires_hit {bool}    - triggers DoDamage on first target (default false)
///              hit_delay {real}    - frame to trigger fires_hit (default: 1, burst/meteor use own timing)
///              sub {struct|array}  - overlay effect(s): { type:"burst"|"fire"|"flash", at:{frame|"hit"}, ... }
///              shake {real}        - screen shake intensity in pixels (default: none)
///              shake_duration {real} - shake duration in frames (default 15)
///   burst:     count {real}        - particle count (default 44)
///              windup {bool}       - show windup sparks (default true)
///   cloud:     count {real}        - particle count (default 80)
///   fire/drizzle: rate {real}      - particles per frame (default 3)
///              hold {real}         - spawn duration in frames (default 60)
///   pillar:    hold {real}         - hold duration (default 40)
///              core_w {real}       - core width px (default 20)
///              outer_w {real}      - outer glow width px (default 32)
///              embers {bool}       - spawn fire particles at base (default false)
///   flash:     hold {real}         - total flash duration (default 20)
///   meteor:    power {real}        - scales size and burst (default 10)
///              speed {real}        - initial fall speed (default 2.5)
///              count {real}        - burst particle count override
///              no_burst {bool}     - skip radial burst on impact (default false)
///              trail_life {real}   - trail particle lifetime (default 15)
///              fire {bool}         - spawn continuous rising fire after impact (default false)
///              fire_hold {real}    - fire spawn duration in frames (default 60)
///              fire_rate {real}    - fire particles per frame (default 3)
///   sprite:    spr {asset}         - sprite to play
///              blend {string}      - "normal" | "add" | "multiply"
///              hold {real}         - frames to hold on last frame (default 20)
///              hit_frame {real}    - frame that triggers on_hit (default last)
///              speed {real}        - frames per sprite frame (default 1)
///   (ragnarok is now sprite + burst sub — see CastSpell "Ragnarok" case for example)
function SetAnim(type, element, opts) {
    var _step      = variable_clone(opts ?? {})
    _step.type     = type
    _step.element  = element
    if !is_array(global.pendingAnim) {
        global.pendingAnim = []
    }
    array_push(global.pendingAnim, _step)
}
