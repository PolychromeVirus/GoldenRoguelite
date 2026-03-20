function draw_rich_text(tx, ty, text, max_width, offset = 4, f = GoldenSun, line_sep = string_height("GoldenSun")+6,max_height = -1){
	var tokens = string_parse(text)
	var _tx = tx
	var _ty = ty
	
	var _max = 3000
	
	if max_height != -1{_max = _ty + (line_sep * max_height)}
	
	draw_set_font(f)
	for (var i=0; i<array_length(tokens); i++){		
		
		if i != array_length(tokens)-1 and  _tx + string_width(tokens[i+1] + " ") > tx + max_width{
			if _ty + line_sep > _max{ tokens[i] = "..." }
		}
		
		if tokens[i] == "\n"{
		
			_tx = tx
			_ty += line_sep
			continue
		
		}
		if tokens[i] == "\t"{
		
			_tx += string_width("    ")
			continue
		
		}
		
		var _col = _GetKeyword(tokens[i])
		
		if i != array_length(tokens)-1 and _col == undefined{ _col = _GetKeyword( tokens[i] + " " + tokens[i+1] ) }
		
		if i != 0 and _col == undefined{ _col = _GetKeyword( tokens[i-1] + " " + tokens[i] ) }
		
		if _col == undefined{_col = c_white}
		var ttext = ["",tokens[i],""]
		var _lead = string_char_at(tokens[i],1)
		var _trail = string_char_at(tokens[i],string_length(tokens[i]))
		
		if !isAlnum(_lead){ttext[0] = _lead; ttext[1] = string_delete(ttext[1],1,1)}
		if !isAlnum(_trail){ttext[2] = _trail; ttext[1] = string_delete(ttext[1],string_length(ttext[1]),1)}
		
		if ttext[0] != ""{
			draw_text_colour(_tx+offset,_ty+offset,ttext[0],c_black,c_black,c_black,c_black,1)
			draw_text_colour(_tx,_ty,ttext[0],c_white,c_white,c_white,c_white,1)
			_tx += string_width(ttext[0])
		}
		
		draw_text_colour(_tx+offset,_ty+offset,ttext[1],c_black,c_black,c_black,c_black,1)
		draw_text_colour(_tx,_ty,ttext[1],_col,_col,_col,_col,1)
		_tx += string_width(ttext[1])
		
		if ttext[2] != ""{
			draw_text_colour(_tx+offset,_ty+offset,ttext[2],c_black,c_black,c_black,c_black,1)
			draw_text_colour(_tx,_ty,ttext[2],c_white,c_white,c_white,c_white,1)
			_tx += string_width(ttext[2])
		}
		
		if ttext[1] == "..."{return}
		
		_tx += string_width(" ")
		
		if i != array_length(tokens)-1 and  _tx + string_width(tokens[i+1]) > tx + max_width{
			_tx = tx;
			_ty += line_sep
			}
	}
	
	
	
}

function _GetKeyword(text){

	text = string_replace_all(text,":","")
	text = string_replace_all(text,".","")
	text = string_replace_all(text,",","")
	text = string_replace_all(text,";","")
	text = string_replace_all(text,"(","")
	text = string_replace_all(text,")","")
	text = string_replace_all(text,"[","")
	text = string_replace_all(text,"]","")

	switch string_lower(text){

		case "venus damage": case "venus charge": case "venus power": case "venus values":
		case "highest venus": case "lowest venus": case "venus value": case "assign venus":
		case "venus dice": case "venus die": case "venus":
			return global.c_venus
		case "mars": case "mars damage": case "mars charge": case "mars power": case "mars values":
		case "highest mars": case "lowest mars": case "mars value": case "assign mars":
		case "mars dice": case "mars die":
			return global.c_mars
		case "jupiter": case "jupiter damage": case "jupiter charge": case "jupiter power": case "jupiter values":
		case "highest jupiter": case "lowest jupiter": case "jupiter value": case "assign jupiter":
		case "jupiter dice": case "jupiter die":
			return global.c_jupiter
		case "mercury": case "mercury damage": case "mercury charge": case "mercury power": case "mercury values":
		case "highest mercury": case "lowest mercury": case "mercury value": case "assign mercury":
		case "mercury dice": case "mercury die":
			return global.c_mercury
		case "melee": case "melee damage": case "melee charge": case "melee power": case "melee values":
		case "highest melee": case "lowest melee": case "melee value": case "assign melee":
		case "melee dice": case "melee die":
			return global.c_melee
		case "elemental": case "elemental damage": case "elemental charge": case "elemental power": case "elemental values":
		case "highest elemental": case "lowest elemental": case "elemental value": case "assign elemental":
		case "elemental dice": case "elemental die":
			return global.c_elemental
		case "poison": case "venom": case "stun": case "sleep": case "delude": case "haunt":
		case "psy seal":
			return global.c_status
	

	}

return undefined
}

function isAlnum(text){

	switch text{

		case ":": case ";": case ".": case ",": case "(": case ")": case "!": case "?": case "/":
		case "[": case "]":
			return false
		default:
			return true
	}

}

function string_parse(text){
	var _buff = ""
	var _tok = []

	for (var i = 1; i < string_length(text)+1; ++i) {
		var _curr = string_char_at(text,i)
	    if _curr != " " and _curr != "\n" and _curr != "\t"{_buff += _curr;continue}
		if _curr == " "{array_push(_tok,_buff);_buff = ""}
		if _curr == "\n"{array_push(_tok,_buff);array_push(_tok,"\n");_buff = ""}
		if _curr == "\t"{array_push(_tok,_buff);array_push(_tok,"\t");_buff = ""}
		
	}
	array_push(_tok,_buff)

return _tok



}