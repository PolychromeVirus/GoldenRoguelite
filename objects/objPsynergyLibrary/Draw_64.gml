var drawx = 50
var drawy = 50
var offset = 4
var rangeoffset = 72
var stageoffset = 72
var elementtextoffset = 72
var textx = drawx
var newlineoffset = 72
var picsize = 128

var currentspell = global.psynergylist[indicator]
draw_set_font(GoldenSun)
draw_set_color(c_black)
draw_text(drawx+offset,drawy+offset,"<- " + currentspell.name + " ->")
draw_set_color(c_white)
draw_text(drawx,drawy,"<- " + currentspell.name + " ->")

var textlong = string_width(string(indicator + 1) + "/" + string(array_length(global.psynergylist)))
draw_set_color(c_black)
draw_text(1536-drawx-textlong+offset,drawy+offset,string(indicator + 1) + "/" + string(array_length(global.psynergylist)))
draw_set_color(c_white)
draw_text(1536-drawx-textlong,drawy,string(indicator + 1) + "/" + string(array_length(global.psynergylist)))

drawy+=newlineoffset

if currentspell.character != ""{
	var charpic = asset_get_index(currentspell.character)
	if charpic == -1{charpic = Unidentified}
	draw_sprite_stretched(charpic,0,1536-drawx-picsize,drawy,picsize,picsize)
}

draw_sprite_stretched(asset_get_index(global.psynergylist[indicator].element + "_Star"),0,drawx+16,drawy,32,32)
draw_set_color(c_black)
draw_text(drawx+elementtextoffset+offset,drawy+offset,global.psynergylist[indicator].element + " - " + string(global.psynergylist[indicator].cost) + " PP")
draw_set_color(c_white)
draw_text(drawx+elementtextoffset,drawy,global.psynergylist[indicator].element + " - " + string(global.psynergylist[indicator].cost) + " PP")

drawy += newlineoffset
draw_sprite_stretched(asset_get_index(currentspell.alias),0,drawx,drawy,64,64)
drawx += rangeoffset

draw_sprite_stretched(asset_get_index("range_" + currentspell.range),0,drawx,drawy+8,128,43)
drawx += stageoffset

var stagetext = "Stage " + string(currentspell.stage)
if currentspell.stage > 1{stagetext += " (Evolves from " + currentspell.base + ")"}
draw_set_color(c_black)
draw_text(drawx+offset+stageoffset,drawy+offset+20, stagetext)
draw_set_color(c_white)
draw_text(drawx+stageoffset,drawy+20, stagetext)

drawy+= newlineoffset + 36
draw_set_color(c_black)
draw_text_ext(textx+offset,drawy+offset,currentspell.text,50,1000)
draw_set_color(c_white)
draw_text_ext(textx,drawy,currentspell.text,50,1000)