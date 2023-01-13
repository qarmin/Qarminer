extends Node


func create_basic_files() -> void:
	var file: FileAccess

	for class_data in CSharpCreateProjectBase.classes:
		var data_to_save: String = ""
		var file_name: String = CSharpCreateProjectBase.base_path

		var file_name_real: String = class_data.name + "_P"

		if ClassDB.is_parent_class(class_data.name, "Node3D"):  # TODO Fix in Godot 4.0
			file_name += "3D" + "/" + file_name_real + ".cs"
			CSharpCreateProjectBase.list_of_all_files["3D"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Node2D"):
			file_name += "2D" + "/" + file_name_real + ".cs"
			CSharpCreateProjectBase.list_of_all_files["2D"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Control"):
			file_name += "Control" + "/" + file_name_real + ".cs"
			CSharpCreateProjectBase.list_of_all_files["Control"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Node"):
			file_name += "Node" + "/" + file_name_real + ".cs"
			CSharpCreateProjectBase.list_of_all_files["Node"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Resource"):
			file_name += "Resource" + "/" + file_name_real + ".cs"
			CSharpCreateProjectBase.list_of_all_files["Resource"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "RefCounted"):
			file_name += "RefCounted" + "/" + file_name_real + ".cs"
			CSharpCreateProjectBase.list_of_all_files["RefCounted"].append(file_name)
		else:
			file_name += "Object" + "/" + file_name_real + ".cs"
			CSharpCreateProjectBase.list_of_all_files["Object"].append(file_name)

		var object_type = class_data.name.trim_prefix("_")  # Change _Directory to Directory etc
		var object_name
		if (
			ClassDB.is_parent_class(class_data.name, "Node")
			|| ClassDB.is_parent_class(class_data.name, "RefCounted")
			|| (ClassDB.is_parent_class(class_data.name, "Object") && ClassDB.class_has_method(class_data.name, "new"))
		):
			object_name = "q_" + object_type
		else:
			object_name = object_type

		### Global
		data_to_save += """using Godot;
using System;

public class <<class_name>> : Godot.Node2D
{
""".replace("<<class_name>>", class_data.name + "_P")
		if (
			ClassDB.is_parent_class(class_data.name, "Node")
			|| ClassDB.is_parent_class(class_data.name, "RefCounted")
			|| (ClassDB.is_parent_class(class_data.name, "Object") && ClassDB.class_has_method(class_data.name, "new"))
		):
			data_to_save += "\tprivate Godot.{} ||| = new Godot.{}();\n\n".replace("{}", object_type).replace("|||", object_name)

		### Ready function
		data_to_save += "\tpublic override void _Ready()\n\t{\n"
		data_to_save += "\t\tif (!Visible)\n\t\t{\n"
		data_to_save += "\t\t\tSetProcess(false);\n"
		if ClassDB.is_parent_class(class_data.name, "Node"):
			data_to_save += "\t\t\t" + object_name + ".QueueFree();\n"
		data_to_save += "\t\t\treturn;\n\t\t}\n"
		if ClassDB.is_parent_class(class_data.name, "Node"):
			data_to_save += "\t\tAddChild(" + object_name + ");\n"
		data_to_save += "\t}\n\n"

		### Process Function
		data_to_save += "\tpublic override void _Process(float _delta)\n\t{\n"

		if CSharpCreateProjectBase.allow_to_replace_old_with_new_objects:
			data_to_save += "\t\tif (GD.Randi() % 10 == 0)\n\t\t{\n"
			if ClassDB.is_parent_class(class_data.name, "Node"):
				data_to_save += "\t\t\t" + object_name + ".QueueFree();\n"
			if (
				ClassDB.is_parent_class(class_data.name, "Object")
				&& !(ClassDB.is_parent_class(class_data.name, "Resource"))
				&& !(ClassDB.is_parent_class(class_data.name, "Node"))
				&& ClassDB.class_has_method(class_data.name, "new")
			):
				data_to_save += "\t\t\t" + object_name + ".Free();\n"
			if (
				ClassDB.is_parent_class(class_data.name, "Node")
				|| ClassDB.is_parent_class(class_data.name, "RefCounted")
				|| (ClassDB.is_parent_class(class_data.name, "Object") && ClassDB.class_has_method(class_data.name, "new"))
			):
				data_to_save += "\t\t\t" + object_name + " = new Godot." + object_type + "();\n"
			if ClassDB.is_parent_class(class_data.name, "Node"):
				data_to_save += "\t\t\tAddChild(" + object_name + ");\n"
			data_to_save += "\t\t}\n\n"

		for i in range(class_data.function_names.size()):
			data_to_save += "\t\tif (GD.Randi() % 2 == 0)\n\t\t{\n"
			if CSharpCreateProjectBase.debug_in_runtime:
				data_to_save += '\t\t\tGD.Print("Executing ' + object_type + "." + class_data.function_names[i] + '");\n\n'

			var arguments := convert_arguments_to_string(class_data.arguments[i])
			var split_arguments := arguments.split(",")

			var list_of_new_arguments: Array = []  # e.g. (variable1,0,0) instead (object.new(),0,0)
			var variables_to_add: Array = []  # e.g. var variable1 = Object.new()

			var index = 0
			for j in split_arguments:
				if j.ends_with("()"):
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
				if !variables_to_add[j].is_empty():
					if variables_to_add[j].find("Collections") == -1 && variables_to_add[j].find("[]") == -1 && variables_to_add[j].find("RID()") == -1:
						assert(ClassDB.class_exists(variables_to_add[j].trim_suffix("()").trim_prefix("new Godot.")))
						data_to_save += "\t\t\t" + variables_to_add[j].trim_suffix("()").trim_prefix("new ") + " " + list_of_new_arguments[j] + " = " + variables_to_add[j] + ";\n"

			var string_new_arguments: String = ""
			for j in range(variables_to_add.size()):
				string_new_arguments += list_of_new_arguments[j]
				if j != (variables_to_add.size() - 1):
					string_new_arguments += ", "

			data_to_save += "\t\t\t" + object_name + "." + class_data.function_names[i] + "(" + string_new_arguments + ");\n"

			# Delete all temporary objects
			for j in range(variables_to_add.size()):
				if !variables_to_add[j].is_empty():
					if variables_to_add[j].find("Collections") == -1 && variables_to_add[j].find("[]") == -1 && variables_to_add[j].find("RID()") == -1:
						if ClassDB.is_parent_class(variables_to_add[j].trim_suffix("()").trim_prefix("new Godot."), "Node"):
							data_to_save += "\t\t\t" + list_of_new_arguments[j] + ".QueueFree();\n"

			data_to_save += "\t\t}\n"
		data_to_save += "\t}\n\n"

		if (
			ClassDB.is_parent_class(class_data.name, "Object")
			&& !(ClassDB.is_parent_class(class_data.name, "Resource"))
			&& !(ClassDB.is_parent_class(class_data.name, "Node"))
			&& ClassDB.class_has_method(class_data.name, "new")
		):
			data_to_save += "public override void _ExitTree()\n\t{\n"
			data_to_save += "\t\t" + object_name + ".Free();\n"
			data_to_save += "\t}\n"

		data_to_save += "}"

		file = FileAccess.open(file_name, FileAccess.WRITE)
		file.store_string(data_to_save)


func convert_arguments_to_string(arguments: Array) -> String:
	var return_string: String = ""

	CSharpValueCreator.number = 100
	CSharpValueCreator.random = false
	CSharpValueCreator.should_be_always_valid = true  # DO NOT CHANGE, BECAUSE NON VALID VALUES WILL SHOW GDSCRIPT ERRORS!

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
				return_string += CSharpValueCreator.get_aabb_string_csharp()
			TYPE_ARRAY:
				return_string += "Godot.Collections.Array<int>()"
			TYPE_BASIS:
				return_string += CSharpValueCreator.get_basis_string_csharp()
			TYPE_BOOL:
				return_string += CSharpValueCreator.get_bool_string().to_lower()
			TYPE_COLOR:
				return_string += CSharpValueCreator.get_color_string_csharp()
			TYPE_PACKED_COLOR_ARRAY:
				return_string += "Godot.Collections.Array<Color>()"
			TYPE_DICTIONARY:
				return_string += "new Godot.Collections.Dictionary()"
			TYPE_INT:
				return_string += CSharpValueCreator.get_int_string()
			TYPE_PACKED_INT32_ARRAY:
				return_string += "Godot.Collections.Array<int>()"
			TYPE_NODE_PATH:
				return_string += 'NodePath(".")'
			TYPE_OBJECT:
				return_string += "new Godot." + CSharpValueCreator.get_object_string(argument["class_name"]) + "()"
			TYPE_PLANE:
				return_string += CSharpValueCreator.get_plane_string_csharp()
			TYPE_QUATERNION:
				return_string += CSharpValueCreator.get_quat_string_csharp()
			TYPE_PACKED_BYTE_ARRAY:
				return_string += "Godot.Collections.Array<byte>()"
			TYPE_FLOAT:
				return_string += CSharpValueCreator.get_float_string()
			TYPE_PACKED_FLOAT32_ARRAY:
				return_string += "Godot.Collections.Array<float>()"
			TYPE_RECT2:
				return_string += CSharpValueCreator.get_rect2_string_csharp()
			TYPE_RID:
				return_string += "RID()"
			TYPE_STRING:
				return_string += CSharpValueCreator.get_string_string()
			TYPE_PACKED_STRING_ARRAY:
				return_string += "Godot.Collections.Array<String>()"
			TYPE_TRANSFORM3D:
				return_string += CSharpValueCreator.get_transform_string_csharp()
			TYPE_TRANSFORM2D:
				return_string += CSharpValueCreator.get_transform2d_string_csharp()
			TYPE_VECTOR2:
				return_string += CSharpValueCreator.get_vector2_string_csharp()
			TYPE_PACKED_VECTOR2_ARRAY:
				return_string += "Godot.Collections.Array<Vector2>()"
			TYPE_VECTOR3:
				return_string += CSharpValueCreator.get_vector3_string_csharp()
			TYPE_PACKED_VECTOR3_ARRAY:
				return_string += "Godot.Collections.Array<Vector3>()"
			_:
				assert(false)  # Missed some types, add it

		argument_number += 1

	return return_string


func _ready() -> void:
	CSharpValueCreator.number = 10
	CSharpValueCreator.random = true
	CSharpValueCreator.should_be_always_valid = true  # DO NOT CHANGE, BECAUSE NON VALID VALUES WILL SHOW C# ERRORS!

	CSharpCreateProjectBase.use_gdscript = false
	CSharpCreateProjectBase.base_path = "res://CSharp/"
	CSharpCreateProjectBase.base_dir = "CSharp/"

	CSharpCreateProjectBase.collect_data()
	if DirAccess.open("res://").dir_exists(CSharpCreateProjectBase.base_path):
		CSharpCreateProjectBase.remove_files_recursivelly(CSharpCreateProjectBase.base_path)
	CSharpCreateProjectBase.create_basic_structure()
	create_basic_files()
	CSharpCreateProjectBase.create_scene_files()
	print("Created test C# project")
	get_tree().quit()
