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


var classes_thing: Array = []

var list_of_all_files = {"2D": [], "3D": [], "Node": [], "Other": [], "Control": [], "Resource": [], "Reference": [], "Object": []}

#func _init():
#	test_normalize_function()
#
#
#func test_normalize_function():
#	use_gdscript = false
#	assert(normalize_function_names("node") == "Node")
#	assert(normalize_function_names("get_methods") == "GetMethods")
#	use_gdscript = true
#	assert(normalize_function_names("node") == "node")


func normalize_function_names(function_name: String) -> String:
	return function_name


#	if use_gdscript:
#		return function_name
#
#	assert(function_name.length() > 1)
#	assert(!function_name.ends_with("_"))  # There is i+1 expression which may be out of bounds
#	function_name = function_name[0].to_upper() + function_name.substr(1)
#
#	for i in function_name.length():
#		if function_name[i] == "_":
#			function_name[i + 1] = function_name[i + 1].to_upper()
#
#	function_name = function_name.replace("_", "")
#
#	return function_name


func collect_data() -> void:
	HelpFunctions.initialize_list_of_available_classes(false, false)
	HelpFunctions.initialize_array_with_allowed_functions(use_parent_methods, BasicData.function_exceptions)

	for name_of_class in BasicData.allowed_thing.keys():
		var found: bool = false
		for exception in project_only_instance:
			if exception == name_of_class:
				found = true
				break
		if found:
			continue

		var class_data: ClassData = ClassData.new()
		class_data.name = name_of_class

		var method_list: Array = BasicData.allowed_thing[name_of_class]

		for method_data in method_list:
			var arguments: Array = []

			for i in method_data["args"]:
				arguments.push_back(i)

			class_data.arguments.append(arguments)

			class_data.function_names.append(normalize_function_names(method_data["name"]))

		classes_thing.append(class_data)


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

			external_dependiences += '[ext_resource path="_PATH_" type="Script" id=COUNTER]\n'.replace("COUNTER", str(counter)).replace("_PATH_", file_name.replace(base_dir, ""))
			node_data += '[node name="FILE_NAME" type="Node2D" parent="."]\n'.replace("FILE_NAME", latest_name)
			node_data += "script = ExtResource( COUNTER )\n\n".replace("COUNTER", str(counter))

			counter += 1

		file.store_string(external_dependiences)
		file.store_string("\n")
		file.store_string('[node name="Root" type="Node2D"]'.replace("Root", type))
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
run/main_scene=\"res://All.tscn\"
[memory]
limits/message_queue/max_size_kb=65536
limits/command_queue/multithreading_queue_size_kb=4096
[network]
limits/debugger_stdout/max_chars_per_second=10
limits/debugger_stdout/max_errors_per_second=10
limits/debugger_stdout/max_warnings_per_second=10
		"""
	)


# Specific classes which are initialized in specific way e.g. var undo_redo = get_undo_redo() instead var undo_redo = UndoRedo.new()
# It is used when generating project
var project_only_instance: Array = [
	"UndoRedo",
	"Object",
	"JSONRPC",
	"MainLoop",
	"SceneTree",
	"ARVRPositionalTracker",
]


### Class which contains informations about used
class SingleArgument:
	var name: String  # E.G. var roman, can be empty, so temp variable isn't created(nodes and objects must be created with temp_variable due to memory leaks)
	var type: String  # np. Vector2 or Object
	var value: String  # np. randi() % 100 or
	var is_object: bool = false  # Check if this is object e.g. Node not Vector2
	var is_only_object: bool = false  # Only needs to freed with .free()
	var is_only_reference: bool = false  # Don't needs to be removed manually
	var is_only_node: bool = false  # Needs to be removed with .queue_free()


func create_gdscript_arguments(arguments: Array) -> Array:
	var argument_array: Array = []

	var counter = 0
	for argument in arguments:
		counter += 1
		var sa: SingleArgument = SingleArgument.new()
		sa.name = "variable" + str(counter)
		match argument["type"]:
			TYPE_NIL:  # Looks that this means VARIANT not null
				sa.type = "Variant"
				sa.value = "false"
			TYPE_AABB:
				sa.type = "AABB"
				sa.value = get_aabb_string()
			TYPE_ARRAY:
				sa.type = "Array"
				sa.value = "[]"
			TYPE_BASIS:
				sa.type = "Basis"
				sa.value = get_basis_string()
			TYPE_BOOL:
				sa.type = "bool"
				sa.value = get_bool_string().to_lower()
			TYPE_COLOR:
				sa.type = "Color"
				sa.value = get_color_string()
			TYPE_COLOR_ARRAY:
				sa.type = "PoolColorArray"
				sa.value = "PoolColorArray([])"
			TYPE_DICTIONARY:
				sa.type = "Dictionary"
				sa.value = "{}"  # TODO Why not all use ValueCreator?
			TYPE_INT:
				sa.type = "int"
				sa.value = get_int_string()
			TYPE_INT_ARRAY:
				sa.type = "PoolIntArray"
				sa.value = "PoolIntArray([])"
			TYPE_NODE_PATH:
				sa.type = "NodePath"
				sa.value = 'NodePath(".")'
			TYPE_OBJECT:
				sa.type = get_object_string(argument["class_name"])
				sa.value = sa.type + ".new()"

				sa.is_object = true
				if ClassDB.is_parent_class(sa.type, "Node"):
					sa.is_only_node = true
				elif ClassDB.is_parent_class(sa.type, "Reference"):
					sa.is_only_reference = true
				else:
					sa.is_only_object = true

			TYPE_PLANE:
				sa.type = "Plane"
				sa.value = get_plane_string()
			TYPE_QUAT:
				sa.type = "Quat"
				sa.value = get_quat_string()
			TYPE_RAW_ARRAY:
				sa.type = "PoolByteArray"
				sa.value = "PoolByteArray([])"
			TYPE_REAL:
				sa.type = "float"
				sa.value = get_float_string()
			TYPE_REAL_ARRAY:
				sa.type = "PoolRealArray"
				sa.value = "PoolRealArray([])"
			TYPE_RECT2:
				sa.type = "Rect2"
				sa.value = get_rect2_string()
			TYPE_RID:
				sa.type = "RID"
				sa.value = "RID()"
			TYPE_STRING:
				sa.type = "String"
				sa.value = get_string_string()
			TYPE_STRING_ARRAY:
				sa.type = "PoolStringArray"
				sa.value = "PoolStringArray([])"
			TYPE_TRANSFORM:
				sa.type = "Transform"
				sa.value = get_transform_string()
			TYPE_TRANSFORM2D:
				sa.type = "Transform2D"
				sa.value = get_transform2D_string()
			TYPE_VECTOR2:
				sa.type = "Vector2"
				sa.value = get_vector2_string()
			TYPE_VECTOR2_ARRAY:
				sa.type = "PoolVector2Array"
				sa.value = "PoolVector2Array([])"
			TYPE_VECTOR3:
				sa.type = "Vector3"
				sa.value = get_vector3_string()
			TYPE_VECTOR3_ARRAY:
				sa.type = "PoolVector3Array"
				sa.value = "PoolVector3Array([])"
			_:
				assert(false, "Missing type, needs to be added to project")
		argument_array.append(sa)

	return argument_array


func get_int_string() -> String:
	if ValueCreator.random:
		if int(ValueCreator.number) == 0:
			return "0"
		return "(randi() % int(number)) - int(number / 2.0)".replace("number", str(ValueCreator.number))
	else:
		return str(int(ValueCreator.number))


func get_float_string() -> String:
	if ValueCreator.random:
		return "(randf() * number) - (number / 2.0)".replace("number", str(ValueCreator.number))
	else:
		return str(ValueCreator.number)


func get_bool_string() -> String:
	if ValueCreator.random:
		if ValueCreator.number < 2:
			return str(bool())
		return "bool(randi() % 2)"
	else:
		return str(bool())


func get_vector2_string() -> String:
	if ValueCreator.random:
		if randi() % 2:
			return "Vector2(" + get_float_string() + ", " + get_float_string() + ").normalized()"
	return "Vector2(" + get_float_string() + ", " + get_float_string() + ")"


func get_vector3_string() -> String:
	if ValueCreator.random:
		if randi() % 2:
			return "Vector3(" + get_float_string() + ", " + get_float_string() + ", " + get_float_string() + ").normalized()"
	return "Vector3(" + get_float_string() + ", " + get_float_string() + ", " + get_float_string() + ")"


func get_aabb_string() -> String:
	return "AABB(" + get_vector3_string() + ", " + get_vector3_string() + ")"


func get_transform_string() -> String:
	return "Transform(" + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ")"


func get_transform2D_string() -> String:
	return "Transform2D(" + get_vector2_string() + ", " + get_vector2_string() + ", " + get_vector2_string() + ")"


func get_plane_string() -> String:
	return "Plane(" + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ")"


func get_quat_string() -> String:
	return "Quat(" + get_vector3_string() + ")"


func get_basis_string() -> String:
	return "Basis(" + get_vector3_string() + ")"


func get_rect2_string() -> String:
	return "Rect2(" + get_vector2_string() + ", " + get_vector2_string() + ")"


func get_color_string() -> String:
	return "Color(" + get_float_string() + ", " + get_float_string() + ", " + get_float_string() + ")"


func get_string_string() -> String:
	if ValueCreator.random:
		if randi() % 3 == 0:
			return '"."'
		elif randi() % 3 == 0:
			return '""'
		else:
			return "str(randi() / 100)"
	return '""'


# TODO Update this with upper implementation
func get_object_string(object_name: String) -> String:
	assert(ClassDB.class_exists(object_name))

	var a = 0
	if ValueCreator.random:
		var classes = ClassDB.get_inheriters_from_class("Node") + ClassDB.get_inheriters_from_class("Reference")

		if object_name == "Object":
			while true:
				var choosen_class: String = classes[randi() % classes.size()]
				if ClassDB.can_instance(choosen_class) && (ClassDB.is_parent_class(choosen_class, "Node") || ClassDB.is_parent_class(choosen_class, "Reference")):
					return choosen_class

		if ClassDB.is_parent_class(object_name, "Node") || ClassDB.is_parent_class(object_name, "Reference"):
			if ValueCreator.should_be_always_valid:
				var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
				to_use_classes.append(object_name)
				if !ClassDB.can_instance(object_name):
					assert(to_use_classes.size() > 0, "Cannot find proper instantable child for " + object_name)

				while true:
					a += 1
					if a > 30:
						# Object doesn't have children which can be instanced
						# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
						assert(false, "Cannot find proper instantable child for " + object_name)
					var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
					if ClassDB.can_instance(choosen_class):
						return choosen_class
			else:
				while true:
					a += 1
					if a > 30:
						assert(false, "Cannot find proper instantable child for " + object_name)
					var choosen_class: String = classes[randi() % classes.size()]
					if !ClassDB.is_parent_class(choosen_class, object_name):
						return choosen_class

		# Non Node/Resource object
		var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
		to_use_classes.append(object_name)
		if !ClassDB.can_instance(object_name) && object_name in BasicData.disabled_classes:
			assert(to_use_classes.size() > 0, "Cannot find proper instantable child for " + object_name)

		while true:
			a += 1
			if a > 50:
				# Object doesn't have children which can be instanced
				# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
				assert(false, "Cannot find proper instantable child for " + object_name)
			var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
			if ClassDB.can_instance(choosen_class) && !(choosen_class in BasicData.disabled_classes):
				return choosen_class

	else:
		if ClassDB.can_instance(object_name):  # E.g. Texture is not instantable or shouldn't be, but LargeTexture is
			return object_name
		else:  # Found child of non instantable object
			var list_of_class = ClassDB.get_inheriters_from_class(object_name)
			assert(list_of_class.size() > 0, "Cannot find proper instantable child for " + object_name)  # Number of inherited class of non instantable class must be greater than 0, otherwise this function would be useless
			for i in list_of_class:
				if ClassDB.can_instance(i) && (ClassDB.is_parent_class(i, "Node") || ClassDB.is_parent_class(i, "Reference")):
					return i
			assert(false, "Cannot find proper instantable child for " + object_name)

	assert(false, "Cannot find proper instantable child for " + object_name)
	return "BoxMesh"


### T1

var number_of_external_resources: int = 0


func get_object_folder(name_of_class: String) -> String:
	assert(ClassDB.class_exists(name_of_class))
	if ClassDB.is_parent_class(name_of_class, "Spatial"):  # TODO Fix in Godot 4.0
		return "3D"
	elif ClassDB.is_parent_class(name_of_class, "Node2D"):
		return "2D"
	elif ClassDB.is_parent_class(name_of_class, "Control"):
		return "Control"
	elif ClassDB.is_parent_class(name_of_class, "Node"):
		return "Node"
	elif ClassDB.is_parent_class(name_of_class, "Resource"):
		return "Resource"
	elif ClassDB.is_parent_class(name_of_class, "Reference"):
		return "Reference"
	else:
		return "Object"


func create_basic_files() -> void:
	var file: File = File.new()
	var self_file: File = File.new()

	for class_data in classes_thing:
		var data_to_save: String = ""
		var file_name: String = base_path

		var prefix = get_object_folder(class_data.name)
		file_name += prefix + "/" + class_data.name + ".gd"
		list_of_all_files[prefix].append(file_name)

		var object_type = class_data.name.trim_prefix("_")  # Change _Directory to Directory etc
		var can_be_instanced: bool
		var is_static: bool  # Can execute static functions on it
		var object_name
		if (
			ClassDB.can_instance(class_data.name)
			&& (
				ClassDB.is_parent_class(class_data.name, "Node")
				|| ClassDB.is_parent_class(class_data.name, "Reference")
				|| (ClassDB.is_parent_class(class_data.name, "Object") && ClassDB.class_has_method(class_data.name, "new"))
			)
		):
			object_name = "q_" + object_type
			can_be_instanced = true
			is_static = false
		elif (
			ClassDB.is_parent_class(class_data.name, "Node")
			|| ClassDB.is_parent_class(class_data.name, "Reference")
			|| (ClassDB.is_parent_class(class_data.name, "Object") && ClassDB.class_has_method(class_data.name, "new"))
		):
			object_name = "q_" + object_type
			can_be_instanced = false
			is_static = false
		else:
			object_name = object_type
			can_be_instanced = false
			is_static = true

		### Create file, which allow to open
		if ClassDB.is_parent_class(class_data.name, "Node"):
			var data_self = ""
			data_self += "extends " + class_data.name + "\n\n"
			data_self += "func _process(_delta: float) -> void:\n"
			data_self += '\tload("res://' + prefix + "/" + class_data.name + '.gd").modify_object(self)'

			assert(self_file.open("res://GDScript/Self/" + class_data.name + ".gd", File.WRITE) == OK)
			self_file.store_string(data_self)

		### Global
		data_to_save += "extends Node2D\n\n"
		if can_be_instanced:
			data_to_save += "var ||| : {} = {}.new()\n\n".replace("{}", object_type).replace("|||", object_name)

		### Ready function
		if can_be_instanced || is_static:
			data_to_save += "func _ready() -> void:\n"
			data_to_save += "\tif !is_visible():\n"
			data_to_save += "\t\tset_process(false)\n"
			if ClassDB.is_parent_class(class_data.name, "Node"):
				data_to_save += "\t\t" + object_name + ".queue_free()\n"
			data_to_save += "\t\treturn\n\n"
			if ClassDB.is_parent_class(class_data.name, "Node"):
				data_to_save += "\tadd_child(" + object_name + ")\n\n"

		### Process Function
		if can_be_instanced || is_static:  # Disallow to use it for e.g. non instantable CollisionObject
			data_to_save += "func _process(_delta : float) -> void:\n"
			if allow_to_replace_old_with_new_objects:
				if can_be_instanced:
					data_to_save += "\tif randi() % 10 == 0:\n"
				if ClassDB.is_parent_class(class_data.name, "Node"):
					data_to_save += "\t\t" + object_name + ".queue_free()\n"
				if can_be_instanced && !(ClassDB.is_parent_class(class_data.name, "Reference")) && !(ClassDB.is_parent_class(class_data.name, "Node")):
					data_to_save += "\t\t" + object_name + ".free()\n"
				if can_be_instanced:
					data_to_save += "\t\t" + object_name + " = " + object_type + ".new()\n"
				if ClassDB.is_parent_class(class_data.name, "Node"):
					data_to_save += "\t\tadd_child(" + object_name + ")\n\n"

				## Execution of function
				if can_be_instanced:
					data_to_save += "\tmodify_object(|||)\n\n".replace("|||", object_name)
				else:
					data_to_save += "\tmodify_object()\n\n"

		### Function which execute
		if !is_static:
			data_to_save += "static func modify_object(||| : {}) -> void:\n".replace("{}", object_type).replace("|||", object_name)
		else:
			data_to_save += "static func modify_object() -> void:\n"

		if !(class_data.name in ["PhysicsDirectBodyState", "PhysicsDirectSpaceState", "Physics2DDirectBodyState", "Physics2DDirectSpaceState", "TreeItem", "Image"]):  # Some functions are static, but some needs to work on objects etc.., TODO Remove Image when it will be enough stable
			for i in range(class_data.function_names.size()):
				var function_use_objects: bool = false

				data_to_save += "\tif randi() % 2 == 0:\n"
				if debug_in_runtime:
					data_to_save += '\t\tprint("Executing ' + object_type + "." + class_data.function_names[i] + '")\n'

				var arguments := create_gdscript_arguments(class_data.arguments[i])

				for argument in arguments:
					if argument.is_object:
						assert(ClassDB.class_exists(argument.type))
						if argument.is_only_reference && use_loaded_resources:
							data_to_save += "\t\tvar " + argument.name + ": " + argument.type + " = " + ' load("res://Resources/' + argument.type + '.res")\n'
						else:
							data_to_save += "\t\tvar " + argument.name + ": " + argument.type.trim_prefix("_") + " = " + argument.type.trim_prefix("_") + ".new()\n"
					else:
						if argument.type == "Variant":
							data_to_save += "\t\tvar " + argument.name + " = " + argument.value + "\n"
						else:
							data_to_save += "\t\tvar " + argument.name + ": " + argument.type + " = " + argument.value + "\n"

				if debug_in_runtime:
					data_to_save += '\t\tprint("Parameters['
					for j in arguments.size():
						data_to_save += '" + str(' + arguments[j].name + ') + "'
						if j != arguments.size() - 1:
							data_to_save += ", "
					data_to_save += ']")\n'

				# Apply data
				if function_use_objects:
					if number_of_external_resources > 0:
						data_to_save += "\t\tfor _i in range(|||):\n".replace("|||", str(number_of_external_resources))
						for argument in arguments:
							if !argument.name.empty() && argument.name != class_data.name:  # Do not allow to recursive execute functions
								data_to_save += '\t\t\tload("res://|||/{}.gd").modify_object(;;;)\n'.replace("|||", get_object_folder(argument.type)).replace("{}", argument.type).replace(
									";;;", argument.name
								)
						data_to_save += "\t\t\tpass\n"

				var string_new_arguments: String = ""
				for j in range(arguments.size()):
					if arguments[j].name.empty():
						string_new_arguments += arguments[j].value
					else:
						string_new_arguments += arguments[j].name
					if j != (arguments.size() - 1):
						string_new_arguments += ", "

				data_to_save += "\t\t" + object_name + "." + class_data.function_names[i] + "(" + string_new_arguments + ")\n"

				# Delete all temporary objects
				for argument in arguments:
					if argument.is_only_node:
						data_to_save += "\t\t" + argument.name + ".queue_free()\n"
					elif argument.is_only_object:
						data_to_save += "\t\t" + argument.name + ".queue_free()\n"

				data_to_save += "\n"
		data_to_save += "\tpass\n\n"

		if can_be_instanced && !ClassDB.is_parent_class(class_data.name, "Node") && !ClassDB.is_parent_class(class_data.name, "Reference"):
			data_to_save += "func _exit_tree() -> void:\n"
			data_to_save += "\t" + object_name + ".free()\n"

		assert(file.open(file_name, File.WRITE) == OK)
		file.store_string(data_to_save)


func create_self_scene() -> void:
	var scene: File = File.new()
	assert(scene.open("res://GDScript/Self.tscn", File.WRITE) == OK)
	var data_to_save: String = """[gd_scene load_steps=2 format=2]
