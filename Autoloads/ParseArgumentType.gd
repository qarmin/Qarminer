extends Node

### Scripts to arguments and return needed info about them.


func parse_and_return_functions_to_create_object(method_data: Dictionary, name_of_class: String, debug_print: bool = false) -> Array:
	var arguments_array: Array = []

	for argument in method_data["args"]:
		match argument.type:
			TYPE_NIL:  # Looks that this means VARIANT not null
				arguments_array.push_back("ValueCreator.get_variant()")
			TYPE_AABB:
				arguments_array.push_back("ValueCreator.get_aabb()")
			TYPE_ARRAY:
				arguments_array.push_back("ValueCreator.get_array()")
			TYPE_BASIS:
				arguments_array.push_back("ValueCreator.get_basis()")
			TYPE_BOOL:
				arguments_array.push_back("ValueCreator.get_bool()")
			TYPE_COLOR:
				arguments_array.push_back("ValueCreator.get_color()")
			TYPE_PACKED_COLOR_ARRAY:
				arguments_array.push_back("ValueCreator.get_packed_color_array()")
			TYPE_DICTIONARY:
				arguments_array.push_back("ValueCreator.get_dictionary()")
			TYPE_INT:
				arguments_array.push_back("ValueCreator.get_int()")
			TYPE_PACKED_INT32_ARRAY:
				arguments_array.push_back("ValueCreator.get_packed_int32_array()")
			TYPE_NODE_PATH:
				arguments_array.push_back("ValueCreator.get_nodepath()")
			TYPE_OBJECT:
				if String(argument["class_name"]).is_empty():
					arguments_array.push_back('ValueCreator.get_object("Object")')
				else:
					arguments_array.push_back('ValueCreator.get_object("' + String(argument["class_name"]) + '")')
			TYPE_PLANE:
				arguments_array.push_back("ValueCreator.get_plane()")
			TYPE_QUATERNION:
				arguments_array.push_back("ValueCreator.get_quaternion()")
			TYPE_PACKED_BYTE_ARRAY:
				arguments_array.push_back("ValueCreator.get_packed_byte_array()")
			TYPE_FLOAT:
				arguments_array.push_back("ValueCreator.get_float()")
			TYPE_PACKED_FLOAT32_ARRAY:
				arguments_array.push_back("ValueCreator.get_packed_float32_array()")
			TYPE_RECT2:
				arguments_array.push_back("ValueCreator.get_rect2()")
			TYPE_RID:
				arguments_array.push_back("RID()")
			TYPE_STRING:
				arguments_array.push_back("ValueCreator.get_string()")
			TYPE_PACKED_STRING_ARRAY:
				arguments_array.push_back("ValueCreator.get_packed_string_array()")
			TYPE_TRANSFORM3D:
				arguments_array.push_back("ValueCreator.get_transform3d()")
			TYPE_TRANSFORM2D:
				arguments_array.push_back("ValueCreator.get_transform2d()")
			TYPE_VECTOR2:
				arguments_array.push_back("ValueCreator.get_vector2()")
			TYPE_PACKED_VECTOR2_ARRAY:
				arguments_array.push_back("ValueCreator.get_packed_vector2_array()")
			TYPE_VECTOR3:
				arguments_array.push_back("ValueCreator.get_vector3()")
			TYPE_PACKED_VECTOR3_ARRAY:
				arguments_array.push_back("ValueCreator.get_packed_vector3_array()")
