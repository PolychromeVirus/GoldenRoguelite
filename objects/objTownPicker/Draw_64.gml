draw_set_font(GoldenSun)
var drawx = 700
var drawy = 308
var vertpad = 54
var offset = 4

draw_set_color(c_black)
draw_text(48 + offset, 48 + offset, "Choose a Town")
draw_set_color(c_white)
draw_text(48, 48, "Choose a Town")
draw_set_halign(fa_right)
for (var i = 0; i < array_length(town_indices); i++) {
	var _town = global.townlist[town_indices[i]]
	var _y = drawy + (i - selected) * vertpad

	if (abs(i - selected) > 5) { continue }

	var _visited = array_contains(global.townVisited, _town.name)
	var _col = _visited ? c_grey : ((i == selected) ? global.c_important : c_white)

	draw_set_color(c_black)
	draw_text(drawx + offset, _y + offset, _town.name)
	draw_set_color(_col)
	draw_text(drawx, _y, _town.name)

	if (_visited) {
		draw_set_color(c_black)
		draw_text(drawx - string_width("(visited) ") + offset, _y + offset, "(visited)")
		draw_set_color(c_grey)
		draw_text(drawx - string_width("(visited) "), _y, "(visited)")
	}
}
draw_set_halign(fa_left)
var _curr = global.townlist[town_indices[selected]]
var _curr_visited = array_contains(global.townVisited, _curr.name)

var descx = 820
var descy = 48
var _text = string_ucfirst(_curr.name) + "\n\n"

if (_curr_visited) {
	_text = "NOT AVAILABLE"
} else {
	if _curr.finds[0] != ""{_text += "- "+ string_ucfirst(_curr.finds[0]) + "\n"}
	if array_length(_curr.finds) > 1{_text += "- "+string_ucfirst(_curr.finds[1]) + "\n"}
	if _text != ""{_text += "\n\nFor Sale:\n"}
	if _curr.wpn_price > 0{_text += "- Weapons " + string(_curr.wpn_price) + "g\n"}
	if _curr.arm_price > 0{_text += "- Armor " + string(_curr.arm_price) + "g\n"}
	if _curr.itm_price > 0{_text += "- Items " + string(_curr.itm_price) + "g\n"}
	if _curr.art_price > 0{_text += "- Artifacts " + string(_curr.art_price) + "g\n"}
	if _curr.psy_price > 0{_text += "- Psynergy " + string(_curr.psy_price) + "g\n"}
	if _curr.sum_price > 0{_text += "- Summons " + string(_curr.sum_price) + "g\n"}

	_text += "\n\n" + _curr.quote
}

draw_set_color(c_black)
draw_text_ext(descx+offset,descy+offset,_text, 40, 660)
draw_set_color(c_white)
draw_text_ext(descx,descy,_text, 40, 660)
