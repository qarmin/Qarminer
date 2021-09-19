extends Node

var debug_print: bool = true
var use_always_new_object: bool = false  # Don't allow to "remeber" other function effects

var expr: Expression = Expression.new()

var thing
#func _ready() -> void:
#	print(Vector2(2,1).length())
#	assert(expr.parse("Vector2(2,1).length()") == OK)
#	print(expr.execute())
#	assert(!expr.has_execute_failed())
#	print("TEST PASSED")


func _process(delta) -> void:
	if BasicData.regression_test_project:
		ValueCreator.random = false  # Results in RegressionTestProject must be always reproducible
	else:
		ValueCreator.random = true

	ValueCreator.number = 5
	ValueCreator.should_be_always_valid = true

	tests_all_functions()


# Test all functions
func tests_all_functions() -> void:
	for type in range(TYPE_MAX):
		if type == TYPE_NIL || type == TYPE_OBJECT:
			continue
		if debug_print:
			print("\n#################### " + type_to_name(type) + " ####################")

		thing = get_basic_thing(type)
		var method_list: Array = ClassDB.get_variant_method_list(type)

		# Removes excluded methods
		method_list = BasicData.remove_disabled_methods(method_list, BasicData.variant_exceptions)

		for method_data in method_list:
			if randi() % 2:
				if !BasicData.check_if_is_allowed(method_data):
					continue

				var is_there_object: bool = false
				for arg in method_data["args"]:
					if arg["type"] == TYPE_OBJECT || arg["type"] == TYPE_NIL:
						is_there_object = true
						break
				if is_there_object:
					continue

				var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, type_to_name(type), debug_print)

				var argument_string: String = ""
				for i in range(arguments.size()):
					argument_string += ParseArgumentType.return_gdscript_code_which_run_this_object(arguments[i])
					if i != arguments.size() - 1:
						argument_string += ", "

				if debug_print:
					var to_print: String = "GDSCRIPT CODE:     "
					to_print += ParseArgumentType.return_gdscript_code_which_run_this_object(thing)
					to_print += "." + method_data["name"] + "(" + argument_string + ")"
					print(to_print)

				#					print(ParseArgumentType.return_gdscript_code_which_run_this_object(arguments))
				#					print(argument_string)
				#					print("thing." + method_data["name"] + "(" + argument_string + ")")

				if expr.parse("thing." + method_data["name"] + "(" + argument_string + ")") != OK:
					printerr("ERROR: " + expr.get_error_text())
					#					assert(false)
					continue
				expr.execute([], self)
				assert(!expr.has_execute_failed())

				if use_always_new_object:
					thing = get_basic_thing(type)

				for argument in arguments:
					if argument is Node:
						argument.queue_free()
					elif argument is Object && !(argument is Reference):
						argument.free()


func type_to_name(type: int) -> String:
	var name: String

	match type:
		TYPE_AABB:
			name = "AABB"
		TYPE_ARRAY:
			name = "Array"
		TYPE_BASIS:
			name = "Basis"
		TYPE_BOOL:
			name = "bool"
		TYPE_COLOR:
			name = "Color"
		TYPE_COLOR_ARRAY:
			name = "PoolColorArray"
		TYPE_DICTIONARY:
			name = "Dictionary"
		TYPE_INT:
			name = "int"
		TYPE_INT_ARRAY:
			name = "PoolIntArray"
		TYPE_NODE_PATH:
			name = "NodePath"
		TYPE_PLANE:
			name = "Plane"
		TYPE_QUAT:
			name = "Quat"
		TYPE_RAW_ARRAY:
			name = "PoolByteArray"
		TYPE_REAL:
			name = "float"
		TYPE_REAL_ARRAY:
			name = "PoolRealArray"
		TYPE_RECT2:
			name = "Rect2"
		TYPE_RID:
			name = "RID"
		TYPE_STRING:
			name = "String"
		TYPE_STRING_ARRAY:
			name = "PoolStringArray"
		TYPE_TRANSFORM:
			name = "Transform"
		TYPE_TRANSFORM2D:
			name = "Transform2D"
		TYPE_VECTOR2:
			name = "Vector2"
		TYPE_VECTOR2_ARRAY:
			name = "PoolVector2Array"
		TYPE_VECTOR3:
			name = "Vector3"
		TYPE_VECTOR3_ARRAY:
			name = "PoolVector3Array"
		TYPE_OBJECT:
			assert(false, "Object not supported")
		TYPE_NIL:
			assert(false, "Variant not supported")
		_:
			assert(false, "Missing type --" + str(type) + "--, needs to be added to project")

	return name


func get_basic_thing(type: int):
	var thing

	match type:
		TYPE_AABB:
			thing = ValueCreator.get_aabb()
		TYPE_ARRAY:
			thing = ValueCreator.get_array()
		TYPE_BASIS:
			thing = ValueCreator.get_basis()
		TYPE_BOOL:
			thing = ValueCreator.get_bool()
		TYPE_COLOR:
			thing = ValueCreator.get_color()
		TYPE_COLOR_ARRAY:
			thing = ValueCreator.get_pool_color_array()
		TYPE_DICTIONARY:
			thing = ValueCreator.get_dictionary()
		TYPE_INT:
			thing = ValueCreator.get_int()
		TYPE_INT_ARRAY:
			thing = ValueCreator.get_pool_int_array()
		TYPE_NODE_PATH:
			thing = ValueCreator.get_nodepath()
		TYPE_PLANE:
			thing = ValueCreator.get_plane()
		TYPE_QUAT:
			thing = ValueCreator.get_quat()
		TYPE_RAW_ARRAY:
			thing = ValueCreator.get_pool_byte_array()
		TYPE_REAL:
			thing = ValueCreator.get_float()
		TYPE_REAL_ARRAY:
			thing = ValueCreator.get_pool_real_array()
		TYPE_RECT2:
			thing = ValueCreator.get_rect2()
		TYPE_RID:
			thing = RID()
		TYPE_STRING:
			thing = ValueCreator.get_string()
		TYPE_STRING_ARRAY:
			thing = ValueCreator.get_pool_string_array()
		TYPE_TRANSFORM:
			thing = ValueCreator.get_transform()
		TYPE_TRANSFORM2D:
			thing = ValueCreator.get_transform2D()
		TYPE_VECTOR2:
			thing = ValueCreator.get_vector2()
		TYPE_VECTOR2_ARRAY:
			thing = ValueCreator.get_pool_vector2_array()
		TYPE_VECTOR3:
			thing = ValueCreator.get_vector3()
		TYPE_VECTOR3_ARRAY:
			thing = ValueCreator.get_pool_vector3_array()
		TYPE_OBJECT:
			assert(false, "Object not supported")
		TYPE_NIL:
			assert(false, "Variant not supported")
		_:
			assert(false, "Missing type --" + str(type) + "--, needs to be added to project")

	return thing
