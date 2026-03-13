# Character Passive TODO

Based on `datafiles/CharacterImport.csv` compared against the current combat / dice / shop scripts.

## Implemented

- Isaac: `Knows "Retreat"`
- Matthew: `Knows "Retreat"`
- Felix: `Knows "Scoop"`
- Delta: `Spells cost -1 PP`
- Garet / Tyrell: `ATK tokens apply twice` (doubling atkmod in weapon attacks)
- Mia / Rief: `Healing +1` (applied in objCharTarget healing paths)
- Ivan / Karis: `Status locked in for 1 turn` (locking flag on status inflicts)
- Kendall: `Gains DEF by buffing others` (implemented in objCharTarget buff branches)
- Omega: `ATK applies to Spells` (matk_ratio / matk_only flags)
- Jenna: `Always has 1 extra Mars Charge`
- Himi: `Always has 1 extra Venus Charge`
- Kai: `Always has 1 extra Mercury Charge`
- Sean: `Always has 1 extra Melee Charge`
- Sveta: `+1 Melee Power`
- Eoleo: `Items sell for 5g`
- Amiti: `Knows "Insight"`
- Flint / Cannon / Waft / Sleet: `Reverse Dice Pool`
- Sheba: `Jupiter dice worth +1`
- Ouranos: `Every 5 in pool is also a 6`
- Jules: `Jupiter dice satisfy all elements, can't do elemental damage`

## TODO: Not Yet Implemented

- Piers: `Marks enemies on attack`
- Eddy: `Resets DEFMOD when dealing damage`
- Lyza: `Does damage when debuffing`

## Notes

- `CharacterImport.csv` columns 37-39 contain passive-related data for some characters, but `InitChars.gml` only reads column 37 as `aegiscurse` and ignores the attack-hook columns.
- Piers / Eddy look like they were meant to use those extra CSV columns.
