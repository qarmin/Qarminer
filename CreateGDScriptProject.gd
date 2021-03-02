extends Node

var number_of_external_resources : int = 4

func object_type(name_of_class  : String) -> String:
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
		
	assert(false)
	return "WHAT"

func create_basic_files() -> void:
	var file: File = File.new()

	for class_data in CreateProjectBase.classes:
		var data_to_save: String = ""
		var file_name: String = CreateProjectBase.base_path

		var prefix = object_type(class_data.name)
		file_name += prefix + "/" + class_data.name + ".gd"
		CreateProjectBase.list_of_all_files[prefix].append(file_name)

		var object_type = class_data.name.trim_prefix("_")  # Change _Directory to Directory etc
		var can_be_instanced : bool
		var object_name
		if (
			ClassDB.is_parent_class(class_data.name, "Node")
			|| ClassDB.is_parent_class(class_data.name, "Reference")
			|| (ClassDB.is_parent_class(class_data.name, "Object") && ClassDB.class_has_method(class_data.name, "new"))
		):
			object_name = "q_" + object_type
			can_be_instanced = true
		else:
			object_name = object_type
			can_be_instanced = false
			
		
		### Global
		data_to_save += "extends Node2D\n\n"
		if can_be_instanced:
			data_to_save += "var ||| : {} = {}.new()\n\n".replace("{}", object_type).replace("|||", object_name)

		### Ready function
		data_to_save += "func _ready() -> void:\n"
		data_to_save += "\tif !is_visible():\n"
		data_to_save += "\t\tset_process(false)\n"
		if ClassDB.is_parent_class(class_data.name, "Node"):
			data_to_save += "\t\t" + object_name + ".queue_free()\n"
		data_to_save += "\t\treturn\n\n"
		if ClassDB.is_parent_class(class_data.name, "Node"):
			data_to_save += "\tadd_child(" + object_name + ")\n\n"

		### Process Function
		data_to_save += "func _process(_delta : float) -> void:\n"

		if CreateProjectBase.allow_to_replace_old_with_new_objects:
			if can_be_instanced:
				data_to_save += "\tif randi() % 10 == 0:\n"
			if ClassDB.is_parent_class(class_data.name, "Node"):
				data_to_save += "\t\t" + object_name + ".queue_free()\n"
			if (
				can_be_instanced
				&& !(ClassDB.is_parent_class(class_data.name, "Resource"))
				&& !(ClassDB.is_parent_class(class_data.name, "Node"))
			):
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
		if can_be_instanced:
			data_to_save += "static func modify_object(||| : {}) -> void:\n".replace("{}", object_type).replace("|||", object_name)
		else:
			data_to_save += "static func modify_object() -> void:\n"

		for i in range(class_data.function_names.size()):
			var function_use_objects : bool = false
		
			data_to_save += "\tif randi() % 2 == 0:\n"
			if CreateProjectBase.debug_in_runtime:
				data_to_save += "\t\tprint(\"Executing " + object_type + "." + class_data.function_names[i] + "\")\n"

			var arguments := convert_arguments_to_string(class_data.arguments[i])

			var list_of_new_arguments: Array = []  # e.g. (variable1,0,0) instead (object.new(),0,0)
			var variables_to_add: Array = []  # e.g. var variable1 = Object.new()

			var index = 0
			for j in arguments:
				if j.ends_with(".new()"):
					# Means that argument is an object
					function_use_objects = true
					var new_variable_name = "p_object_" + str(index)
					index += 1
					list_of_new_arguments.append(new_variable_name)
					variables_to_add.append(j.strip_edges().trim_suffix(".new()"))
				else:
					list_of_new_arguments.append(j.strip_edges())
					variables_to_add.append("")

			assert(list_of_new_arguments.size() == variables_to_add.size())
			# Create temporary objects
			for j in variables_to_add.size():
				if !variables_to_add[j].empty():
					assert(ClassDB.class_exists(variables_to_add[j]))
					if ClassDB.is_parent_class(variables_to_add[j], "Resource") && CreateProjectBase.use_loaded_resources:
						data_to_save += "\t\tvar " + list_of_new_arguments[j] + " = load(\"res://Resources/" + variables_to_add[j] + ".res\")\n"
					else:
						data_to_save += "\t\tvar " + list_of_new_arguments[j] + " = " + variables_to_add[j] + ".new()\n"
			# Apply data
			if function_use_objects:
				if number_of_external_resources > 0:
					data_to_save += "\t\tfor _i in range(|||):\n".replace("|||",str(number_of_external_resources))
					for j in variables_to_add.size():
						if !variables_to_add[j].empty():
							data_to_save += "\t\t\tload(\"res://|||/{}.gd\").modify_object(;;;)\n".replace("|||",object_type(variables_to_add[j])).replace("{}",variables_to_add[j]).replace(";;;",list_of_new_arguments[j])


			var string_new_arguments: String = ""
			for j in range(variables_to_add.size()):
				string_new_arguments += list_of_new_arguments[j]
				if j != (variables_to_add.size() - 1):
					string_new_arguments += ", "

			data_to_save += "\t\t" + object_name + "." + class_data.function_names[i] + "(" + string_new_arguments + ")\n"

			# Delete all temporary objects
			for j in range(variables_to_add.size()):
				if !variables_to_add[j].empty():
					if ClassDB.is_parent_class(variables_to_add[j], "Node"):
						data_to_save += "\t\t" + list_of_new_arguments[j] + ".queue_free()\n"

			data_to_save += "\n"
		data_to_save += "\tpass\n\n"

		if can_be_instanced:
			data_to_save += "func _exit_tree() -> void:\n"
			data_to_save += "\t" + object_name + ".free()\n"

		assert(file.open(file_name, File.WRITE) == OK)
		file.store_string(data_to_save)


