extends Node
func _process(delta):
	var temp_variable18110 = CSGCylinder3D.new()
	add_child(temp_variable18110)
	temp_variable18110.queue_free()
	var temp_variable18237 = Image.new()
	temp_variable18237.copy_from(null)
	temp_variable18237._set_data({})
	temp_variable18237.is_empty()
	temp_variable18237.crop(17, 65)
	temp_variable18237.compress_from_channels(1, 91, -89)
	temp_variable18237.get_height()
	temp_variable18237.save_jpg_to_buffer(36.2883925437927)