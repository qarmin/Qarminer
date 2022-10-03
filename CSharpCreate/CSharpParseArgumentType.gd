extends Node

### Scripts to arguments and return needed info about them.


### Class which contains informations about used
class SingleArgument:
	var name: String  # E.G. var roman, can be empty, so temp variable isn't created(nodes and objects must be created with temp_variable due to memory leaks)
	var type: String  # np. Vector2 or Object
	var value: String  # np. randi() % 100 or
	var is_object: bool = false  # Check if this is object e.g. Node not Vector2
	var is_only_object: bool = false  # Only needs to freed with super.free()
	var is_only_reference: bool = false  # Don't needs to be removed manually
	var is_only_node: bool = false  # Needs to be removed with super.queue_free()


func create_gdscript_arguments(arguments: Array) -> Array:
	var argument_array: Array = []

	var counter = 0
	for argument in arguments:
		counter += 1
		var sa: SingleArgument = SingleArgument.new()
		sa.name = "variable" + str(counter)
		match argument["type"]:
			TYPE_NIL:  # Looks that this means VARIANT not null
				sa.type = "Variant"
				sa.value = "false"
			TYPE_AABB:
				sa.type = "AABB"
				sa.value = CSharpValueCreator.get_aabb_string()
			TYPE_ARRAY:
				sa.type = "Array"
				sa.value = "[]"
			TYPE_BASIS:
				sa.type = "Basis"
				sa.value = CSharpValueCreator.get_basis_string()
			TYPE_BOOL:
				sa.type = "bool"
				sa.value = CSharpValueCreator.get_bool_string().to_lower()
			TYPE_COLOR:
				sa.type = "Color"
				sa.value = CSharpValueCreator.get_color_string()
			TYPE_PACKED_COLOR_ARRAY:
				sa.type = "PackedColorArray"
				sa.value = "PackedColorArray([])"
			TYPE_DICTIONARY:
				sa.type = "Dictionary"
				sa.value = "{}"  # TODO Why not all use CSharpValueCreator?
			TYPE_INT:
				sa.type = "int"
				sa.value = CSharpValueCreator.get_int_string()
			TYPE_PACKED_INT32_ARRAY:
				sa.type = "PackedInt32Array"
				sa.value = "PackedInt32Array([])"
			TYPE_NODE_PATH:
				sa.type = "NodePath"
				sa.value = 'NodePath(".")'
			TYPE_OBJECT:
				sa.type = CSharpValueCreator.get_object_string(argument["class_name"])
				sa.value = sa.type + ".new()"

				sa.is_object = true
				if ClassDB.is_parent_class(sa.type, "Node"):
					sa.is_only_node = true
				elif ClassDB.is_parent_class(sa.type, "RefCounted"):
					sa.is_only_reference = true
				else:
					sa.is_only_object = true

			TYPE_PLANE:
				sa.type = "Plane"
				sa.value = CSharpValueCreator.get_plane_string()
			TYPE_QUATERNION:
				sa.type = "Quaternion"
				sa.value = CSharpValueCreator.get_quat_string()
			TYPE_PACKED_BYTE_ARRAY:
				sa.type = "PackedByteArray"
				sa.value = "PackedByteArray([])"
			TYPE_FLOAT:
				sa.type = "float"
				sa.value = CSharpValueCreator.get_float_string()
			TYPE_PACKED_FLOAT32_ARRAY:
				sa.type = "PackedFloat32Array"
				sa.value = "PackedFloat32Array([])"
			TYPE_RECT2:
				sa.type = "Rect2"
				sa.value = CSharpValueCreator.get_rect2_string()
			TYPE_RID:
				sa.type = "RID"
				sa.value = "RID()"
			TYPE_STRING:
				sa.type = "String"
				sa.value = CSharpValueCreator.get_string_string()
			TYPE_PACKED_STRING_ARRAY:
				sa.type = "PackedStringArray"
				sa.value = "PackedStringArray([])"
			TYPE_TRANSFORM3D:
				sa.type = "Transform3D"
				sa.value = CSharpValueCreator.get_transform_string()
			TYPE_TRANSFORM2D:
				sa.type = "Transform2D"
				sa.value = CSharpValueCreator.get_transform2d_string()
			TYPE_VECTOR2:
				sa.type = "Vector2"
				sa.value = CSharpValueCreator.get_vector2_string()
			TYPE_PACKED_VECTOR2_ARRAY:
				sa.type = "PackedVector2Array"
				sa.value = "PackedVector2Array([])"
			TYPE_VECTOR3:
				sa.type = "Vector3"
				sa.value = CSharpValueCreator.get_vector3_string()
			TYPE_PACKED_VECTOR3_ARRAY:
				sa.type = "PackedVector3Array"
				sa.value = "PackedVector3Array([])"
			_:
				assert(false)  #,"Missing type, needs to be added to project")
		argument_array.append(sa)

	return argument_array


