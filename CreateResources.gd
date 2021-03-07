extends Node

var base_path: String = "res://Resources/"
var base_dir: String = "Resources/"


func remove_files_recursivelly(to_delete: String) -> void:
	var directory: Directory = Directory.new()

	assert(directory.open(to_delete) == OK)
	assert(directory.list_dir_begin() == OK)
	var file_name: String = directory.get_next()
	while file_name != "":
		if file_name != "." && file_name != "..":
			if directory.current_is_dir():
				file_name = to_delete + file_name + "/"
				remove_files_recursivelly(file_name)
			else:
				file_name = to_delete + file_name
				assert(file_name.find("/./") == -1 && file_name.begins_with("res://") && file_name.begins_with(CreateProjectBase.base_path) && file_name.find("//", 6) == -1)
#				print(file_name)
				assert(directory.remove(file_name) == OK)

			assert(file_name.find("/./") == -1 && file_name.begins_with("res://") && file_name.begins_with(CreateProjectBase.base_path) && file_name.find("//", 6) == -1)
		file_name = directory.get_next()

	assert(to_delete.find("/./") == -1 && to_delete.begins_with("res://") && to_delete.begins_with(CreateProjectBase.base_path) && to_delete.find("//", 6) == -1)
	assert(directory.remove(to_delete) == OK)  # TODO, Test This


func create_basic_structure() -> void:
	var directory: Directory = Directory.new()
	assert(directory.make_dir_recursive(base_path) == OK)
	var file: File = File.new()
	assert(file.open(base_path + "project.godot", File.WRITE) == OK)


func create_resources() -> void:
	for name_of_class in Autoload.get_list_of_available_classes():
		if !ClassDB.is_parent_class(name_of_class, "Resource"):
			continue
		if !ClassDB.can_instance(name_of_class):
			continue

		var object = ClassDB.instance(name_of_class)

		var method_list: Array = ClassDB.class_get_method_list(name_of_class, false)
		for exception in Autoload.function_exceptions + Autoload.slow_functions:
			var index: int = -1
			for method_index in range(method_list.size()):
				if method_list[method_index]["name"] == exception:
					index = method_index
					break
			if index != -1:
				method_list.remove(index)

		if name_of_class == "GDScript": # Cause some strange errors
			continue
		print("################ CLASS - " + name_of_class)

		for i in range(20):
			for method_data in method_list:
				if ClassDB.class_has_method("Object", method_data["name"]):
					continue
				if method_data["name"] == "start":  # Do not create new thread
					continue
				# Function is virtual, so we just skip it
				if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
					continue
				print(method_data["name"])

				var arguments: Array = return_for_all(method_data)
				object.callv(method_data["name"], arguments)

				for argument in arguments:
					assert(argument != null)
					if argument is Node:
						argument.queue_free()
					elif argument is Object && !(argument is Reference):
						argument.free()
		if ResourceSaver.save(base_path + name_of_class + ".tres", object) != OK:
			assert(ResourceSaver.save(base_path + name_of_class + ".res", object) == OK)


func _ready() -> void:
	if Directory.new().dir_exists(base_path):
		remove_files_recursivelly(base_path)
	create_basic_structure()
	create_resources()
	print("Saved resources")
	get_tree().quit()


func return_for_all(method_data: Dictionary) -> Array:
	var arguments_array: Array = []

	ValueCreator.number = 100
	ValueCreator.random = true  # RegressionTestProject - This must be false
	ValueCreator.should_be_always_valid = false

	for argument in method_data["args"]:
		match argument.type:
			TYPE_NIL:  # Looks that this means VARIANT not null
				arguments_array.push_back(false)  # TODO randomize this
			TYPE_AABB:
				arguments_array.push_back(ValueCreator.get_aabb())
			TYPE_ARRAY:
				arguments_array.push_back(ValueCreator.get_array())
			TYPE_BASIS:
				arguments_array.push_back(ValueCreator.get_basis())
			TYPE_BOOL:
				arguments_array.push_back(ValueCreator.get_bool())
			TYPE_COLOR:
				arguments_array.push_back(ValueCreator.get_color())
			TYPE_COLOR_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_color_array())
			TYPE_DICTIONARY:
				arguments_array.push_back(ValueCreator.get_dictionary())
			TYPE_INT:
				arguments_array.push_back(ValueCreator.get_int())
			TYPE_INT_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_int_array())
			TYPE_NODE_PATH:
				arguments_array.push_back(ValueCreator.get_nodepath())
			TYPE_OBJECT:
				arguments_array.push_back(ValueCreator.get_object(argument["class_name"]))
			TYPE_PLANE:
				arguments_array.push_back(ValueCreator.get_plane())
			TYPE_QUAT:
				arguments_array.push_back(ValueCreator.get_quat())
			TYPE_RAW_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_byte_array())
			TYPE_REAL:
				arguments_array.push_back(ValueCreator.get_float())
			TYPE_REAL_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_real_array())
			TYPE_RECT2:
				arguments_array.push_back(ValueCreator.get_rect2())
			TYPE_RID:
				arguments_array.push_back(RID())
			TYPE_STRING:
				arguments_array.push_back(ValueCreator.get_string())
			TYPE_STRING_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_string_array())
			TYPE_TRANSFORM:
				arguments_array.push_back(ValueCreator.get_transform())
			TYPE_TRANSFORM2D:
				arguments_array.push_back(ValueCreator.get_transform2D())
			TYPE_VECTOR2:
				arguments_array.push_back(ValueCreator.get_vector2())
			TYPE_VECTOR2_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_vector2_array())
			TYPE_VECTOR3:
				arguments_array.push_back(ValueCreator.get_vector3())
			TYPE_VECTOR3_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_vector3_array())
			_:
				assert(false)  # Missed some types, add it

	return arguments_array
