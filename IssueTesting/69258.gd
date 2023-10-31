extends Node
func _process(delta):

	var temp_variable4692 = CSGMesh3D.new()
	add_child(temp_variable4692)
	temp_variable4692.set_extra_cull_margin(99.3937611579895)
	temp_variable4692.queue_free()

	var temp_variable4915 = PackedScene.new()
	var temp_argument4915_f1_0 = MultiMeshInstance3D.new()
	temp_variable4915.pack(temp_argument4915_f1_0)
	temp_argument4915_f1_0.queue_free()
