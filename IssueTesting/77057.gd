extends Node
func _process(delta):
	var temp_variable383 = Skeleton3D.new()
	add_child(temp_variable383)
	temp_variable383.clear_bones_global_pose_override()
	temp_variable383.queue_free()

	var temp_variable466 = VSplitContainer.new()
	add_child(temp_variable466)
	temp_variable466.queue_free()
