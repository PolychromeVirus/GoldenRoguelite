var drawx = 50
var drawy = 50
var offset = 4

var sprite = global.players[viewPlayer].portrait

draw_set_font(GoldenSun)

draw_sprite_stretched(sprite,0,drawx,drawy,32*4,32*4)

var statarray = []

var _p = global.players[viewPlayer]

if _p.poison {array_push(statarray,Poison)}
if _p.stun > 0 {array_push(statarray,Bolt)}
if _p.sleep {array_push(statarray,Sleep)}
if _p.psyseal {array_push(statarray,Psy_Seal)}
if _p.venom {array_push(statarray,Poison_Flow)}
if _p.rootTokens > 0 {array_push(statarray,Growth)}
if _p.regen {array_push(statarray,Ply)}
if _p.cloak {array_push(statarray,Cloak)}
if array_length(_p.rerolls) > 0 {array_push(statarray,Lucky_Medal1503)}
if _p.atkmod > 0 {array_push(statarray, attack_up)}
if _p.atkmod < 0 {array_push(statarray, attack_down)}
if _p.defmod > 0 {array_push(statarray, defense_up)}
if _p.defmod < 0 {array_push(statarray, defense_down)}
if variable_struct_exists(_p.delaydata,"revive") and _p.delaydata.revive {array_push(statarray,Poison_Flow)}

var statx = drawx
var staty = drawy + (32 * 4) + 2

for (var i = 0;i<array_length(statarray);i++){
	draw_sprite_stretched(statarray[i],0,statx,staty,39,39)
	statx += 39+4
}

var dicex = drawx + (32 * 4) + 10
var hpx = drawx + (32 * 4) + 10
var hpy = drawy + 50

var dicepad = 10

if global.players[viewPlayer].melee > 0{
	var subdice = global.players[viewPlayer].melee
	var col = c_black
	for (var i = 0;i < subdice; i++){
		draw_rectangle_color(dicex,drawy,dicex+32,drawy+32,col,col,col,col,false)
		dicex += 32 + dicepad
	}
}
if global.players[viewPlayer].venus > 0{
	var subdice = global.players[viewPlayer].venus
	var col = c_yellow
	for (var i = 0;i < subdice; i++){
		draw_rectangle_color(dicex,drawy,dicex+32,drawy+32,col,col,col,col,false)
		dicex += 32 + dicepad
	}
}
if global.players[viewPlayer].mars > 0{
	var subdice = global.players[viewPlayer].mars
	var col = c_red
	for (var i = 0;i < subdice; i++){
		draw_rectangle_color(dicex,drawy,dicex+32,drawy+32,col,col,col,col,false)
		dicex += 32 + dicepad
	}
}
if global.players[viewPlayer].jupiter > 0{
	var subdice = global.players[viewPlayer].jupiter
	var col = c_purple
	for (var i = 0;i < subdice; i++){
		draw_rectangle_color(dicex,drawy,dicex+32,drawy+32,col,col,col,col,false)
		dicex += 32 + dicepad
	}
}
if global.players[viewPlayer].mercury > 0{
	var subdice = global.players[viewPlayer].mercury
	var col = c_blue
	for (var i = 0;i < subdice; i++){
		draw_rectangle_color(dicex,drawy,dicex+32,drawy+32,col,col,col,col,false)
		dicex += 32 + dicepad
	}
}

var barsize = 300
var barstart = hpx + 200
var barend = barstart + barsize

draw_set_color(c_black)
draw_text(hpx+4,hpy+4,"HP: " + string(global.players[viewPlayer].hp) + "/" + string(global.players[viewPlayer].hpmax))
draw_set_color(c_white)
draw_text(hpx,hpy,"HP: " + string(global.players[viewPlayer].hp) + "/" + string(global.players[viewPlayer].hpmax))

