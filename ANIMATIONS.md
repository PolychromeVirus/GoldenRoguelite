# Spell Animation Reference

## Usage

Call `SetAnim(type, element, opts)` inside `CastSpell` to queue animation steps.
Call multiple times to chain steps (e.g. pillar then burst for Volcano).

```gml
SetAnim("burst", "mars", { fires_hit: true, count: 60, windup: false })
SetAnim("pillar", "mars", { fires_hit: true, embers: true })
SetAnim("cloud", "jupiter", { fires_hit: true })
```

`fires_hit` should be `true` on exactly one step per spell — this is the step that triggers `DoDamage`.
If multiple steps have it, only the first across all targets actually fires.

For fire-and-forget animations outside the spell pipeline (e.g. passive buffs), use `QueueAnim` + `PlayAnimation` directly:
```gml
QueueAnim("flash", "jupiter", target, { hold: 15 })
PlayAnimation(function() {}, function() {})
```

---

## Shared Options (all types)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `fires_hit` | bool | `false` | Triggers DoDamage on the first target when this step fires |
| `hit_delay` | real | `1` | Frame to trigger fires_hit (burst/meteor/sprite use own timing) |
| `sub` | struct or array | none | Sub-effect(s) to fire during this step (see below) |
| `shake` | real | none | Screen shake intensity in pixels (fires at step start) |
| `shake_duration` | real | `15` | Screen shake duration in frames |

### `sub` — Overlay effects

Any animation step can include a `sub` field to layer additional effects on top, firing at a specific frame while the parent continues playing. Can be a single struct or an array of structs.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `type` | string | `"burst"` | Sub-effect type: `"burst"`, `"fire"`, `"flash"` |
| `at` | real or `"hit"` | `1` | Frame number to fire, or `"hit"` to fire when parent triggers impact |
| `delay` | real | `0` | Extra frames to wait after `at` before firing |
| `element` | string | parent's | Element color override (inherits from parent step if omitted) |
| `shake` | real | none | Screen shake intensity when this sub fires |
| `shake_duration` | real | `15` | Shake duration for this sub |

**burst sub-fields:**
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `count` | real | `44` | Particle count per target |
| `max_speed` | real | `5` | Max radial particle speed |
| `max_scale` | real | `2` | Max particle scale |
| `at_foot` | bool | `false` | Spawn at target feet instead of center |
| `offset_x` | real | `0` | Additional x offset |
| `offset_y` | real | `0` | Additional y offset |

**fire sub-fields:**
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `count` | real | `30` | Number of rising fire particles per target |

**flash sub-fields:**
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `hold` | real | `20` | Flash duration |

Sub-effects target all same-type enemies in the queue (matching pillar/stream behavior).

**Example — pillar with burst overlay:**
```gml
SetAnim("pillar", "mars", { fires_hit: true, sub: { type: "burst", at: 6 } })
```

**Example — sprite with delayed burst + flash + shake (Ragnarok):**
```gml
SetAnim("sprite", "venus", { spr: RagnarokSword, blend: "add", hold: 75, fires_hit: true,
    sub: [
        { type: "flash", at: "hit", hold: 3, shake: 8, shake_duration: 35 },
        { type: "flash", at: "hit", delay: 30, hold: 15 },
        { type: "burst", at: "hit", delay: 30, at_foot: true, count: 120, max_scale: 4 },
    ]
})
```

---

## `"burst"` — Radial particle explosion

Windup sparks converge on target, then burst outward. Good for direct-damage spells.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `count` | real | `44` | Number of burst particles |
| `max_speed` | real | `5` | Max radial particle speed |
| `max_scale` | real | `2` | Max particle scale |
| `windup` | bool | `true` | Show converging sparks before burst |
| `windup_duration` | real | `12` | Windup phase length in frames |
| `spark_count` | real | `2` | Sparks spawned per frame during windup |
| `duration` | real | `30` | Total animation duration on last target |
| `stagger` | real | `8` | Frames per target before last |
| `at_foot` | bool | `false` | Spawn at target feet instead of center |
| `offset_x` | real | `0` | Additional x offset |
| `offset_y` | real | `0` | Additional y offset |

**Timing:** Windup frames (skipped if `windup: false`). Total `duration` frames on last target, `stagger` frames between multi-targets.

**Example:** `SetAnim("burst", "mars", { fires_hit: true, count: 80, windup: false })`

---

## `"cloud"` — Surface-rendered gas cloud

