extends Node
func _process(delta):
	for i in get_children():
		i.queue_free()
	var temp_variable29522 = CodeHighlighter.new()
	temp_variable29522.clear_member_keyword_colors()
	var temp_variable29574 = GLTFBufferView.new()
	var temp_variable29766 = PopupMenu.new()
	add_child(temp_variable29766)
	temp_variable29766.get_item_icon_max_width(-63)
	temp_variable29766.get_item_shortcut(11)
	temp_variable29766.set_item_count(49)
	temp_variable29766.set_item_submenu(11, ".")
	temp_variable29766.activate_item_by_event(InputEventAction.new(), false)