draw_rectangle_color(barstart,hpy,barend,hpy+string_height("HP:"),c_black,c_black,c_black,c_black,false)
barsize = floor(barsize * (global.players[viewPlayer].hp / global.players[viewPlayer].hpmax))
draw_rectangle_color(barstart,hpy,barstart+barsize,hpy+string_height("HP:"),c_lime,c_lime,c_lime,c_lime,false)

var weaponsprite = asset_get_index(global.itemcardlist[global.players[viewPlayer].weapon].alias)
var equipx = hpx+550
if weaponsprite != -1{draw_sprite_stretched(weaponsprite,0,equipx,hpy,64,64)}
equipx += 70
for (var k = 0; k < 4; k++){
	if k < array_length(global.players[viewPlayer].armor){
		var armorsprite = asset_get_index(global.itemcardlist[global.players[viewPlayer].armor[k]].alias)
		draw_sprite_stretched(armorsprite,0,equipx,hpy,64,64)
		equipx += 64
	}else{
		draw_sprite_stretched(Blank_Item,0,equipx,hpy,64,64)
		equipx += 64
	}
}
equipx+= 6
for (var k = 0; k < 5; k++){
	if k < array_length(global.players[viewPlayer].inventory){
		var itemsprite = asset_get_index(global.itemcardlist[global.players[viewPlayer].inventory[k]].alias)
		draw_sprite_stretched(itemsprite,0,equipx,hpy,64,64)
		equipx += 64
	}else{
		draw_sprite_stretched(Blank_Item,0,equipx,hpy,64,64)
		equipx += 64
	}
}

//draw the equipment here once it is set up properly in initChars

hpy += string_height("HP:") + 5

draw_set_color(c_black)
draw_text(hpx+4,hpy+4,"PP: " + string(global.players[viewPlayer].pp) + "/" + string(global.players[viewPlayer].ppmax))
draw_set_color(c_white)
draw_text(hpx,hpy,"PP: " + string(global.players[viewPlayer].pp) + "/" + string(global.players[viewPlayer].ppmax))

draw_rectangle_color(barstart,hpy,barend,hpy+string_height("PP:"),c_black,c_black,c_black,c_black,false)
barsize = floor(barsize * (global.players[viewPlayer].pp / global.players[viewPlayer].ppmax))
draw_rectangle_color(barstart,hpy,barstart+barsize,hpy+string_height("PP:"),c_purple,c_purple,c_purple,c_purple,false)

drawy += (32 * 4) + 50

var _starx = drawx + string_width("ATK: 10") + 32
var _stary = drawy +string_height("Isaac") + 5
draw_sprite_stretched(Venus_Star_Clean,0,_starx,_stary,64,64)
draw_sprite_stretched(Mars_Star_Clean,0,_starx,_stary+54,64,64)

draw_set_color(c_black)
draw_text(_starx+64+offset,_stary+offset+16, venusmod)
draw_set_color(global.c_venus)
draw_text(_starx+64,_stary+16, venusmod)

draw_set_color(c_black)
draw_text(_starx+64+offset,_stary+offset+16+54, marsmod)
draw_set_color(global.c_mars)
draw_text(_starx+64,_stary+16+54, marsmod)

_starx += max(string_width(venusmod)+32,string_width(marsmod)+32)+32
draw_sprite_stretched(Jupiter_Star_Clean,0,_starx,_stary,64,64)
draw_sprite_stretched(Mercury_Star_Clean,0,_starx,_stary+54,64,64)

draw_set_color(c_black)
draw_text(_starx+64+offset,_stary+offset+16, jupitermod)
draw_set_color(global.c_jupiter)
draw_text(_starx+64,_stary+16, jupitermod)

draw_set_color(c_black)
draw_text(_starx+64+offset,_stary+offset+16+54, mercurymod)
draw_set_color(global.c_mercury)
draw_text(_starx+64,_stary+16+54, mercurymod)

draw_set_color(c_white)

draw_set_color(c_black)
draw_text(drawx+4,drawy+4,content)
draw_set_color(c_white)
draw_text(drawx,drawy,content)

