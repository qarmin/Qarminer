extends Node

var debug_print: bool = true
var add_to_tree: bool = true  # Adds nodes to tree
var use_parent_methods: bool = false  # Allows Node2D use Node methods etc. - it is a little slow option which rarely shows
var use_always_new_object: bool = true  # Don't allow to "remeber" other function effects


#func _ready() -> void:
func _process(_delta: float) -> void:  # Replace this with _ready in RegressionTestProject
	tests_all_functions()
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
				if method_list[method_index].get("name") == exception:
					index = method_index
					break
			if index != -1:
				method_list.remove(index)

		if debug_print:
			print("############### CLASS ############### - " + name_of_class)
		for _i in range(1):
			for method_data in method_list:
				# Function is virtual, so we just skip it
				if method_data.get("flags") == method_data.get("flags") | METHOD_FLAG_VIRTUAL:
					continue

				if debug_print:
					print(method_data.get("name"))

				var arguments: Array = return_for_all(method_data)
				object.callv(method_data.get("name"), arguments)

				for argument in arguments:
					if argument is Object:
						assert(argument != null)
						if argument is Node:
							argument.queue_free()
						elif argument is Object && !(argument is Reference):
							argument.free()

				if use_always_new_object:
					if object is Object:
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

	for argument in method_data.get("args"):
		var type = argument.get("type")
		if type == TYPE_NIL: # Looks that this means VARIANT not null
				arguments_array.push_back(false) # TODO Add some randomization
#				assert(false)
		elif type == TYPE_MAX:
				assert(false)
		elif type == TYPE_AABB:
				arguments_array.push_back(ValueCreator.get_aabb())
		elif type == TYPE_ARRAY:
				arguments_array.push_back(ValueCreator.get_array())
		elif type == TYPE_BASIS:
				arguments_array.push_back(ValueCreator.get_basis())
		elif type == TYPE_BOOL:
				arguments_array.push_back(ValueCreator.get_bool())
		elif type == TYPE_COLOR:
				arguments_array.push_back(ValueCreator.get_color())
		elif type == TYPE_COLOR_ARRAY:
				arguments_array.push_back(PackedColorArray([]))
		elif type == TYPE_DICTIONARY:
				arguments_array.push_back(ValueCreator.get_dictionary())
		elif type == TYPE_INT:
				arguments_array.push_back(ValueCreator.get_int())
		elif type == TYPE_INT32_ARRAY:
				arguments_array.push_back(PackedInt32Array([]))
		elif type == TYPE_INT64_ARRAY:
				arguments_array.push_back(PackedInt64Array([]))
		elif type == TYPE_NODE_PATH:
				arguments_array.push_back(ValueCreator.get_nodepath())
		elif type == TYPE_OBJECT:
				arguments_array.push_back(ValueCreator.get_object(argument.get("class_name")))
		elif type == TYPE_PLANE:
				arguments_array.push_back(ValueCreator.get_plane())
		elif type == TYPE_QUAT:
				arguments_array.push_back(ValueCreator.get_quat())
		elif type == TYPE_RAW_ARRAY:
				arguments_array.push_back(PackedByteArray([]))
		elif type == TYPE_FLOAT:
				arguments_array.push_back(ValueCreator.get_float())
		elif type == TYPE_FLOAT32_ARRAY:
				arguments_array.push_back(PackedFloat32Array([]))
		elif type == TYPE_FLOAT64_ARRAY:
				arguments_array.push_back(PackedFloat64Array([]))
		elif type == TYPE_RECT2:
				arguments_array.push_back(ValueCreator.get_rect2())
		elif type == TYPE_RECT2I:
				arguments_array.push_back(ValueCreator.get_rect2i())
		elif type == TYPE_RID:
				arguments_array.push_back(RID())
		elif type == TYPE_STRING:
				arguments_array.push_back(ValueCreator.get_string())
		elif type == TYPE_STRING_NAME:
				arguments_array.push_back(StringName(ValueCreator.get_string()))
		elif type == TYPE_STRING_ARRAY:
				arguments_array.push_back(PackedStringArray([]))
		elif type == TYPE_TRANSFORM:
				arguments_array.push_back(ValueCreator.get_transform())
		elif type == TYPE_TRANSFORM2D:
				arguments_array.push_back(ValueCreator.get_transform2D())
		elif type == TYPE_VECTOR2:
				arguments_array.push_back(ValueCreator.get_vector2())
		elif type == TYPE_VECTOR2I:
				arguments_array.push_back(ValueCreator.get_vector2i())
		elif type == TYPE_VECTOR2_ARRAY:
				arguments_array.push_back(PackedVector2Array([]))
		elif type == TYPE_VECTOR3:
				arguments_array.push_back(ValueCreator.get_vector3())
		elif type == TYPE_VECTOR3I:
				arguments_array.push_back(ValueCreator.get_vector3i())
		elif type == TYPE_VECTOR3_ARRAY:
				arguments_array.push_back(PackedVector3Array([]))
		elif type== TYPE_CALLABLE:
			arguments_array.push_back(Callable(BoxMesh.new(),"Rar"))
		else:
				assert(false) # Missed some types, add it

	if debug_print:
		print("Parameters " + str(arguments_array))
	return arguments_array
