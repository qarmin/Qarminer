extends Node

### Script:
### - finds all available classes and methods which can be used(e.g. types of arguments are checked)
### - for all classes in list(all classes or only one depends on list) instance them
### - adds them to tree if needed
### - creates aruments
### - executes functions with provided arguments
### - clean memory, instance other objects etc. until there is no other classes to check
### - waits for new frame to starts everything from start

var before : int = 0
var valid : bool = false

var debug_print: bool = true  # Switch to turn off printed things to screen
var exiting: bool = false  # Close app after first run
var add_to_tree: bool = true  # Adds nodes to tree
var delay_removing_added_nodes_to_next_frame: bool = true  # Delaying removing nodes added to tree to next frame, which force to render it
var add_arguments_to_tree: bool = false  # Adds nodes which are used as arguments to tree
var delay_removing_added_arguments_to_next_frame: bool = false  # Delaying removing arguments(nodes added to tree) to next frame, which force to render it
var use_parent_methods: bool = false  # Allows to use parent methods e.g. Sprite can use Node.queue_free()
var use_always_new_object: bool = false  # Don't allow to "remember" other function effects
var number_of_function_repeats: int = 3  # How many times all functions will be executed in single class
var number_of_classes_repeats: int = 1  # How much times class will be instanced in row(one after one)
var allow_to_use_notification: bool = false  # Allows to use notification function in classes,to use this, parent methods must be enabled
var shuffle_methods: bool = true  # Mix method execution order to be able to get more random results
var miss_some_functions: int = true  # Allows to not execute some functions to be able to get more random results
var remove_returned_value: bool = false  # Removes returned value from function(not recommended as default option, because can cause hard to reproduce bugs)
var save_data_to_file: bool = true  # Save results to file
var test_one_class_multiple_times: bool = false  # Test same class across multiple frames - helpful to find one class which cause problems

var save_resources_to_file: bool = false  # Saves created resources to files

var file_handler: File = File.new()  # Handles saves to file, in case of testing one class, entire log is saved to it

var to_print: String = ""  # Specify what needs to be printed

var number_to_track_variables: int = 0  # Unique number to specify number which is added to variable name to prevent from using variables with same name
var function_number: int = 0  # Needed to be able to use arguments with unique names

var how_many_times_test_one_class: int = 30  # How many times, same class will be tested(works only with test_one_class_multiple_times enabled)
var tested_times: int = how_many_times_test_one_class  # How many times class is tested now
var current_tested_element: int = 0  # Which element from array is tested now
var tested_classes: Array = []  # Array with elements that are tested, in normal situation this equal to base_classes variable

var timer: int = 0  # Checks how much things are executed
var timer_file_handler: File = File.new()


