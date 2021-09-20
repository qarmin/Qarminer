extends Node

# Checks if function can be executed
# Looks at its arguments and method type
# This is useful when e.g. adding/renaming type Transform -> Transform3D


# TODO use this at the begining, before doing any computation, since this will save
# a lot of time, but only when running this in loop
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
			print("MISSING TYPE in function " + method_data["name"] + "  --  Variant type - " + str(t))
			return false

		if name_of_class.empty():
			continue

		#This is only for RegressionTestProject, because it needs for now clear visual info what is going on screen, but some nodes broke view
		if BasicData.regression_test_project:
			# That means that this is constant, not class
			if !ClassDB.class_exists(name_of_class):
				continue
			if !ClassDB.is_parent_class(name_of_class, "Node") && !ClassDB.is_parent_class(name_of_class, "Reference"):
				return false

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


# Initialize array which contains only allowed Functions
func initialize_array_with_allowed_functions(use_parent_methods: bool, disabled_methods: Array):
	assert(!BasicData.classes.empty(), "Missing initalization of classes")
	var class_info: Dictionary = {}

	for name_of_class in BasicData.classes:
		var old_method_list: Array = []
		var new_method_list: Array = []

		old_method_list = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)
		old_method_list = remove_disabled_methods(old_method_list, disabled_methods)
		for method_data in old_method_list:
			if !check_if_is_allowed(method_data):
				continue
			new_method_list.append(method_data)

		class_info[name_of_class] = new_method_list
	BasicData.allowed_thing = class_info


# Returns all available classes to use
func initialize_list_of_available_classes(must_be_instantable: bool = true, allow_editor: bool = true, available_classes : Array = []) -> void:
	if !available_classes.empty():
		available_classes.sort()
		BasicData.classes = available_classes
		return
	
	var full_class_list: Array = Array(ClassDB.get_class_list())
	full_class_list.sort()

	var custom_classes: Array = []
	var file = File.new()
	if file.file_exists("res://classes.txt"):
		file.open("res://classes.txt", File.READ)
		while !file.eof_reached():
			var cname = file.get_line()
			var internal_cname = "_" + cname
			# The declared class may not exist, and it may be exposed as `_ClassName` rather than `ClassName`.
			if !ClassDB.class_exists(cname) && !ClassDB.class_exists(internal_cname):
				continue
			if ClassDB.class_exists(internal_cname):
				cname = internal_cname
			custom_classes.push_back(cname)
		file.close()

	for name_of_class in full_class_list:
		if name_of_class in BasicData.disabled_classes:
			continue

		# This only checks basic nodes and refcounted things
		# Other objects may broke view, so remove this check in 4.0
		# when there is no even 1 visually normal scene
		if BasicData.regression_test_project:
			if !ClassDB.is_parent_class(name_of_class, "Node") && !ClassDB.is_parent_class(name_of_class, "Reference"):
				continue

		if name_of_class.find("Server") != -1 && !ClassDB.is_parent_class(name_of_class, "Reference"):
			continue
		if name_of_class.find("Editor") != -1 && (BasicData.regression_test_project || !allow_editor):
			continue

		if !custom_classes.empty() and !(name_of_class in custom_classes):
			continue

		if !must_be_instantable || ClassDB.can_instance(name_of_class):
			BasicData.classes.push_back(name_of_class)

#	classes = classes.slice(0, 200)

	print(str(BasicData.classes.size()) + " choosen classes from all " + str(full_class_list.size()) + " classes.")
