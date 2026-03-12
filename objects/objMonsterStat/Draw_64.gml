var drawx = 50
var drawy = 50
var offset = 4

var sprite = alias

draw_set_font(GoldenSun)

draw_sprite_stretched(sprite,0,drawx,drawy,sprite_get_width(sprite) * 4, sprite_get_height(sprite) * 4)

var statarray = []

var namey = drawy + 8 + (sprite_get_height(sprite) * 4)

var starsize = 20
var pad = 4
var stary = namey + ((string_height(name + " - " + element)/2) - (starsize/2))

draw_sprite_stretched(asset_get_index(element + "_Star"),0,drawx,stary,starsize,starsize)

draw_set_colour(c_black)
draw_text(drawx+(starsize+8)+pad+offset,namey+offset,name + " - " + element)
draw_set_colour(c_white)
draw_text(drawx+(starsize+8)+pad,namey,name + " - " + element)

if poison {array_push(statarray,Poison)}
if stun > 0 {array_push(statarray,Bolt)}
if sleep {array_push(statarray,Sleep)}
if psyseal {array_push(statarray,Psy_Seal)}
if venom {array_push(statarray,Poison_Flow)}

var hpx = drawx + (sprite_get_width(sprite) * 4) + 10
var hpy = drawy + 50

var barsize = 300
var barstart = hpx + 200
var barend = barstart + barsize

draw_set_color(c_black)
draw_text(hpx+4,hpy+4,"HP: " + string(monsterHealth) + "/" + string(maxhp))
draw_set_color(c_white)
draw_text(hpx,hpy,"HP: " + string(monsterHealth) + "/" + string(maxhp))

draw_rectangle_color(barstart,hpy,barend,hpy+string_height("HP:"),c_black,c_black,c_black,c_black,false)
barsize = floor(barsize * (monsterHealth / maxhp))
draw_rectangle_color(barstart,hpy,barstart+barsize,hpy+string_height("HP:"),c_lime,c_lime,c_lime,c_lime,false)

var statx = barstart
var staty = hpy+string_height("HP:")+8

for (var i = 0;i<array_length(statarray);i++){
	draw_sprite_stretched(statarray[i],0,statx,staty,39,39)
	statx += 39+4
}


