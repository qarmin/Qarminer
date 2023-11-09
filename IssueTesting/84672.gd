extends Node
func _process(delta):
	for i in get_children():
		i.queue_free()
	var temp_variable8107 = CanvasItemMaterial.new()
	temp_variable8107.set_particles_anim_h_frames(-22)
	var temp_variable8274 = MultiMesh.new()
	temp_variable8274.set_mesh(PlaceholderMesh.new())
	temp_variable8274.get_instance_custom_data(-72)
	temp_variable8274.set_use_colors(true)
	temp_variable8274.set_instance_count(0)
	temp_variable8274.get_instance_transform(13)
	temp_variable8274.set_buffer(PackedFloat32Array([]))