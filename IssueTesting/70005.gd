extends Node
func _process(delta):
	var temp_variable14923 = TabContainer.new()
	add_child(temp_variable14923)
	temp_variable14923.set_drag_to_rearrange_enabled(true)
	temp_variable14923._get_drag_data_fw(Vector2(-NAN, -NAN), null)
	temp_variable14923.queue_free()

