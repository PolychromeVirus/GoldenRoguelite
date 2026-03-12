// Expects: amount (number), world_x, world_y, col (color, optional), gui_mode (bool, optional), icon (sprite, optional)
if !variable_instance_exists(self, "col") { col = c_white }
if !variable_instance_exists(self, "gui_mode") { gui_mode = false }
if !variable_instance_exists(self, "icon") { icon = -1 }
alpha = 1
rise = 0
