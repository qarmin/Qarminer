extends Node

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
var number_of_repeats: int = 5  # How many times functions can be repeated
var shuffle_methods: bool = true
var miss_some_functions: int = true  # Allows to not execute some functions to be able to get more random results
var remove_returned_value: bool = true  # Removes returned value from function


# Prepare options for desired type of test
func _ready() -> void:
	# TODO when argument is not valid print ClassDB.instance("AAA") instead AAA.new()
	ValueCreator.should_be_always_valid = false

	if BasicData.regression_test_project:
		add_to_tree = false
		use_parent_methods = false
		use_always_new_object = true
		number_of_repeats = 1
		shuffle_methods = false
		miss_some_functions = false
		remove_returned_value = false

		ValueCreator.random = false  # Results in RegressionTestProject must be always reproducible
		ValueCreator.number = 100
	else:
		ValueCreator.random = true
		ValueCreator.number = 100

	if BasicData.regression_test_project:
		tests_all_functions()


func _process(_delta: float) -> void:
	if !BasicData.regression_test_project:
		tests_all_functions()
		if exiting:
			get_tree().quit()


# Test all functions
func tests_all_functions() -> void:
	for name_of_class in HelpFunctions.get_list_of_available_classes():
		if debug_print:
			print("\n######################################## " + name_of_class + " ########################################")

		var object: Object = ClassDB.instance(name_of_class)
		assert(object != null, "Object must be instantable")
		if add_to_tree:
			if object is Node:
				add_child(object)
		var method_list: Array = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)

		# Removes excluded methods
		HelpFunctions.remove_disabled_methods(method_list, BasicData.function_exceptions)

		if shuffle_methods:
			method_list.shuffle()

		if debug_print && !use_always_new_object:
			print("\tvar temp_variable = " + HelpFunctions.get_gdscript_class_creation(name_of_class))

		for _i in range(number_of_repeats):
			for method_data in method_list:
				if !HelpFunctions.check_if_is_allowed(method_data):
					continue

				if !miss_some_functions || randi() % 2 == 0:
					var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, name_of_class, debug_print)

					if debug_print:
						var to_print: String
						if use_always_new_object:
							to_print = "GDSCRIPT CODE:     "
							to_print += HelpFunctions.get_gdscript_class_creation(name_of_class)
						else:
							to_print = "\ttemp_variable"

						to_print += "." + method_data["name"] + "("

						for i in arguments.size():
							to_print += ParseArgumentType.return_gdscript_code_which_run_this_object(arguments[i])
							if i != arguments.size() - 1:
								to_print += ", "
						to_print += ")"
						print(to_print)

					var ret = object.callv(method_data["name"], arguments)

					if remove_returned_value:
						if ret is Object && ret != null:
							HelpFunctions.remove_thing(ret)

					for argument in arguments:
						HelpFunctions.remove_thing(argument)

					if use_always_new_object:
						HelpFunctions.remove_thing(object)

						object = ClassDB.instance(name_of_class)
						if add_to_tree:
							if object is Node:
								add_child(object)

		HelpFunctions.remove_thing(object)
