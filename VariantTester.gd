extends Node

var debug_print: bool = true
var use_always_new_object: bool = false  # Don't allow to "remeber" other function effects

var expr : Expression = Expression.new()

var thing
#func _ready() -> void:
#	print(Vector2(2,1).length())
#	assert(expr.parse("Vector2(2,1).length()") == OK)
#	print(expr.execute())
#	assert(!expr.has_execute_failed())
#	print("TEST PASSED")
	
	
#func _ready() -> void:
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
		if type == TYPE_NIL || type == TYPE_OBJECT || type == TYPE_SIGNAL:
			continue
		if debug_print:
			print("\n#################### " + type_to_name(type) + " ####################")
		

		thing = get_basic_thing(type)
		var method_list: Array = ClassDB.get_non_object_methods_list(type)

		# Removes excluded methods
		BasicData.remove_disabled_methods(method_list, BasicData.variant_exceptions)

		for method_data in method_list:
			if randi() % 2:
				if !BasicData.check_if_is_allowed(method_data):
					continue
				if method_data["name"] in ["decompress_dynamic"]:
					continue
				
				var is_there_object : bool = false
				for arg in method_data["args"]:
					if arg["type"] == TYPE_OBJECT || arg["type"] == TYPE_NIL|| arg["type"] == TYPE_SIGNAL:
						is_there_object = true
						break
				if is_there_object:
					continue

				var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, type_to_name(type), debug_print)
				
				var argument_string : String = ""
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
				expr.execute([],self)
#				assert(!expr.has_execute_failed())
				
				if use_always_new_object:
					thing = get_basic_thing(type)

				for argument in arguments:
					if argument is Node:
						argument.queue_free()
					elif argument is Object && !(argument is RefCounted):
						argument.free()


func type_to_name(type:int) -> String:
	var name : String
	
	if type == TYPE_AABB:
		name = "AABB"
	elif type == TYPE_ARRAY:
		name = "Array"
	elif type == TYPE_BASIS:
		name = "Basis"
	elif type == TYPE_BOOL:
		name = "bool"
	elif type == TYPE_COLOR:
		name = "Color"
	elif type == TYPE_COLOR_ARRAY:
		name = "PackedColorArray"
	elif type == TYPE_DICTIONARY:
		name = "Dictionary"
	elif type == TYPE_INT:
		name = "int"
	elif type == TYPE_INT32_ARRAY:
		name = "PackedInt32Array"
	elif type == TYPE_INT64_ARRAY:
		name = "PackedInt64Array"
	elif type == TYPE_NODE_PATH:
		name = "NodePath"
	elif type == TYPE_PLANE:
		name = "Plane"
	elif type == TYPE_QUATERNION:
		name = "Quaternion"
	elif type == TYPE_RAW_ARRAY:
		name = "PackedByteArray"
	elif type == TYPE_FLOAT:
		name = "float"
	elif type == TYPE_FLOAT32_ARRAY:
		name = "PackedFloat32Array"
	elif type == TYPE_FLOAT64_ARRAY:
		name = "PackedFloat64Array"
	elif type == TYPE_RECT2:
		name = "Rect2"
	elif type == TYPE_RID:
		name = "RID"
	elif type == TYPE_STRING:
		name = "String"
	elif type == TYPE_STRING_NAME:
		name = "StringName"
	elif type == TYPE_STRING_ARRAY:
		name = "PackedStringArray"
	elif type == TYPE_TRANSFORM3D:
		name = "Transform3D"
	elif type == TYPE_TRANSFORM2D:
		name = "Transform2D"
	elif type == TYPE_VECTOR2:
		name = "Vector2"
	elif type == TYPE_VECTOR2_ARRAY:
		name = "PackedVector2Array"
	elif type == TYPE_VECTOR2I:
		name = "Vector2i"
	elif type == TYPE_VECTOR3:
		name = "Vector3"
	elif type == TYPE_VECTOR3_ARRAY:
		name = "PackedVector3Array"
	elif type == TYPE_VECTOR3I:
		name = "Vector3i"
	elif type == TYPE_RECT2I:
		name = "Rect2i"
	elif type == TYPE_CALLABLE:
		name = "Callable"
	elif type == TYPE_OBJECT:
			assert(false, "Object not supported")
	elif type == TYPE_NIL:
			assert(false, "Variant not supported")
	else:
			assert(false, "Missing type, needs to be added to project")
	
	return name

func get_basic_thing(type:int):
	var thing
	
	if type == TYPE_AABB:
		thing = ValueCreator.get_aabb()
	elif type == TYPE_ARRAY:
		thing = ValueCreator.get_array()
	elif type == TYPE_BASIS:
		thing = ValueCreator.get_basis()
	elif type == TYPE_BOOL:
		thing = ValueCreator.get_bool()
	elif type == TYPE_COLOR:
		thing = ValueCreator.get_color()
	elif type == TYPE_COLOR_ARRAY:
		thing = ValueCreator.get_Packed_color_array()
	elif type == TYPE_DICTIONARY:
		thing = ValueCreator.get_dictionary()
	elif type == TYPE_INT:
		thing = ValueCreator.get_int()
	elif type == TYPE_INT32_ARRAY:
		thing = ValueCreator.get_Packed_int32_array()
	elif type == TYPE_INT64_ARRAY:
		thing = ValueCreator.get_Packed_int64_array()
	elif type == TYPE_NODE_PATH:
		thing = ValueCreator.get_nodepath()
	elif type == TYPE_PLANE:
		thing = ValueCreator.get_plane()
	elif type == TYPE_QUATERNION:
		thing =ValueCreator.get_quat()
	elif type == TYPE_RAW_ARRAY:
		thing = ValueCreator.get_Packed_byte_array()
	elif type == TYPE_FLOAT:
		thing = ValueCreator.get_float()
	elif type == TYPE_FLOAT32_ARRAY:
		thing = ValueCreator.get_Packed_float32_array()
	elif type == TYPE_FLOAT64_ARRAY:
		thing = ValueCreator.get_Packed_float64_array()
	elif type == TYPE_RECT2:
		thing = ValueCreator.get_rect2()
	elif type == TYPE_RID:
		thing = RID()
	elif type == TYPE_STRING:
		thing = ValueCreator.get_string()
	elif type == TYPE_STRING_NAME:
		thing = StringName(ValueCreator.get_string())
	elif type == TYPE_STRING_ARRAY:
		thing = ValueCreator.get_Packed_string_array()
	elif type == TYPE_TRANSFORM3D:
		thing = ValueCreator.get_transform3D()
	elif type == TYPE_TRANSFORM2D:
		thing = ValueCreator.get_transform2D()
	elif type == TYPE_VECTOR2:
		thing = ValueCreator.get_vector2()
	elif type == TYPE_VECTOR2_ARRAY:
		thing = ValueCreator.get_Packed_vector2_array()
	elif type == TYPE_VECTOR2I:
		thing = ValueCreator.get_vector2i()
	elif type == TYPE_VECTOR3:
		thing = ValueCreator.get_vector3()
	elif type == TYPE_VECTOR3_ARRAY:
		thing = ValueCreator.get_Packed_vector3_array()
	elif type == TYPE_VECTOR3I:
		thing = ValueCreator.get_vector3i()
	elif type == TYPE_RECT2I:
		thing = ValueCreator.get_rect2i()
	elif type == TYPE_CALLABLE:
		thing = Callable(self, "ff")
	else:
		assert(false, "Missing type, needs to be added to project")
	
	return thing
