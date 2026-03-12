var drawx = 50
var drawy = 300
var offset = 4
var vertpad = 54
draw_set_font(GoldenSun)

var _town = global.townlist[global.currentTown]

// Title + gold
draw_set_color(c_black)
draw_text(drawx + offset, 44, _town.name + " Shop")
draw_set_color(c_white)
draw_text(drawx, 40, _town.name + " Shop")

draw_set_color(c_black)
draw_text(drawx + 400 + offset, 44, "Gold: " + string(global.gold))
draw_set_color(c_yellow)
draw_text(drawx + 400, 40, "Gold: " + string(global.gold))

if (array_length(shoplist) == 0) {
	draw_set_color(c_grey)
	draw_text(drawx + 72, drawy, "Nothing for sale.")
	exit
}

for (var i = 0; i < array_length(shoplist); i++) {
	var draw = true
	var _entry = shoplist[i]

	if (i - selected > 6) { draw = false }
	if (selected - i > 4) { draw = false }
	if (!draw) { continue }

	var _y = drawy + (i - selected) * vertpad
	var _affordable = (global.gold >= _entry.price)
	var _col = _affordable ? c_white : c_grey

	// Category color
	var _catcol = c_white
	switch (_entry.category) {
		case "Weapon": _catcol = global.c_weapons; break
		case "Armor": _catcol = global.c_armor; break
		case "Psynergy":
			var _el = global.psynergylist[_entry.id].element
			switch (_el) {
				case "Venus": _catcol = global.c_psynergy; break
				case "Mars": _catcol = global.c_psynergy; break
				case "Jupiter": _catcol = global.c_psynergy; break
				case "Mercury": _catcol = global.c_psynergy; break
			}
			break
		case "Summon": _catcol = global.c_summon; break
	}

	// Icon
	if (_entry.category == "Psynergy") {
		var _alias = global.psynergylist[_entry.id].alias
		if (asset_get_index(_alias) != -1) {
			draw_sprite_stretched(asset_get_index(_alias), 0, drawx, _y, 48, 48)
		}
	} else if (_entry.category == "Summon") {
		var _alias = global.summonlist[_entry.id].alias
		if (asset_get_index(_alias) != -1) {
			draw_sprite_stretched(asset_get_index(_alias), 0, drawx, _y, 48, 48)
		}
	} else {
		var _alias = global.itemcardlist[_entry.id].alias
		if (asset_get_index(_alias) != -1) {
			draw_sprite_stretched(asset_get_index(_alias), 0, drawx, _y, 48, 48)
		}
	}

	// Name
	_col = _affordable ? _catcol : c_grey
	draw_set_color(c_black)
	draw_text(drawx + 72 + offset, _y + offset + 8, _entry.name)
	draw_set_color(_col)
	draw_text(drawx + 72, _y + 8, _entry.name)

	// Price
	var _pricetext = string(_entry.price) + "g"
	var _pricecol = _affordable ? c_yellow : c_grey
	draw_set_color(c_black)
	draw_text(drawx + 420 + offset, _y + offset + 8, _pricetext)
	draw_set_color(_pricecol)
	draw_text(drawx + 420, _y + 8, _pricetext)

	// Count (right of price)
	if (_entry.count > 1) {
		var _countx = drawx + 420 + string_width(_pricetext) + 12
		var _counttext = "x" + string(_entry.count)
		draw_set_color(c_black)
		draw_text(_countx + offset, _y + offset + 8, _counttext)
		draw_set_color(c_white)
		draw_text(_countx, _y + 8, _counttext)
	}
}

// Description panel for selected item
if (selected >= 0 && selected < array_length(shoplist)) {
	var descx = 820
	var descy = 64
	var _sel = shoplist[selected]
	var _desctext = ""

	if (_sel.category == "Psynergy") {
		var _sp = global.psynergylist[_sel.id]
		_desctext = _sp.text
	} else if (_sel.category == "Summon") {
		_desctext = global.summonlist[_sel.id].name + " Summon"
	} else {
		_desctext = global.itemcardlist[_sel.id].text
	}
	var _slotinfo = ""
	
	switch _sel.category{
		case "Weapon":
		case "Item":
			_slotinfo = global.itemcardlist[_sel.id].type
			break
		case "Armor":
			_slotinfo = global.itemcardlist[_sel.id].slot
			break
		case "Psynergy":
			_slotinfo = "Psynergy"
			break
		case "Summon":
			_slotinfo = "Summon"
			break
	
	
	}
	
	
	
	draw_set_color(c_black)
	draw_text_ext(descx + offset, descy + offset, "[" + _slotinfo + "]", 40, 660)
	draw_set_color(c_white)
	draw_text_ext(descx, descy,  "[" + _slotinfo + "]", 40, 660)
	
	descy += string_height(_slotinfo) + 16
	

	//if (string_length(_desctext) > 170) {
	//	_desctext = string_delete(_desctext, 170, string_length(_desctext) - 169) + "..."
	//}

	draw_set_color(c_black)
	draw_text_ext(descx + offset, descy + offset, _desctext, 40, 660)
	draw_set_color(c_white)
	draw_text_ext(descx, descy, _desctext, 40, 660)
}
