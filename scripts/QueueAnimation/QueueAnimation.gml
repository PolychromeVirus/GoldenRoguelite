function QueueAnim(type, element, target, opts) {
    var _step      = variable_clone(opts ?? {})
    _step.type     = type
    _step.element  = element
    _step.target   = target
    array_push(global.animQueue, _step)
}