# Prepare options for desired type of test
func _ready() -> void:
	ValueCreator.random = true
	ValueCreator.number = 100

	if save_resources_to_file:
		var dir: Directory = Directory.new()

		for base_dir in ["res://test_resources/.import/", "res://test_resources/.godot/", "res://test_resources/"]:
			if dir.open(base_dir) == OK:
				var _unused = dir.list_dir_begin()
				var file_name: String = dir.get_next()
				while file_name != "":
					if file_name != ".." && file_name != ".":
						var rr: int = dir.remove(base_dir + file_name)
						assert(rr == OK)
					file_name = dir.get_next()
				var ret2: int = dir.remove(base_dir)
				assert(ret2 == OK)

		var ret: int = dir.make_dir("res://test_resources")
		assert(ret == OK)
		ret = File.new().open("res://test_resources/.gdignore", File.WRITE)
		assert(ret == OK)
		ret = File.new().open("res://test_resources/project.godot", File.WRITE)
		assert(ret == OK)

	if allow_to_use_notification:
		BasicData.function_exceptions.erase("notification")
		BasicData.function_exceptions.erase("propagate_notification")
		HelpFunctions.disable_nodes_with_internal_child()  # notification may free internal child

	# Adds additional arguments to excluded items
	HelpFunctions.add_excluded_too_big_functions(ValueCreator.number > 40)
	HelpFunctions.add_excluded_too_big_classes(ValueCreator.number > 100)

	# Load data from file if available
	debug_print = Settings.load_setting("debug_print", TYPE_BOOL, debug_print)
	exiting = Settings.load_setting("exiting", TYPE_BOOL, exiting)
	add_to_tree = Settings.load_setting("add_to_tree", TYPE_BOOL, add_to_tree)
	delay_removing_added_nodes_to_next_frame = Settings.load_setting("delay_removing_added_nodes_to_next_frame", TYPE_BOOL, delay_removing_added_nodes_to_next_frame)
	add_arguments_to_tree = Settings.load_setting("add_arguments_to_tree", TYPE_BOOL, add_arguments_to_tree)
	delay_removing_added_arguments_to_next_frame = Settings.load_setting("delay_removing_added_arguments_to_next_frame", TYPE_BOOL, delay_removing_added_arguments_to_next_frame)
	use_parent_methods = Settings.load_setting("use_parent_methods", TYPE_BOOL, use_parent_methods)
	use_always_new_object = Settings.load_setting("use_always_new_object", TYPE_BOOL, use_always_new_object)
	number_of_function_repeats = Settings.load_setting("number_of_function_repeats", TYPE_INT, number_of_function_repeats)
	number_of_classes_repeats = Settings.load_setting("number_of_classes_repeats", TYPE_INT, number_of_classes_repeats)
	allow_to_use_notification = Settings.load_setting("allow_to_use_notification", TYPE_BOOL, allow_to_use_notification)
	shuffle_methods = Settings.load_setting("shuffle_methods", TYPE_BOOL, shuffle_methods)
	miss_some_functions = Settings.load_setting("miss_some_functions", TYPE_BOOL, miss_some_functions)
	remove_returned_value = Settings.load_setting("remove_returned_value", TYPE_BOOL, remove_returned_value)
	save_data_to_file = Settings.load_setting("save_data_to_file", TYPE_BOOL, save_data_to_file)
	test_one_class_multiple_times = Settings.load_setting("test_one_class_multiple_times", TYPE_BOOL, test_one_class_multiple_times)
	save_resources_to_file = Settings.load_setting("save_resources_to_file", TYPE_BOOL, save_resources_to_file)
	how_many_times_test_one_class = Settings.load_setting("how_many_times_test_one_class", TYPE_INT, how_many_times_test_one_class)

	# Initialize array of objects
#	BasicData.custom_classes = []  # Here can be choosen any classes that user want to use
	HelpFunctions.initialize_list_of_available_classes()
	HelpFunctions.initialize_array_with_allowed_functions(use_parent_methods, BasicData.function_exceptions)
	tested_classes = BasicData.base_classes.duplicate(true)
	for i in BasicData.allowed_thing:
		for j in BasicData.allowed_thing[i]:
			print("\""+j["name"] + "\",")
#	# Debug check if all methods exists in choosen classes
#	assert(BasicData.allowed_thing.size() == BasicData.base_classes.size())
#	var index: int = 0
#	for i in BasicData.allowed_thing.keys():
#		assert(i == BasicData.base_classes[index])
#		for met in BasicData.allowed_thing[i]:
#			assert(ClassDB.class_has_method(i, met["name"]))
#		index += 1

	if save_data_to_file:
		var _a: int = file_handler.open("res://results.txt", File.WRITE)
		var _b: int = timer_file_handler.open("res://timer.txt", File.WRITE)


func _process(_delta: float) -> void:
	tests_all_functions()
	if exiting:
		get_tree().quit()


# Test all functions
func tests_all_functions() -> void:
	if test_one_class_multiple_times:
		tested_times += 1
		if tested_times > how_many_times_test_one_class:
			tested_times = 0
			tested_classes.clear()
			tested_classes.append(BasicData.base_classes[current_tested_element])

			current_tested_element += 1
			current_tested_element = current_tested_element % BasicData.base_classes.size()

