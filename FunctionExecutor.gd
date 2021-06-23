extends Node

### Script:
### - takes all available classes
### - checks if method is allowed
### - checks each argument if is allowed(in case e.g. adding new, to prevent crashes due not recognizing types)
### - print info if needed to console
### - execute function with parameters

var debug_print: bool = true
var add_to_tree: bool = false  # Adds nodes to tree, freeze godot when removing a lot of nodes
var use_parent_methods: bool = false  # Allows Node2D use Node methods etc. - it is a little slow option which rarely shows
var use_always_new_object: bool = false  # Don't allow to "remeber" other function effects
var exiting: bool = false
var number_of_loops : int = 1 # How much times will be repeated this


func _ready() -> void:
	if BasicData.regression_test_project:
		ValueCreator.random = false  # Results in RegressionTestProject must be always reproducible
	else:
		ValueCreator.random = true

	ValueCreator.number = 100
	ValueCreator.should_be_always_valid = true
	
	if BasicData.regression_test_project:
		number_of_loops = 1
	else:
		number_of_loops = 5

	if BasicData.regression_test_project:
		exiting = false
		tests_all_functions()


func _process(_delta: float) -> void:
	if !BasicData.regression_test_project:
		tests_all_functions()
		if exiting:
			get_tree().quit()


# Test all functions
func tests_all_functions() -> void:
	for name_of_class in BasicData.get_list_of_available_classes():
		if debug_print:
			print("\n#################### " + name_of_class + " ####################")

		var object: Object = ClassDB.instance(name_of_class)
		assert(object != null, "Object must be instantable")
		if add_to_tree:
			if object is Node:
				add_child(object)
		var method_list: Array = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)

		# Removes excluded methods
		BasicData.remove_disabled_methods(method_list, BasicData.function_exceptions)

		if !BasicData.regression_test_project:
			method_list.shuffle()
			
		for _i in range(number_of_loops):
			for method_data in method_list:
				if !BasicData.check_if_is_allowed(method_data):
					continue

				var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, name_of_class, debug_print)

				if debug_print:
					var to_print: String = "GDSCRIPT CODE:     "
					if (
						ClassDB.is_parent_class(name_of_class, "Object")
						&& !ClassDB.is_parent_class(name_of_class, "Node")
						&& !ClassDB.is_parent_class(name_of_class, "RefCounted")
						&& !ClassDB.class_has_method(name_of_class, "new")
					):
						to_print += "ClassDB.instance(\"" + name_of_class + "\")." + method_data.get("name") + "("
					else:
						to_print += name_of_class.trim_prefix("_") + ".new()." + method_data.get("name") + "("

					for i in arguments.size():
						to_print += ParseArgumentType.return_gdscript_code_which_run_this_object(arguments[i])
						if i != arguments.size() - 1:
							to_print += ", "
					to_print += ")"
					print(to_print)

				object.callv(method_data.get("name"), arguments)

				for argument in arguments:
					if argument is Node:
						argument.queue_free()
					elif argument is Object && !(argument is RefCounted):
						argument.free()

				if use_always_new_object:
					if object is Node:
						object.queue_free()
					elif object is Object && !(object is RefCounted):
						object.free()

					object = ClassDB.instance(name_of_class)
					if add_to_tree:
						if object is Node:
							add_child(object)

		if object is Node:
			object.queue_free()
		elif object is Object && !(object is RefCounted):
			object.free()