Particles draw to a surface at full opacity, surface composited at reduced alpha — creates a uniform gaseous look. Cloud fades in, holds, then fades out.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `count` | real | `80` | Total soft particles spawned |
| `spawn` | real | `8` | Frames over which particles spawn |
| `alpha` | real | `0.55` | Max cloud alpha |
| `cloud_hold` | real | `60` | Frames to hold at full alpha before fading |
| `height` | real | `0.7` | Vertical position as fraction of target sprite height |
| `scl` | real | `3` | Base particle scale |
| `scl_var` | real | `2` | Random scale variance added to base |

**Timing:** Spawns over `spawn` frames. Holds at `alpha` for `cloud_hold` frames, then fades out slowly.

**Rendering:** Uses `global._cloud_surf` surface. Particles tagged `soft: true` draw to the surface instead of directly to screen.

**Example:** `SetAnim("cloud", "jupiter", { fires_hit: true, alpha: 0.7, cloud_hold: 80 })`

---

## `"fire"` — Rising particle stream

Continuous particles spawning at monster's feet, floating upward. All targets spawn simultaneously.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `rate` | real | `3` | Particles spawned per frame per target |
| `hold` | real | `60` | Spawn duration in frames |
| `linger` | real | `40` | Extra frames after spawning stops |
| `trail` | real | `60` | Trail history length per particle |
| `life` | real | `80` | Base particle lifetime |
| `life_var` | real | `40` | Random lifetime variance |
| `scl` | real | `1` | Base particle scale |
| `scl_var` | real | `3` | Random scale variance |
| `grav` | real | `-0.02` | Particle gravity (negative = upward) |

**Timing:** Spawns for `hold` frames, then `linger` extra frames for particles to drift. Total = hold + linger.

**Example:** `SetAnim("fire", "mars", { fires_hit: true, hold: 80, rate: 5, trail: 80 })`

---

## `"drizzle"` — Falling rain particles

Continuous particles spawning at y=0 (top of screen), falling down to monster's feet. All targets spawn simultaneously.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `rate` | real | `3` | Particles spawned per frame per target |
| `hold` | real | `60` | Spawn duration in frames |
| `linger` | real | `40` | Extra frames after spawning stops |
| `trail` | real | `10` | Trail history length per particle |
| `life` | real | `80` | Base particle lifetime |
| `life_var` | real | `40` | Random lifetime variance |
| `scl` | real | `1` | Base particle scale |
| `scl_var` | real | `3` | Random scale variance |
| `grav` | real | `0.06` | Particle gravity |

**Timing:** Same as fire — hold + linger frames total.

