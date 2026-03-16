if !global.pause{
	DeleteButtons()
	DestroyAllBut(objMonsterStat)
	var target = {};
	var _var_names = variable_struct_get_names(id); // Get names from the instance's internal struct

	for (var i = 0; i < array_length(_var_names); i++)
	{
		var _name = _var_names[i];
		var _value = variable_instance_get(id, _name); // Get the value

		variable_struct_set(target, _name, _value); // Set in the new struct
	}
	instance_create_depth(0,0,0,objMonsterStat, target)
}