drawx = drawx + string_width("Psynergy Learned:  ") + 50

draw_set_color(c_black)
draw_text(drawx+4,drawy+4,"Short Sword:\nLong Sword:\nStaves:\nAxes:\nMaces:")
draw_set_color(c_white)
draw_text(drawx,drawy,"Short Sword:\nLong Sword:\nStaves:\nAxes:\nMaces:")

draw_set_color(c_black)
draw_text(drawx+4,drawy+4+string_height("Short Sword:\nLong Sword:\nStaves:\nAxes:\nMaces:\n"),equips)
draw_set_color(c_white)
draw_text(drawx,drawy+string_height("Short Sword:\nLong Sword:\nStaves:\nAxes:\nMaces:\n"),equips)

drawx = drawx + string_width("Long Sword: ") + 20

var djinny = drawy

draw_set_color(c_black)
draw_text(drawx+4,drawy+4,shorttrue)
if(global.players[viewPlayer].equipshort){draw_set_color(c_lime)}else{draw_set_color(c_red)}
draw_text(drawx,drawy,shorttrue)
drawy += string_height("Long Sword: ")

draw_set_color(c_black)
draw_text(drawx+4,drawy+4,longtrue)
if(global.players[viewPlayer].equiplong){draw_set_color(c_lime)}else{draw_set_color(c_red)}
draw_text(drawx,drawy,longtrue)
drawy += string_height("Long Sword: ")

draw_set_color(c_black)
draw_text(drawx+4,drawy+4,stafftrue)
if(global.players[viewPlayer].equipstaff){draw_set_color(c_lime)}else{draw_set_color(c_red)}
draw_text(drawx,drawy,stafftrue)
drawy += string_height("Long Sword: ")

draw_set_color(c_black)
draw_text(drawx+4,drawy+4,axetrue)
if(global.players[viewPlayer].equipaxe){draw_set_color(c_lime)}else{draw_set_color(c_red)}
draw_text(drawx,drawy,axetrue)
drawy += string_height("Long Sword: ")

draw_set_color(c_black)
draw_text(drawx+4,drawy+4,macetrue)
if(global.players[viewPlayer].equipmace){draw_set_color(c_lime)}else{draw_set_color(c_red)}
draw_text(drawx,drawy,macetrue)

drawx += 300

draw_set_color(c_black)
draw_text(drawx+offset,djinny+offset,"Djinn:")
draw_set_color(c_white)
draw_text(drawx,djinny,"Djinn:")

djinny+=string_height("Long Sword: ")+16

for (j = 0; j < array_length(global.players[viewPlayer].djinn); j++){
	
	var djinni = global.djinnlist[global.players[viewPlayer].djinn[j]].name
	var elcolor = global.c_venus
	switch global.djinnlist[global.players[viewPlayer].djinn[j]].element{
		case "Venus":
			elcolor = global.c_venus
			break
		case "Mars":
			elcolor = global.c_mars
			break
		case "Jupiter":
			elcolor = global.c_jupiter
			break
		case "Mercury":
			elcolor = global.c_mercury
			break
	}if global.djinnlist[global.players[viewPlayer].djinn[j]].ready == false and global.djinnlist[global.players[viewPlayer].djinn[j]].spent == false{
		elcolor = c_ltgray
	}if global.djinnlist[global.players[viewPlayer].djinn[j]].ready == false and global.djinnlist[global.players[viewPlayer].djinn[j]].spent == true{
		elcolor = c_red
	}
	
	
	
	draw_set_color(c_black)
	draw_text(drawx+offset,djinny+offset,djinni)
	draw_set_color(elcolor)
	draw_text(drawx,djinny,djinni)
	djinny += string_height(djinni)+4
}

var text = string(global.gold) + "gp"
var goldheight = 50
draw_set_color(c_black)
draw_text(global.camwidth - 50 - string_width(text)+offset,goldheight+offset,text)
draw_set_color(c_white)
draw_text(global.camwidth - 50 - string_width(text),goldheight,text)