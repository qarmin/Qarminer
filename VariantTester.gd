extends Node

var debug_print: bool = true
var use_always_new_object: bool = false  # Don't allow to "remeber" other function effects

var expr: Expression = Expression.new()

var temp_gdscript_file: File = File.new()
var loaded_gdscript

var thing


func _process(delta) -> void:
	ValueCreator.number = 10000

	HelpFunctions.initialize_list_of_available_classes()

	tests_all_functions()


var max_numbers: Array = [2, 5, 10, 100, 1000, 10000, 100000]


# Test all functions
func tests_all_functions() -> void:
	ValueCreator.number = max_numbers[randi() % max_numbers.size()]
	for type in range(TYPE_MAX):
		if type == TYPE_NIL || type == TYPE_OBJECT:
			continue  # TODO Add support for objects
		if debug_print:
			print("\n#################### " + type_to_name(type) + " ####################")

		thing = get_basic_thing(type)
		var method_list: Array = ClassDB.get_variant_method_list(type)

		method_list = HelpFunctions.remove_disabled_methods(method_list, BasicData.variant_exceptions)

		for method_data in method_list:
			if !HelpFunctions.check_if_is_allowed(method_data):
				continue

			var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, type_to_name(type), debug_print)

			var argument_string: String = ""
			for i in range(arguments.size()):
				argument_string += ParseArgumentType.return_gdscript_code_which_run_this_object(arguments[i])
				if i != arguments.size() - 1:
					argument_string += ", "
			if debug_print:
#				var to_print: String = "GDSCRIPT CODE:     "
				var to_print: String = "\t"
				to_print += ParseArgumentType.return_gdscript_code_which_run_this_object(thing)
				to_print += "." + method_data["name"] + "(" + argument_string + ")"
				print(to_print)

			temp_gdscript_file.open("temp_gdscript.gd", File.WRITE)
			temp_gdscript_file.store_string("static func test_function() -> void:\n\t")
			# TODO create temporary variables
			temp_gdscript_file.store_string(ParseArgumentType.return_gdscript_code_which_run_this_object(thing) + "." + method_data["name"] + "(" + argument_string + ")")
			# TODO Remove files which needs to be removed
			temp_gdscript_file.flush()

			# TODO, save to files which things are printed to screen

			loaded_gdscript = load("temp_gdscript.gd")
			loaded_gdscript.test_function()

			for argument in arguments:
				if argument is Object:
					HelpFunctions.remove_thing(argument)


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
		TYPE_PACKED_COLOR_ARRAY:
			name = "PackedColorArray"
		TYPE_DICTIONARY:
			name = "Dictionary"
		TYPE_INT:
			name = "int"
		TYPE_PACKED_INT32_ARRAY:
			name = "PackedInt32Array"
		TYPE_NODE_PATH:
			name = "NodePath"
		TYPE_PLANE:
			name = "Plane"
		TYPE_QUATERNION:
			name = "Quaternion"
		TYPE_PACKED_BYTE_ARRAY:
			name = "PackedByteArray"
		TYPE_FLOAT:
			name = "float"
		TYPE_PACKED_FLOAT32_ARRAY:
			name = "PackedFloat32Array"
		TYPE_RECT2:
			name = "Rect2"
		TYPE_RID:
			name = "RID"
		TYPE_STRING:
			name = "String"
		TYPE_PACKED_STRING_ARRAY:
			name = "PackedStringArray"
		TYPE_TRANSFORM3D:
			name = "Transform3D"
		TYPE_TRANSFORM2D:
			name = "Transform2D"
		TYPE_VECTOR2:
			name = "Vector2"
		TYPE_PACKED_VECTOR2_ARRAY:
			name = "PackedVector2Array"
		TYPE_VECTOR3:
			name = "Vector3"
		TYPE_PACKED_VECTOR3_ARRAY:
			name = "PackedVector3Array"
