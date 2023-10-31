extends Node
func _process(delta):

	var temp_variable382 = CodeEdit.new()
	add_child(temp_variable382)
	temp_variable382.set_highlight_matching_braces_enabled(true)
	temp_variable382.begin_complex_operation()
	temp_variable382.do_indent()
	temp_variable382.do_indent()
	temp_variable382.unindent_lines()
	temp_variable382.undo()
	temp_variable382.queue_free()
