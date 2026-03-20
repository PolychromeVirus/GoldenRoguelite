var pad = 8

var drawx = x+32 / 2
var drawy = y+32 + pad
var name = global.players[selector.selector].name
var namestart = max(x, (x+32 / 2) - (string_width(name) / 2))

draw_set_font(GoldenSunItalic)

draw_text(namestart,drawy,name)

if keyboard_hover {
    draw_set_color(c_yellow)
    draw_rectangle(x - 1, y - 1, x + 33, y + 33, true)
    draw_set_color(c_white)
}
draw_sprite_stretched(global.players[selector.selector].portrait,0,x,y,32,32)
var starsprite = asset_get_index(global.players[selector.selector].element + "_Star")
draw_sprite_stretched(starsprite,0,drawx-4 ,y-16,8,8)