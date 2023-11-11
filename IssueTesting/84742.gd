extends Node
func _process(delta):
	var temp_variable385 = CodeEdit.new()
	add_child(temp_variable385)
	temp_variable385.set_fit_content_height_enabled(true)
	temp_variable385.duplicate_lines()
	temp_variable385.set_scroll_past_end_of_file_enabled(true)
	temp_variable385.duplicate_lines()
	temp_variable385.queue_free()