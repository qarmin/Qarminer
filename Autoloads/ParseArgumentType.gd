extends Node


class SingleArgument:
	var name: String  # E.G. var roman, can be empty, so temp variable isn't created(nodes and objects must be created with temp_variable due to memory leaks)
	var type: String  # np. Vector2 or Object
	var value: String  # np. randi() % 100 or
	var is_object: bool = false  # Check if this is object e.g. Node not Vector2
	var is_only_object: bool = false  # Only needs to freed with .free()
	var is_only_reference: bool = false  # Don't needs to be removed manually
	var is_only_node: bool = false  # Needs to be removed with .queue_free()


func create_gdscript_arguments(arguments: Array) -> Array:
	var argument_array: Array = []

	ValueCreator.number = 10
	ValueCreator.random = true
	ValueCreator.should_be_always_valid = true  # DO NOT CHANGE, BECAUSE NON VALID VALUES WILL SHOW GDSCRIPT ERRORS!

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
				sa.value = ValueCreator.get_aabb_string()
			TYPE_ARRAY:
				sa.type = "Array"
				sa.value = "[]"
			TYPE_BASIS:
				sa.type = "Basis"
				sa.value = ValueCreator.get_basis_string()
			TYPE_BOOL:
				sa.type = "bool"
				sa.value = ValueCreator.get_bool_string().to_lower()
			TYPE_COLOR:
				sa.type = "Color"
				sa.value = ValueCreator.get_color_string()
			TYPE_COLOR_ARRAY:
				sa.type = "PoolColorArray"
				sa.value = "PoolColorArray([])"
			TYPE_DICTIONARY:
				sa.type = "Dictionary"
				sa.value = "{}"  # TODO Why not all use ValueCreator?
			TYPE_INT:
				sa.type = "int"
				sa.value = ValueCreator.get_int_string()
			TYPE_INT_ARRAY:
				sa.type = "PoolIntArray"
				sa.value = "PoolIntArray([])"
			TYPE_NODE_PATH:
				sa.type = "NodePath"
				sa.value = "NodePath(\".\")"
			TYPE_OBJECT:
				sa.type = ValueCreator.get_object_string(argument["class_name"])
				sa.value = sa.type + ".new()"

				sa.is_object = true
				if ClassDB.is_parent_class(sa.type, "Node"):
					sa.is_only_node = true
				elif ClassDB.is_parent_class(sa.type, "Reference"):
					sa.is_only_reference = true
				else:
					sa.is_only_object = true

			TYPE_PLANE:
				sa.type = "Plane"
				sa.value = ValueCreator.get_plane_string()
			TYPE_QUAT:
				sa.type = "Quat"
				sa.value = ValueCreator.get_quat_string()
			TYPE_RAW_ARRAY:
				sa.type = "PoolByteArray"
				sa.value = "PoolByteArray([])"
			TYPE_REAL:
				sa.type = "float"
				sa.value = ValueCreator.get_float_string()
			TYPE_REAL_ARRAY:
				sa.type = "PoolRealArray"
				sa.value = "PoolRealArray([])"
			TYPE_RECT2:
				sa.type = "Rect2"
				sa.value = ValueCreator.get_rect2_string()
			TYPE_RID:
				sa.type = "RID"
				sa.value = "RID()"
			TYPE_STRING:
				sa.type = "String"
				sa.value = ValueCreator.get_string_string()
			TYPE_STRING_ARRAY:
				sa.type = "PoolStringArray"
				sa.value = "PoolStringArray([])"
			TYPE_TRANSFORM:
				sa.type = "Transform"
				sa.value = ValueCreator.get_transform_string()
			TYPE_TRANSFORM2D:
				sa.type = "Transform2D"
				sa.value = ValueCreator.get_transform2D_string()
			TYPE_VECTOR2:
				sa.type = "Vector2"
				sa.value = ValueCreator.get_vector2_string()
			TYPE_VECTOR2_ARRAY:
				sa.type = "PoolVector2Array"
				sa.value = "PoolVector2Array([])"
			TYPE_VECTOR3:
				sa.type = "Vector3"
				sa.value = ValueCreator.get_vector3_string()
			TYPE_VECTOR3_ARRAY:
				sa.type = "PoolVector3Array"
				sa.value = "PoolVector3Array([])"
			_:
				assert(false, "Missing type, needs to be added to project")
		argument_array.append(sa)

	return argument_array


func parse_and_return_objects(method_data: Dictionary, debug_print: bool = false) -> Array:
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
				if ValueCreator.random && randi() % 2:
					arguments_array.push_back(null)
				else:
					var obj: Object = ValueCreator.get_object(argument["class_name"])
					arguments_array.push_back(obj)
					assert(obj != null, "Failed to create an object of type " + argument["class_name"])

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
				assert(false, "Missing type, needs to be added to project")

	if debug_print:
		print("Parameters " + str(arguments_array))
	return arguments_array
