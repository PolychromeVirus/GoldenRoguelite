# Character Passive TODO

Based on `datafiles/CharacterImport.csv` compared against the current combat / dice / shop scripts.

## Implemented

- Isaac: `Knows "Retreat"`
- Felix: `Knows "Scoop"`
- Delta: `Spells cost -1 PP`

## Partially Implemented

- Garet: `ATK tokens apply twice`
- Implemented for weapon attacks by doubling `atkmod`.
- TODO: confirm whether this should also affect spell/djinn formulas that use ATK.
- Tyrell: `ATK tokens apply twice`
- Same status as Garet.
- Mia: `Healing +1`
- Only applied in the `SelectTargets` full-party ally branch.
- TODO: extend to single-target healing and direct-heal spell paths if intended.
- Rief: `Healing +1`
- Same status as Mia.
- Ivan: `Status locked in for 1 turn`
- Locking exists, but Ivan's passive is only injected in one target-all damage path.
- TODO: apply this consistently to Ivan's status-inflicting actions.
- Karis: `Status locked in for 1 turn`
- Same status as Ivan.

## TODO: Not Implemented

- Matthew: `Knows "Retreat"`
- Text says he knows it, but his character row does not grant the spell.
- Jenna: `Always has 1 extra Mars Charge`
- Sheba: `Jupiter dice worth +1`
- Piers: `Marks enemies on attack`
- Eddy: `Resets DEFMOD when dealing damage`
- Kendall: `Gains DEF by buffing others`
- Omega: `ATK applies to Spells`
- The CSV flag is not wired into spell damage calculation.
- Lyza: `Does damage when debuffing`
- Flint: `Reverse Dice Pool`
- Cannon: `Reverse Dice Pool`
- Waft: `Reverse Dice Pool`
- Sleet: `Reverse Dice Pool`
- Himi: `Always has 1 extra Venus Charge`
- Eoleo: `Items sell for 5g`
- Sveta: `+1 Melee Power`
- Amiti: `Knows "Insight"`
- `Insight` has a stub in `CastSpell`, but no real effect yet.
- Jules: `Jupiter dice satisfy all elements, can't do elemental damage`
- Kai: `Always has 1 extra Mercury Charge`
- Sean: `Always has 1 extra Melee Charge`
- Ouranos: `Every 5 in pool is also a 6`

## Likely Wiring Gaps

- `CharacterImport.csv` columns 37-39 appear to contain passive-related data for some characters, but `InitChars.gml` only reads column 37 as `aegiscurse` and ignores the attack-hook columns.
- Piers / Eddy / Omega look like they were meant to use those extra CSV columns, but the imported data is not currently mapped into character structs.
