extends Node


func create_basic_files() -> void:
	var file: File = File.new()

	for class_data in CreateProjectBase.classes:
		var data_to_save: String = ""
		var file_name: String = CreateProjectBase.base_path

		if ClassDB.is_parent_class(class_data.name, "Node3D"):  # TODO Fix in Godot 4.0
			file_name += "3D" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files.get("3D").append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Node2D"):
			file_name += "2D" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files.get("2D").append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Control"):
			file_name += "Control" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files.get("Control").append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Node"):
			file_name += "Node" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files.get("Node").append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Resource"):
			file_name += "Resource" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files.get("Resource").append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Reference"):
			file_name += "Reference" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files.get("Reference").append(file_name)
		else:
			file_name += "Object" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files.get("Object").append(file_name)

		var object_type = class_data.name.trim_prefix("_")  # Change _Directory to Directory etc
		var object_name
		if (
			ClassDB.is_parent_class(class_data.name, "Node")
			|| ClassDB.is_parent_class(class_data.name, "Reference")
			|| (ClassDB.is_parent_class(class_data.name, "Object") && ClassDB.class_has_method(class_data.name, "new"))
		):
			object_name = "q_" + object_type
		else:
			object_name = object_type

		### Global
		data_to_save += "extends Node2D\n\n"
		if (
			ClassDB.is_parent_class(class_data.name, "Node")
			|| ClassDB.is_parent_class(class_data.name, "Reference")
			|| (ClassDB.is_parent_class(class_data.name, "Object") && ClassDB.class_has_method(class_data.name, "new"))
		):
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
			data_to_save += "\tif randi() % 10 == 0:\n"
			if ClassDB.is_parent_class(class_data.name, "Node"):
				data_to_save += "\t\t" + object_name + ".queue_free()\n"
			if (
				ClassDB.is_parent_class(class_data.name, "Object")
				&& ! (ClassDB.is_parent_class(class_data.name, "Resource"))
				&& ! (ClassDB.is_parent_class(class_data.name, "Node"))
				&& ClassDB.class_has_method(class_data.name, "new")
			):
				data_to_save += "\t\t" + object_name + ".free()\n"
			if (
				ClassDB.is_parent_class(class_data.name, "Node")
				|| ClassDB.is_parent_class(class_data.name, "Reference")
				|| (ClassDB.is_parent_class(class_data.name, "Object") && ClassDB.class_has_method(class_data.name, "new"))
			):
				data_to_save += "\t\t" + object_name + " = " + object_type + ".new()\n"
			if ClassDB.is_parent_class(class_data.name, "Node"):
				data_to_save += "\t\tadd_child(" + object_name + ")\n"
			data_to_save += "\t\tpass\n\n"

		for i in range(class_data.function_names.size()):
			data_to_save += "\tif randi() % 2 == 0:\n"
			if CreateProjectBase.debug_in_runtime:
				data_to_save += "\t\tprint(\"Executing " + object_type + "." + class_data.function_names[i] + "\")\n\n"
			
			var arguments := convert_arguments_to_string(class_data.arguments[i])
			var split_arguments := arguments.split(",")

			var list_of_new_arguments: Array = []  # e.g. (variable1,0,0) instead (object.new(),0,0)
			var variables_to_add: Array = []  # e.g. var variable1 = Object.new()

			var index = 0
			for j in split_arguments:
				if j.ends_with(".new()"):
					# Means that argument is an object
					var new_variable_name = "p_object_" + str(index)
					index += 1
					list_of_new_arguments.append(new_variable_name)
					variables_to_add.append(j.strip_edges())
				else:
					list_of_new_arguments.append(j.strip_edges())
					variables_to_add.append("")
			assert(list_of_new_arguments.size() == variables_to_add.size())
			# Create temporary objects
			for j in variables_to_add.size():
				if variables_to_add[j].length() > 0:
					assert(ClassDB.class_exists(variables_to_add[j].trim_suffix(".new()")))
					data_to_save += "\t\tvar " + list_of_new_arguments[j] + " = " + variables_to_add[j] + "\n"

			var string_new_arguments: String = ""
			for j in range(variables_to_add.size()):
				string_new_arguments += list_of_new_arguments[j]
				if j != (variables_to_add.size() - 1):
					string_new_arguments += ", "

			data_to_save += "\t\t" + object_name + "." + class_data.function_names[i] + "(" + string_new_arguments + ")\n"

			# Delete all temporary objects
			for j in range(variables_to_add.size()):
				if variables_to_add[j].length() > 0:
					if ClassDB.is_parent_class(variables_to_add[j].trim_suffix(".new()"), "Node"):
						data_to_save += "\t\t" + list_of_new_arguments[j] + ".queue_free()\n"

			data_to_save += "\n"
		data_to_save += "\tpass\n\n"

		if (
			ClassDB.is_parent_class(class_data.name, "Object")
			&& ! (ClassDB.is_parent_class(class_data.name, "Resource"))
			&& ! (ClassDB.is_parent_class(class_data.name, "Node"))
			&& ClassDB.class_has_method(class_data.name, "new")
		):
			data_to_save += "func _exit_tree() -> void:\n"
			data_to_save += "\t" + object_name + ".free()\n"

		assert(file.open(file_name, File.WRITE) == OK)
		file.store_string(data_to_save)


