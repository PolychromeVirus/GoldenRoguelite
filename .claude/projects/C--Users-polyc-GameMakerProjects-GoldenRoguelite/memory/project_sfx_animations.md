---
name: Sound effects tied to animations
description: User plans to tie SFX to the animation system so sounds play at impact/spawn moments
type: project
---

User intends to add sound effect hooks to the animation system. This is a key reason to prefer animation-driven damage over silent systems like _FireRepeats.

**Why:** Sound needs to be synchronized with visual impacts (meteor hits, bursts, pillar spawns). The animation system has precise timing control via _timer, hit detection, and stagger.

**How to apply:** When designing new spell animations, prefer animation-driven damage flow over repeater/silent paths. Keep this in mind when choosing between approaches — the animation system will become the single source of truth for combat feedback (visual + audio).
