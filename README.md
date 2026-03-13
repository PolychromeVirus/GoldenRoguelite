# Golden Sun Themed Roguelite
##Based on Lighthouse Dash! by PolychromeVirus

---

Rules are inherited from the board game. current rules are in the source code as a reference doc.

Some effects are changed but not many, mostly intuitively. the in game effect text should be accurate.

All spells, djinn, and summon effects are implemented, save for "Call Zombie" which is a character skill for an unimplemented character.

-----
# Menu navigation
Menus are navigated by using the scroll wheel to move through the vertical carousel. The confirm button (and occasionally the enter key) are used to lock in selections
Some menus aren't fully implemented, they use keyboard and enter/confirm

Enemy targeting uses the scroll wheel or clicking on enemies directly to target your attack.
Character targeting uses a vertical carousel (for now)


# Character select
Select your characters by clicking the character faces on the first page
Out of combat, to cycle who's "turn" it is, click the face of the chosen character in the top bar

# Towns
You can visit towns when entering a floor before doing any challenges. Each town may only be visited once, and is the primary method of drafting djinn

# Djinn
Djinn give you dice for your pool

# Game end
Each dungeon has 8 floors and a boss. After the boss there is a boss item draft and then the next dungeon. There are currently 3 dungeons.