#			if save_data_to_file:
#				var _a: int = file_handler.open("res://results.txt", File.WRITE)
#
#	elif save_data_to_file:
#		var _a: int = file_handler.open("res://results.txt", File.WRITE)

	if (delay_removing_added_nodes_to_next_frame && add_to_tree) || (delay_removing_added_arguments_to_next_frame && add_arguments_to_tree):
		to_print = "\n\tfor i in get_children():\n\t\ti.queue_free()"
		save_to_file_to_screen("\n" + to_print, to_print)
		for i in get_children():
			i.queue_free()

	for name_of_class in tested_classes:
		for _f in range(number_of_classes_repeats):
			if debug_print || save_data_to_file:
				to_print = "\n######################################## " + name_of_class + " ########################################"
				save_to_file_to_screen("\n" + to_print, to_print)

			var object: Object = ClassDB.instance(name_of_class)
			assert(object != null, "Object must be instantable")
			if add_to_tree:
				if object is Node:
					add_child(object)
			var method_list: Array = BasicData.allowed_thing[name_of_class]

			if shuffle_methods:
				method_list.shuffle()

			if (debug_print || save_data_to_file) && !use_always_new_object:
				function_number = 0
				number_to_track_variables += 1
				to_print = "\tvar temp_variable" + str(number_to_track_variables) + " = " + HelpFunctions.get_gdscript_class_creation(name_of_class)
				if add_to_tree:
					if object is Node:
						to_print += "\n\tadd_child(temp_variable" + str(number_to_track_variables) + ")"
				save_to_file_to_screen("\n" + to_print, to_print)

			for _i in range(number_of_function_repeats):
				for method_data in method_list:
					function_number += 1
					if !miss_some_functions || randi() % 2 == 0:
						var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, name_of_class, debug_print)

						if use_always_new_object && (debug_print || save_data_to_file):
							number_to_track_variables += 1
							to_print = "\tvar temp_variable" + str(number_to_track_variables) + " = " + HelpFunctions.get_gdscript_class_creation(name_of_class)
							if add_to_tree:
								if object is Node:
									to_print += "\n\tadd_child(temp_variable" + str(number_to_track_variables) + ")"
							save_to_file_to_screen("\n" + to_print, to_print)

						if add_arguments_to_tree:
							for argument in arguments:
								if argument is Node:
									add_child(argument)

						if debug_print || save_data_to_file:
							to_print = ""

							# Handle here objects by creating temporary values
							for i in arguments.size():
								if arguments[i] is Object && !(arguments[i] is Reference):
									var temp_name: String = "temp_argument" + str(number_to_track_variables) + "_f" + str(function_number) + "_" + str(i)
									to_print += ("\tvar " + temp_name + " = " + ParseArgumentType.return_gdscript_code_which_run_this_object(arguments[i]) + "\n")
									if add_arguments_to_tree:
										if arguments[i] is Node:
											to_print += "\tadd_child(" + temp_name + ")\n"

							to_print += "\ttemp_variable" + str(number_to_track_variables)
							to_print += "." + method_data["name"] + "("

							for i in arguments.size():
								if arguments[i] is Object && !(arguments[i] is Reference):
									to_print += "temp_argument" + str(number_to_track_variables) + "_f" + str(function_number) + "_" + str(i)
								else:
									to_print += ParseArgumentType.return_gdscript_code_which_run_this_object(arguments[i])
								if i != arguments.size() - 1:
									to_print += ", "
							to_print += ")"

							save_to_file_to_screen("\n" + to_print, to_print)

						if save_data_to_file:
							timer = OS.get_ticks_usec()
						print_memory_usage("BEFORE:")
						var ret = object.callv(method_data["name"], arguments)
						print_memory_usage("AFTER:")

						if save_data_to_file:
							timer_file_handler.store_string(str(OS.get_ticks_usec() - timer) + " us - " + name_of_class + "." + method_data["name"] + "\n")
							timer_file_handler.flush()

						for i in arguments.size():
							if !(delay_removing_added_arguments_to_next_frame && add_arguments_to_tree && arguments[i] is Node):
								if arguments[i] is Object && arguments[i] != null:
									if debug_print || save_data_to_file:
										if (arguments[i] is Node) || !(arguments[i] is Reference):
											to_print = "\ttemp_argument" + str(number_to_track_variables) + "_f" + str(function_number) + "_" + str(i)
											to_print += HelpFunctions.remove_thing_string(arguments[i])
											save_to_file_to_screen("\n" + to_print, to_print)
									HelpFunctions.remove_thing(arguments[i])

						if remove_returned_value:
							# Looks that argument of function may become its returned value, so
							# needs to be checked if was not freed before
							if is_instance_valid(ret):
								if ret is Object && ret != null && !(method_data["name"] in BasicData.return_value_exceptions):
									if !(ret is Reference):
										# This code must create duplicate line, because ret type is only known after executing function and cannot be deduced before.
										var remove_function: String = HelpFunctions.remove_thing_string(ret)
										save_to_file_to_screen(to_print + remove_function, to_print + remove_function)

									HelpFunctions.remove_thing(ret)

						if use_always_new_object:
							if !(delay_removing_added_nodes_to_next_frame && add_to_tree && object is Node):
								if (object is Node) || !(object is Reference):
									to_print = "\ttemp_variable" + str(number_to_track_variables)
									to_print += HelpFunctions.remove_thing_string(object)
									save_to_file_to_screen("\n" + to_print, to_print)
								HelpFunctions.remove_thing(object)

							object = ClassDB.instance(name_of_class)
							if add_to_tree:
								if object is Node:
									add_child(object)

			if save_resources_to_file:
				var res_path: String = "res://test_resources/" + str(number_to_track_variables) + ".tres"
				if object is Resource:
					if !(name_of_class in ["PluginScript"]):
						var _retu: int = ResourceSaver.save(res_path, object)
			#								assert(retu == OK)
			if !(delay_removing_added_nodes_to_next_frame && add_to_tree && object is Node):
				if (object is Node) || !(object is Reference):
					to_print = "\ttemp_variable" + str(number_to_track_variables)
					to_print += HelpFunctions.remove_thing_string(object)
					save_to_file_to_screen("\n" + to_print, to_print)
				HelpFunctions.remove_thing(object)

