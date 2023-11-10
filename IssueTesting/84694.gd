extends Node
func _process(delta):
	var temp_variable15100 = TabContainer.new()
	add_child(temp_variable15100)
	temp_variable15100.get_signal_connection_list(StringName(""))
	temp_variable15100.queue_free()
	var temp_variable15102 = TabContainer.new()
	add_child(temp_variable15102)
	temp_variable15102.get_method_list()
	temp_variable15102.set_tabs_visible(false)
	temp_variable15102.notify_deferred_thread_group(1)
	temp_variable15102.queue_free()