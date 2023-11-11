extends Node
func _process(delta):
	for i in get_children():
		i.queue_free()
	var temp_variable8899 = Image.new()
	temp_variable8899.crop(79, 42)
	temp_variable8899.convert(10)
	temp_variable8899.generate_mipmaps(false)
	temp_variable8899.convert(-19)