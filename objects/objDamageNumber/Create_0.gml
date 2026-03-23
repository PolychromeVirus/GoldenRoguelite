// Expects: amount (number), world_x, world_y, col (color, optional), gui_mode (bool, optional), icon (sprite, optional), text (string, optional)
if !variable_instance_exists(self, "col") { col = c_white }
if !variable_instance_exists(self, "gui_mode") { gui_mode = false }
if !variable_instance_exists(self, "icon") { icon = -1 }
if !variable_instance_exists(self, "text") { text = "" }
if !variable_instance_exists(self, "life") { life = 60 }
if !variable_instance_exists(self, "no_rise") { no_rise = false }
alpha = 1
rise = 0
