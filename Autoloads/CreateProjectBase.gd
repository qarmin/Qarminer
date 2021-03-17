extends Node

var base_path: String
var base_dir: String

var use_loaded_resources: bool = false  # Loads resources from file instead using empty

var use_gdscript: bool

var debug_in_runtime: bool = true  # Allow to print info in runtime about currenty executed function, it is very helpful, so I don't recommend to turn this off
var use_parent_methods: bool = false  # Allows Node2D use Node methods etc. - it is a little slow option
var allow_to_replace_old_with_new_objects: bool = true  # Allows to delete old object and use new


class ClassData:
	var name: String = ""
	var function_names: Array = []
	var arguments: Array = []


var classes: Array

var list_of_all_files = {"2D": [], "3D": [], "Node": [], "Other": [], "Control": [], "Resource": [], "Reference": [], "Object": []}


func _init() -> void:
	test_normalize_function()


func test_normalize_function():
	use_gdscript = false
	assert(normalize_function_names("node") == "Node")
	assert(normalize_function_names("get_methods") == "GetMethods")
	use_gdscript = true
	assert(normalize_function_names("node") == "node")


func normalize_function_names(function_name: String) -> String:
	if use_gdscript:
		return function_name

	assert(function_name.length() > 1)
	assert(!function_name.ends_with("_"))  # There is i+1 expression which may be out of bounds
	function_name = function_name[0].to_upper() + function_name.substr(1)

	for i in function_name.length():
		if function_name[i] == "_":
			function_name[i + 1] = function_name[i + 1].to_upper()

	function_name = function_name.replace("_", "")

	return function_name


func collect_data() -> void:
	for name_of_class in Autoload.get_list_of_available_classes(false):
		var found: bool = false
		for exception in Autoload.only_instance:
			if exception == name_of_class:
				found = true
				break
		if found:
			continue

		var class_data: ClassData = ClassData.new()
		class_data.name = name_of_class

		var method_list: Array = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)
		for exception in Autoload.function_exceptions + Autoload.slow_functions:
			var index: int = -1
			for method_index in range(method_list.size()):
				if method_list[method_index]["name"] == exception:
					index = method_index
					break
			if index != -1:
				method_list.remove(index)

		for method_data in method_list:
			# Function is virtual, so we just skip it
			if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
				continue

			var arguments: Array = []

			for i in method_data["args"]:
				arguments.push_back(i)

			class_data.arguments.append(arguments)

			class_data.function_names.append(normalize_function_names(method_data["name"]))

		classes.append(class_data)


func create_scene_files() -> void:
	var file: File = File.new()

	for type in ["2D", "3D", "Node", "Control", "Resource", "Reference", "Object"]:
		var external_dependiences: String = ""
		var node_data: String = ""

		assert(file.open(base_path + str(type) + ".tscn", File.WRITE) == OK)
		file.store_string("[gd_scene load_steps=1000 format=2]\n\n")
		var counter: int = 1
		for file_name in list_of_all_files[type]:
			var split: PoolStringArray = file_name.rsplit("/")
			var latest_name: String
			if use_gdscript:
				latest_name = split[split.size() - 1].trim_suffix(".gd")
			else:
				latest_name = split[split.size() - 1].trim_suffix(".cs")

			external_dependiences += "[ext_resource path=\"_PATH_\" type=\"Script\" id=COUNTER]\n".replace("COUNTER", str(counter)).replace("_PATH_", file_name.replace(base_dir, ""))
			node_data += "[node name=\"FILE_NAME\" type=\"Node2D\" parent=\".\"]\n".replace("FILE_NAME", latest_name)
			node_data += "script = ExtResource( COUNTER )\n\n".replace("COUNTER", str(counter))

			counter += 1

		file.store_string(external_dependiences)
		file.store_string("\n")
		file.store_string("[node name=\"Root\" type=\"Node2D\"]".replace("Root", type))
		file.store_string("\n\n")
		file.store_string(node_data)

	assert(file.open(base_path + "All.tscn", File.WRITE) == OK)
	file.store_string(
		"""[gd_scene load_steps=7 format=2]

[ext_resource path=\"res://Resource.tscn\" type=\"PackedScene\" id=1]
[ext_resource path=\"res://Reference.tscn\" type=\"PackedScene\" id=2]
[ext_resource path=\"res://Node.tscn\" type=\"PackedScene\" id=3]
[ext_resource path=\"res://Control.tscn\" type=\"PackedScene\" id=4]
[ext_resource path=\"res://3D.tscn\" type=\"PackedScene\" id=5]
[ext_resource path=\"res://2D.tscn\" type=\"PackedScene\" id=6]
[ext_resource path=\"res://Object.tscn\" type=\"PackedScene\" id=7]

[node name=\"Node2D\" type=\"Node2D\"]

[node name=\"Object\" parent=\".\" instance=ExtResource( 7 )]
[node name=\"2D\" parent=\".\" instance=ExtResource( 6 )]
[node name=\"3D\" parent=\".\" instance=ExtResource( 5 )]
[node name=\"Control\" parent=\".\" instance=ExtResource( 4 )]
[node name=\"Node\" parent=\".\" instance=ExtResource( 3 )]
[node name=\"Reference\" parent=\".\" instance=ExtResource( 2 )]
[node name=\"Resource\" parent=\".\" instance=ExtResource( 1 )]"""
	)


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
				assert(file_name.find("/./") == -1 && file_name.begins_with("res://") && file_name.begins_with(base_path) && file_name.find("//", 6) == -1)
#				print(file_name)
				assert(directory.remove(file_name) == OK)

			assert(file_name.find("/./") == -1 && file_name.begins_with("res://") && file_name.begins_with(base_path) && file_name.find("//", 6) == -1)
		file_name = directory.get_next()

#	print(to_delete)
	assert(to_delete.find("/./") == -1 && to_delete.begins_with("res://") && to_delete.begins_with(base_path) && to_delete.find("//", 6) == -1)
	assert(directory.remove(to_delete) == OK)


func create_basic_structure() -> void:
	var directory: Directory = Directory.new()
	assert(directory.make_dir_recursive(base_path + "2D/") == OK)
	assert(directory.make_dir_recursive(base_path + "3D/") == OK)
	assert(directory.make_dir_recursive(base_path + "Node/") == OK)
	assert(directory.make_dir_recursive(base_path + "Object/") == OK)
	assert(directory.make_dir_recursive(base_path + "Control/") == OK)
	assert(directory.make_dir_recursive(base_path + "Resource/") == OK)
	assert(directory.make_dir_recursive(base_path + "Reference/") == OK)
	assert(directory.make_dir_recursive(base_path + "Self/") == OK)

	var file: File = File.new()

	assert(file.open(base_path + "project.godot", File.WRITE) == OK)
	file.store_string(
		"""
config_version=4

[application]
run/main_scene="res://All.tscn"

[memory]
limits/message_queue/max_size_kb=65536
limits/command_queue/multithreading_queue_size_kb=4096

[network]

limits/debugger_stdout/max_chars_per_second=10
limits/debugger_stdout/max_errors_per_second=10
limits/debugger_stdout/max_warnings_per_second=10
		"""
	)
