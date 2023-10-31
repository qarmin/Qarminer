extends Node
func _process(delta):

	var temp_variable2349 = CodeEdit.new()
	add_child(temp_variable2349)
	temp_variable2349.add_code_completion_option(15, "127.0.0.1", "", Color(25.7821083068848, -14.8434524536133, 67.1832809448242, 1), Material.new(), Array([Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([]), Array([])]))
	temp_variable2349.get_node_or_null(NodePath("127.0.0.1"))
	temp_variable2349.set_text("127.0.0.1")
	temp_variable2349.adjust_carets_after_edit(26, -58, 70, -64, -77)
	temp_variable2349.update_code_completion_options(false)
	temp_variable2349.confirm_code_completion(true)