func convert_arguments_to_string(arguments: Array) -> PoolStringArray:
	var return_array: PoolStringArray = PoolStringArray([])

	ValueCreator.number = 100
	ValueCreator.random = true
	ValueCreator.should_be_always_valid = true  # DO NOT CHANGE, BECAUSE NON VALID VALUES WILL SHOW GDSCRIPT ERRORS!

	var argument_number: int = 0

	for argument in arguments:
		match argument["type"]:
			TYPE_NIL:  # Looks that this means VARIANT not null
				return_array.append("false")  # TODO add some randomization
			TYPE_MAX:
				assert(false)
			TYPE_AABB:
				return_array.append(ValueCreator.get_aabb_string())
			TYPE_ARRAY:
				return_array.append("[]")
			TYPE_BASIS:
				return_array.append(ValueCreator.get_basis_string())
			TYPE_BOOL:
				return_array.append(ValueCreator.get_bool_string().to_lower())
			TYPE_COLOR:
				return_array.append(ValueCreator.get_color_string())
			TYPE_COLOR_ARRAY:
				return_array.append("PoolColorArray([])")
			TYPE_DICTIONARY:
				return_array.append("{}")
			TYPE_INT:
				return_array.append(ValueCreator.get_int_string())
			TYPE_INT_ARRAY:
				return_array.append("PoolIntArray([])")
			TYPE_NODE_PATH:
				return_array.append("NodePath(\".\")")
			TYPE_OBJECT:
				return_array.append(ValueCreator.get_object_string(argument["class_name"]) + ".new()")
			TYPE_PLANE:
				return_array.append(ValueCreator.get_plane_string())
			TYPE_QUAT:
				return_array.append(ValueCreator.get_quat_string())
			TYPE_RAW_ARRAY:
				return_array.append("PoolByteArray([])")
			TYPE_REAL:
				return_array.append(ValueCreator.get_float_string())
			TYPE_REAL_ARRAY:
				return_array.append("PoolRealArray([])")
			TYPE_RECT2:
				return_array.append(ValueCreator.get_rect2_string())
			TYPE_RID:
				return_array.append("RID()")
			TYPE_STRING:
				return_array.append(ValueCreator.get_string_string())
			TYPE_STRING_ARRAY:
				return_array.append("PoolStringArray([])")
			TYPE_TRANSFORM:
				return_array.append(ValueCreator.get_transform_string())
			TYPE_TRANSFORM2D:
				return_array.append(ValueCreator.get_transform2D_string())
			TYPE_VECTOR2:
				return_array.append(ValueCreator.get_vector2_string())
			TYPE_VECTOR2_ARRAY:
				return_array.append("PoolVector2Array([])")
			TYPE_VECTOR3:
				return_array.append(ValueCreator.get_vector3_string())
			TYPE_VECTOR3_ARRAY:
				return_array.append("PoolVector3Array([])")
			_:
				assert(false)  # Missed some types, add it

		argument_number += 1

	return return_array


func _ready() -> void:
	CreateProjectBase.use_gdscript = true
	CreateProjectBase.base_path = "res://GDScript/"
	CreateProjectBase.base_dir = "GDScript/"

	CreateProjectBase.collect_data()
	if Directory.new().dir_exists(CreateProjectBase.base_path):
		CreateProjectBase.remove_files_recursivelly(CreateProjectBase.base_path)
	CreateProjectBase.create_basic_structure()
	create_basic_files()
	CreateProjectBase.create_scene_files()
	print("Created test GDScript project")
	get_tree().quit()