func convert_arguments_to_string(arguments : Array) -> String:
	var return_string : String = ""
	
	ValueCreator.number = 100
	ValueCreator.random = true
	ValueCreator.should_be_always_valid = true
	
	
	var argument_number : int = 0
	
	for argument in arguments:
		
		var typ = argument.get("type")
		
		if argument_number != 0:
			return_string += ", "
		if typ == TYPE_NIL: # Looks that this means VARIANT not null
				return_string += "false" # TODO aadd some randomization
#				assert(false)
		elif typ ==TYPE_MAX:
				assert(false)
		elif typ ==TYPE_AABB:
				return_string += ValueCreator.get_aabb_string()
		elif typ ==TYPE_ARRAY:
				return_string += "[]"
		elif typ ==TYPE_BASIS:
				return_string += ValueCreator.get_basis_string()
		elif typ ==TYPE_BOOL:
				return_string += ValueCreator.get_bool_string()
		elif typ ==TYPE_COLOR:
				return_string += ValueCreator.get_color_string()
		elif typ ==TYPE_COLOR_ARRAY:
				return_string += "PackedColorArray([])"
		elif typ ==TYPE_DICTIONARY:
				return_string += "{}"
		elif typ ==TYPE_INT:
				return_string += ValueCreator.get_int_string()
		elif typ ==TYPE_INT32_ARRAY:
				return_string += "PackedInt32Array([])"
		elif typ ==TYPE_INT64_ARRAY:
				return_string += "PackedInt64Array([])"
		elif typ ==TYPE_NODE_PATH:
				return_string += "NodePath(\".\")"
		elif typ ==TYPE_OBJECT:
				return_string += String(ValueCreator.get_object_string(argument.get("class_name")) + String(".new()"))
		elif typ ==TYPE_PLANE:
				return_string += ValueCreator.get_plane_string()
		elif typ ==TYPE_QUAT:
				return_string += ValueCreator.get_quat_string()
		elif typ ==TYPE_RAW_ARRAY:
				return_string += "PackedByteArray([])"
		elif typ ==TYPE_FLOAT:
				return_string += ValueCreator.get_float_string()
		elif typ ==TYPE_FLOAT32_ARRAY:
				return_string += "PackedFloat32Array([])"
		elif typ ==TYPE_FLOAT64_ARRAY:
				return_string += "PackedFloat64Array([])"
		elif typ ==TYPE_RECT2:
				return_string += ValueCreator.get_rect2_string()
		elif typ ==TYPE_RID:
				return_string += "RID()"
		elif typ ==TYPE_STRING:
				return_string += ValueCreator.get_string_string()
		elif typ ==TYPE_STRING_NAME:
				return_string += ValueCreator.get_string_string()
		elif typ ==TYPE_STRING_ARRAY:
				return_string += "PackedStringArray([])"
		elif typ ==TYPE_TRANSFORM:
				return_string += ValueCreator.get_transform_string()
		elif typ ==TYPE_TRANSFORM2D:
				return_string += ValueCreator.get_transform2D_string()
		elif typ ==TYPE_VECTOR2:
				return_string += ValueCreator.get_vector2_string()
		elif typ ==TYPE_VECTOR2_ARRAY:
				return_string += "PackedVector2Array([])"
		elif typ ==TYPE_VECTOR2I:
				return_string += ValueCreator.get_vector2i_string()
		elif typ ==TYPE_VECTOR3:
				return_string += ValueCreator.get_vector3_string()
		elif typ ==TYPE_VECTOR3_ARRAY:
				return_string += "PackedVector3Array([])"
		elif typ ==TYPE_VECTOR3I:
				return_string += ValueCreator.get_vector3i_string()
		elif typ ==TYPE_RECT2I:
				return_string += ValueCreator.get_rect2i_string()
		elif typ ==TYPE_CALLABLE:
				assert(false) # Currently not supported
		else:
			print("Missing " + str(argument) )
			assert(false) # Missed some types, add it
				
		argument_number += 1
		
	return return_string


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