[ext_resource path=\"res://Self.gd\" type=\"Script\" id=1]
[node name=\"Self\" type=\"Node\"]
script = ExtResource( 1 )"""
	scene.store_string(data_to_save)

	assert(scene.open("res://GDScript/Self.gd", File.WRITE) == OK)
	data_to_save = """extends Node
var number_of_nodes : int = 0
var collected_nodes : Array = []
var disabled_classes : Array = [
	"ReflectionProbe", # Cause errors, not sure about it
] # Just add name of any class if cause problems
func collect() -> void:
	var classes : Array = ClassDB.get_class_list()
	classes.sort()
	for name_of_class in classes:
		if ClassDB.is_parent_class(name_of_class,"Node"):
			if name_of_class.find("Editor") != -1: # We don't want to test editor nodes
				continue
			if disabled_classes.has(name_of_class): # Class is disabled
				continue
			if ClassDB.can_instance(name_of_class): # Only instantable nodes can be used
				collected_nodes.append(name_of_class)
func _ready() -> void:
	seed(405)
	collect()
	number_of_nodes = max(collected_nodes.size(),200) # Use at least all nodes, or more if you want(168 is probably number nodes)
	for i in range(number_of_nodes): 
		var index = i
		if i >= collected_nodes.size(): # Wrap values
			index = i % collected_nodes.size()
		
		var child : Node = get_special_node(collected_nodes[index])
		child.set_name("Special Node " + str(i))
		add_child(child)
func _process(delta: float) -> void:
#	assert(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT) == 0) # Don't work good with running more than 1 this scene
	
	var choosen_node : Node
	var parent_of_node : Node
	for i in range(5):
		var number : String = "Special Node " + str(randi() % number_of_nodes)
		choosen_node = find_node(number,true,false)
		parent_of_node = choosen_node.get_parent()
		
		var random_node = find_node("Special Node " + str(randi() % number_of_nodes),true,false)
		parent_of_node.remove_child(choosen_node)
		
		if randi() % 6 == 0: # 16% chance to remove node with children
			var names_to_remove : Array = find_all_special_children_names(choosen_node)
			for name_to_remove in names_to_remove:
				var node : Node = get_special_node(collected_nodes[randi() % collected_nodes.size()])
				node.set_name(name_to_remove)
				add_child(node)
			choosen_node.queue_free()
			continue
		
		
		if choosen_node.find_node(random_node.get_name(),true,false) != null: # Cannot set as node parent one of its child
			add_child(choosen_node)
			continue
		if choosen_node == random_node: # Do not reparent node to self
			add_child(choosen_node)
			continue
		random_node.add_child(choosen_node)
# Finds recusivelly all child nodes which are not internal
func find_all_special_children_names(node : Node) -> Array:
	var array : Array = []
	array.append(node.get_name())
	for child in node.get_children():
		if String(child.get_name()).begins_with("Special Node"):
			array.append_array(find_all_special_children_names(child))
	
	return array
func get_special_node(var name_of_class : String) -> Node:
	assert(ClassDB.can_instance(name_of_class))
	assert(ClassDB.is_parent_class(name_of_class, "Node"))
	var node : Node = ClassDB.instance(name_of_class)
	node.set_script(load("res://Self/" + name_of_class + ".gd"))
	return node
	"""
	scene.store_string(data_to_save)


func _ready() -> void:
	ValueCreator.number = 10
	ValueCreator.random = true
	ValueCreator.should_be_always_valid = true  # DO NOT CHANGE, BECAUSE NON VALID VALUES WILL SHOW GDSCRIPT ERRORS!

	use_gdscript = true
	base_path = "res://GDScript/"
	base_dir = "GDScript/"

	collect_data()
	if Directory.new().dir_exists(base_path):
		remove_files_recursivelly(base_path)
	create_basic_structure()
	create_basic_files()
	create_scene_files()
	create_self_scene()
	print("Created test GDScript project")
	get_tree().quit()