func parse_and_return_objects(method_data: Dictionary, name_of_class: String, debug_print: bool = false) -> Array:
	var arguments_array: Array = []

	for argument in method_data["args"]:
		match argument.type:
			TYPE_NIL:  # Looks that this means VARIANT not null
				if CSharpValueCreator.random == false:
					arguments_array.push_back(false)
				else:
					if randi() % 3:
						arguments_array.push_back(CSharpValueCreator.get_array())
					elif randi() % 3:
						arguments_array.push_back(CSharpValueCreator.get_object("Object"))
					elif randi() % 3:
						arguments_array.push_back(CSharpValueCreator.get_dictionary())
					elif randi() % 3:
						arguments_array.push_back(CSharpValueCreator.get_string())
					elif randi() % 3:
						arguments_array.push_back(CSharpValueCreator.get_int())
					else:
						arguments_array.push_back(CSharpValueCreator.get_basis())
			TYPE_AABB:
				arguments_array.push_back(CSharpValueCreator.get_aabb())
			TYPE_ARRAY:
				arguments_array.push_back(CSharpValueCreator.get_array())
			TYPE_BASIS:
				arguments_array.push_back(CSharpValueCreator.get_basis())
			TYPE_BOOL:
				arguments_array.push_back(CSharpValueCreator.get_bool())
			TYPE_COLOR:
				arguments_array.push_back(CSharpValueCreator.get_color())
			TYPE_PACKED_COLOR_ARRAY:
				arguments_array.push_back(CSharpValueCreator.get_packed_color_array())
			TYPE_DICTIONARY:
				arguments_array.push_back(CSharpValueCreator.get_dictionary())
			TYPE_INT:
				arguments_array.push_back(CSharpValueCreator.get_int())
			TYPE_PACKED_INT32_ARRAY:
				arguments_array.push_back(CSharpValueCreator.get_packed_int_array())
			TYPE_NODE_PATH:
				arguments_array.push_back(CSharpValueCreator.get_nodepath())
			TYPE_OBJECT:
				if CSharpValueCreator.random && randi() % 2:
					arguments_array.push_back(null)
				else:
					var obj: Object = CSharpValueCreator.get_object(argument["class_name"])
					arguments_array.push_back(obj)
					assert(obj != null)  #,"Failed to create an object of type " + argument["class_name"])

			TYPE_PLANE:
				arguments_array.push_back(CSharpValueCreator.get_plane())
			TYPE_QUATERNION:
				arguments_array.push_back(CSharpValueCreator.get_quat())
			TYPE_PACKED_BYTE_ARRAY:
				arguments_array.push_back(CSharpValueCreator.get_packed_byte_array())
			TYPE_FLOAT:
				arguments_array.push_back(CSharpValueCreator.get_float())
			TYPE_PACKED_FLOAT32_ARRAY:
				arguments_array.push_back(CSharpValueCreator.get_packed_real_array())
			TYPE_RECT2:
				arguments_array.push_back(CSharpValueCreator.get_rect2())
			TYPE_RID:
				arguments_array.push_back(RID())
			TYPE_STRING:
				arguments_array.push_back(CSharpValueCreator.get_string())
			TYPE_PACKED_STRING_ARRAY:
				arguments_array.push_back(CSharpValueCreator.get_packed_string_array())
			TYPE_TRANSFORM3D:
				arguments_array.push_back(CSharpValueCreator.get_transform())
			TYPE_TRANSFORM2D:
				arguments_array.push_back(CSharpValueCreator.get_transform2d())
			TYPE_VECTOR2:
				arguments_array.push_back(CSharpValueCreator.get_vector2())
			TYPE_PACKED_VECTOR2_ARRAY:
				arguments_array.push_back(CSharpValueCreator.get_packed_vector2_array())
			TYPE_VECTOR3:
				arguments_array.push_back(CSharpValueCreator.get_vector3())
			TYPE_PACKED_VECTOR3_ARRAY:
				arguments_array.push_back(CSharpValueCreator.get_packed_vector3_array())
			_:
				assert(false)  #,"Missing type, needs to be added to project")

	if debug_print:
		print("\n" + name_of_class + "." + method_data["name"] + " --- executing with " + str(arguments_array.size()) + " parameters " + str(arguments_array))
	return arguments_array


func return_gdscript_code_which_run_this_object(data) -> String:
	if data == null:
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
		_:
			assert(false)  #,"Missing type, needs to be added to project")

	return return_string
