clickable = false
alarm_set(0,30)

breath_t   = 0
btn_scale  = 1.0
is_pressed = false

if !variable_instance_exists(id,"on_cancel"){
	
on_cancel = function(){}

}