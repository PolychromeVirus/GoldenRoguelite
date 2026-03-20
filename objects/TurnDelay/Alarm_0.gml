var _cb = on_complete
on_complete = undefined   // prevent Destroy_0 from firing it again
if !is_undefined(_cb) { _cb() }
instance_destroy()
