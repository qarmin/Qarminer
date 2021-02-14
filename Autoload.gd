extends Node

var function_exceptions = [
# They exists without assigment like Class.method, because they may be a parent of other objects and children also should have disabled child.method, its children also etc. which is too much to do
"align",# GH 45976
"_screen_pick_pressed",# GH 45977
"debug_bake",# GH 45978
"bake", # GH 45978
"_editor_settings_changed",# GH 45979
"_mesh_changed",# GH 45980
"_submenu_timeout", # GH 45981
"set_data", # GH 45995 - probably this will cause a lot of different errors in other classes
"_set_user_data", # GH 45996
"set_config_file", # GH 45997
"_gui_input", # GH 45998
"_unhandled_key_input", # GH 45998
"navpoly_add", #GH 43288
"create_from_mesh", #GH 45999
"_thread_done", #GH 46000
"generate", #GH 46001
"_proximity_group_broadcast", #GH 46002
"_direct_state_changed", #GH 46003
"create_from", #GH 46004
"create_from_blend_shape", #GH 46004
"append_from", #GH 46004
"get_column_width", #GH 46005
"_unhandled_input", # TODO
"_input", # TODO
"lightmap_unwrap", #GH 46007 - memory leak
"", #GH 
"", #GH 
"", #GH 

	
# Looks like a bug in FuncRef, probably but not needed
"call_func",

# Godot Freeze
"discover",
"wait",

# TODO check if really produce spam
#"get",
#"_get",
#"set",
#"_set",

# Too dangerous, because add, mix and remove randomly nodes and objects
"init_ref",
"reference",
"unreference",
"new",
"duplicate",
"queue_free",
"free",
"print_tree",
"print_stray_nodes",
"print_tree_pretty",
"remove_and_skip",
"remove_child",
"move_child",
"raise",
"add_child",
"add_child_below_node",
]

# Return all available classes to instance and test
func get_list_of_available_classes() -> Array:
	var debug_print : bool = false
	var full_class_list : Array = Array(ClassDB.get_class_list())
	var classes : Array = []
	full_class_list.sort()
	var c = 0
	for name_of_class in full_class_list:
		if name_of_class == "AudioServer": # Crash GH #45972
			continue
		if name_of_class == "NetworkedMultiplayerENet": # TODO - create leaked reference instance, look at it later
			continue
		
		
		if ClassDB.is_parent_class(name_of_class,"Node") or ClassDB.is_parent_class(name_of_class,"Reference"): # Only instance childrens of this 
			if debug_print:
				print(name_of_class)
			if ClassDB.can_instance(name_of_class):
				classes.push_back(name_of_class)
				c+= 1
				var q = ClassDB.instance(name_of_class)
				if q is Node:
					q.queue_free()
		else:
			if debug_print:
				push_error("Failed to instance " + str(name_of_class) )

	print(str(c) + " choosen classes from all " + str(full_class_list.size()) + " classes.")
	return classes
