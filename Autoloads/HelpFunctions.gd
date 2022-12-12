extends Node


func add_excluded_too_big_functions(add_it: bool) -> void:
	if add_it:
		BasicData.function_exceptions.append_array(BasicData.too_big_arguments)


func add_excluded_too_big_classes(add_it: bool) -> void:
	if add_it:
		BasicData.disabled_classes.append_array(BasicData.too_big_classes)


func find_things_from_first_array_not_in_second(arr1: Array, arr2: Array) -> Array:
	var new_arr: Array = []
	for i in arr1:
		if !(i in arr2):
			new_arr.append(i)
	return new_arr


# TODOGODOT4 - this probably will hide internal childs in Godot 4
# Disable nodes with internal child, because can cause strange crashes when executing e.g. notification
func disable_nodes_with_internal_child() -> void:
	var f = Array(ClassDB.get_class_list())
	f.sort()
	var list = []
	for i in f:
		if ClassDB.can_instantiate(i) && ClassDB.is_parent_class(i, "Node"):
			var rr = ClassDB.instantiate(i)
			if rr.get_child_count() > 0:
				list.append(i)
			remove_thing(rr)
	BasicData.disabled_classes.append_array(list)


# Checks if function can be executed
# Looks at its arguments and method type
# This is useful when e.g. adding/renaming type Transform3D -> Transform3D
func check_if_is_allowed(method_data: Dictionary, disabled_classes_dict: Dictionary, csharp_project: bool = false) -> bool:
	# Function is virtual or vararg, so we just skip it
	if method_data["flags"] & METHOD_FLAG_VIRTUAL != 0:
		return false
	if method_data["flags"] & 128 != 0:  # VARARG TODO, Godot issue, add missing flag binding
		return false

	for arg in method_data["args"]:
		var name_of_class: String = arg["class_name"]

		if csharp_project:
			# If checking C# project, disable checking for enums, because they needs to be
			# converted, but later there is no info that this is enum
			if !ClassDB.class_exists(name_of_class):
				return false

		if name_of_class in disabled_classes_dict:
			return false
		if name_of_class.find("Server") != -1 && ClassDB.class_exists(name_of_class) && !ClassDB.is_parent_class(name_of_class, "RefCounted"):
			return false
		# Editor stuff usually aren't good choice for arguments
		if name_of_class.find("Editor") != -1 || name_of_class.find("SkinReference") != -1:
			return false

		# TODO is this enum?
#		if name_of_class.empty():
#			continue

	return true


# Return GDScript code which create this object
func get_gdscript_class_creation(name_of_class: String) -> String:
	if (
		ClassDB.is_parent_class(name_of_class, "Object")
		&& !ClassDB.is_parent_class(name_of_class, "Node")
		&& !ClassDB.is_parent_class(name_of_class, "RefCounted")
		&& !ClassDB.class_has_method(name_of_class, "new")
	):
		return 'ClassDB.instantiate("' + name_of_class + '")'
	else:
		return name_of_class.trim_prefix("_") + ".new()"


func remove_disabled_methods(method_list: Array, exceptions: Dictionary, csharp_project: bool = false) -> Array:
	var new_method_list: Array = []

	for method in method_list:
		if !(method["name"] in exceptions):
			new_method_list.append(method)

	return new_method_list


# Removes specific object/node
func remove_thing(thing: Object) -> void:
	if thing is Node:
		thing.queue_free()
	elif thing is Object && !(thing is RefCounted):
		thing.free()


func remove_thing_string(thing: Object) -> String:
	if thing is Node:
		return ".queue_free()"
	elif thing is Object && !(thing is RefCounted):
		return ".free()"
	else:
		return ""


