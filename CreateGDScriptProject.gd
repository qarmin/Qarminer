extends Node


		



func create_basic_files() -> void:
	var file: File = File.new()
	
	for class_data in CreateProjectBase.classes:
		var data_to_save: String = ""
		var file_name: String = CreateProjectBase.base_path

		if ClassDB.is_parent_class(class_data.name, "Spatial"):  # TODO Fix in Godot 4.0
			file_name += "3D" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files["3D"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Node2D"):
			file_name += "2D" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files["2D"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Control"):
			file_name += "Control" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files["Control"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Node"):
			file_name += "Node" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files["Node"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Resource"):
			file_name += "Resource" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files["Resource"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Reference"):
			file_name += "Reference" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files["Reference"].append(file_name)
		else:
			file_name += "Object" + "/" + class_data.name + ".gd"
			CreateProjectBase.list_of_all_files["Object"].append(file_name)

		var object_type = class_data.name.trim_prefix("_")  # Change _Directory to Directory etc
		var object_name
		if ClassDB.is_parent_class(class_data.name, "Node") || ClassDB.is_parent_class(class_data.name, "Reference") || (ClassDB.is_parent_class(class_data.name,"Object") && ClassDB.class_has_method(class_data.name, "new")):
			object_name = "q_" + object_type
		else:
			object_name = object_type
		
		### Global
		data_to_save += "extends Node2D\n\n"
		if ClassDB.is_parent_class(class_data.name, "Node") || ClassDB.is_parent_class(class_data.name, "Reference") || (ClassDB.is_parent_class(class_data.name,"Object") && ClassDB.class_has_method(class_data.name, "new")):
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
			if (ClassDB.is_parent_class(class_data.name,"Object") && !(ClassDB.is_parent_class(class_data.name,"Resource")) && !(ClassDB.is_parent_class(class_data.name,"Node")) && ClassDB.class_has_method(class_data.name, "new")):
				data_to_save += "\t\t" + object_name + ".free()\n"
			if ClassDB.is_parent_class(class_data.name, "Node") || ClassDB.is_parent_class(class_data.name, "Reference") || (ClassDB.is_parent_class(class_data.name,"Object") && ClassDB.class_has_method(class_data.name, "new")):
				data_to_save +=  "\t\t" + object_name + " = " + object_type + ".new()\n"
			if ClassDB.is_parent_class(class_data.name, "Node"):
				data_to_save += "\t\tadd_child(" + object_name + ")\n"
			data_to_save += "\t\tpass\n\n"
			
		
		for i in range(class_data.function_names.size()):
			data_to_save += "\tif randi() % 2 == 0:\n"
			if CreateProjectBase.debug_in_runtime:
				data_to_save += "\t\tprint(\"Executing " + object_type + "." + class_data.function_names[i] + "\")\n\n"
				
			var arguments := convert_arguments_to_string(class_data.arguments[i])
			var split_arguments := arguments.split(",")
			
			var list_of_new_arguments :Array= [] # e.g. (variable1,0,0) instead (object.new(),0,0)
			var variables_to_add : Array= [] # e.g. var variable1 = Object.new()
			
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
				if !variables_to_add[j].empty():
					assert(ClassDB.class_exists(variables_to_add[j].trim_suffix(".new()")))
					data_to_save += "\t\tvar " + list_of_new_arguments[j] + " = " + variables_to_add[j] + "\n"
					
			var string_new_arguments : String = ""
			for j in range(variables_to_add.size()):
				string_new_arguments += list_of_new_arguments[j]
				if j != (variables_to_add.size() - 1):
					string_new_arguments += ", "
				
			data_to_save += "\t\t" + object_name + "." + class_data.function_names[i] + "(" + string_new_arguments + ")\n"
			
			# Delete all temporary objects
			for j in range(variables_to_add.size()):
				if !variables_to_add[j].empty():
					if ClassDB.is_parent_class(variables_to_add[j].trim_suffix(".new()"),"Node"):
						data_to_save += "\t\t" + list_of_new_arguments[j] + ".queue_free()\n"
						
			data_to_save += "\n"
		data_to_save += "\tpass\n\n"
		
		if (ClassDB.is_parent_class(class_data.name,"Object") && !(ClassDB.is_parent_class(class_data.name,"Resource")) && !(ClassDB.is_parent_class(class_data.name,"Node")) && ClassDB.class_has_method(class_data.name, "new")):
			data_to_save += "func _exit_tree() -> void:\n"
			data_to_save += "\t" + object_name  + ".free()\n"
			

		assert(file.open(file_name, File.WRITE) == OK)
		file.store_string(data_to_save)


func convert_arguments_to_string(arguments: Array) -> String:
	var return_string: String = ""

	ValueCreator.number = 100
	ValueCreator.random = true
	ValueCreator.should_be_always_valid = true # DO NOT CHANGE, BECAUSE NON VALID VALUES WILL SHOW GDSCRIPT ERRORS!

	var argument_number: int = 0

	for argument in arguments:
		if argument_number != 0:
			return_string += ", "
		match argument["type"]:
			TYPE_NIL:  # Looks that this means VARIANT not null
				return_string += "false"  # TODO add some randomization
			TYPE_MAX:
				assert(false)
			TYPE_AABB:
				return_string += ValueCreator.get_aabb_string()
			TYPE_ARRAY:
				return_string += "[]"
			TYPE_BASIS:
				return_string += ValueCreator.get_basis_string()
			TYPE_BOOL:
				return_string += ValueCreator.get_bool_string().to_lower()
			TYPE_COLOR:
				return_string += ValueCreator.get_color_string()
			TYPE_COLOR_ARRAY:
				return_string += "PoolColorArray([])"
			TYPE_DICTIONARY:
				return_string += "{}"
			TYPE_INT:
				return_string += ValueCreator.get_int_string()
			TYPE_INT_ARRAY:
				return_string += "PoolIntArray([])"
			TYPE_NODE_PATH:
				return_string += "NodePath(\".\")"
			TYPE_OBJECT:
				return_string += ValueCreator.get_object_string(argument["class_name"]) + ".new()" 
			TYPE_PLANE:
				return_string += ValueCreator.get_plane_string()
			TYPE_QUAT:
				return_string += ValueCreator.get_quat_string()
			TYPE_RAW_ARRAY:
				return_string += "PoolByteArray([])"
			TYPE_REAL:
				return_string += ValueCreator.get_float_string()
			TYPE_REAL_ARRAY:
				return_string += "PoolRealArray([])"
			TYPE_RECT2:
				return_string += ValueCreator.get_rect2_string()
			TYPE_RID:
				return_string += "RID()"
			TYPE_STRING:
				return_string += ValueCreator.get_string_string()
			TYPE_STRING_ARRAY:
				return_string += "PoolStringArray([])"
			TYPE_TRANSFORM:
				return_string += ValueCreator.get_transform_string()
			TYPE_TRANSFORM2D:
				return_string += ValueCreator.get_transform2D_string()
			TYPE_VECTOR2:
				return_string += ValueCreator.get_vector2_string()
			TYPE_VECTOR2_ARRAY:
				return_string += "PoolVector2Array([])"
			TYPE_VECTOR3:
				return_string += ValueCreator.get_vector3_string()
			TYPE_VECTOR3_ARRAY:
				return_string += "PoolVector3Array([])"
			_:
				assert(false)  # Missed some types, add it

		argument_number += 1

	return return_string



func _ready() -> void:
#	test_normalize_function()
	CreateProjectBase.collect_data()
	if Directory.new().dir_exists(CreateProjectBase.base_path):
		CreateProjectBase.remove_files_recursivelly(CreateProjectBase.base_path)
	CreateProjectBase.create_basic_structure()
	create_basic_files()
	CreateProjectBase.create_scene_files()
	print("Created test GDScript project")
