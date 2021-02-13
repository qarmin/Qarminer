extends Node2D



	
#func _ready() -> void:
#	#print(get_list_of_available_classes())
#	var name_of_class : String = "StaticBody"
#	var object : Object = ClassDB.instance(name_of_class)
#
#	for method_data in ClassDB.class_get_method_list(name_of_class, true):
#
#		print(method_data)
#		print(method_data["name"])
##		object.call(method_data["name"], Vector3())
#		print(method_data["args"])
#		if method_data["args"].size() == 0:
#			object.call(method_data["name"])
##	print()
#	pass

func _ready() -> void:
	tests_0_arguments()

# Test all functions which takes 0 arguments
func tests_0_arguments() -> void:
	var debug_print : bool = false
	
#	PopupMenu.new()._submenu_timeout()
#	return
	
	var function_exception = [
	"align",# GH 45978
	"_screen_pick_pressed",# GH 45978
	"debug_bake",# GH 45978
	"_editor_settings_changed",# GH 45978
	"_mesh_changed",# GH 45978
	"_submenu_timeout", # GH 45978
		
	"call_func",
	"wait",
	
	# 
	"get",
	"_get",
	"set",
	"_set",
	
	# Too dangerous, because add, mix and remove randomly nodes and objects
	"init_ref",
	"reference",
	"unreference",
	"new", # Don't want to create new nodes
	"duplicate", # Just no
	"queue_free", # Don't delete now
	"free", # Don't delete too early
	"print_tree", # Too big spam
	"print_stray_nodes",
	"print_tree_pretty",
	"remove_and_skip",
	"remove_child",
	"move_child",
	"raise",
	"add_child",
	"add_child_below_node",
	]
	
	for name_of_class in get_list_of_available_classes():
		var object : Object = ClassDB.instance(name_of_class)
		if object == null:
			push_warning("Pierd " + name_of_class)
		for i in range(20): # Execute multiple times this
			for method_data in ClassDB.class_get_method_list(name_of_class, true):
				
				# Function is virtual, so we just skip it
				if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
					continue 
				
				# For now there are some bugs which needs to be fixed
				var found : bool = false
				for exception in function_exception:
					if method_data["name"] == exception:
						found = true
						break
				if found:
					continue
				
				if debug_print:
					print("##### - " + name_of_class)
#					print(method_data)
					print(method_data["name"])
#					print(method_data["args"])
					
				if method_data["args"].size() == 0:
					object.call(method_data["name"])
		if object is Node:
			object.queue_free()



# Return all available classes to instance and test
func get_list_of_available_classes() -> Array:
	var debug_print : bool = false
	var full_class_list : Array = Array(ClassDB.get_class_list())
	var classes : Array = []
	full_class_list.sort()
	for i in full_class_list:
		print(i)
	var c = 0
	for name_of_class in full_class_list:
		if name_of_class == "AudioServer": # Crash GH #45972
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
