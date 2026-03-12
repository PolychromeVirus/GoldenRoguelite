
//feed this object a number of dice to assign, an element for the damage to be, a subset of dice, and a target type.
//{ dieset(string), num(int), element(string), target(string) }

DestroyAllBut(objAssignMenu)

if variable_struct_exists(global.players[global.turn],string_lower(dieset)){
	var eval = string_lower(dieset)
	
}
var dpool = variable_clone(global.players[global.turn].dicepool)


dice = []
var vpool = []

var pipbonus = 0
var vbonus = global.players[global.turn].vbonus
var mabonus = global.players[global.turn].mabonus
var jbonus = global.players[global.turn].jbonus
var mebonus = global.players[global.turn].mebonus
var meleebonus = global.players[global.turn].meleebonus

if array_contains(global.players[global.turn].armor, "Guardian Ring"){ pipbonus += 1 }
if array_contains(global.players[global.turn].armor, "Fairy Ring"){ pipbonus -= 1 }

for (var i = 0; i < array_length(dpool[POOL_VENUS]); ++i) {
    dpool[POOL_VENUS][i] = max(min(dpool[POOL_VENUS][i] + pipbonus, 6), 1) + vbonus
}
for (var i = 0; i < array_length(dpool[POOL_JUPITER]); ++i) {
    dpool[POOL_JUPITER][i] = max(min(dpool[POOL_JUPITER][i] + pipbonus, 6), 1) + jbonus
}
for (var i = 0; i < array_length(dpool[POOL_MARS]); ++i) {
    dpool[POOL_MARS][i] = max(min(dpool[POOL_MARS][i] + pipbonus, 6), 1) + mabonus
}
for (var i = 0; i < array_length(dpool[POOL_MERCURY]); ++i) {
    dpool[POOL_MERCURY][i] = max(min(dpool[POOL_MERCURY][i] + pipbonus, 6), 1) + mebonus
}
for (var i = 0; i < array_length(dpool[POOL_MELEE]); ++i) {
    dpool[POOL_MELEE][i] = max(min(dpool[POOL_MELEE][i] + pipbonus, 6), 1) + meleebonus
}

	
	switch eval{
		case "venus": vpool = dpool[POOL_VENUS]; break
		case "mars": vpool = dpool[POOL_MARS]; break
		case "jupiter": vpool = dpool[POOL_JUPITER]; break
		case "mercury": vpool = dpool[POOL_MERCURY]; break
		case "melee": vpool = dpool[POOL_MELEE]; break
		case "all": vpool = array_concat( 
			dpool[POOL_VENUS],
			dpool[POOL_MARS],
			dpool[POOL_JUPITER],
			dpool[POOL_MERCURY],
			dpool[POOL_MELEE]); 
		break
		case "elemental": vpool = array_concat( 
			dpool[POOL_VENUS],
			dpool[POOL_MARS],
			dpool[POOL_JUPITER],
			dpool[POOL_MERCURY]); 
		break
	}
dice = variable_clone(vpool)
if target = "enemy" {num = min(num, instance_number(objMonster), array_length(dice))}else{
	num = min(num,array_length(dice),4)
}

instance_create_depth(sprite_width,sprite_height/2,0,objQuarterMenu)

var button1 = 36
var buttonno = 94

DeleteButtons()

instance_create_depth(buttonno,124,0,objCancel)

var sprite = {image:Psynergy,text:"Select Die"}

instance_create_depth(button1,124,0,objConfirm,sprite)