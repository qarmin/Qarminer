extends Node

var base_path : String = "res://Resources/"
var base_dir : String = "Resources/"
	
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
	for choosen_class in Autoload.get_list_of_available_classes():
		if !ClassDB.is_parent_class(choosen_class,"Resource"):
			continue
		if !ClassDB.can_instance(choosen_class):
			continue
		
		assert(ResourceSaver.save(base_path + choosen_class + ".res", ClassDB.instance(choosen_class)) == OK)

func _ready() -> void:
	if Directory.new().dir_exists(base_path):
		remove_files_recursivelly(base_path)
	create_basic_structure()
	create_resources()
	print("Saved resources")
	get_tree().quit()
