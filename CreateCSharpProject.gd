extends Node


func create_basic_files() -> void:
	var file: File = File.new()

	for class_data in CreateProjectBase.classes:
		var data_to_save: String = ""
		var file_name: String = CreateProjectBase.base_path

		if ClassDB.is_parent_class(class_data.name, "Spatial"):  # TODO Fix in Godot 4.0
			file_name += "3D" + "/" + class_data.name + ".cs"
			CreateProjectBase.list_of_all_files["3D"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Node2D"):
			file_name += "2D" + "/" + class_data.name + ".cs"
			CreateProjectBase.list_of_all_files["2D"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Control"):
			file_name += "Control" + "/" + class_data.name + ".cs"
			CreateProjectBase.list_of_all_files["Control"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Node"):
			file_name += "Node" + "/" + class_data.name + ".cs"
			CreateProjectBase.list_of_all_files["Node"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Resource"):
			file_name += "Resource" + "/" + class_data.name + ".cs"
			CreateProjectBase.list_of_all_files["Resource"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name, "Reference"):
			file_name += "Reference" + "/" + class_data.name + ".cs"
			CreateProjectBase.list_of_all_files["Reference"].append(file_name)
		else:
			file_name += "Object" + "/" + class_data.name + ".cs"
			CreateProjectBase.list_of_all_files["Object"].append(file_name)

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
		data_to_save += """using Godot;
using System;

public class Node2D : Godot.Node2D
{
"""
		if (
			ClassDB.is_parent_class(class_data.name, "Node")
			|| ClassDB.is_parent_class(class_data.name, "Reference")
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

		if CreateProjectBase.allow_to_replace_old_with_new_objects:
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
				|| ClassDB.is_parent_class(class_data.name, "Reference")
				|| (ClassDB.is_parent_class(class_data.name, "Object") && ClassDB.class_has_method(class_data.name, "new"))
			):
				data_to_save += "\t\t\t" + object_name + " = new Godot." + object_type + "();\n"
			if ClassDB.is_parent_class(class_data.name, "Node"):
				data_to_save += "\t\t\tAddChild(" + object_name + ");\n"
			data_to_save += "\t\t}\n\n"

		for i in range(class_data.function_names.size()):
			data_to_save += "\t\tif (GD.Randi() % 2 == 0)\n\t\t{\n"
			if CreateProjectBase.debug_in_runtime:
				data_to_save += "\t\t\tGD.Print(\"Executing " + object_type + "." + class_data.function_names[i] + "\");\n\n"

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
				if !variables_to_add[j].empty():
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
				if !variables_to_add[j].empty():
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

		assert(file.open(file_name, File.WRITE) == OK)
		file.store_string(data_to_save)


func convert_arguments_to_string(arguments: Array) -> String:
	var return_string: String = ""

	ValueCreator.number = 100
	ValueCreator.random = false
	ValueCreator.should_be_always_valid = true  # DO NOT CHANGE, BECAUSE NON VALID VALUES WILL SHOW GDSCRIPT ERRORS!

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
				return_string += ValueCreator.get_aabb_string_csharp()
			TYPE_ARRAY:
				return_string += "Godot.Collections.Array<int>()"
			TYPE_BASIS:
				return_string += ValueCreator.get_basis_string_csharp()
			TYPE_BOOL:
				return_string += ValueCreator.get_bool_string().to_lower()
			TYPE_COLOR:
				return_string += ValueCreator.get_color_string_csharp()
			TYPE_COLOR_ARRAY:
				return_string += "Color[]"
			TYPE_DICTIONARY:
				return_string += "{}"
			TYPE_INT:
				return_string += ValueCreator.get_int_string()
			TYPE_INT_ARRAY:
				return_string += "int[]"
			TYPE_NODE_PATH:
				return_string += "NodePath(\".\")"
			TYPE_OBJECT:
				return_string += "new Godot." + ValueCreator.get_object_string(argument["class_name"]) + "()"
			TYPE_PLANE:
				return_string += ValueCreator.get_plane_string_csharp()
			TYPE_QUAT:
				return_string += ValueCreator.get_quat_string_csharp()
			TYPE_RAW_ARRAY:
				return_string += "byte[]"
			TYPE_REAL:
				return_string += ValueCreator.get_float_string()
			TYPE_REAL_ARRAY:
				return_string += "float[]"
			TYPE_RECT2:
				return_string += ValueCreator.get_rect2_string_csharp()
			TYPE_RID:
				return_string += "RID()"
			TYPE_STRING:
				return_string += ValueCreator.get_string_string()
			TYPE_STRING_ARRAY:
				return_string += "String[]"
			TYPE_TRANSFORM:
				return_string += ValueCreator.get_transform_string_csharp()
			TYPE_TRANSFORM2D:
				return_string += ValueCreator.get_transform2D_string_csharp()
			TYPE_VECTOR2:
				return_string += ValueCreator.get_vector2_string_csharp()
			TYPE_VECTOR2_ARRAY:
				return_string += "Vector2[]"
			TYPE_VECTOR3:
				return_string += ValueCreator.get_vector3_string_csharp()
			TYPE_VECTOR3_ARRAY:
				return_string += "Vector3[]"
			_:
				assert(false)  # Missed some types, add it

		argument_number += 1

	return return_string


func _ready() -> void:
	CreateProjectBase.use_gdscript = false
	CreateProjectBase.base_path = "res://CSharp/"
	CreateProjectBase.base_dir = "CSharp/"

	CreateProjectBase.collect_data()
	if Directory.new().dir_exists(CreateProjectBase.base_path):
		CreateProjectBase.remove_files_recursivelly(CreateProjectBase.base_path)
	CreateProjectBase.create_basic_structure()
	create_basic_files()
	CreateProjectBase.create_scene_files()
	print("Created test C# project")
	get_tree().quit()
