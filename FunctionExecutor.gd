extends Node

var debug_print: bool = true
var add_to_tree: bool = true  # Adds nodes to tree
var use_parent_methods: bool = false  # Allows Node2D use Node methods etc. - it is a little slow option which rarely shows
var use_always_new_object: bool = true  # Don't allow to "remeber" other function effects
var exiting: bool = false

#func _ready() -> void:
func _process(_delta: float) -> void:  # Replace this with _ready in RegressionTestProject
	tests_all_functions()
	if exiting:
		get_tree().quit()  # Remove this when using it with RegressionTestProject


# Test all functions
func tests_all_functions() -> void:
	for name_of_class in Autoload.get_list_of_available_classes():
		# Instance object to be able to execute on it specific functions and later delete to prevent memory leak if it is a Node
		var object: Object = ClassDB.instance(name_of_class)
		assert(object != null)  # This should be checked before when collectiong functions
		if add_to_tree:
			if object is Node:
				add_child(object)
		var method_list: Array = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)

		## Exception
		for exception in Autoload.function_exceptions:
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
					print(method_data["name"])

				var arguments: Array = return_for_all(method_data)
				object.callv(method_data["name"], arguments)

				for argument in arguments:
					assert(argument != null)
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

		if object is Node:  # Just prevent memory leak
			object.queue_free()
		elif object is Object && !(object is Reference):
			object.free()


func return_for_all(method_data: Dictionary) -> Array:
	var arguments_array: Array = []

	ValueCreator.number = 100
	ValueCreator.random = true  # RegressionTestProject - This must be false
	ValueCreator.should_be_always_valid = false

	for argument in method_data["args"]:
		match argument.type:
			TYPE_NIL:  # Looks that this means VARIANT not null
				if ValueCreator.random == false:
					arguments_array.push_back(false)
				else:
					if randi() % 3:
						arguments_array.push_back(ValueCreator.get_array())
					elif randi() % 3:
						arguments_array.push_back(ValueCreator.get_object("Object"))
					elif randi() % 3:
						arguments_array.push_back(ValueCreator.get_dictionary())
					elif randi() % 3:
						arguments_array.push_back(ValueCreator.get_string())
					elif randi() % 3:
						arguments_array.push_back(ValueCreator.get_int())
					else:
						arguments_array.push_back(ValueCreator.get_basis())
			TYPE_AABB:
				arguments_array.push_back(ValueCreator.get_aabb())
			TYPE_ARRAY:
				arguments_array.push_back(ValueCreator.get_array())
			TYPE_BASIS:
				arguments_array.push_back(ValueCreator.get_basis())
			TYPE_BOOL:
				arguments_array.push_back(ValueCreator.get_bool())
			TYPE_COLOR:
				arguments_array.push_back(ValueCreator.get_color())
			TYPE_COLOR_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_color_array())
			TYPE_DICTIONARY:
				arguments_array.push_back(ValueCreator.get_dictionary())
			TYPE_INT:
				arguments_array.push_back(ValueCreator.get_int())
			TYPE_INT_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_int_array())
			TYPE_NODE_PATH:
				arguments_array.push_back(ValueCreator.get_nodepath())
			TYPE_OBJECT:
				arguments_array.push_back(ValueCreator.get_object(argument["class_name"]))
			TYPE_PLANE:
				arguments_array.push_back(ValueCreator.get_plane())
			TYPE_QUAT:
				arguments_array.push_back(ValueCreator.get_quat())
			TYPE_RAW_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_byte_array())
			TYPE_REAL:
				arguments_array.push_back(ValueCreator.get_float())
			TYPE_REAL_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_real_array())
			TYPE_RECT2:
				arguments_array.push_back(ValueCreator.get_rect2())
			TYPE_RID:
				arguments_array.push_back(RID())
			TYPE_STRING:
				arguments_array.push_back(ValueCreator.get_string())
			TYPE_STRING_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_string_array())
			TYPE_TRANSFORM:
				arguments_array.push_back(ValueCreator.get_transform())
			TYPE_TRANSFORM2D:
				arguments_array.push_back(ValueCreator.get_transform2D())
			TYPE_VECTOR2:
				arguments_array.push_back(ValueCreator.get_vector2())
			TYPE_VECTOR2_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_vector2_array())
			TYPE_VECTOR3:
				arguments_array.push_back(ValueCreator.get_vector3())
			TYPE_VECTOR3_ARRAY:
				arguments_array.push_back(ValueCreator.get_pool_vector3_array())
			_:
				assert(false)  # Missed some types, add it

	if debug_print:
		print("Parameters " + str(arguments_array))
	return arguments_array
