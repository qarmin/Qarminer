extends Node
func _process(delta):
	var temp_variable3 = GPUParticles3D.new()
	temp_variable3.set_process_material(FogMaterial.new())
	temp_variable3.queue_free()


