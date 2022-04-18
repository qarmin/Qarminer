extends Node

### Script:
### - finds all available classes and methods which can be used(e.g. types of arguments are checked)
### - for all classes in list(all classes or only one depends on list) instantiate them
### - adds them to tree if needed
### - creates aruments
### - executes functions with provided arguments
### - clean memory, instantiate other objects etc. until there is no other classes to check
### - waits for new frame to starts everything from start

var debug_print: bool = true  # Switch to turn off printed things to screen
var exiting: bool = false  # Close app after first run
var add_to_tree: bool = false  # Adds nodes to tree
var delay_removing_added_nodes_to_next_frame: bool = false  # Delaying removing nodes added to tree to next frame, which force to render it
var add_arguments_to_tree: bool = false  # Adds nodes which are used as arguments to tree
var delay_removing_added_arguments_to_next_frame: bool = false  # Delaying removing arguments(nodes added to tree) to next frame, which force to render it
var use_parent_methods: bool = false  # Allows to use parent methods e.g. Sprite2D can use Node.queue_free()
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

var memory_usage_file_handler: File = File.new()
var memory_before: float = 0.0

# This setting allow to decrease number of executed functions on object, to be able to easily find the smallest subset of functions
# that will cause problem with Godot
var maximum_executed_functions_on_object: int = -1
var currently_executed_functions_on_object: int = 0


# Prepare options for desired type of test
func _ready() -> void:
	ValueCreator.number = 100

	if save_resources_to_file:
		var dir: Directory = Directory.new()

		for base_dir in ["res://test_resources/.import/", "res://test_resources/.godot/", "res://test_resources/"]:
			if dir.open(base_dir) == OK:
				var _unused = dir.list_dir_begin()  # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
				var file_name: String = dir.get_next()
				while file_name != "":
					if file_name != ".." && file_name != ".":
						var rr: int = dir.remove_at(base_dir + file_name)
						assert(rr == OK)
					file_name = dir.get_next()
				var ret2: int = dir.remove_at(base_dir)
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
	debug_print = SettingsLoader.load_setting("debug_print", TYPE_BOOL, debug_print)
	exiting = SettingsLoader.load_setting("exiting", TYPE_BOOL, exiting)
	add_to_tree = SettingsLoader.load_setting("add_to_tree", TYPE_BOOL, add_to_tree)
	delay_removing_added_nodes_to_next_frame = SettingsLoader.load_setting("delay_removing_added_nodes_to_next_frame", TYPE_BOOL, delay_removing_added_nodes_to_next_frame)
	add_arguments_to_tree = SettingsLoader.load_setting("add_arguments_to_tree", TYPE_BOOL, add_arguments_to_tree)
	delay_removing_added_arguments_to_next_frame = SettingsLoader.load_setting("delay_removing_added_arguments_to_next_frame", TYPE_BOOL, delay_removing_added_arguments_to_next_frame)
	use_parent_methods = SettingsLoader.load_setting("use_parent_methods", TYPE_BOOL, use_parent_methods)
	use_always_new_object = SettingsLoader.load_setting("use_always_new_object", TYPE_BOOL, use_always_new_object)
	number_of_function_repeats = SettingsLoader.load_setting("number_of_function_repeats", TYPE_INT, number_of_function_repeats)
	number_of_classes_repeats = SettingsLoader.load_setting("number_of_classes_repeats", TYPE_INT, number_of_classes_repeats)
	allow_to_use_notification = SettingsLoader.load_setting("allow_to_use_notification", TYPE_BOOL, allow_to_use_notification)
	shuffle_methods = SettingsLoader.load_setting("shuffle_methods", TYPE_BOOL, shuffle_methods)
	miss_some_functions = SettingsLoader.load_setting("miss_some_functions", TYPE_BOOL, miss_some_functions)
	remove_returned_value = SettingsLoader.load_setting("remove_returned_value", TYPE_BOOL, remove_returned_value)
	save_data_to_file = SettingsLoader.load_setting("save_data_to_file", TYPE_BOOL, save_data_to_file)
	test_one_class_multiple_times = SettingsLoader.load_setting("test_one_class_multiple_times", TYPE_BOOL, test_one_class_multiple_times)
	save_resources_to_file = SettingsLoader.load_setting("save_resources_to_file", TYPE_BOOL, save_resources_to_file)
	how_many_times_test_one_class = SettingsLoader.load_setting("how_many_times_test_one_class", TYPE_INT, how_many_times_test_one_class)
	maximum_executed_functions_on_object = SettingsLoader.load_setting("maximum_executed_functions_on_object", TYPE_INT, maximum_executed_functions_on_object)

	# Initialize array of objects
#	BasicData.custom_classes = []  # Here can be choosen any classes that user want to use
	HelpFunctions.initialize_list_of_available_classes()
