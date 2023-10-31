extends Node
func _process(delta):
	var temp_variable998 = ParallaxBackground.new()
	add_child(temp_variable998)
	var temp_argument998_f903_0 = FileDialog.new()
	temp_variable998.set_custom_viewport(temp_argument998_f903_0)
	temp_argument998_f903_0.queue_free()
	temp_variable998.queue_free()
