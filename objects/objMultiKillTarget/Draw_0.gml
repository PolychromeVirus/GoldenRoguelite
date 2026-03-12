if array_length(monsters) == 0 { exit }
var mon = monsters[selected]
var _top = mon.y - sprite_get_height(mon.sprite_index)
draw_sprite(Down_Arrow, 0, mon.x, _top)
