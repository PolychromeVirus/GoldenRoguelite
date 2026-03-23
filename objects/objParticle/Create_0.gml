// vx, vy, grav, life, col, scl, spr passed via creation struct
max_life = life
history  = []   // recent positions for trail — [{x,y}, ...]
// Optional fields — default if not passed via creation struct
if !variable_instance_exists(id, "soft")   { soft = false }
if !variable_instance_exists(id, "shrink") { shrink = false }
if !variable_instance_exists(id, "trail")  { trail = 20 }
if !variable_instance_exists(id, "die_y")    { die_y = undefined }
if !variable_instance_exists(id, "wiggle")     { wiggle = 0 }
if !variable_instance_exists(id, "wiggle_spd") { wiggle_spd = 0.1 }
if !variable_instance_exists(id, "wiggle_t")   { wiggle_t = random(6.28) }
if !variable_instance_exists(id, "osc_amp")  { osc_amp = 0 }
if !variable_instance_exists(id, "osc_speed") { osc_speed = 0 }
if !variable_instance_exists(id, "osc_phase") { osc_phase = 0 }
if !variable_instance_exists(id, "osc_y")    { osc_y = 0 }
osc_cx = x
osc_cy = y
