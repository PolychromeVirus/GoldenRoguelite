// Clean up any remaining controllers (safety net)
for (var _i = 0; _i < array_length(_controllers); _i++) {
    if instance_exists(_controllers[_i]) {
        instance_destroy(_controllers[_i])
    }
}
