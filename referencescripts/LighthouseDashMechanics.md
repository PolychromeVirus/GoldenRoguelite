# Lighthouse Dash! — Complete Game Mechanics Reference

## Overview

1–4 player campaign ascending four elemental lighthouses. Each chapter = one lighthouse, increasing difficulty. Characters carry over equipment, Psynergy, Djinn, and Boss Loot between chapters.

---

## Characters (Adepts)

Each Adept has:
- **Element** (Venus/Mars/Jupiter/Mercury/None) — always provides 1 die of that element
- **Weakness** — element they take extra damage from
- **ATK / DEF** — base combat stats
- **HP** — per-chapter max (increases each chapter)
- **PP** — starts at 3 × chapter number; regenerates 1/turn
- **Starting Psynergy** — one spell (choose between two options for most characters)
- **Starting Djinni** — some characters start with one
- **Weapon proficiencies** — which weapon types they can equip
- **Level-up bonus** — ATK, DEF, MATK, or special per chapter

### Character Roster

| Name | Class | Element | Weakness | HP (Ch1-4) | PP (Ch1-4) | Level Up | Starting Psy | Weapons |
|------|-------|---------|----------|------------|------------|----------|-------------|---------|
| Isaac | Squire | Venus | Jupiter | 10/17/22/27 | 10/17/22/27 | ATK +1/2/2/3 | Quake OR Cure | short,long,axe |
| Garet | Guard | Mars | Mercury | 10/20/25/30 | 10/15/20/25 | ATK +1/2/3/4 | Volcano OR Fume | long,axe,mace |
| Ivan | Wind Seer | Jupiter | Venus | 10/15/20/25 | 10/20/25/30 | ATK +1/1/2/2 | Sleep OR Ray | short,staff |
| Mia | Water Seer | Mercury | Mars | 10/15/20/25 | 10/20/25/30 | ATK +1/1/2/2 | Ply OR Douse | staff,mace |
| Felix | Squire | Venus | Jupiter | 10/17/22/27 | 10/17/22/27 | ATK +1/2/2/3 | Spire OR Ragnarok | short,long,axe |
| Jenna | Flame User | Mars | Mercury | 10/15/20/25 | 10/20/25/30 | ATK +1/1/2/2 | Aura OR Flare | short,staff |
| Sheba | Wind Seer | Jupiter | Venus | 10/15/20/25 | 10/20/25/30 | ATK +1/1/2/2 | Reveal OR Plasma | short,staff,mace |
| Piers | Mariner | Mercury | Mars | 10/20/25/30 | 10/15/20/25 | ATK +1/2/3/4 | Diamond Dust OR Ice | short,long,axe,mace |
| Feizhi | Pupil | None | None | 10/17/22/27 | 10/17/22/30 | DJN +1/2/3/4 | Quake,Flare,Ward,Wish | short,staff,mace |
| Babi | Noble | None | None | 10/15/20/25 | 10/10/10/10 | DEF +0/1/1/2 | (none) | staff |
| Kraden | Scholar | None | All | 8/12/15/20 | 15/25/30/35 | ATK +1/2/3/4 | Random x2 | staff |
| Briggs | Pirate | None | None | 15/20/25/30 | 0/0/0/0 | +1 ATK | (none) | short,long,axe |
| Eddy | Prince | Mercury | Mars | 10/20/25/30 | 8/12/15/20 | ATK +1/2/3/4 | Djinni: Hail | short,long,staff,axe,mace |
| Kendall | Bulwark | Venus | Jupiter | 10/20/25/30 | 10/15/20/25 | DEF +1/2/2/3 | Root | short,long,axe,mace |
| Delta | Wind Wizard | Jupiter | Venus | 8/12/15/20 | 15/25/30/35 | ATK +1/2/2/3 | Djinni: Gust | short,staff,mace |
| Omega | Sorcerer | Mars | Mercury | 8/12/15/20 | 15/25/30/35 | ATK +1/2/2/3 | Djinni: Fever | short,staff,mace |
| Lyza | Trickster | Jupiter | Venus | 10/17/22/27 | 10/17/22/27 | ATK +1/2/2/3 | Delude OR Dull | short,long,mace |
| D. Waller | Assassin | Jupiter | Venus | 8/12/15/20 | 15/25/30/35 | ATK +1/2/3/4 | (Ninjutsu) | short |
| Sveta | Beastling | Jupiter | Venus | 10/20/25/30 | 10/15/20/25 | ATK +1/2/3/4 | Astral Blast OR Backstab | long,axe,mace |
| Amiti | Aqua Squire | Mercury | Mars | 10/17/22/27 | 10/17/22/27 | ATK +1/2/2/3 | Cool OR Break | short,staff |
| Sean | Warrior | None | Mars | 10/20/25/30 | 10/15/20/25 | ATK per level | (none) | long,axe,mace |
| Ouranos | Warrior | None | Mercury | 10/20/25/30 | 10/15/20/25 | DEF +1/1/2/2 | (none) | long,axe,mace |

*(Additional characters: Flint/Cannon/Waft/Sleet as Djinni Adepts, Matthew/Tyrell/Karis/Rief/Himi/Eoleo as TLA equivalents, Jules/Kai/Roulet/Akafubu as custom characters)*

---

## Dice System (Core Mechanic)

### Five Die Types
- **Melee** (Black) — physical damage
- **Venus** (Yellow) — earth element
- **Mars** (Red) — fire element
- **Jupiter** (Purple) — wind element
- **Mercury** (Blue) — water element

Colors stored in global variables (global.c_venus, global.c_mars, global.c_jupiter, global.c_mercury)

