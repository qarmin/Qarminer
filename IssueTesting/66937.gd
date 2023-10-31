extends Node
func _process(delta: float):
	print(delta)
	var temp_variable115684 = TextEdit.new()
	add_child(temp_variable115684)
	temp_variable115684.set_line_wrapping_mode(49)
	temp_variable115684.set_text("127.0.0.1")
	temp_variable115684.copy()
	temp_variable115684.set_fit_content_height_enabled(true)
	temp_variable115684.paste()
	temp_variable115684.set_scroll_past_end_of_file_enabled(true)
	temp_variable115684.queue_free()