#			# TODOGODOT4
			TYPE_CALLABLE:
				arguments_array.push_back("Callable(BoxMesh.new(), 'Rar')")  # TODO this line should not create callable object but string!!!!
			TYPE_VECTOR2I:
				arguments_array.push_back("ValueCreator.get_vector2i()")
			TYPE_VECTOR3I:
				arguments_array.push_back("ValueCreator.get_vector3i()")
			TYPE_VECTOR4:
				arguments_array.push_back("ValueCreator.get_vector4()")
			TYPE_VECTOR4I:
				arguments_array.push_back("ValueCreator.get_vector4i()")
			TYPE_STRING_NAME:
				arguments_array.push_back("ValueCreator.get_string_name()")
			TYPE_RECT2I:
				arguments_array.push_back("ValueCreator.get_rect2i()")
			TYPE_PACKED_FLOAT64_ARRAY:
				arguments_array.push_back("ValueCreator.get_packed_float64_array()")
			TYPE_PACKED_INT64_ARRAY:
				arguments_array.push_back("ValueCreator.get_packed_int64_array()")
			TYPE_SIGNAL:
				arguments_array.push_back("ValueCreator.get_signal()")
			TYPE_PROJECTION:
				arguments_array.push_back("ValueCreator.get_projection()")
			_:
				assert(false)  #,"Missing type --" + str(argument.type) + "-- needs to be added to project")

	if debug_print:
		print("\n" + name_of_class + "." + method_data["name"] + " --- executing with " + str(arguments_array.size()) + " parameters " + str(arguments_array))
	return arguments_array


func parse_and_return_objects(method_data: Dictionary, name_of_class: String, debug_print: bool = false) -> Array:
	var arguments_array: Array = []

	for argument in method_data["args"]:
		match argument.type:
			TYPE_NIL:  # Looks that this means VARIANT not null
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
			TYPE_PACKED_COLOR_ARRAY:
				arguments_array.push_back(ValueCreator.get_packed_color_array())
			TYPE_DICTIONARY:
				arguments_array.push_back(ValueCreator.get_dictionary())
			TYPE_INT:
				arguments_array.push_back(ValueCreator.get_int())
			TYPE_PACKED_INT32_ARRAY:
				arguments_array.push_back(ValueCreator.get_packed_int32_array())
			TYPE_NODE_PATH:
				arguments_array.push_back(ValueCreator.get_nodepath())
			TYPE_OBJECT:
				if String(argument["class_name"]).is_empty():
					var obj: Object = ValueCreator.get_object("Object")
					arguments_array.push_back(obj)
				else:
					var obj: Object = ValueCreator.get_object(argument["class_name"])
					arguments_array.push_back(obj)
#				assert(obj != null) #,"Failed to create an object of type " + argument["class_name"])

			TYPE_PLANE:
				arguments_array.push_back(ValueCreator.get_plane())
			TYPE_QUATERNION:
				arguments_array.push_back(ValueCreator.get_quaternion())
			TYPE_PACKED_BYTE_ARRAY:
				arguments_array.push_back(ValueCreator.get_packed_byte_array())
			TYPE_FLOAT:
				arguments_array.push_back(ValueCreator.get_float())
			TYPE_PACKED_FLOAT32_ARRAY:
				arguments_array.push_back(ValueCreator.get_packed_float32_array())
			TYPE_RECT2:
				arguments_array.push_back(ValueCreator.get_rect2())
			TYPE_RID:
				arguments_array.push_back(RID())
			TYPE_STRING:
				arguments_array.push_back(ValueCreator.get_string())
			TYPE_PACKED_STRING_ARRAY:
				arguments_array.push_back(ValueCreator.get_packed_string_array())
			TYPE_TRANSFORM3D:
				arguments_array.push_back(ValueCreator.get_transform3d())
			TYPE_TRANSFORM2D:
				arguments_array.push_back(ValueCreator.get_transform2d())
			TYPE_VECTOR2:
				arguments_array.push_back(ValueCreator.get_vector2())
			TYPE_PACKED_VECTOR2_ARRAY:
				arguments_array.push_back(ValueCreator.get_packed_vector2_array())
			TYPE_VECTOR3:
				arguments_array.push_back(ValueCreator.get_vector3())
			TYPE_PACKED_VECTOR3_ARRAY:
				arguments_array.push_back(ValueCreator.get_packed_vector3_array())