**Particles:** Fall straight down (no horizontal drift), particles die at `target.y` (monster's feet).

**Example:** `SetAnim("drizzle", "mercury", { fires_hit: true, trail: 15 })`

---

## `"pillar"` — Full-height rectangle beam

Bright rectangular beam from top of screen to monster's feet. Outer colored glow + white core. All targets render simultaneously. Optional fire embers at base.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `hold` | real | `40` | Hold at full brightness (frames) |
| `fade` | real | `50` | Fade-out duration (frames) |
| `fade_in` | real | `6` | Fade-in duration (frames) |
| `linger` | real | `40` | Extra frames after fade for embers to die |
| `core_w` | real | `20` | Core rectangle width in pixels |
| `outer_w` | real | `32` | Outer glow rectangle width in pixels |
| `embers` | bool | `false` | Spawn rising fire particles at monster's feet |
| `ember_count` | real | `5` | Embers spawned per target per tick |
| `ember_trail` | real | `8` | Trail length for ember particles |
| `ember_scl` | real | `1` | Max random scale for ember particles |

**Timing:** Fades in over `fade_in` frames, holds, fades out over `fade` frames, then `linger` extra frames. Total = hold + fade + linger.

**Rendering:** Additive blending. Core is 70% toward white from element color.

**Example:** `SetAnim("pillar", "mars", { fires_hit: true, embers: true, core_w: 24, outer_w: 40 })`

---

## `"flash"` — Full-screen color tint

Quick full-screen additive flash in element color. Good for passive/buff spell effects.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `hold` | real | `20` | Total flash duration in frames |
| `peak` | real | `3` | Frames to reach full brightness |
| `alpha` | real | `0.5` | Max flash alpha |

**Timing:** Peaks in `peak` frames, fades out over remaining frames.

**Rendering:** Additive blend, full-screen rectangle.

**Example:** `SetAnim("flash", "jupiter", { hold: 15, alpha: 0.8 })`

---

## `"meteor"` — Falling star with impact burst

A pixel-art meteor falls from above, leaving an ember trail, then explodes on impact. Size and burst scale with `power`.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `power` | real | `10` | Scales meteor size and burst count (10 = 1x, 40 = 4x) |
| `speed` | real | `2.5` | Initial fall speed |
| `accel` | real | `0.08` | Fall acceleration per frame |
| `count` | real | auto | Override burst particle count (default: `20 + power * 3`) |
| `max_speed` | real | auto | Override burst max speed (default: `3 + scale * 2`) |
| `max_scale` | real | auto | Override burst max scale (default: `1 + scale`) |
| `no_burst` | bool | `false` | Skip the radial burst on impact |
| `trail_life` | real | `15` | Trail particle lifetime (higher = longer trails) |
| `trail` | real | `6` | Trail history length for falling ember particles |
| `linger` | real | `30` | Frames to wait after impact (or after fire finishes) |
| `fire` | bool | `false` | Spawn continuous rising fire at target after impact |
| `fire_hold` | real | `60` | Fire spawn duration in frames |
| `fire_rate` | real | `3` | Fire particles per frame |
| `fire_trail` | real | `12` | Trail length for post-impact fire particles |

**Timing:** Falls until impact (y = monster center), then waits `linger` frames (or `fire_hold + linger` if `fire: true`).

**Rendering:** Meteor drawn as additive cross pattern (outer glow) + white core. Scales with power.

**Example:** `SetAnim("meteor", "mars", { fires_hit: true, power: 25, accel: 0.12 })`

---

## `"sprite"` — Custom sprite animation

Plays a sprite asset frame-by-frame at the target, with optional blend mode. Leaves a fading ghost after advancing to next step.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `spr` | asset | **required** | Sprite asset to play |
| `blend` | string | `"normal"` | `"normal"`, `"add"`, or `"multiply"` |
| `hold` | real | `20` | Frames to hold on hit_frame before advancing |
| `hit_frame` | real | last frame | Frame index that triggers `fires_hit` |
| `speed` | real | `1` | Frames per sprite frame (higher = slower) |

**Timing:** Plays at `speed` rate, holds on `hit_frame` for `hold` frames, then advances. Previous frame lingers as a fading ghost.

**Example:** `SetAnim("sprite", "venus", { spr: RagnarokSword, blend: "add", hold: 20 })`

---

## Particle Options

These fields can be set on `objParticle` creation structs (used internally by animation types):

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `shrink` | bool | `false` | Scale particle down to 0 over its lifetime |
| `soft` | bool | `false` | Draw to cloud surface instead of screen (used by cloud type) |
| `trail` | real | `20` | Trail history length in frames |
| `die_y` | real | none | Kill particle when it reaches this y coordinate |

---

## Element Colors

Set automatically by `AnimColor(element)`. Unknown elements (including `"none"`, `"normal"`, `""`) default to neutral gray.

---

## Frame Rate

All animations tick at `ANIM_TICK` (default 3 = effective 20fps). Particle velocities and spawn rates are compensated automatically. Change `ANIM_TICK` in `InitGlobalVars.gml`.

---

## Multi-target Behavior

- **burst**: Staggers between targets (`stagger` frames per target, full `duration` on last)
- **cloud**: Staggers between targets, holds/fades only on last target
- **fire / drizzle**: All targets spawn simultaneously from one step
- **pillar**: All targets draw simultaneously from one step
- **flash**: Full-screen, no per-target behavior
- **meteor**: One per target, sequential
- **sprite**: One per target, sequential

---

## Chaining Example

Volcano uses pillar + fire:
```gml
SetAnim("pillar", "mars", { fires_hit: true, embers: true })
SetAnim("fire", "mars")
```

Ragnarok (sprite with delayed burst sub):
```gml
SetAnim("sprite", "venus", { spr: RagnarokSword, blend: "add", hold: 75, fires_hit: true,
    sub: [
        { type: "flash", at: "hit", hold: 3, shake: 8, shake_duration: 35 },
        { type: "flash", at: "hit", delay: 30, hold: 15 },
        { type: "burst", at: "hit", delay: 30, at_foot: true, count: 120, max_scale: 4 },
    ]
})
```

Planet Diver (meteor scales with damage):
```gml
SetAnim("meteor", "mars", { fires_hit: true, power: struct.dam })
```
