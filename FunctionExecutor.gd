extends Node

### TODO Update this
### Script:
### - takes all available classes
### - checks if method is allowed
### - checks each argument if is allowed(in case e.g. adding new, to prevent crashes due not recognizing types)
### - print info if needed to console
### - execute function with parameters

var debug_print: bool = true
var exiting: bool = false  # Exit after 1 loop?
var add_to_tree: bool = false  # Adds nodes to tree, freeze godot when removing a lot of nodes
var use_parent_methods: bool = false  # Allows Node2D use Node methods etc. - it is a little slow option which rarely shows
var use_always_new_object: bool = false  # Don't allow to "remeber" other function effects
var number_of_function_repeats: int = 3  # How many times functions can be repeated
var number_of_classes_repeats: int = 1  # How many times classes will be repeated
var shuffle_methods: bool = true  # Mix methods to be able to get more random results
var miss_some_functions: int = true  # Allows to not execute some functions to be able to get more random results
var remove_returned_value: bool = true  # Removes returned value from function
var save_data_to_file: bool = true  # Save data to file(not big performance impact as I exepected)
var test_one_class_multiple_times: bool = false  # Test same class across multiple frames

var file_handler: File = File.new()  # Handles saves to file, in case of testing one class, entire log is saved to it

var to_print: String = ""  # Specify what needs to be printed

var number_to_track_variables: int = 0  # Unique number to specify number which is added to variable name to prevent from using variables with same name

var how_many_times_test: int = 30  # How many times, same class will be tested
var tested_times: int = how_many_times_test  # How many times class is tested now
var current_tested_element: int = 0  # Which element from array is tested now
var tested_classes: Array = []  # Array with elements that are tested, in normal situation this equal to base_classes variable


# Prepare options for desired type of test
func _ready() -> void:
	ValueCreator.should_be_always_valid = false

	if BasicData.regression_test_project:
		debug_print = false
		add_to_tree = false
		use_parent_methods = false
		use_always_new_object = true
		number_of_function_repeats = 1
		number_of_classes_repeats = 1
		shuffle_methods = false
		miss_some_functions = false
		remove_returned_value = false
		save_data_to_file = false
		test_one_class_multiple_times = false

		ValueCreator.random = false  # Results in RegressionTestProject must be always reproducible
		ValueCreator.number = 100
	else:
		ValueCreator.random = true
		ValueCreator.number = 100

	# Initialize array of objects at the end
	HelpFunctions.initialize_list_of_available_classes(true, true, [])
	HelpFunctions.initialize_array_with_allowed_functions(use_parent_methods, BasicData.function_exceptions)
	tested_classes = BasicData.base_classes.duplicate(true)
#	# Not needed always
#	assert(BasicData.allowed_thing.size() == BasicData.base_classes.size())
#	var index : int = 0
#	for i in BasicData.allowed_thing.keys():
#		assert(i == BasicData.base_classes[index])
#		index += 1

	if BasicData.regression_test_project:
		tests_all_functions()


func _process(_delta: float) -> void:
	if !BasicData.regression_test_project:
		tests_all_functions()
		if exiting:
			get_tree().quit()


# Test all functions
func tests_all_functions() -> void:
	if test_one_class_multiple_times:
		tested_times += 1
		if tested_times > how_many_times_test:
			tested_times = 0
			tested_classes.clear()
			tested_classes.append(BasicData.base_classes[current_tested_element])

			current_tested_element += 1
			current_tested_element = current_tested_element % BasicData.base_classes.size()

			if save_data_to_file:
				var _a: int = file_handler.open("res://results.txt", File.WRITE)

	elif save_data_to_file:
		var _a: int = file_handler.open("res://results.txt", File.WRITE)

	for _f in range(number_of_classes_repeats):
		for name_of_class in tested_classes:
			if debug_print || save_data_to_file:
				to_print = "\n######################################## " + name_of_class + " ########################################"
				if save_data_to_file:
					file_handler.store_string(to_print)
					file_handler.flush()
				if debug_print:
					print(to_print)

			var object: Object = ClassDB.instance(name_of_class)
			assert(object != null, "Object must be instantable")
			if add_to_tree:
				if object is Node:
					add_child(object)
			var method_list: Array = BasicData.allowed_thing[name_of_class]

			if shuffle_methods:
				method_list.shuffle()

			if (debug_print || save_data_to_file) && !use_always_new_object:
				number_to_track_variables += 1
				to_print = "\tvar temp_variable" + str(number_to_track_variables) + " = " + HelpFunctions.get_gdscript_class_creation(name_of_class)
				if add_to_tree:
					if object is Node:
						to_print += "\n\tadd_child(temp_variable" + str(number_to_track_variables) + ")"
				if save_data_to_file:
					file_handler.store_string("\n" + to_print)
					file_handler.flush()
				if debug_print:
					print(to_print)

			for _i in range(number_of_function_repeats):
				for method_data in method_list:
					if !miss_some_functions || randi() % 2 == 0:
						var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, name_of_class, debug_print)

						if debug_print || save_data_to_file:
							if use_always_new_object:
								if save_data_to_file:
									to_print = "\t"
								else:
									to_print = "GDSCRIPT CODE:     "
								to_print += HelpFunctions.get_gdscript_class_creation(name_of_class)
							else:
								to_print = "\ttemp_variable" + str(number_to_track_variables)

							to_print += "." + method_data["name"] + "("

							for i in arguments.size():
								to_print += ParseArgumentType.return_gdscript_code_which_run_this_object(arguments[i])
								if i != arguments.size() - 1:
									to_print += ", "
							to_print += ")"

							if save_data_to_file:
								file_handler.store_string("\n" + to_print)
								file_handler.flush()
							if debug_print:
								print(to_print)

						var ret = object.callv(method_data["name"], arguments)

						if remove_returned_value:
							if ret is Object && ret != null && !(method_data["name"] in BasicData.return_value_exceptions):
								HelpFunctions.remove_thing(ret)

								# This code must create duplicate line, because ret type is only known after executing function and cannot be deduced before.
								var remove_function: String = HelpFunctions.remove_thing_string(object)

								if save_data_to_file:
									file_handler.store_string("\n" + to_print + remove_function)
									file_handler.flush()
								if debug_print:
									print(to_print + remove_function)

						for argument in arguments:
							if argument is Object && argument != null:
								HelpFunctions.remove_thing(argument)

						if use_always_new_object:
							HelpFunctions.remove_thing(object)

							object = ClassDB.instance(name_of_class)
							if add_to_tree:
								if object is Node:
									add_child(object)

			HelpFunctions.remove_thing(object)