#			# TODOGODOT4
			TYPE_CALLABLE:
				arguments_array.push_back(Callable(BoxMesh.new(), "Rar"))
			TYPE_VECTOR2I:
				arguments_array.push_back(ValueCreator.get_vector2i())
			TYPE_VECTOR3I:
				arguments_array.push_back(ValueCreator.get_vector3i())
			TYPE_VECTOR4:
				arguments_array.push_back(ValueCreator.get_vector4())
			TYPE_VECTOR4I:
				arguments_array.push_back(ValueCreator.get_vector4i())
			TYPE_STRING_NAME:
				arguments_array.push_back(ValueCreator.get_string_name())
			TYPE_RECT2I:
				arguments_array.push_back(ValueCreator.get_rect2i())
			TYPE_PACKED_FLOAT64_ARRAY:
				arguments_array.push_back(ValueCreator.get_packed_float64_array())
			TYPE_PACKED_INT64_ARRAY:
				arguments_array.push_back(ValueCreator.get_packed_int64_array())
			TYPE_SIGNAL:
				arguments_array.push_back(ValueCreator.get_signal())
			TYPE_PROJECTION:
				arguments_array.push_back(ValueCreator.get_projection())
			_:
				assert(false)  #,"Missing type --" + str(argument.type) + "-- needs to be added to project")

	if debug_print:
		print("\n" + name_of_class + "." + method_data["name"] + " --- executing with " + str(arguments_array.size()) + " parameters " + str(arguments_array))
	return arguments_array


func return_gdscript_code_which_run_this_object(data) -> String:
	# TODO workaround https://github.com/godotengine/godot/pull/68136
	if typeof(data) == TYPE_NIL:
#	if data == null:
		return "null"

	var return_string: String = ""

	match typeof(data):
		TYPE_NIL:  # Looks that this means VARIANT not null
			assert("false")  #,"This is even possible?")
		TYPE_AABB:
			return_string = "AABB("
			return_string += return_gdscript_code_which_run_this_object(data.position)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.size)
			return_string += ")"
		TYPE_ARRAY:
			return_string = "Array(["
			for i in data.size():
				return_string += return_gdscript_code_which_run_this_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_BASIS:
			return_string = "Basis("
			return_string += return_gdscript_code_which_run_this_object(data.x)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.y)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.z)
			return_string += ")"
		TYPE_BOOL:
			if data == true:
				return_string = "true"
			else:
				return_string = "false"
		TYPE_COLOR:
			return_string = "Color("
			return_string += return_gdscript_code_which_run_this_object(data.r)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.g)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.b)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.a)
			return_string += ")"
		TYPE_PACKED_COLOR_ARRAY:
			return_string = "PackedColorArray(["
			for i in data.size():
				return_string += return_gdscript_code_which_run_this_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_DICTIONARY:
			return_string = "{"
			for i in data.size():
				return_string += return_gdscript_code_which_run_this_object(data.keys()[i])
				return_string += " : "
				return_string += return_gdscript_code_which_run_this_object(data.values()[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "}"
		TYPE_INT:
			return_string = str(data)
		TYPE_PACKED_INT32_ARRAY:
			return_string = "PackedInt32Array(["
			for i in data.size():
				return_string += return_gdscript_code_which_run_this_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_NODE_PATH:
			return_string = "NodePath("
			return_string += return_gdscript_code_which_run_this_object(str(data))
			return_string += ")"
		TYPE_OBJECT:
			if data == null:
				return_string = "null"
			else:
				var name_of_class: String = data.get_class()
				if (
					ClassDB.is_parent_class(name_of_class, "Object")
					&& !ClassDB.is_parent_class(name_of_class, "Node")
					&& !ClassDB.is_parent_class(name_of_class, "RefCounted")
					&& !ClassDB.class_has_method(name_of_class, "new")
				):
					return_string += 'ClassDB.instantiate("' + name_of_class + '")'
				else:
					return_string = name_of_class.trim_prefix("_")
					return_string += ".new()"

		TYPE_PLANE:
			return_string = "Plane("
			return_string += return_gdscript_code_which_run_this_object(data.x)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.y)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.z)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.d)
			return_string += ")"
		TYPE_QUATERNION:
			return_string = "Quaternion("
			return_string += return_gdscript_code_which_run_this_object(data.x)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.y)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.z)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.w)
			return_string += ")"
		TYPE_PACKED_BYTE_ARRAY:
			return_string = "PackedByteArray(["
			for i in data.size():
				return_string += return_gdscript_code_which_run_this_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_FLOAT:
			if is_inf(data):
				if data > 0:
					return_string = "INF"
				else:
					return_string = "-INF"
			elif is_nan(data):
				if data > 0:
					return_string = "NAN"
				else:
					return_string = "-NAN"
			else:
				return_string = str(data)
		TYPE_PACKED_FLOAT32_ARRAY:
			return_string = "PackedFloat32Array(["
			for i in data.size():
				return_string += return_gdscript_code_which_run_this_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_RECT2:
			return_string = "Rect2("
			return_string += return_gdscript_code_which_run_this_object(data.position)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.size)
			return_string += ")"
		TYPE_RID:
			return_string = "RID()"
		TYPE_STRING:
			return_string = '"' + data + '"'
		TYPE_PACKED_STRING_ARRAY:
			return_string = "PackedStringArray(["
			for i in data.size():
				return_string += return_gdscript_code_which_run_this_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_TRANSFORM3D:
			return_string = "Transform3D("
			return_string += return_gdscript_code_which_run_this_object(data.basis)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.origin)
			return_string += ")"
		TYPE_TRANSFORM2D:
			return_string = "Transform2D("
			return_string += return_gdscript_code_which_run_this_object(data.x)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.y)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.origin)
			return_string += ")"
		TYPE_VECTOR2:
			return_string = "Vector2("
			return_string += return_gdscript_code_which_run_this_object(data.x)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.y)
			return_string += ")"
		TYPE_PACKED_VECTOR2_ARRAY:
			return_string = "PackedVector2Array(["
			for i in data.size():
				return_string += return_gdscript_code_which_run_this_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_VECTOR3:
			return_string = "Vector3("
			return_string += return_gdscript_code_which_run_this_object(data.x)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.y)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.z)
			return_string += ")"
		TYPE_PACKED_VECTOR3_ARRAY:
			return_string = "PackedVector3Array(["
			for i in data.size():
				return_string += return_gdscript_code_which_run_this_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"