### Dice Pool Construction
Pool comes from three sources:
1. **Character element** — always 1 die of that element (if not None)
2. **Weapon** — each icon on weapon card = 1 die (melee or elemental; "Sol" icon = die of character's element)
3. **Equipped Djinn** — +1 die per Djinni of that element (removed while Djinni is in recovery)

Dice are **never spent** — they stay in your pool and are re-rolled every turn.

### Three Interaction Modes

#### 1. Power (Affinity)
The **count** of dice of a given type in your pool (charged or not).
- Venus Power = number of Venus dice
- Elemental Power = total non-melee dice
- Melee Power = number of Melee dice

#### 2. Charged Dice
Weapon type determines which dice are "charged" after rolling:

| Weapon Type | Charged When | Attack Formula |
|-------------|-------------|----------------|
| Short Sword | pip ≥ 4 | ATK + All Charge |
| Long Sword | pip is even (2,4,6) | ATK + All Charge |
| Staff | pip ≥ 3 | ATK + **Melee** Charge only |
| Mace | pip ≥ 5 | ATK + (All Charge × 2) |
| Axe | pip appears 2+ times in entire pool (pairs) | ATK + (pairs × 3) |

"All Charge" = count of all charged dice across entire pool.
"Melee Charge" = count of only charged melee dice.

Cursed weapons have unique damage formulas which are an inversion of this

| Weapon Type | Charged When | Attack Formula |
|-------------|-------------|----------------|
| Short Sword | pip <= 3 | ATK + All Charge |
| Long Sword | pip is off (1,3,5) | ATK + All Charge |
| Staff | pip <= 4 | ATK + **Melee** Charge only |
| Mace | pip < = 2| ATK + (All Charge × 2) |
| Axe | pip appears exactly once in entire pool (uniques) | ATK + (All Charge x 9) |

#### 3. Value
The actual pip number on the die face (1–6).
- **Values** = sum of specified dice pips
- **Highest** / **Lowest** = single highest or lowest pip among specified type
- **Top 2** = sum of 2 highest pips

### Evaluation Keywords (on cards)
- **Assign** — Select one die per target, each used once. Fewer dice than targets = fewer hits.
- **Split** — Total up damage/healing, distribute freely among targets.
- **Highest / Lowest** — Single pip value from specified pool.

### Subset Qualifiers
- **Venus / Mars / Jupiter / Mercury** — only dice of that element
- **All** — every die in pool
- **Elemental** — any non-melee die
- **Melee** — only melee dice

---

## Turn Order

### Player Turn (each player, in order):
1. **PP Regen** — gain +1 PP (some effects add more)
2. **Roll** — roll entire dice pool
3. **Action** — choose ONE action (Attack / Psynergy / Item / Djinni / Summon)
4. **Djinn Flip** — flip up 1 face-down Djinni → flip down any unleashed this turn → recover 1 from recovery
5. **ATK Decay** — remove 1 ATK token (toward 0) from yourself

### Enemy Turn (after all players act):
1. **Enemy DEF Decay** — remove 1 DEF token from each enemy
2. **Enemies act left to right** — each selects a move (roll targeting die) and target (roll d4)
3. **Enemy ATK Decay** — remove 1 ATK token from each enemy

### After Enemy Turn:
- **Player DEF Decay** — remove 1 DEF token from each player

### Boss Turns
Bosses act **between every player's turn** AND on the regular enemy turn.

Full turn order with boss:
```
Boss → P1 → Boss → P2 → Boss → P3 → Boss → P4 → Enemy Turn (all enemies) → P1 → ...
```

Fewer boss turns when players are downed (downed players are removed from turn order).

---

## Player Actions (choose ONE per turn)

### Attack
Deal weapon damage to one opponent. Damage = weapon's attack formula (see charge table above).

### Cast Psynergy
- Pay full PP cost before resolving
- **Requirement**: must have ≥1 die of the spell's element in your pool (does NOT need to be charged)
- Can learn spells of any element regardless of pool
- Multi-tier: each copy of a spell unlocks the next tier

### Use an Item
- Activate a consumable item's Use effect (most heal or cure status)
- OR equip a weapon/armor card (replaces existing if slot full; old item goes to hand)
- Consumables are discarded after use

### Unleash a Djinni
- Activate the Unleash effect of one equipped Djinni
- OR flip a face-down Djinni face-up (still costs your Djinni action)
- At end of turn, unleashed Djinni flips face-down (into recovery)

### Summon
- Cast a Summon the party knows
- **Cost**: Select Djinn matching the elemental cost (can use Djinn from any party member)
- Those Djinn go to recovery (face-down, die removed from pool)
- Recovery: 1 Djinni recovers per turn at end of Djinn Flip step
- Djinn used for summon may include their die in the summon's effect before going to recovery

---

## Damage Calculation

### Outgoing Damage Order:
1. Base damage (from weapon/spell)
2. Buffs (ATK up tokens)
3. Debuffs (ATK down tokens)
4. Unleash/Djinn/other bonuses

### Incoming Damage Order:
1. Weakness modifier (increases damage)
2. Resistance modifier (decreases damage)
3. Buffs (DEF up tokens)
4. Debuffs (DEF down tokens)
5. Special effects (Granite halving, Flash reduction)

### Weakness
When hitting an enemy with an element it's **weak to**, increase damage by your **Elemental Modifier** for that element.
- Elemental Modifier = Power ÷ 2, rounded down. **Minimum 1.**

### Resistance
Adepts are **resistant to their own element**. When taking elemental damage of your own element, reduce damage by your Elemental Modifier.
- Elemental Modifier = Power ÷ 2, rounded down. **Minimum 1.**
- Enemies: always take 1 less damage from their own element by default.

### Flash Interaction
Flash is calculated last. Any attack doing ANY positive damage before Flash is reduced to exactly 1. Applied after all other reductions.

---

## Status Conditions

| Status | Effect | Duration/Recovery |
|--------|--------|-------------------|
| **Sleep** | Cannot act. Roll d6 at start of turn; wake on 4+. | Until wake roll succeeds |
| **Poison** | 1 damage at end of every player turn AND enemy turn | Does not expire; must be healed |
| **Venom** | 3 damage at end of every player turn AND enemy turn | Healed by anything that cures Poison |
| **Stun** | Must roll 4+ on d6 before Attack/Psynergy/Djinni actions. Items and Summons bypass. | 3 stun tokens; -1 per turn. Reapply resets to 3 |
| **Delusion** | Enemy only: rolls d6 for targeting. 1-4 = normal, 5 = hit left ally, 6 = hit right ally | Until cured |
| **Psynergy Seal** | Cannot use Psynergy or Summon actions | Until cured |
| **Haunt** | 2 Haunt tokens on character. Remove 1 per enemy turn. When last removed = immediately Downed. **Bosses immune.** | 2 enemy turns |
| **Downed** | HP = 0. All tokens removed. Turns skipped. | Until healed; any healing revives |

### Attempt Rolls
Some abilities "attempt" to inflict status: roll d6, succeed on 4+.
**All status against bosses is downgraded to an attempt** (never automatic).
Bosses recover from all status after a set number of turns (listed on boss card).

---

## Djinn System

### States
- **Ready** (face-up) — provides die, can be unleashed
- **Spent/Recovery** (face-down) — die removed from pool, recovering
- **Just Unleashed** — flips face-down at end of turn

### End-of-Turn Djinn Flip
1. Flip up one face-down Djinni (recovery → ready)
2. Flip down any Djinni unleashed this turn (ready → recovery)

### Party Limits
- Max 4 Djinn per adept
- No adept can have 2+ more Djinn than any other player
- Can trade Djinn between players outside combat
- Djinn do NOT auto-recover at end of combat

---

## Djinn List

### Chapter 1

**Venus:**
| Name | Effect |
|------|--------|
| Flint | T1 Weapon Attack (no unleash) + X Venus (X = ½ damage, rounded up) |
| Bane | T1 Venus Damage + Poison = All Charge |
| Sap | T1 Weapon Attack; Self Recover X HP (X = ½ damage) |
| Vine | Passive 3 Rounds: All attempt rolls fail |
| Mud | Passive 3 Rounds: Subtract 1 from all enemy move selection and attempt rolls |
| Mold | T1 Enemy Damage: target's neighbors each attack with selected move |
| Flower | Party Healing = Assigned Venus pips |

**Mars:**
| Name | Effect |
|------|--------|
| Forge | Party +2 ATK |
| Fever | T1 Mars Damage + Delusion = All Charge |
| Cannon | T1 Weapon Attack (no unleash) + X Mars (X = ½ damage) |
| Ember | Party Recover X PP (X = Mars Charge) |
| Kindle | Passive 1 Round: Party +2 Melee Power |
| Torch | T1 Mars Damage = Weapon Attack Damage (ignore DEF) |
| Scorch | T1 Weapon Attack Damage + Stun |

**Jupiter:**
| Name | Effect |
|------|--------|
| Gust | T1 Weapon Attack; roll d6, 5-6: attack again (can retarget) |
| Kite | Auto End of Target Turn: Target Adept takes another turn (no Djinni/PP recovery) |
| Squall | T1 Jupiter Damage + Stun = All Charge |
| Zephyr | Party: Gain Reroll Token (reroll entire pool, max 1) |
| Luff | T1 Seal Psynergy |
| Ether | Target Adept: Recover X PP (X = All Charge) |
| Wheeze | T1 Jupiter Damage + Poison = All Charge |

**Mercury:**
| Name | Effect |
|------|--------|
| Hail | T1 Mercury Damage = All Charge + inflict -2 DEF |
| Spritz | Party Healing = Elemental Charge |
| Dew | Target Downed Adept: Recover all HP (Djinni does not self-recover) |
| Tonic | Target Adept: Remove any tokens |
| Steam | Passive 3 Rounds: Party +X Temp Elemental Power (X = Countdown remaining) |
| Mist | T1 Mercury Damage + Sleep = All Charge |
| Spring | Target Adept: Healing = All Charge |

### Chapter 2

**Venus:**
| Name | Effect |
|------|--------|
| Granite | Passive 1 Round: Party all incoming damage halved (rounded up) |
| Ground | Auto Start of Enemy Turn: Skip Enemy Turn (starts face down) |
| Iron | Party +3 DEF |
| Salt | Party: Remove all tokens + cancel all passives |
| Quartz | Target Downed Adept: d6 → 1-4: ½ Max HP, 5-6: all HP |
| Echo | T1 Weapon Attack; if unleash triggers, trigger again; Passive: all damage is Venus |
| Steel | T1 Weapon Attack; if unleash triggered, unleash damage converts to healing |

**Mars:**
| Name | Effect |
|------|--------|
| Flash | Passive 1 Round: Party all damage reduced to 1 (does not self-recover) |
| Char | T1 Mars Damage + Stun = All Charge |
| Corona | Party +2 DEF |
| Shine | T1 Mars Damage = All Charge; neighbors Inflict Delusion |
| Spark | Target Downed Adept: Recover X HP (X = ½ Max HP) |
| Core | T1 Weapon Attack; Auto if X damage done: Reset target ATK/DEF (X = ½ max possible) |
| Reflux | Passive 1 Round: When attacked, attacker takes X damage (X = ATK) |

**Jupiter:**
| Name | Effect |
|------|--------|
| Haze | Passive 1 Round: Target Adept immune to damage (does not self-recover) |
| Breeze | Party +2 DEF |
| Smog | T1 Jupiter Damage + Delusion = All Charge |
| Breath | Target Adept: Healing = All Charge |
| Blitz | T1 Jupiter Damage + Stun = All Charge |
| Aroma | Party: Recover X PP (X = Elemental Charge) |
| Whorl | T1 Weapon Attack; roll d6, 6: non-boss Downed |

**Mercury:**
| Name | Effect |
|------|--------|
| Fizz | Target Adept: Recover X HP (X = ½ Max HP) |
| Fog | T1 Inflict Delusion |
| Sleet | T1 Mercury Damage = All Charge + inflict -2 ATK |
| Sour | T1 Weapon Attack (no unleash) + X Mercury (X = ½ damage) |
| Chill | T1 Mercury Damage = All Charge; T1 Reset ATK and DEF |
| Gel | T1 Weapon Attack; if unleash triggers, trigger again; Passive: all damage is Mercury |
| Serac | T1 Weapon Attack; roll d6, 6: non-boss Downed |

### Chapter 3

**Venus:**
| Name | Effect |
|------|--------|
| Meld | T1 Weapon Attack using another Adept's weapon |
| Petra | Passive 3 Rounds: All enemies reroll if they select move X (choose X) |
| Geode | T1 Weapon Attack + X Venus (X = Weapon Attack Damage) |
| Crystal | Party Healing: Elemental Charge + DEF |

**Mars:**
| Name | Effect |
|------|--------|
| Fugue | All Opposing Mars = Split All Charge; Auto if damage: Seal Psynergy |
| Coal | Party: Gain Partial Reroll Token (reroll any dice, max 1, 1 round) |
| Tinder | Auto End of Round: Target Downed Adept Recover Mars Power |
| Fury | T1 Mars Damage + Haunt = All Charge |

**Jupiter:**
| Name | Effect |
|------|--------|
| Waft | T3 Inflict Sleep |
| Gasp | All Opposing: Attempt Haunt |
| Lull | Immediate: End turn, round restarts from first player |
| Gale | T1 roll d6: evens = non-boss Downed (no reward), odds = nothing |

**Mercury:**
| Name | Effect |
|------|--------|
| Shade | Passive 1 Round: All incoming damage halved (rounded up) |
| Rime | T1 Seal Psynergy |
| Eddy | Party: Unleash 1 face-down Djinni (does not self-recover) |
| Balm | Party: Downed adepts healed for ½ Max HP (does not self-recover) |

---

## Summons

| Name | Element | Cost | Effect |
|------|---------|------|--------|
| Zagan | Venus | 1V + 1Ma | T1 Weapon Attack; target and neighbors -3 DEF |
| Megaera | Mars | 1Ma + 1J | T1 Weapon Attack x2; Party +3 ATK |
| Flora | Jupiter | 1V + 2J | All Jupiter Damage = Party Jupiter Power + Inflict Sleep |
| Moloch | Mercury | 2Me + 1J | Select a number; that number = "do nothing" on enemy move lists for rest of combat |
| Haures | Venus | 2V + 1Ma | All Inflict Poison; Passive: Poison does 2 damage for rest of combat |
| Ulysses | Mars | 2Ma + 2Me | Passive 2 Enemy Turns (3 Boss Turns): enemy turns skipped |
| Eclipse | Jupiter | 3J + 1Me | All X Jupiter Damage (X = ½ Max HP or 10% Boss HP) + All Delusion |
| Coatlicue | Mercury | 1J + 2Me | Party Recover all HP; Countdown 5 Rounds: Auto Party +5 HP |
| Daedalus | Mars | 1V + 3Ma | T1 Mars Damage = All pips; chain damage (each next enemy takes ½ of previous) |
| Azul | Mercury | 2V + 2Me | All Mercury Damage = Elemental pips + Stun |
| Catastrophe | Jupiter | 3Ma + 3J | All Weapon Attack |
| Charon | Venus | 2x Any (pairs) | TX Target Downed (X = # Djinni pairs spent) |
| Iris | Mars | 4Ma + 4Me | Party full heal; Passive 1 Round: all damage → 1; next turn: damage halved |
| Boreas | Mercury | 4Me | Cast any Mercury spell at max level, set dice manually, 0 PP |
| Thor | Jupiter | 4J | Cast any Jupiter spell at max level, set dice manually, 0 PP |
| Meteor | Mars | 4Ma | Cast any Mars spell at max level, set dice manually, 0 PP |
| Judgment | Venus | 4V | Cast any Venus spell at max level, set dice manually, 0 PP |

---

## Psynergy (Spells)

### Venus — Combat

| Spell | Tiers | Cost | Range | Effect |
|-------|-------|------|-------|--------|
| Quake / Earthquake / Quake Sphere | 3 | 3/7/15 | T3/T5/T7 | Venus: 3 / Venus Power+3 / Venus Power×2 |
| Spire / Clay Spire / Stone Spire | 3 | 2/6/12 | T1/T3/T3 | Venus: All Charge / Venus Charge×2 / All Charge×2 |
| Gaia / Mother Gaia / Grand Gaia | 3 | 4/10/15 | T3 | Venus: Venus Power / Power×2 (T6 if Jupiter Charge) / Power × 2^(Jupiter Charge) |
| Thorn / Briar / Nettle | 3 | 5/6/15 | All | Venus: 2 / Venus Charge / All Charge |
| Ragnarok / Odyssey | 2 | 10/20 | T1 | Venus: Venus pips / Venus pips×2 (same target) |
| Cure / Cure Well / Potent Cure | 3 | 3/10/15 | Self+Target | Heal: Highest Venus pip / 2× Highest / 2× Highest ×2 |
| Aegis / Divine Aegis | 2 | 4/8 | Target Adept | +X DEF −X ATK (X = Venus Charge); S2: no ATK penalty if max charge; Passive 1 round: Psy uses ATK |
| Root / Root System | 2 | 3/6 | Target Adept | 3/6 Root tokens (each round: +2 HP +1 DEF, -1 token) |
| Resonate / Grand Resonate | 2 | 3/7 | Passive 1 Round | Multi-target spells +X damage or +X targets (X = Venus Charge/2 or Venus Charge) |

**Venus — Utility:**
- **Revive** (4 PP) — Auto End of Round: Target Downed Adept Recover Venus Power × 2

### Mars — Combat

| Spell | Tiers | Cost | Range | Effect |
|-------|-------|------|-------|--------|
| Flare / Flare Wall / Flare Storm | 3 | 3/7/10 | T3 | Mars: 5 / 10 / 15 |
| Volcano / Eruption / Pyroclasm | 3 | 5/8/14 | T1/T3/T5 | Mars: Mars Power+4 / +6 / +10 |
| Fume / Serpent Fume / Dragon Fume | 3 | 3/10/20 | T1 | Mars: 7 / Mars pips / Mars pips×2 |
| Blast / Mad Blast / Fiery Blast | 3 | 3/9/16 | TX (X=unique elements) | Mars: All Charge / All Charge+2X / Highest Elemental pip per element |
| Beam / Cycle Beam / Searing Beam | 3 | 7/12/20 | T3/T5/All | Mars: Uncharged Mars + 2×Charged / 3×Charge / 3×Charge |
| Aura / Healing Aura / Cool Aura | 3 | 5/10/20 | Party | Heal: Lowest Mars pip / Lowest+Highest / (Lowest×2)+(Highest×2) |
| Planet Diver / Planetary | 2 | 8/18 | T1 | Mars or Venus: 2 Elemental pips (×2 if 1 Mars+1 Venus); S2: Set HP to 1, next turn all pips = damage |
| Burn Off / Burn Away | 2 | 2/6 | Target/Party | Reset ATK and DEF |

### Jupiter — Combat

| Spell | Tiers | Cost | Range | Effect |
|-------|-------|------|-------|--------|
| Ray / Storm Ray / Destruct Ray | 3 | 3/6/10 | T3 | Jupiter: 3 / 8 / 12 |
| Whirlwind / Tornado / Tempest | 3 | 5/8/12 | T3/T5/T5 | Jupiter: 2×Charge / 2×Charge / Non-Jupiter Charge + 2×Jupiter Charge |
| Plasma / Shine Plasma / Spark Plasma | 3 | 7/10/20 | T3/T5/T7 | Jupiter: Assigned pips / (2 dice can assign twice) / Split pips |
| Bolt / Flash Bolt / Blue Bolt | 3 | 3/6/10 | T1/T3/T5 | Jupiter + Stun: 5 / 5 / 10 |
| Slash / Wind Slash / Sonic Slash | 3 | 2/5/8 | T1/T3/T3 | Weapon Damage ignore DEF / Jupiter = Weapon ignore DEF (+DEF if 2 Mercury Charge) / Wind Slash ×2 |
| Astral Blast / Thunder Mine | 2 | 2/10 | — | S1: Weapon + Jupiter Charge; S2: Jupiter = Jupiter pips |
| Backstab | 1 | 3 | — | Weapon Attack + 2 Jupiter; d10: 10 = non-boss Downed |
| Impact / High Impact | 2 | 2/6 | Target/Party | +3 ATK |
| Ward / Resist | 2 | 2/6 | Target/Party | +3 DEF |
| Sleep | 1 | 4 | T3 | Inflict Sleep |
| Delude | 1 | 4 | T3 | Inflict Delusion |
| Dull | 1 | 4 | T3 | -3 ATK |
| Djinn Echo / Call Djinn | 2 | 3/6 | — | S1: 2 rounds Djinn T1→T3; S2: 3 rounds + Unleash Djinn |

**Jupiter — Utility:**
- **Halt** (3 PP) — Auto Start of Boss Fight: Boss skips first Boss Turn
- **Reveal** (5 PP) — Reveal extra cards during drafts; all adepts level up when learned

### Mercury — Combat

| Spell | Tiers | Cost | Range | Effect |
|-------|-------|------|-------|--------|
| Douse / Drench / Deluge | 3 | 3/6/12 | T3/T3/T5 | Mercury: 3 / 8 / 12 |
| Ice / Ice Horn / Ice Missile | 3 | 2/6/12 | T1/T3/T3 | Mercury: All Charge / Mercury Charge×2 / All Charge×2 |
| Frost / Tundra / Glacier | 3 | 4/8/15 | T3/T3/T5 | Mercury: Melee Charge / Melee Charge + 2×Mercury Charge / same ×5 targets |
| Cool / Supercool / Megacool | 3 | 5/8/15 | All | Mercury: 2 / Mercury Charge / All Charge |
| Froth / Froth Sphere / Froth Spiral | 3 | 3/5/10 | T3/T5/T5 | Mercury: Mercury Charge (-2 DEF if 2+ Venus) / same ×5 / 2×Charge -X DEF |
| Prism / Hail Prism / Freeze Prism | 3 | 4/7/12 | T3/T5/T5 | Mercury: Highest pip + skip X (Jupiter Charge) / same / 1 Mercury × 2×Highest times |
| Diamond Dust / Diamond Berg | 2 | 5/10 | T1 | Mercury: Weapon + neighbors Weapon/2 / Weapon×2 |
| Ply / Ply Well / Pure Ply | 3 | 2/5/10 | Target Adept | Heal: Highest Mercury pip + 3 round HoT / Mercury Power + HoT / All HP + HoT |
| Wish / Wish Well / Pure Wish | 3 | 4/7/15 | Party | Heal: Highest Mercury Value / +Mercury Power / (All Charge×2)+Mercury Power |
| Break | 1 | 3 | T3 | Reset ATK and DEF |
| Restore / Panacea | 2 | 2/? | Target/Party | Cure all status |

### None Element

| Spell | Cost | Effect |
|-------|------|--------|
| Miracle | 5 | T3 Mars = Mars Charge; Self +Venus Charge DEF; Target Adept heal Mercury Charge; T-Y inflict status (Y = Jupiter Charge) |
| Psy Drain | 0 | Self +X PP (X = All Charge) |
| Catch | 5 | Auto End of Combat: Draw additional item card |
| Cloak | 10 | Target Adept: Passive 1 Round: Immune to damage and attack effects |
| Force | 3× | Target Normal Damage = X Elemental Values (X = times cost paid) |
| Move | 3 | Auto Puzzle Drawn: Shuffle+Redraw puzzle (once per floor) |

### Ninjutsu (D. Waller exclusive)

| Spell | Tiers | Cost | Effect |
|-------|-------|------|--------|
| Thunderclap / Thunderbolt / Thunderhead | 3 | 2/4/9 | T3 Jupiter: 3 / 8 / 12 |
| Shuriken | 1 | X | All: assign pips, damage type = die element; X = dice assigned |
| Death Plunge / Death Leap | 2 | 2/8 | Weapon Attack + Stun / Weapon×2 (same target) |
| Punji / Punji Trap / Punji Strike | 3 | 5/7/12 | T3/T3/T5 Venus: 3+Poison / 5+Venom / 5+Venom |
| Fire Bomb / Cluster / Carpet Bomb | 3 | 4/6/12 | T5/All/All Mars: 3 / 3 / 8 + T3 Delusion |
| Annihilation | 1 | 3 | T1 Venus = Weapon; d10: 1-9 +½ damage Venus, 10 = non-boss Downed |
| Gale / Typhoon / Hurricane | 3 | 3/6/9 | T3/T5/T5 Jupiter: 1+Elem Power / 3+Elem Power / 5+Elem Power+Melee Power |

---

## Weapons

### Chapter 0 (Starting)

| Name | Type | Pool | Unleash |
|------|------|------|---------|
| Short Sword | Short Sword | 2 melee | — |
| Long Sword | Long Sword | 3 melee | — |
| Battle Axe | Axe | 3 melee | — |
| Mace | Mace | 4 melee | — |
| Wooden Stick | Staff | 2 melee + 1 elemental | — |
| Pirate's Sword | Short Sword | 3 melee | Dual 6s: Inflict Sleep + X Mercury to neighbors (X = ½ damage) |

### Chapter 1 (Mercury Lighthouse)

| Name | Type | Pool | Unleash |
|------|------|------|---------|
| Short Sword | Short Sword | 2 melee | — |
| Bandit's Sword | Short Sword | 3 melee | Solo 6: Jupiter Damage, assign each point individually |
| Elven Rapier | Short Sword | 3 melee | Auto: +X Jupiter (X = number of 6s) |
| Long Sword | Long Sword | 3 melee | — |
| Broad Sword | Long Sword | 5 melee | — |
| Arctic Blade | Long Sword | 4 melee | Auto: +X Mercury (X = number of 6s) |
| Battle Axe | Axe | 3 melee | — |
| Great Axe | Axe | 6 melee | — |
| Vulcan Axe | Axe | 4 melee | Dual 6s: +2 Mars + 2 Mars to neighbors |
| Mace | Mace | 4 melee | — |
| Grievous Mace | Mace | 4 melee | Dual 6s: +2 Venus |
| Wooden Stick | Staff | 2 melee + 1 elemental | — |
| Psynergy Rod | Staff | 4 melee | Auto: Recover X PP (X = number of 6s) |
| Witch's Wand | Staff | 3 melee + 1 Jupiter | Solo 6: Jupiter Damage + Stun |

### Chapter 2 (Venus Lighthouse)

| Name | Type | Pool | Unleash | Cursed |
|------|------|------|---------|--------|
| Hunter's Sword | Short Sword | 4 melee | — | |
| Assassin Blade | Short Sword | 6 melee | Triple 6s: Non-boss Downed | |
| Kusanagi | Short Sword | 8 melee | — | Yes (charge: 3 or less; 1-2 ends turn) |
| Broad Sword | Long Sword | 5 melee | — | |
| Storm Brand | Long Sword | 7 melee | Dual 6s: +3 Mercury + inflict -1 ATK | |
| Muramasa | Long Sword | 9 melee | — | Yes (charge: odd; 1-2 ends turn) |
| Burning Axe | Axe | 5 melee | Dual 6s: +X Mars (X = All Uncharged) | |
| Great Axe | Axe | 6 melee | — | |
| Demon Axe | Axe | 8 melee | — | Yes (charge: unique values; ATK + Charge×9; 1-2 ends turn) |
| War Mace | Mace | 5 melee | — | |
| Blessed Mace | Mace | 6 melee | Triple 6s: Recover HP = damage done | |
| Wicked Mace | Mace | 8 melee | — | Yes (charge: 2 or less; 1-2 ends turn) |
| Magic Rod | Staff | 3 melee + 3 elemental | — | |
| Staff of Anubis | Staff | 5 melee | Auto: +X Venus (X = dead enemies) | |
| Angelic Ankh | Staff | 2 melee + 3 Mercury | Auto: Target Adept recover X HP (X = number of 6s) | |
| Demonic Staff | Staff | 4 melee + 4 Mars | — | Yes (charge: 4 or less; 1-2 ends turn) |

### Chapter 3 (Jupiter Lighthouse)

| Name | Type | Pool | Unleash | Cursed |
|------|------|------|---------|--------|
| Swift Blade | Short Sword | 5 melee | Triple 6s: 3× Jupiter Damage | |
| Ninja Blade | Short Sword | 6 melee | Deal 10 Damage: inflict -3 DEF | |
| Pirate's Sabre | Short Sword | 7 melee | Dual 6s: Venom + X Normal to neighbors | |
| Kikuichimonji | Short Sword | 8 melee | Auto: ATK applies twice | |
| Kusanagi | Short Sword | 8 melee | — | Yes |
| Rune Blade | Long Sword | 5 melee | Solo 6: Seal Psynergy | |
| Soul Brand | Long Sword | 6 melee | Triple 6s: Recover X PP (X = ½ damage) | |
| Gaia Blade | Long Sword | 9 melee | Triple 6s: Venus T3 | |
| Huge Sword | Long Sword | 10 melee | Auto: Attack does Venus Damage | |
| Burning Axe | Axe | 5 melee | Dual 6s: Broil | |
| Captain's Axe | Axe | 7 melee | — | |
| Demon Axe | Axe | 8 melee | — | Yes |
| Hagbone Mace | Mace | 6 melee | X Melee Charge: Inflict Haunt | |
| Wicked Mace | Mace | 8 melee | — | Yes |
| Zodiac Wand | Staff | 4 melee + 4 Jupiter | (Psy) T3: Inflict Delusion | |
| Crystal Rod | Staff | 6 melee | Auto: +X Mercury (6s×2); Triple 6s: Downed | |
| Cloud Wand | Staff | 3 melee + 4 elemental | All Melee 5+: Stun target and neighbors | |
| Dracomace | Staff | 5 melee | Auto: Recover X HP (X = 5s and 6s in pool) | |

### Cursed Weapons
Cursed weapons have alternate charge rules (often easier to charge = more dice) but roll d6 at start of turn: on 1-2, turn ends immediately. Cleric's Ring prevents the turn skip (but can't unequip).

### Weapon Improvement (Artifacts)
Buy a weapon from a previous chapter at a Town artifact shop. Gains 1 improvement token per chapter gap.
Each token, choose one:
- **Unleash**: +2 flat damage on unleash (or gain a basic unleash if none)
- **Melee**: +1 Melee die
- **Elemental**: +1 die of an element the weapon already provides

---

## Armor

### Chapter 1

| Name | Slot | Effect |
|------|------|--------|
| Bronze Shield | Shield | +1 DEF |
| Earth Shield | Shield | -2 Venus/Jupiter Damage (min 1) |
| Dragon Shield | Shield | -2 Mars/Mercury Damage (min 1) |
| Psychic Circlet | Headwear | Auto Start of Turn: +1 PP; d8 break |
| Healing Ring | Ring | Auto Weapon Attack: Target Adept Recover 3 HP; d4 break |
| War Ring | Ring | +1 Melee Power; d8 break |
| Unicorn Ring | Ring | Auto Start of Turn: Target Adept Cure Poison; d8 break |
| Adept Ring | Ring | Auto Weapon Attack: Target Adept Recover 2 PP; d8 break |

### Chapter 2

| Name | Slot | Effect |
|------|------|--------|
| Bronze Shield | Shield | +1 DEF |
| Herbed Shirt | Body | Auto Poison/Venom Damage: Cure Poison or Venom |
| Psychic Circlet | Headwear | Auto Start of Turn: +1 PP; d8 break |
| Lucky Cap | Headwear | Reroll 1 die once per turn; d8 break |
| Lure Cap | Headwear | Auto Enemy Attack: redirect once per round; d8 break |
| Guardian Ring | Ring | All dice +1 pip (max 6) |
| War Ring | Ring | +1 Melee Power; d8 break |
| Cleric's Ring | Ring | Curses can't skip turns (still can't unequip) |
| Fairy Ring | Ring | All dice -1 pip (min 1) |

### Chapter 3

| Name | Slot | Effect |
|------|------|--------|
| Iron Shield | Shield | +2 DEF (or +1 if you have DEF up tokens) |
| Mirrored Shield | Shield | Auto: Attacker takes X Normal (X = ½ damage if only target, else 1) |
| Dragon Robe | Body | Psynergy costs 1 less PP (min 1) |
| Silk Robe | Body | Attempt rolls vs you require 6 |
| Adept's Clothes | Body | +5 Max PP |
| Water Jacket | Body | -2 Mars/Mercury Damage |
| Storm Gear | Body | -2 Venus/Jupiter Damage |
| Lure Cap | Headwear | Auto Enemy Attack: redirect; d8 break |
| Lucky Cap | Headwear | Reroll 1 die; d8 break |
| Fear Helm | Headwear | +3 DEF; CURSED: 1-2 ends turn |
| Thunder Crown | Headwear | Auto Start of Turn: +2 PP; CURSED: 1-2 ends turn |
| Soul Ring | Ring | Auto Downed: Recover all HP, discard this card |
| Spirit Ring | Ring | Auto Weapon Attack + Dual 6s: Party Recover 6 HP; d8 break |
| Stardust Ring | Ring | Auto Weapon Attack + Dual 6s: Seal Psynergy; d8 break |

### Armor Break Mechanic
Rings roll d4 (25% break), other armor rolls d8 (12.5% break) at end of combat.

---

## Items

### Healing
| Name | Effect |
|------|--------|
| Herb | Target Adept: Recover 3 HP |
| Nut | Target Adept: Recover 6 HP |
| Vial | Target Adept: Recover 10 HP |
| Potion | Target Adept: Recover 20 HP |
| Mist Potion | Party: Recover all HP |
| Water of Life | Target Downed Adept: Recover all HP |
| Antidote | Target Adept: Cure Poison |
| Psy Crystal | Target Adept: Recover 3 PP |

### Battle Items
| Name | Effect |
|------|--------|
| Bramble Seed | All Opposing: Venus Damage = 1 + Elemental Charge (min 1) |
| Oil Drop | All Opposing: Mars Damage = 1 + Elemental Charge (min 1) |
| Weasel's Claw | All Opposing: Jupiter Damage = 1 + Elemental Charge (min 1) |
| Crystal Powder | All Opposing: Mercury Damage = 1 + Elemental Charge (min 1) |
| Smoke Bomb | Target 3: Inflict Delusion |
| Sleep Bomb | Target 3: Inflict Sleep |

### Special Draws
| Name | Effect |
|------|--------|
| Summon Tablet | Auto Draw: Draft 1 Summon (reveal 2, pick 1) |
| Psynergy Stone | Auto Draw: Self Recover all PP |
| Elemental Star | Auto Draw: Draft 1 Djinni (reveal 3, pick 1) |
| Coins (10/20/30) | Auto Draw: Gain gold, discard |

### Boss Loot
| Name | Effect |
|------|--------|
| Apple | Passive: +1 ATK |
| Hard Nut | Passive: +1 DEF |
| Power Bread | Passive: +3 Max HP |
| Cookie | Passive: +3 Max PP |
| Shiny Gem | Passive: +1 Level |
| Mint | May reroll dice pool once per combat |
| Lucky Medal | 1 Round: +1 Turn to all Adepts (second turn immediately after first) |
| Mystic Draught | Counts as a copy of any learned spell not at max level (permanent) |

---

## Monsters

### Chapter 1 (Mercury Lighthouse)

| Name | HP | Element | Weakness | Moves |
|------|-----|---------|----------|-------|
| Ooze | 5 | Venus | Mars | 1-3: 1 Normal; 4: -2 DEF |
| Cuttle | 8 | Mercury | Mars | 1-3: 2 Normal; 4: 3 Venus + Attempt Poison |
| Ghoul | 10 | Venus | Mars | 1-3: 2 Normal; 4: 1 Normal + Recover HP |
| Gnome | 5 | Mars | Mercury | 1-2: 1; 3-5: 2 Mars; 6-7: 3 Jupiter; 8: Party +1 DEF |
| Harpy | 6 | Jupiter | Jupiter | 1-2: 1; 3-4: 2 Jupiter |
| Lizard Man | 12 | Mercury | Mars | 1-3: 3; 4: All 2 Mercury |
| Mauler | 8 | Jupiter | Mars | 1-3: 2; 4: 4 Normal |
| Siren | 10 | Mercury | Mars | 1-3: 1; 4-5: 2 Mercury; 6: Attempt Sleep |

### Chapter 1 Bosses

| Name | HP | Element | Weakness | Vulnerable | Moves | Reward |
|------|-----|---------|----------|-----------|-------|--------|
| Mercury Djinni | 30 | Mercury | Mars | 5 | 1-4: 3 Mercury; 5-6: 2 Mercury; 7: All 2 Mercury; 8: Attempt Sleep | Djinni |
| Mimic | 20 | Jupiter | Mars | 10 | 1-3: 3; 4-5: -2PP; 6-7: Inflict Sleep; 8: Flee (5+) | Upgrade Draw |
| Saturos | 50 | Mars | Mercury | 3 | 1: 2; 2-3: 3 Mars; 4-6: All 2 Mars; 7-8: 3 Mars | Crown |

### Chapter 2 (Venus Lighthouse)

| Name | HP | Element | Weakness | Moves |
|------|-----|---------|----------|-------|
| Boulder Beast | 8 | Mars | Mercury | 1-3: 2; 4-5: 2 Mars; 6-7: 3 Mars; 8: All 4 Venus + Self Downed |
| Chimera Mage | 8 | Mars | Mercury | 1-3: 2; 4-6: All 2 Mars; 7: Self +3 HP; 8: 3 Venus + Attempt Poison |
| Fenrir | 15 | Mercury | Mars | 1-4: 3; 5: All 2 Mercury; 6-7: 2 Venus (×2 on Attempt); 8: 1 Jupiter + Attempt Stun |
| Grand Golem | 12 | Venus | Jupiter | 1-3: 2 Venus; 4: 5 Venus |
| Ice Gargoyle | 8 | Jupiter | Venus | 1-2: 2; 3: Self +3 DEF; 4-5: 3 Venus; 6: All 2 Mercury |
| Manticore King | 8 | Mars | Mercury | 1-4: 2; 5: Attempt Poison; 6-7: 3 Mars; 8: Attempt Seal |
| Recluse | 6 | Venus | Mars | 1-2: 1; 3: 1 Venus + Poison; 4: -2 DEF |
| Skull Warrior | 15 | Mercury | Venus | 1-2: 3; 3: 4 Venus; 4: -3 ATK |
| Thunder Lizard | 12 | Jupiter | Venus | 1-3: 2; 4: All 4 Jupiter |
| Wild Gryphon | 12 | Venus | Jupiter | 1-2: 3; 3: 4 Jupiter (×2 on Attempt); 4: 3 Jupiter |
| Willowisp | 10 | Mercury | Venus | 1-2: 1; 3: 4 Mercury; 4: 2 Jupiter + Self Recover HP |

### Chapter 2 Bosses

| Name | HP | Element | Weakness | Vulnerable | Moves | Reward |
|------|-----|---------|----------|-----------|-------|--------|
| Venus Djinni | 60 | Venus | Jupiter | 5 | 1-3: 3 Venus; 4-5: All 2 Venus; 6-7: 5 Venus; 8: Self +6 HP | Djinni |
| Tempest Lizard | 50 | Jupiter | Venus | 4 | 1-4: 2 Jupiter (×2); 5-6: All 2 Jupiter; 7-8: 4 Jupiter; 9: Self +3 ATK; 0: Self +3 DEF | +1 Draw |
| Fusion Dragon | 150 | Mars | Mercury | 2 | 1-2: 5; 3-4: All 3 Mars; 5-6: All Reset ATK/DEF; 7-8: 4 Venus + Recover HP; 9-0: 3 Venus + Poison | Crown |

### Chapter 3 (Jupiter Lighthouse)

| Name | HP | Element | Weakness | Moves |
|------|-----|---------|----------|-------|
| Blue Dragon | 30 | Mercury | Mars | 1-4: 4; 5-6: All 6 Mercury; 7-8: 7 Mercury |
| Devil Scorpion | 23 | Jupiter | Mars | 1: 3; 2: 5 Venus (×2); 3: All 4 Venus; 4: 3 Venus + Attempt Venom |
| Foul Mummy | 23 | Mercury | Mars | 1-3: 3; 4: 6 Venus + Attempt Stun (Ignore DEF) |
| Ghost Army | 20 | Mercury | Jupiter | 1-4: 3; 5-7: 7 Jupiter (Ignore DEF); 8: 5 Jupiter |
| Macetail | 20 | Mars | Mercury | 1: 4; 2: 3 Mars + Stun; 3-4: Self +3 DEF |
| Wyvern | 25 | Venus | Jupiter | 1-2: 3; 3: All 6 Mars; 4: All Attempt Poison |

### Chapter 3 Bosses

| Name | HP | Element | Weakness | Vulnerable | Moves | Reward |
|------|-----|---------|----------|-----------|-------|--------|
| Jupiter Djinni | 60 | Jupiter | Venus | 5 | 1-3: 3 Jupiter; 4-5: All 4 Jupiter; 6-7: Inflict Sleep; 8-9: 5 Jupiter + Stun; 0: Self +3 ATK | Djinni |
| Star Magician | 90 | Mercury | Mars | 4 | 1-2: 2; 3: All 4; 4-5: 6 Jupiter; 6-8: All 3 Mercury (ignore DEF); 9-0: Respawn 1 Ball | Summon |
| Sentinel | 190 | Mercury | Venus | 0 | 1-2: 5 + Stun; 3: Reset+Remove tokens; 4-5: Self +3 DEF; 6-7: All 7 Mars; 8-0: 4 (ignore DEF) -2 DEF | Summon |
| Agatio | 140 | Mars | Mercury | 3 | 1: 5; 2-3: 6 Mars; 4-5: 4 Mars + Stun; 6-8: 4 Mars; 9-0: -3 DEF | Crown |
| Karst | 140 | Mars | Mercury | 3 | 1-3: 5; 4-5: All 5 Mars (ignore DEF); 6-7: Party +10 HP; 8-9: -3 ATK; 0: All put 1 Djinni in recovery | Crown |

### Star Magician's Balls

| Name | HP | Element | Weakness | Moves |
|------|-----|---------|----------|-------|
| Anger Ball | 20 | Mars | Mercury | 1-3: 4; 4: 7 Mars (ignore DEF), then dies |
| Guardian Ball | 20 | Venus | Jupiter | 1: Self +2 DEF; 2-4: All other enemies +1 DEF |
| Refresh Ball | 20 | Mercury | Mars | 1-2: Heal all balls 10 HP; 3-4: Heal Star Magician 15 HP |
| Thunder Ball | 20 | Jupiter | Venus | 1: 2; 2: 5 Jupiter T1; 3: 4 Jupiter T3; 4: 3 Jupiter All |

---

## Floors & Lighthouse Structure

Each lighthouse has ~8 floors plus an Aerie (final boss). Floors are shuffled into a deck. Red-key floors are set aside for specific sections.

### Chapter 1 — Mercury Lighthouse
- Entry: Hermes Fountain (Combat 4)
- Regular floors: mix of Puzzles + Combat (4-8 enemies)
- Mini-bosses: Mimic, Mercury Djinni
- Aerie: Saturos

### Chapter 2 — Venus Lighthouse
- Entry 1-2: Puzzles + Combat
- Entry 3: Boss: Tempest Lizard + 2 adds
- Regular floors: Puzzles + Combat (6-10 enemies)
- Mini-boss: Venus Djinni
- Aerie: Fusion Dragon

### Chapter 3 — Jupiter Lighthouse
- Tower Left/Right branches (Puzzles + Combat)
- Tower bosses: Star Magician (Left), Sentinel (Right)
- Regular floors: Combat + Puzzles
- Mini-boss: Jupiter Djinni
- Aerie: Agatio + Karst (dual boss)

### Floor Challenges
- **Combat Challenge**: Set number of enemies
- **Psynergy Puzzle**: Flip a puzzle card, solve per instructions
- **Boss Challenge**: Specific boss with optional adds

Floors have a threshold (e.g., 2/3 = complete 2 of 3 challenges).

---

## Curses & Rewards (Lighthouse Tracker)

### Rewards (blue, on floor clear)
- Green gem: all players gain 1 level
- Djinni icon: 1 Djinni joins party
- Summon tablet: learn 1 Summon

### Curses (red, on floor enter)
Roll curse die:
- All enemies +1 ATK
- All enemies +1 Resistance to own element
- All enemies +3 Max HP (Bosses +10 HP)

Curses are permanent for the chapter. At chapter end, choose one to carry as a **Permanent Curse** into the next chapter.

---

## Psynergy Puzzles

| Puzzle | Disarm With | Reward / Trap Effect |
|--------|------------|---------------------|
| Catch | Cast Catch | See next floor card |
| Cloak | Cast Cloak | No damage from non-boss enemies, round 1 |
| Douse | Cast Douse | Enemies start -1 DEF |
| Force | Cast Force | Cure all status |
| Halt | Cast Halt | d4: on 1, trade a Djinni for different element |
| Move | Cast Move | All players 2 blind draws |
| Reveal | Cast Reveal | All players 1 choice draw |
| Whirlwind | Cast Whirlwind | Gain 10g |
| Frost | Cast Frost | d4: on 1, Djinni joins |
| **Traps:** | | |
| Stolen Supplies | Cast Catch | No HP/PP gain end of combat |
| Sentry Statues | Cast Cloak | Jupiter enemies +3 ATK |
| Evil Desert Wind | Cast Douse | Venus enemies +3 ATK |
| Speedy Enemies | Cast Halt | First enemy turn before players |
| Statue Trap | Cast Move | +2 enemies in combats this floor |
| Falling Rocks | Cannot disarm | All adepts -2 HP before combats |
| Poison Spike | Cast Restore | 1 adept poisoned at combat start |
| Venus Overload | Jupiter spell (8+ PP) | All adepts take Venus affinity as damage |
| Mars Overload | Mercury spell (8+ PP) | All adepts take Mars affinity as damage |
| Jupiter Overload | Venus spell (8+ PP) | All adepts take Jupiter affinity as damage |
| Mercury Overload | Mars spell (8+ PP) | All adepts take Mercury affinity as damage |
| Magic Powder | Whirlwind or Douse | All adepts Stunned at combat start |
| Sleeping Gas | Cast Force | All adepts Sleeping at combat start |
| Psy Seal | Cast Halt | No Psynergy first turn of combats |
| Armory | Cast Break | All enemies start with 2 ATK up + 2 DEF up tokens |

---

## Towns

| Town | Chapter | Rewards | Weapon | Armor | Item | Artifact | Psy | Summon |
|------|---------|---------|--------|-------|------|----------|-----|--------|
| Vale | 1 | Level Up + Djinni | — | — | 10g | — | — | — |
| Vault | 1 | Djinni + Choice Draw | 20g | 20g | 10g | — | — | — |
| Kolima | 1 | Djinni | 20g | 20g | 5g | — | — | — |
| Imil | 1 | Djinni | 20g | 20g | 10g | — | 50g | — |
| Xian | 2 | Djinni | 20g | 20g | 10g | 25g | 30g | — |
| Tolbi | 2 | Djinni + Choice Draw | 20g | 20g | 10g | 25g | — | 50g |
| Lalivero | 2 | Djinni | 10g | 10g | 10g | 25g | — | — |
| Air's Rock | 3 | Summon | — | 20g | — | 25g | 30g | 50g |
| Gaia Rock | 3 | Level Up | — | 20g | 20g | 25g | 30g | 50g |
| Aqua Rock | 3 | Djinni | 20g | — | 10g | 25g | 30g | 50g |
| Magma Rock | 3 | Djinni + Level Up | 20g | 20g | 20g | 25g | 30g | 50g |

### Town Actions (in order):
1. **Recover** — full HP/PP, cure all status, recover all Djinn
2. **Find** — resolve town rewards (level-ups, Djinn, draws)
3. **Buy** — purchase from available shops

---

## Learning Magic

### Psynergy
- At level-up: reveal 10 cards, each learning player picks one
- Once per chapter: search deck for another copy of a known spell (upgrade tier)
- Before learning: may trade known spells for first-level alternatives (unlimited trades)

### Djinn
- Reveal 3 from deck, party selects 1 to join. Can pass.
- Max 4 per adept; no adept can have 2+ more than any other

### Summons
- Reveal 2, party selects 1. Other shuffled back.

---

## Campaign — Chapter Transitions

### Carry Over:
- Learned Psynergy
- Equipped Djinn and equipment
- Boss Loot cards

### Do NOT Carry Over:
- Consumable items, gold

### New Chapter Start:
- Max HP for new chapter
- PP = 3 × chapter number
- Starting consumable item re-given
- Equipment from prior chapters persists

---

## Key Rules Interactions

1. **Dice never deplete** — re-rolled every turn, never spent
2. **Dead enemies still count** for adjacency — can't skip them for multi-targeting
3. **A Round** = all players act once + all enemies act once
4. **Stat decay only affects tokens**, not permanent armor/loot bonuses
5. **Bosses act on Boss Turns AND the Enemy Turn**
6. **Flash** always reduces positive damage to exactly 1, applied last
7. **Weakness/Resistance minimum is always 1**, even with low power
8. **Djinn do NOT auto-recover at end of combat**
9. **Downed players reduce boss turn frequency** (removed from turn order)
10. **Items and Summons bypass Stun** — only Attack/Psynergy/Djinni need the stun roll
11. **All status vs bosses is an attempt** (d6, 4+ to inflict)
12. **Poison/Venom tick** at end of every player turn AND enemy turn (NOT on Boss Turns)
