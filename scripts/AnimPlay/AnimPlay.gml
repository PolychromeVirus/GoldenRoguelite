/// @func AnimPlay(layers, packet, on_complete)
/// @desc Spawn an animation orchestrator that creates per-target controllers.
/// @param {array}    layers       Array of layer structs: { type, element, mode, opts... }
/// @param {struct}   packet       Aggression schema (or undefined for non-damaging anims)
/// @param {function} on_complete  Called when ALL animations are done
///
/// Layer struct fields:
///   type       {string}  "burst"|"cloud"|"fire"|"drizzle"|"pillar"|"flash"|"meteor"|"sprite"|"wind"|"ray"
///   element    {string}  "venus"|"mars"|"jupiter"|"mercury"|"none"|"melee"
///   mode       {string}  "simultaneous"|"stagger"|"sequence"|"shared"|"single" (default "simultaneous")
///   targets    {array}   Override target list for this layer (optional)
///   target     {id}      Single target for "single" mode (optional)
///   delay      {real}    Explicit start delay from time 0 (optional)
///   overlap    {bool}    Start at same time as previous layer (optional)
///   stagger_delay {real} Frames between each target in stagger mode (default 15)
///   fires_hit  {bool}    Trigger DoDamage at hit_delay (default false)
///   hit_delay  {real}    Frame to trigger damage (default 1)
///   + all existing animation opts (count, hold, color, shake, sub, etc.)
function AnimPlay(_layers, _packet, _on_complete) {
    // Gather default targets: all alive monsters
    var _default_targets = []
    with (objMonster) {
        if monsterHealth > 0 { array_push(_default_targets, id) }
    }

    instance_create_depth(0, 0, -150, objAnimOrchestrator, {
        _layers:          _layers,
        _packet:          _packet,
        _on_complete:     _on_complete,
        _default_targets: _default_targets,
    })
}
