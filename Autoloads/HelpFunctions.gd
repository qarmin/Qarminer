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
		if ClassDB.can_instance(i) && ClassDB.is_parent_class(i, "Node"):
			var rr = ClassDB.instance(i)
			if rr.get_child_count() > 0:
				list.append(i)
			remove_thing(rr)
	BasicData.disabled_classes.append_array(list)


# Checks if function can be executed
# Looks at its arguments and method type
# This is useful when e.g. adding/renaming type Transform -> Transform3D
func check_if_is_allowed(method_data: Dictionary) -> bool:
	# Function is virtual or vararg, so we just skip it
	if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
		return false
	if method_data["flags"] == method_data["flags"] | 128:  # VARARG TODO, Godot issue, add missing flag binding
		return false

	for arg in method_data["args"]:
		var name_of_class: String = arg["class_name"]

		if name_of_class in BasicData.disabled_classes:
			return false
		if name_of_class.find("Server") != -1 && ClassDB.class_exists(name_of_class) && !ClassDB.is_parent_class(name_of_class, "Reference"):
			return false
		# Editor stuff usually aren't good choice for arguments
		if name_of_class.find("Editor") != -1 || name_of_class.find("SkinReference") != -1:
			return false

		# In case of adding new type, this prevents from crashing due not recognizing this type
		# In case of removing/rename type, just comment e.g. TYPE_ARRAY and all occurencies on e.g. switch statement with it
		var t: int = arg["type"]
		if !(
			t == TYPE_NIL
			|| t == TYPE_AABB
			|| t == TYPE_ARRAY
			|| t == TYPE_BASIS
			|| t == TYPE_BOOL
			|| t == TYPE_COLOR
			|| t == TYPE_COLOR_ARRAY
			|| t == TYPE_DICTIONARY
			|| t == TYPE_INT
			|| t == TYPE_INT_ARRAY
			|| t == TYPE_NODE_PATH
			|| t == TYPE_OBJECT
			|| t == TYPE_PLANE
			|| t == TYPE_QUAT
			|| t == TYPE_RAW_ARRAY
			|| t == TYPE_REAL
			|| t == TYPE_REAL_ARRAY
			|| t == TYPE_RECT2
			|| t == TYPE_RID
			|| t == TYPE_STRING
			|| t == TYPE_STRING_ARRAY
			|| t == TYPE_TRANSFORM
			|| t == TYPE_TRANSFORM2D
			|| t == TYPE_VECTOR2
			|| t == TYPE_VECTOR2_ARRAY
			|| t == TYPE_VECTOR3
			|| t == TYPE_VECTOR3_ARRAY
		):
			#			# TODOGODOT4
			#			|| t == TYPE_VECTOR2I
			#			|| t == TYPE_VECTOR3I
			#			|| t == TYPE_STRING_NAME
			#			|| t == TYPE_RECT2I
			#			|| t == TYPE_FLOAT64_ARRAY
			#			|| t == TYPE_INT64_ARRAY
			#			|| t == TYPE_CALLABLE
			print("MISSING TYPE in function " + method_data["name"] + "  --  Variant type - " + str(t))
			return false

		if name_of_class.empty():
			continue

	return true


# Return GDScript code which create this object
func get_gdscript_class_creation(name_of_class: String) -> String:
	if (
		ClassDB.is_parent_class(name_of_class, "Object")
		&& !ClassDB.is_parent_class(name_of_class, "Node")
		&& !ClassDB.is_parent_class(name_of_class, "Reference")
		&& !ClassDB.class_has_method(name_of_class, "new")
	):
		return 'ClassDB.instance("' + name_of_class + '")'
	else:
		return name_of_class.trim_prefix("_") + ".new()"


# Removes disabled methods from list - TODO, for now it do unecessary duplication
# because passing by reference seems to be broken in 4.0
func remove_disabled_methods(method_list: Array, exceptions: Array) -> Array:
	var new_method_list: Array = method_list.duplicate(true)
	for exception in exceptions:
		var index: int = -1
		for method_index in range(new_method_list.size()):
			if new_method_list[method_index]["name"] == exception:
				index = method_index
				break
		if index != -1:
			new_method_list.remove(index)
	return new_method_list


# Removes specific object/node
func remove_thing(thing: Object) -> void:
	if thing is Node:
		thing.queue_free()
	elif thing is Object && !(thing is Reference):
		thing.free()


func remove_thing_string(thing: Object) -> String:
	if thing is Node:
		return ".queue_free()"
	elif thing is Object && !(thing is Reference):
		return ".free()"
	else:
		return ""


# Initialize array which contains only allowed functions
# If BasicData.allowed_functions is not set, every possible functions is checked
func initialize_array_with_allowed_functions(use_parent_methods: bool, disabled_methods: Array):
	assert(!BasicData.base_classes.empty(), "Missing initalization of classes")
	assert(!BasicData.argument_classes.empty(), "Missing initalization of classes")
	var class_info: Dictionary = {}

	if BasicData.allowed_functions.empty():
		for name_of_class in BasicData.base_classes:
			var old_method_list: Array = []
			var new_method_list: Array = []
			old_method_list = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)
			old_method_list = remove_disabled_methods(old_method_list, disabled_methods)
			for method_data in old_method_list:
				if !check_if_is_allowed(method_data):
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
				if !check_if_is_allowed(method_data):
					continue
				new_method_list.append(method_data)

			class_info[name_of_class] = new_method_list

	BasicData.allowed_thing = class_info


# Returns all available classes to use
func initialize_list_of_available_classes() -> void:
	var full_class_list: Array = Array(ClassDB.get_class_list())
	full_class_list.sort()

	for name_of_class in full_class_list:
		if name_of_class in BasicData.disabled_classes:
			continue

		if name_of_class.find("Server") != -1 && !ClassDB.is_parent_class(name_of_class, "Reference"):
			continue
		if name_of_class.find("Editor") != -1:
			continue

		if ClassDB.can_instance(name_of_class):
			BasicData.all_available_classes.push_back(name_of_class)

	BasicData.argument_classes = BasicData.all_available_classes.duplicate()
	BasicData.base_classes = BasicData.all_available_classes.duplicate()

	leave_custom_classes_if_needed(full_class_list.size())


func leave_custom_classes_if_needed(how_much_all_classes: int) -> void:
	if !BasicData.custom_classes.empty():
		BasicData.base_classes = []
		for name_of_class in BasicData.custom_classes:
			if BasicData.all_available_classes.has(name_of_class):
				BasicData.base_classes.append(name_of_class)

	if BasicData.base_classes.size() == 0:
		print("There is no classes available!!!!!!!!!!!!!!!!!!!")
		get_tree().quit()

	print(str(BasicData.base_classes.size()) + " choosen classes from all " + str(how_much_all_classes) + " classes.")
	print(str(BasicData.argument_classes.size()) + " classes can be used as arguments.")
