extends Node2D

func _ready() -> void:
	tests_0_arguments()


# TODO - Think about adding 'add_child', to test nodes in scene tree
# Test all functions which takes 0 arguments
func tests_0_arguments() -> void:
	var debug_print : bool = false
	var use_parent_methods : bool = false # Allows Node2D use Node methods etc. - it is a little slow option
	var number_of_loops : int = 1 # Can be executed in multiple loops
	
	for name_of_class in Autoload.get_list_of_available_classes():
		# Instance object to be able to execute on it specific functions and later delete to prevent memory leak if it is a Node
		var object : Object = ClassDB.instance(name_of_class)
		assert(object != null) # This should be checked before when collectiong functions
		var method_list : Array = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)
		for exception in Autoload.function_exceptions:
			var index : int = -1
			for method_index in range(method_list.size()):
				if method_list[method_index]["name"] == exception:
					index = method_index
					break
			if index != -1:
				method_list.remove(index)
		
		
		for i in range(number_of_loops):
			for method_data in method_list:
				if method_data["args"].size() == 0:
					
					# Function is virtual, so we just skip it
					if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
						continue 
					
					if debug_print:
						print("##### - " + name_of_class)
	#					print(method_data)
						print(method_data["name"])
						print(method_data["args"])
						
					object.call(method_data["name"])
					
		if object is Node: # Just prevent memory leak
			object.queue_free()