# Initialize array which contains only allowed functions
# If BasicData.allowed_functions is not set, every possible functions is checked
func initialize_array_with_allowed_functions(use_parent_methods: bool, disabled_methods: Array, csharp_project: bool = false):
	assert(!BasicData.base_classes.is_empty())  #, "Missing initalization of classes")
	assert(!BasicData.argument_classes.is_empty())  #, "Missing initalization of classes")
	var class_info: Dictionary = {}
	var disabled_methods_names: Dictionary = {}
	for method_name in disabled_methods:
		disabled_methods_names[method_name] = false

	var disabled_classes_names: Dictionary = {}
	for method_name in BasicData.disabled_classes:
		disabled_classes_names[method_name] = false

	#var i = 0
	#print(Time.get_datetime_dict_from_system())

	if BasicData.allowed_functions.is_empty():
		for name_of_class in BasicData.base_classes:
			#i += 1
			#if i % 50 == 0:
			#	print(str(i) + "/" + str(BasicData.base_classes.size()))
			var old_method_list: Array = []
			var new_method_list: Array = []
			old_method_list = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)
			old_method_list = remove_disabled_methods(old_method_list, disabled_methods_names, csharp_project)
			for method_data in old_method_list:
				if !check_if_is_allowed(method_data, disabled_classes_names, csharp_project):
					continue
				new_method_list.append(method_data)

			class_info[name_of_class] = new_method_list
	else:
		for name_of_class in BasicData.base_classes:
			var old_method_list: Array = []
			var new_method_list: Array = []
			old_method_list = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)
			for method_data in old_method_list:
				if !(method_data["name"] in BasicData.allowed_functions):
					continue
				if !check_if_is_allowed(method_data, disabled_classes_names, csharp_project):
					continue
				new_method_list.append(method_data)

			class_info[name_of_class] = new_method_list

	#print(Time.get_datetime_dict_from_system())
	BasicData.allowed_thing = class_info


# Returns all available classes to use
func initialize_list_of_available_classes() -> void:
	var full_class_list: Array = Array(ClassDB.get_class_list())
	full_class_list.sort()

	var singleton_list: Array = Array(Engine.get_singleton_list())
	singleton_list.sort()

	for name_of_class in full_class_list:
		if name_of_class in BasicData.disabled_classes:
			continue

		if name_of_class.find("Server") != -1 && !ClassDB.is_parent_class(name_of_class, "RefCounted"):
			continue
		if name_of_class.find("Editor") != -1:
			continue

		if ClassDB.can_instantiate(name_of_class):
			if !singleton_list.has(name_of_class):
				BasicData.all_available_classes.push_back(name_of_class)

	BasicData.argument_classes = BasicData.all_available_classes.duplicate()
	BasicData.base_classes = BasicData.all_available_classes.duplicate()

	leave_custom_classes_if_needed(full_class_list.size())


func leave_custom_classes_if_needed(how_much_all_classes: int) -> void:
	if !BasicData.custom_classes.is_empty():
		BasicData.base_classes = []
		for name_of_class in BasicData.custom_classes:
			if BasicData.all_available_classes.has(name_of_class):
				BasicData.base_classes.append(name_of_class)

	if BasicData.base_classes.size() == 0:
		print("There is no classes available!!!!!!!!!!!!!!!!!!!")
		get_tree().quit()

	print(str(BasicData.base_classes.size()) + " chosen classes from all " + str(how_much_all_classes) + " classes.")
	print(str(BasicData.argument_classes.size()) + " classes can be used as arguments.")


func normalize_function_names(function_name: String) -> String:
	assert(function_name.length() > 1)
	assert(!function_name.ends_with("_"))  # There is i+1 expression which may be out of bounds
	var started_with_underscore = function_name.begins_with("_")
	function_name = function_name[0].to_upper() + function_name.substr(1)

	for i in function_name.length():
		if function_name[i] == "_":
			function_name[i + 1] = function_name[i + 1].to_upper()

	function_name = function_name.replace("_", "")

#	if started_with_underscore:
#		function_name = "_" + function_name

	return function_name
