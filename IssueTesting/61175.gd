extends Node
func _process(delta: float):
	var temp_variable118 = GPUParticles2D.new()
	add_child(temp_variable118)
	temp_variable118.set_process_material(PanoramaSkyMaterial.new())
	temp_variable118.queue_free()
