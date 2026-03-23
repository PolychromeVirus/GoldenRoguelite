if !global.pause{
	var target = {};
	var _var_names = variable_struct_get_names(id);

	for (var i = 0; i < array_length(_var_names); i++)
	{
		var _name = _var_names[i];
		var _value = variable_instance_get(id, _name);

		variable_struct_set(target, _name, _value);
	}
	PushMenu(objMonsterStat, target)
}