---
name: Prism 3 barrage plan
description: Prism stage 3 should use animation-driven barrage of tiny meteors instead of repeater system
type: project
---

Prism stage 3 (Freeze Prism) currently uses `struct.repeater` which bypasses animations entirely via `_FireRepeats`. Plan is to replace this with animation-driven damage:

- Remove `struct.repeater`, keep `struct.dam = 1`
- Loop N times calling `SetAnim("meteor", "mercury", ...)` with `power: 5` (tiny), `stagger_damage: true`, tight stagger timing
- Increase x-spread on meteors for random scatter (`irandom_range` wider than default ±4)
- Each meteor's `fires_hit` handles 1 damage via the stagger_damage per-target system
- Multi-meteor system (built in Anim_Meteor) already supports overlapping falls via `spawn_at` delays

**Why:** Animation-driven approach means sound effects can be tied to meteor impacts (user plans to add SFX to animation system). Repeater system fires DoDamage silently with no visual/audio hooks.

**How to apply:** When implementing, replace the stage 3 block in CastSpell's Prism case. The number of meteors = `QueryDice(caster, "mercury", "highest") * 2`. Each targets a random enemy.
