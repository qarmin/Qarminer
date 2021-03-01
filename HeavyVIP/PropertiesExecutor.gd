extends Node

var debug_print: bool = true
var add_to_tree: bool = true  # Adds nodes to tree
var use_parent_methods: bool = false  # Allows Node2D use Node methods etc. - it is a little slow option which rarely shows
var use_always_new_object: bool = true  # Don't allow to "remeber" other function effects


func _ready() -> void:
	tests_all_functions()
	get_tree().quit()  # Remove this when using it with RegressionTestProject


# Test all functions
func tests_all_functions() -> void:
	for name_of_class in Autoload.get_list_of_available_classes():
		if name_of_class == "_OS":  # Do not change size of window
			continue

		# Instance object to be able to execute on it specific functions and later delete to prevent memory leak if it is a Node
		var object: Object = ClassDB.instance(name_of_class)
		assert(object != null)  # This should be checked before when collectiong functions
		if add_to_tree:
			if object is Node:
				add_child(object)
		var properties_list: Array = ClassDB.class_get_property_list(name_of_class, !use_parent_methods)

		## Exception
		for exception in Autoload.properties_exceptions:
			var index: int = -1
			for properties_index in range(properties_list.size()):
				if properties_list[properties_index]["name"] == exception:
					index = properties_index
					break
			if index != -1:
				properties_list.remove(index)

		if debug_print:
			print("############### CLASS ############### - " + name_of_class)

		for properties_data in properties_list:
			if debug_print:
				print(properties_data["name"])

			var argument = return_for_all(properties_data)
			object.set(properties_data["name"], argument)

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


func return_for_all(properties_data: Dictionary):
	var argument

	ValueCreator.number = 1000
	ValueCreator.random = true  # RegressionTestProject - This must be false
	ValueCreator.should_be_always_valid = false

	match properties_data["type"]:
		TYPE_NIL:  # Looks that this means VARIANT not null
			argument = false  # TODO randomize this
		TYPE_AABB:
			argument = ValueCreator.get_aabb()
		TYPE_ARRAY:
			argument = ValueCreator.get_array()
		TYPE_BASIS:
			argument = ValueCreator.get_basis()
		TYPE_BOOL:
			argument = ValueCreator.get_bool()
		TYPE_COLOR:
			argument = ValueCreator.get_color()
		TYPE_COLOR_ARRAY:
			argument = ValueCreator.get_pool_color_array()
		TYPE_DICTIONARY:
			argument = ValueCreator.get_dictionary()
		TYPE_INT:
			argument = ValueCreator.get_int()
		TYPE_INT_ARRAY:
			argument = ValueCreator.get_pool_int_array()
		TYPE_NODE_PATH:
			argument = ValueCreator.get_nodepath()
		TYPE_OBJECT:
			if properties_data["class_name"].length() == 0:
				argument = ""  # TODO check wyhy this happens
			else:
				argument = ValueCreator.get_object(properties_data["class_name"].split(",")[0])  # TODO, Check why things are THI,THI,THI etc.
		TYPE_PLANE:
			argument = ValueCreator.get_plane()
		TYPE_QUAT:
			argument = ValueCreator.get_quat()
		TYPE_RAW_ARRAY:
			argument = ValueCreator.get_pool_byte_array()
		TYPE_REAL:
			argument = ValueCreator.get_float()
		TYPE_REAL_ARRAY:
			argument = ValueCreator.get_pool_real_array()
		TYPE_RECT2:
			argument = ValueCreator.get_rect2()
		TYPE_RID:
			argument = RID()
		TYPE_STRING:
			argument = ValueCreator.get_string()
		TYPE_STRING_ARRAY:
			argument = ValueCreator.get_pool_string_array()
		TYPE_TRANSFORM:
			argument = ValueCreator.get_transform()
		TYPE_TRANSFORM2D:
			argument = ValueCreator.get_transform2D()
		TYPE_VECTOR2:
			argument = ValueCreator.get_vector2()
		TYPE_VECTOR2_ARRAY:
			argument = ValueCreator.get_pool_vector2_array()
		TYPE_VECTOR3:
			argument = ValueCreator.get_vector3()
		TYPE_VECTOR3_ARRAY:
			argument = ValueCreator.get_pool_vector3_array()
		_:
			assert(false)  # Missed some types, add it

	if debug_print:
		print("Argument " + str(argument))
	return argument