func print_memory_usage(where : String) -> void:
	print(where)
	print(before)
	print(Performance.get_monitor(Performance.MEMORY_STATIC)/(1024*1024))
	if valid:
		if before + 2 < Performance.get_monitor(Performance.MEMORY_STATIC)/(1024*1024):
			pass
#			get_tree().quit()
	
	print("MEM_DYNAMIC: " + str(Performance.get_monitor(Performance.MEMORY_DYNAMIC)/(1024*1024)) + " MB")
	print("MEM_STATIC: " + str(Performance.get_monitor(Performance.MEMORY_STATIC)/(1024*1024)) + " MB")
	print("MEM_DYNAMIC_MAX: " + str(Performance.get_monitor(Performance.MEMORY_DYNAMIC_MAX)/(1024*1024)) + " MB")
	print("MEM_STATIC_MAX: " + str(Performance.get_monitor(Performance.MEMORY_STATIC_MAX)/(1024*1024)) + " MB")
	
	before = Performance.get_monitor(Performance.MEMORY_STATIC)/(1024*1024)
	valid = true

func save_to_file_to_screen(text_to_save_to_file: String, text_to_print_on_screen: String) -> void:
	if save_data_to_file:
		file_handler.store_string(text_to_save_to_file)
		file_handler.flush()
	if debug_print:
		print(text_to_print_on_screen)
