var unleashdam = 0
var splash = 0
var selfheal = 0
var selfpp = 0

var splashcol = c_white
var color = c_white

var drawx = 32
var drawy = 250
var offset = 4

	
if variable_struct_exists(unleash, "dam_bonus"){unleashdam = unleash.dam_bonus}
if variable_struct_exists(unleash, "splash_ratio"){ splash =  unleashdam * unleash.splash_ratio}
if variable_struct_exists(unleash, "splash_element"){ splashcol = variable_global_get( "c_" + string_lower(unleash.splash_element) ) }
if variable_struct_exists(unleash, "heal_hp_ratio"){ selfheal = unleashdam * unleash.heal_hp_ratio }
if variable_struct_exists(unleash, "heal_hp_flat"){ selfheal = unleash.heal_hp_flat }
if variable_struct_exists(unleash, "heal_pp_ratio"){ selfpp = unleashdam * unleash.heal_pp_ratio }
if variable_struct_exists(unleash, "heal_pp_flat"){ selfpp = unleash.heal_pp_flat }
if variable_struct_exists(unleash, "convert_element"){ if unleash.convert_element != ""{ splashcol = variable_global_get("c_" + string_lower(unleash.convert_element)) } }


var divis = ""

var poison = false
var venom = false
var stun = false
var sleep = false
var delude = false
var psyseal = false
var bre = false
var defd = false
var atkd = false
var statcontent = []
var mark = false
if variable_instance_exists(statuses, "inflict_poison") { poison = true; array_push(statcontent, "Poison") }
if variable_instance_exists(statuses, "inflict_venom") { venom = true; array_push(statcontent, "Venom") }
if variable_instance_exists(statuses, "inflict_stun") { stun = 3; array_push(statcontent, "Stun") }
if variable_instance_exists(statuses, "inflict_sleep") { sleep = true; array_push(statcontent, "Sleep") }
if variable_instance_exists(statuses, "inflict_delude") { delude = true; array_push(statcontent, "Delude") }
if variable_instance_exists(statuses, "inflict_psyseal") { psyseal = true; array_push(statcontent, "Psyseal") }
if variable_instance_exists(statuses, "inflict_defdown") { defd = true; array_push(statcontent, "Drop Defense") }
if variable_instance_exists(statuses, "inflict_atkdown") { atkd = true; array_push(statcontent, "Drop Attack") }
if variable_instance_exists(statuses, "inflict_clearstats") { bre = true; array_push(statcontent, "Clear Stat Buffs") }
if variable_instance_exists(statuses, "inflict_mark") { mark = true; array_push(statcontent, "Mark") }

draw_set_font(GoldenSun)

draw_set_colour(c_black)
draw_text(drawx + offset, drawy + offset, "Assign:" )
draw_set_colour(c_white)
draw_text(drawx, drawy, "Assign:" )
drawx += string_width("Assign: ")

if string_lower(dmgtype) == "venus"{ color = global.c_venus }
if string_lower(dmgtype) == "mars"{ color = global.c_mars }
if string_lower(dmgtype) == "jupiter"{ color = global.c_jupiter }
if string_lower(dmgtype) == "mercury"{ color = global.c_mercury }

if dam{
	draw_set_colour(c_black)
	draw_text(drawx + offset, drawy + offset, string(dam) + " Damage")
	draw_set_colour(color)
	draw_text(drawx, drawy, string(dam) + " Damage")
	drawx += string_width(string(dam) + " Damage")
	divis = " + "
}

if unleashdam{
	draw_set_colour(c_black)
	draw_text(drawx + offset, drawy + offset,  divis + string(unleashdam) + " [ Unleash ]"  + divis)
	draw_set_colour(splashcol)
	draw_text(drawx, drawy, divis + string(unleashdam) + " [ Unleash ]" + divis)
	drawx += string_width(string(unleashdam) + " [ Unleash ] + ")
	divis = " + "
}
splashcol = color
if array_length(statcontent) > 1{
	draw_set_colour(c_black)
	draw_text(drawx + offset, drawy + offset, divis + string_join(statcontent, ", "))
	draw_set_colour(splashcol)
	draw_text(drawx, drawy,  divis + string_join(statcontent, ", "))
	drawx += string_width(string_join(statcontent, ", "))
	divis = " + "
}else if array_length(statcontent) == 1{
	draw_set_colour(c_black)
	draw_text(drawx + offset, drawy + offset, divis + statcontent[0])
	draw_set_colour(splashcol)
	draw_text(drawx, drawy,  divis + statcontent[0])
}

draw_set_font(GoldenSun)

