extends Node

var debug_print: bool = true
var add_to_tree: bool = true  # Adds nodes to tree
var use_parent_methods: bool = false  # Allows Node2D use Node methods etc. - it is a little slow option which rarely shows
var use_always_new_object: bool = true  # Don't allow to "remeber" other function effects
var exiting: bool = true


#func _ready() -> void:
func _process(_delta: float) -> void:  # Replace this with _ready in RegressionTestProject
	tests_all_functions()
	if exiting:
		get_tree().quit()  # Remove this when using it with RegressionTestProject


# Test all functions
func tests_all_functions() -> void:
	for name_of_class in BasicData.get_list_of_available_classes():
		# Instance object to be able to execute on it specific functions and later delete to prevent memory leak if it is a Node
		var object: Object = ClassDB.instance(name_of_class)
		assert(object != null)  # This should be checked before when collectiong functions
		if add_to_tree:
			if object is Node:
				add_child(object)
		var method_list: Array = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)

		## Exception
		for exception in BasicData.function_exceptions:
			var index: int = -1
			for method_index in range(method_list.size()):
				if method_list[method_index]["name"] == exception:
					index = method_index
					break
			if index != -1:
				method_list.remove(index)

		if debug_print:
			print("############### CLASS ############### - " + name_of_class)
		for _i in range(1):
			for method_data in method_list:
				# Function is virtual, so we just skip it
				if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
					continue

				if debug_print:
					print(name_of_class + "." + method_data["name"])

				var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, debug_print)
				object.callv(method_data["name"], arguments)

				for argument in arguments:
					if argument != null:
						if argument is Node:
							argument.queue_free()
						elif argument is Object && !(argument is Reference):
							argument.free()

				if use_always_new_object:
					assert(object != null)
					if object is Node:
						object.queue_free()
					elif object is Object && !(object is Reference):
						object.free()

					object = ClassDB.instance(name_of_class)
					if add_to_tree:
						if object is Node:
							add_child(object)

		if object is Node:  # Just prevent memory leak
			object.queue_free()
		elif object is Object && !(object is Reference):
			object.free()