#		# TODOGODOT4
		TYPE_VECTOR2I:
			name = "Vector2i"
		TYPE_VECTOR3I:
			name = "Vector3i"
		TYPE_VECTOR4:
			name = "Vector4"
		TYPE_VECTOR4I:
			name = "Vector4i"
		TYPE_RECT2I:
			name = "Rect2i"
		TYPE_STRING_NAME:
			name = "StringName"
		TYPE_CALLABLE:
			name = "Callable"
		TYPE_SIGNAL:
			name = "Signal"
		TYPE_PACKED_FLOAT64_ARRAY:
			thing = "PackedFloat64Array"
		TYPE_PACKED_INT64_ARRAY:
			thing = "PackedInt64Array"
		TYPE_PROJECTION:
			thing = "Projection"
		TYPE_OBJECT:
			assert(false)  #,"Object not supported")
		TYPE_NIL:
			assert(false)  #,"Variant not supported")
		_:
			assert(false)  #,"Missing type --" + str(type) + "--, needs to be added to project")

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
		TYPE_PACKED_COLOR_ARRAY:
			thing = ValueCreator.get_packed_color_array()
		TYPE_DICTIONARY:
			thing = ValueCreator.get_dictionary()
		TYPE_INT:
			thing = ValueCreator.get_int()
		TYPE_PACKED_INT32_ARRAY:
			thing = ValueCreator.get_packed_int32_array()
		TYPE_NODE_PATH:
			thing = ValueCreator.get_nodepath()
		TYPE_PLANE:
			thing = ValueCreator.get_plane()
		TYPE_QUATERNION:
			thing = ValueCreator.get_quaternion()
		TYPE_PACKED_BYTE_ARRAY:
			thing = ValueCreator.get_packed_byte_array()
		TYPE_FLOAT:
			thing = ValueCreator.get_float()
		TYPE_PACKED_FLOAT32_ARRAY:
			thing = ValueCreator.get_packed_float32_array()
		TYPE_RECT2:
			thing = ValueCreator.get_rect2()
		TYPE_RID:
			thing = RID()
		TYPE_STRING:
			thing = ValueCreator.get_string()
		TYPE_PACKED_STRING_ARRAY:
			thing = ValueCreator.get_packed_string_array()
		TYPE_TRANSFORM3D:
			thing = ValueCreator.get_transform3d()
		TYPE_TRANSFORM2D:
			thing = ValueCreator.get_transform2D()
		TYPE_VECTOR2:
			thing = ValueCreator.get_vector2()
		TYPE_PACKED_VECTOR2_ARRAY:
			thing = ValueCreator.get_packed_vector2_array()
		TYPE_VECTOR3:
			thing = ValueCreator.get_vector3()
		TYPE_PACKED_VECTOR3_ARRAY:
			thing = ValueCreator.get_packed_vector3_array()
		TYPE_OBJECT:
			assert(false)  #,"Object not supported")
		TYPE_NIL:
			assert(false)  #,"Variant not supported")
		# TODOGODOT4
		TYPE_CALLABLE:
			thing = Callable(BoxMesh.new(), "Rar")
		TYPE_VECTOR3I:
			thing = ValueCreator.get_vector3i()
		TYPE_VECTOR4:
			thing = ValueCreator.get_vector4()
		TYPE_VECTOR4I:
			thing = ValueCreator.get_vector4i()
		TYPE_VECTOR2I:
			thing = ValueCreator.get_vector2i()
		TYPE_STRING_NAME:
			thing = ValueCreator.get_string_name()
		TYPE_RECT2I:
			thing = ValueCreator.get_rect2i()
		TYPE_PACKED_FLOAT64_ARRAY:
			thing = ValueCreator.get_packed_float64_array()
		TYPE_PACKED_INT64_ARRAY:
			thing = ValueCreator.get_packed_int64_array()
		TYPE_SIGNAL:
			thing = ValueCreator.get_signal()
		TYPE_PROJECTION:
			thing = ValueCreator.get_projection()
		_:
			assert(false)  #,"Missing type --" + str(type) + "--, needs to be added to project")

	return thing
