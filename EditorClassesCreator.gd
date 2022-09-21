extends Node2D

var created_editor_nodes

var allowed_functions: Array = []

var excluded_functions: Array = []

var begin_of_file: String = """tool
extends <<node>>

func _process(_delta : float) -> void:
"""


func _ready():
	var editor_classes: Array = []
	for i in ClassDB.get_class_list():
		if i.begins_with("Editor") && ClassDB.is_parent_class(i, "Node"):
			editor_classes.append(i)
	editor_classes.sort()
	#print(editor_classes)

	var dir = DirAccess.new()
	dir.make_dir("res://Files")

	print("[autoload]")
	for name_of_class in editor_classes:
		var argument_number = 0
		var file_handler: FileAccess = FileAccess.new()

		file_handler.open("res://Files/" + name_of_class + ".gd", FileAccess.WRITE)
		file_handler.store_string(begin_of_file.replace("<<node>>", name_of_class))
		var functions: String = "\t"
		for function_data in ClassDB.class_get_method_list(name_of_class, true):
			if function_data.name in allowed_functions:
				pass
			else:
				if allowed_functions.is_empty():
					if function_data.name in excluded_functions:
						continue
				else:
					continue
			if function_data.flags & METHOD_FLAG_VIRTUAL == 0 && function_data.flags & 128 == 0:  # TODO maybe also static
#				print(method)
				functions += function_data.name + "()\n\t"
#				print(name_of_class + "." + method.name)

				var arguments: Array = ParseArgumentType.parse_and_return_functions_to_create_object(function_data, name_of_class, false)

				var creation_of_arguments: String = ""
				var variable_names: Array = []
				var deleting_arguments: String = ""
				for argument in arguments:
					argument_number += 1
					var variable_name = "temp_variable" + str(argument_number)
					creation_of_arguments += "\tvar " + variable_name + " = " + argument + "\n"
					creation_of_arguments += '\tprint("var ' + variable_name + ' = " + ParseArgumentType.return_gdscript_code_which_run_this_object(' + variable_name + "))\n"

					variable_names.append(variable_name)

					if argument.find("get_object") != -1:
						deleting_arguments += "\tHelpFunctions.remove_thing(" + variable_name + ")\n"
						deleting_arguments += "\tprint('" + variable_name + "'+ HelpFunctions.remove_thing_string(" + variable_name + "))\n"

				file_handler.store_string(creation_of_arguments)

				var to_execute = function_data.name + "("
				for name_index in variable_names.size():
					to_execute += variable_names[name_index]
					if name_index + 1 != variable_names.size():
						to_execute += ","
				to_execute += ")"
				file_handler.store_string("\tprint('" + to_execute + " # " + name_of_class + "')\n")
				file_handler.store_string("\t" + to_execute + "\n")

				file_handler.store_string(deleting_arguments + "\n")

		file_handler.store_string("\n\tpass")
		print("Global" + name_of_class + '="*res://Files/' + name_of_class + '.gd"')

	# Remove Files
#	if dir.change_dir("Files") == OK:
#		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
#		var file_name = dir.get_next()
#		while file_name != "":
#			#dir.remove_at(file_name)
#			file_name = dir.get_next()

	get_tree().quit()