#		# TODOGODOT4
		TYPE_CALLABLE:
			return_string = 'Callable(BoxMesh.new(),"")'
		TYPE_STRING_NAME:
			return_string = "StringName("
			return_string += return_gdscript_code_which_run_this_object(str(data))
			return_string += ")"
		TYPE_VECTOR2I:
			return_string = "Vector2i("
			return_string += return_gdscript_code_which_run_this_object(data.x)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.y)
			return_string += ")"
		TYPE_VECTOR3I:
			return_string = "Vector3i("
			return_string += return_gdscript_code_which_run_this_object(data.x)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.y)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.z)
			return_string += ")"
		TYPE_VECTOR4:
			return_string = "Vector4("
			return_string += return_gdscript_code_which_run_this_object(data.x)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.y)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.z)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.w)
			return_string += ")"
		TYPE_VECTOR4I:
			return_string = "Vector4i("
			return_string += return_gdscript_code_which_run_this_object(data.x)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.y)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.z)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.w)
			return_string += ")"
		TYPE_RECT2I:
			return_string = "Rect2i("
			return_string += return_gdscript_code_which_run_this_object(data.position)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.size)
			return_string += ")"
		TYPE_PACKED_FLOAT64_ARRAY:
			return_string = "PackedFloat64Array(["
			for i in data.size():
				return_string += return_gdscript_code_which_run_this_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_PACKED_INT64_ARRAY:
			return_string = "PackedInt64Array(["
			for i in data.size():
				return_string += return_gdscript_code_which_run_this_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_SIGNAL:
			return_string = "Signal()"  # TODO, not sure
		TYPE_PROJECTION:
			return_string = "Projection("
			return_string += return_gdscript_code_which_run_this_object(data.x)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.y)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.w)
			return_string += ", "
			return_string += return_gdscript_code_which_run_this_object(data.z)
			return_string += ")"
		_:
			assert(false)  #,"Missing type --" + str(typeof(data)) + "-- needs to be added to project")

	return return_string
