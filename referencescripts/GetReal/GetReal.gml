// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function GetReal(cell){
	if cell == "" or cell == "dam"{
		return real(0)
	}else if cell == "TRUE"{
		return true
	}else{
		return real(cell)
	}
}