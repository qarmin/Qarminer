extends Node

# Class to create Resources files

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
	assert(directory.remove(to_delete) == OK)


func create_basic_structure() -> void:
	var directory: Directory = Directory.new()
	assert(directory.make_dir_recursive(base_path) == OK)
	var file: File = File.new()
	assert(file.open(base_path + "project.godot", File.WRITE) == OK)


func create_resources() -> void:
	for name_of_class in BasicData.get_list_of_available_classes():
		if !ClassDB.is_parent_class(name_of_class, "Resource"):
			continue

		var object = ClassDB.instance(name_of_class)

		var method_list: Array = ClassDB.class_get_method_list(name_of_class, false)
		for exception in BasicData.function_exceptions + BasicData.project_resources_exclusion:
			var index: int = -1
			for method_index in range(method_list.size()):
				if method_list[method_index]["name"] == exception:
					index = method_index
					break
			if index != -1:
				method_list.remove(index)

		if name_of_class == "Image":
			continue
		print("################ CLASS - " + name_of_class)

		for _i in range(20):
			for method_data in method_list:
				if ClassDB.class_has_method("Object", method_data["name"]):
					continue
				if method_data["name"] == "start":  # Do not create new thread
					continue
				if !BasicData.check_if_is_allowed(method_data):
					continue
				print(method_data["name"])

				var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data,name_of_class)
				object.callv(method_data["name"], arguments)

				for argument in arguments:
					if argument != null:
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
