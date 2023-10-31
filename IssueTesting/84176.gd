extends Node
func _process(delta):
	var temp_variable11695 = PopupMenu.new()
	add_child(temp_variable11695)
	temp_variable11695.add_submenu_item("", ".", -18)
	temp_variable11695.activate_item_by_event(InputEventJoypadMotion.new(), false)
