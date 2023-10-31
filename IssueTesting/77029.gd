extends Node
func _process(delta):

	var temp_variable125 = AcceptDialog.new()
	add_child(temp_variable125)
	temp_variable125.call_deferred_thread_group(StringName(""))
	temp_variable125.queue_free()
