extends Node
func _process(delta):
	for i in get_children():
		i.queue_free()
	var temp_variable4230 = Image.new()
	temp_variable4230.crop(70, 75)
	temp_variable4230.compress_from_channels(1, -60, -88)
	temp_variable4230.save_webp_to_buffer(false, -2.51768231391907)