#	BasicData.base_classes = BasicData.base_classes.slice(250,260)
#	print("After preselection, choosed " + str(BasicData.base_classes.size()) + " classes")
	HelpFunctions.initialize_array_with_allowed_functions(use_parent_methods, BasicData.function_exceptions)
	tested_classes = BasicData.base_classes.duplicate(true)

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
		var _c: int = memory_usage_file_handler.open("res://memory_usage.txt", File.WRITE)
		var current_memory: float = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
		memory_before = current_memory
		memory_usage_file_handler.store_string("When,Class,Function,Current Memory Usage,Difference\n")


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

			if save_data_to_file:
				var _a: int = file_handler.open("res://results.txt", File.WRITE)

	elif save_data_to_file:
		var _a: int = file_handler.open("res://results.txt", File.WRITE)

	# Prevent from using by this files more than 1GB of disk
	if save_data_to_file:
		if timer_file_handler.get_position() > 1000000000:
			var _b: int = timer_file_handler.open("res://timer.txt", File.WRITE)
		if memory_usage_file_handler.get_position() > 1000000000:
			var _c: int = memory_usage_file_handler.open("res://memory_usage.txt", File.WRITE)
			memory_usage_file_handler.store_string("When,Class,Function,Current Memory Usage,Difference\n")

	if (delay_removing_added_nodes_to_next_frame && add_to_tree) || (delay_removing_added_arguments_to_next_frame && add_arguments_to_tree):
		to_print = "\n\tfor i in get_children():\n\t\ti.queue_free()"
		save_to_file_to_screen("\n" + to_print, to_print)
		for i in get_children():
			i.queue_free()

	for name_of_class in tested_classes:
		for _f in range(number_of_classes_repeats):
			currently_executed_functions_on_object = 0
			if debug_print || save_data_to_file:
				to_print = "\n######################################## " + name_of_class + " ########################################"
				save_to_file_to_screen("\n" + to_print, to_print)

			var object: Object = ClassDB.instantiate(name_of_class)
			assert(object != null)  #,"Object must be instantable")
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
						currently_executed_functions_on_object += 1
						if maximum_executed_functions_on_object >= 0 && currently_executed_functions_on_object > maximum_executed_functions_on_object:
							break

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
								if arguments[i] is Object && !(arguments[i] is RefCounted):
									var temp_name: String = "temp_argument" + str(number_to_track_variables) + "_f" + str(function_number) + "_" + str(i)
									to_print += ("\tvar " + temp_name + " = " + ParseArgumentType.return_gdscript_code_which_run_this_object(arguments[i]) + "\n")
									if add_arguments_to_tree:
										if arguments[i] is Node:
											to_print += "\tadd_child(" + temp_name + ")\n"

							to_print += "\ttemp_variable" + str(number_to_track_variables)
							to_print += "." + method_data["name"] + "("

							for i in arguments.size():
								if arguments[i] is Object && !(arguments[i] is RefCounted):
									to_print += "temp_argument" + str(number_to_track_variables) + "_f" + str(function_number) + "_" + str(i)
								else:
									to_print += ParseArgumentType.return_gdscript_code_which_run_this_object(arguments[i])
								if i != arguments.size() - 1:
									to_print += ", "
							to_print += ")"

							save_to_file_to_screen("\n" + to_print, to_print)

						if save_data_to_file:
							timer = Time.get_ticks_usec()

						save_memory_file("Before," + name_of_class + "," + method_data["name"] + ",")

						var ret = object.callv(method_data["name"], arguments)

						save_memory_file("After," + name_of_class + "," + method_data["name"] + ",")

						if save_data_to_file:
							timer_file_handler.store_string(str(Time.get_ticks_usec() - timer) + " us - " + name_of_class + "." + method_data["name"] + "\n")
							# timer_file_handler.flush() # Don't need to be flushed immendiatelly

						for i in arguments.size():
							if !(delay_removing_added_arguments_to_next_frame && add_arguments_to_tree && arguments[i] is Node):
								if arguments[i] is Object && arguments[i] != null:
									if debug_print || save_data_to_file:
										if (arguments[i] is Node) || !(arguments[i] is RefCounted):
											to_print = "\ttemp_argument" + str(number_to_track_variables) + "_f" + str(function_number) + "_" + str(i)
											to_print += HelpFunctions.remove_thing_string(arguments[i])
											save_to_file_to_screen("\n" + to_print, to_print)
									HelpFunctions.remove_thing(arguments[i])

						if remove_returned_value:
							# Looks that argument of function may become its returned value, so
							# needs to be checked if was not freed before
							if is_instance_valid(ret):
								if ret is Object && ret != null && !(method_data["name"] in BasicData.return_value_exceptions):
									if !(ret is RefCounted):
										# This code must create duplicate line, because ret type is only known after executing function and cannot be deduced before.
										var remove_function: String = HelpFunctions.remove_thing_string(ret)
										save_to_file_to_screen(to_print + remove_function, to_print + remove_function)

									HelpFunctions.remove_thing(ret)

						if use_always_new_object:
							if !(delay_removing_added_nodes_to_next_frame && add_to_tree && object is Node):
								if (object is Node) || !(object is RefCounted):
									to_print = "\ttemp_variable" + str(number_to_track_variables)
									to_print += HelpFunctions.remove_thing_string(object)
									save_to_file_to_screen("\n" + to_print, to_print)
								HelpFunctions.remove_thing(object)

							object = ClassDB.instantiate(name_of_class)
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
				if (object is Node) || !(object is RefCounted):
					to_print = "\ttemp_variable" + str(number_to_track_variables)
					to_print += HelpFunctions.remove_thing_string(object)
					save_to_file_to_screen("\n" + to_print, to_print)
				HelpFunctions.remove_thing(object)


func save_to_file_to_screen(text_to_save_to_file: String, text_to_print_on_screen: String) -> void:
	if save_data_to_file:
		file_handler.store_string(text_to_save_to_file)
		file_handler.flush()
	if debug_print:
		print(text_to_print_on_screen)


func save_memory_file(text: String) -> void:
	if save_data_to_file || debug_print:
		var current_memory: float = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
		var upd_text: String = text + str(current_memory) + "," + str(current_memory - memory_before) + "\n"
		memory_before = current_memory
		if save_data_to_file:
			memory_usage_file_handler.store_string(upd_text)
			# memory_usage_file_handler.flush() # Don't need to be flushed immendiatelly
#		if debug_print: # Not really usable, but can be enabled if needed
#			print(upd_text)
# big usage of memory can be searched by this regex "difference 0.[1-9]" or even "difference [1-9]"
