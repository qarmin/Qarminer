extends Node

# Execute every object function

var debug_print: bool = true
var add_to_tree: bool = false  # Adds nodes to tree, freeze godot when removing a lot of nodes
var use_parent_methods: bool = false  # Allows Node2D use Node methods etc. - it is a little slow option which rarely shows
var use_always_new_object: bool = true  # Don't allow to "remeber" other function effects
var exiting: bool = true


func _ready() -> void:
	if BasicData.regression_test_project:
		tests_all_functions()
	
func _process(_delta: float) -> void:
	if !BasicData.regression_test_project:
		tests_all_functions()
		if exiting:
			get_tree().quit()


# Test all functions
func tests_all_functions() -> void:
	for name_of_class in BasicData.get_list_of_available_classes():
		var object: Object = ClassDB.instance(name_of_class)
		if add_to_tree:
			if object is Node:
				add_child(object)
		var method_list: Array = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)

		## Exception
		for exception in BasicData.function_exceptions:
			var index: int = -1
			for method_index in range(method_list.size()):
				if method_list[method_index].get("name") == exception:
					index = method_index
					break
			if index != -1:
				method_list.remove(index)

		if debug_print:
			print("#################### " + name_of_class +" ####################")
		for _i in range(1):
			for method_data in method_list:
				if !BasicData.check_if_is_allowed(method_data):
					continue

				if debug_print:
					print(name_of_class + "." + method_data.get("name"))

				var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, debug_print)
				object.callv(method_data.get("name"), arguments)

				for argument in arguments:
					if argument is Node:
						argument.queue_free()
					elif argument is Object && !(argument is Reference):
						argument.free()

				if use_always_new_object:
					assert(object != null, "Object must be instantable")
					if object is Node:
						object.queue_free()
					elif object is Object && !(object is Reference):
						object.free()

					object = ClassDB.instance(name_of_class)
					if add_to_tree:
						if object is Node:
							add_child(object)

		if object is Node:
			object.queue_free()
		elif object is Object && !(object is Reference):
			object.free()
