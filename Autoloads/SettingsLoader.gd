extends Node

const SETTINGS_FILE_NAME: String = "res://settings.txt"
const DEBUG_PRINT: bool = true  # Enable to validate your scipt
var settings: Dictionary = {}


# Loads settings from file
func _init():
	load_deprecated_classes()

	var file_handler: FileAccess
	if !FileAccess.file_exists(SETTINGS_FILE_NAME):
		print("Setting file doesn't exists, so it cannot be loaded.")
	else:
		file_handler = FileAccess.open(SETTINGS_FILE_NAME, FileAccess.READ)
		if file_handler == null:
			print("Failed to open settings file.")
		else:
			var current_setting: String = ""
			var temp_array_with_settings: Array = []
			var line_number: int = 0

			while !file_handler.eof_reached():
				line_number += 1
				var line: String = file_handler.get_line().strip_edges()
				# Comments and empty lines can be ignored safely
				if line.begins_with("#"):
					print_text("INFO: Found comment: '" + line + "'", line_number)
					continue
				if line == "":
					print_text("INFO: Found empty line", line_number)
					continue

				# Removes comments
				if line.find("#") != -1:
					line = line.substr(0, line.find("#")).strip_edges()

				# Contains info about setting which needs to be changed
				if line.find(":") != -1:
					var before_colon: String = line.substr(0, line.find(":")).strip_edges()
					var after_colon: String = line.substr(line.find(":") + 1).strip_edges()
					if before_colon == "":
						print_text("ERROR: Missing setting name", line_number)
						continue

					if current_setting != "":
						if !temp_array_with_settings.is_empty():
							settings[current_setting] = temp_array_with_settings
							temp_array_with_settings = []
						else:
							print_text("ERROR: Found array setting '" + current_setting + "' without any value", line_number)
						current_setting = ""

					if after_colon == "":
						current_setting = before_colon
						print_text("INFO: Checking for new array setting '" + current_setting + "'", line_number)
					else:
						settings[before_colon] = after_colon
						print_text("INFO: Found new single setting: '" + before_colon + "' with value '" + after_colon + "'", line_number)

				# Normal setting
				else:
					if current_setting != "":
						temp_array_with_settings.append(line)
						print_text("INFO: Found for array setting '" + current_setting + "' value '" + line + "'", line_number)
					else:
						print_text("ERROR: Found orphan text without any assignement '" + line + "'", line_number)

			# Save latest results if still waiting
			if current_setting != "":
				if !temp_array_with_settings.is_empty():
					settings[current_setting] = temp_array_with_settings
				else:
					print_text("ERROR: Found array setting '" + current_setting + "' without any value", line_number)

			print("\nLoaded settings:")
			for setting_name in settings.keys():
				print("'" + setting_name + "' with value '" + str(settings[setting_name]) + "'")
			print()

			load_basic_settings_from_file()


func load_basic_settings_from_file() -> void:
	var custom_classes: Array = load_setting("custom_classes", TYPE_ARRAY, [])
	BasicData.custom_classes = custom_classes

	var function_exceptions_replace: Array = load_setting("function_exceptions_replace", TYPE_ARRAY, BasicData.function_exceptions)
	BasicData.function_exceptions = function_exceptions_replace

	var function_exceptions_append: Array = load_setting("function_exceptions_append", TYPE_ARRAY, [])
	BasicData.function_exceptions.append_array(function_exceptions_append)

	var function_exceptions_remove: Array = load_setting("function_exceptions_remove", TYPE_ARRAY, [])
	BasicData.function_exceptions = HelpFunctions.find_things_from_first_array_not_in_second(BasicData.function_exceptions, function_exceptions_remove)

	var disabled_classes_replace: Array = load_setting("disabled_classes_replace", TYPE_ARRAY, BasicData.disabled_classes)
	BasicData.disabled_classes = disabled_classes_replace

	var disabled_classes_append: Array = load_setting("disabled_classes_append", TYPE_ARRAY, [])
	BasicData.disabled_classes.append_array(disabled_classes_append)

	var disabled_classes_remove: Array = load_setting("disabled_classes_remove", TYPE_ARRAY, [])
	BasicData.disabled_classes = HelpFunctions.find_things_from_first_array_not_in_second(BasicData.disabled_classes, disabled_classes_remove)

	var allowed_functions: Array = load_setting("allowed_functions", TYPE_ARRAY, [])
	BasicData.allowed_functions = allowed_functions

	var value_max: int = load_setting("value_max", TYPE_INT, ValueCreator.number)
	ValueCreator.number = value_max


func print_text(text: String, line_number: int) -> void:
	if DEBUG_PRINT:
		print(text + " LINE " + str(line_number))


func load_setting(setting_name: String, value_type: int, default_value):
#	print("Checking " + setting_name)
	if settings.has(setting_name):
		if settings[setting_name] is Array:
			if value_type == TYPE_ARRAY:
				print("INFO: Properly loaded setting '" + setting_name + "' with value '" + str(settings[setting_name]) + "'.")
				return settings[setting_name]
			print("ERROR: Expected Array settings for '" + setting_name + "', found '" + str(settings[setting_name]) + "'")
		else:
			if settings[setting_name] is String:
				if value_type == TYPE_FLOAT:
					print("INFO: Properly loaded setting '" + setting_name + "' with value '" + settings[setting_name] + "'.")
					return settings[setting_name].to_float()
				elif value_type == TYPE_BOOL:
					var val: String = settings[setting_name]
					if val.to_lower() == "true":
						print("INFO: Properly loaded setting '" + setting_name + "' with value 'true'.")
						return true
					elif val.to_lower() == "false":
						print("INFO: Properly loaded setting '" + setting_name + "' with value 'false'.")
						return false
					printerr("ERROR: Expected 'true' or 'false' value for '" + setting_name + "', found '" + val + "'")

				elif value_type == TYPE_INT:
					print("INFO: Properly loaded setting '" + setting_name + "' with value '" + settings[setting_name] + "'.")
					return settings[setting_name].to_int()
				else:
					printerr("ERROR: Expected Int, Float or Bool settings for '" + setting_name + "', found '" + settings[setting_name] + "'")
			else:
				printerr("ERROR: Unsupported setting for '" + setting_name + "', found '" + settings[setting_name] + "'")
	return default_value


func load_deprecated_classes() -> void:
	var custom_classes: Array = []

	# Compatibility tool
	if FileAccess.file_exists("res://classes.txt"):
		var file: FileAccess = FileAccess.open("res://classes.txt", FileAccess.READ)
		while !file.eof_reached():
			var cname = file.get_line().strip_edges()
			if !cname.is_empty():
				var internal_cname = "_" + cname
				# The declared class may not exist, and it may be exposed as `_ClassName` rather than `ClassName`, this is not needed by Godot 4.x.
				if !ClassDB.class_exists(cname) && !ClassDB.class_exists(internal_cname):
					printerr('Trying to use non existent custom class "' + cname + '"')
					continue
				if ClassDB.class_exists(internal_cname):
					cname = internal_cname
				if !ClassDB.can_instantiate(cname):
					printerr('Trying to use non instantable custom class "' + cname + '"')
					continue
				custom_classes.push_back(cname)
		file.close()

	BasicData.custom_classes = custom_classes
