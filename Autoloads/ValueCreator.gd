extends Node

# Creates random or not objects, variables etc.
var number: float = 0.0
var random: bool = false
var should_be_always_valid: bool = true  # Generate only valid values e.g. to Node generate Node2D instead

var max_array_size: int = 15


func _ready() -> void:
	randomize()


func get_int() -> int:
	if random:
		if int(number) == 0:
			return 0
		return (randi() % int(number)) - int(number / 2.0)
	else:
		return int(number)


func get_int_string() -> String:
	if random:
		if int(number) == 0:
			return "0"
		return "(randi() % int(number)) - int(number / 2.0)".replace("number", str(number))
	else:
		return str(int(number))


func get_float() -> float:
	if random:
		return (randf() * number) - (number / 2.0)
	else:
		return number


func get_float_string() -> String:
	if random:
		return "(randf() * number) - (number / 2.0)".replace("number", str(number))
	else:
		return str(number)


func get_bool() -> bool:
	if random:
		if number < 2:
			return bool()
		return bool(randi() % 2)
	else:
		return bool()


func get_bool_string() -> String:
	if random:
		if number < 2:
			return str(bool())
		return "bool(randi() % 2)"
	else:
		return str(bool())


func get_vector2() -> Vector2:
	return Vector2(get_float(), get_float())


func get_vector2i() -> Vector2i:
	return Vector2i(get_int(), get_int())


func get_vector2_string() -> String:
	return "Vector2(" + get_float_string() + ", " + get_float_string() + ")"


func get_vector2i_string() -> String:
	return "Vector2i(" + get_int_string() + ", " + get_int_string() + ")"


func get_vector3() -> Vector3:
	return Vector3(get_float(), get_float(), get_float())


func get_vector3i() -> Vector3i:
	return Vector3i(get_int(), get_int(), get_int())


func get_vector3i_string() -> String:
	return "Vector3i(" + get_int_string() + ", " + get_int_string() + ", " + get_int_string() + ")"


func get_vector3_string() -> String:
	return "Vector3(" + get_float_string() + ", " + get_float_string() + ", " + get_float_string() + ")"


func get_aabb() -> AABB:
	return AABB(get_vector3(), get_vector3())


func get_aabb_string() -> String:
	return "AABB(" + get_vector3_string() + ", " + get_vector3_string() + ")"


func get_transform() -> Transform:
	return Transform(get_vector3(), get_vector3(), get_vector3(), get_vector3())


func get_transform_string() -> String:
	return "Transform(" + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ")"


func get_transform2D() -> Transform2D:
	return Transform2D(get_vector2(), get_vector2(), get_vector2())


func get_transform2D_string() -> String:
	return "Transform2D(" + get_vector2_string() + ", " + get_vector2_string() + ", " + get_vector2_string() + ")"


func get_plane() -> Plane:
	return Plane(get_vector3(), get_vector3(), get_vector3())


func get_plane_string() -> String:
	return "Plane(" + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ")"


func get_quat() -> Quat:
	return Quat(get_vector3())


func get_quat_string() -> String:
	return "Quat(" + get_vector3_string() + ")"


func get_basis() -> Basis:
	return Basis(get_vector3())


func get_basis_string() -> String:
	return "Basis(" + get_vector3_string() + ")"


func get_rect2() -> Rect2:
	return Rect2(get_vector2(), get_vector2())


func get_rect2i() -> Rect2i:
	return Rect2i(get_vector2i(), get_vector2i())


func get_rect2_string() -> String:
	return "Rect2(" + get_vector2_string() + ", " + get_vector2_string() + ")"


func get_rect2i_string() -> String:
	return "Rect2i(" + get_vector2i_string() + ", " + get_vector2i_string() + ")"


func get_color() -> Color:
	return Color(get_float(), get_float(), get_float())


func get_color_string() -> String:
	return "Color(" + get_float_string() + ", " + get_float_string() + ", " + get_float_string() + ")"


# TODO
func get_string() -> String:
	if random:
		if randi() % 2 == 0:
			return String(".")
		else:
			return str(randi())
	return String()


func get_string_string() -> String:
	if random:
		if randi() % 2 == 0:
			return "\".\""
		else:
			return "\"randi())\""
	return "\"\""


# TODO
func get_nodepath() -> NodePath:
	return NodePath(get_string())


# TODO
func get_array() -> Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append([])
	return Array([])


# TODO
func get_dictionary() -> Dictionary:
	return Dictionary({})


func get_Packed_string_array() -> PackedStringArray:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_string())
	return PackedStringArray(array)


func get_Packed_int32_array() -> PackedInt32Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PackedInt32Array(array)


func get_Packed_int64_array() -> PackedInt32Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PackedInt32Array(array)


func get_Packed_byte_array() -> PackedByteArray:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PackedByteArray(array)


func get_Packed_float32_array() -> PackedFloat32Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_float())
	return PackedFloat32Array(array)


func get_Packed_float64_array() -> PackedFloat64Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_float())
	return PackedFloat64Array(array)


func get_Packed_vector2_array() -> PackedVector2Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector2())
	return PackedVector2Array(array)


func get_Packed_vector3_array() -> PackedVector3Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector3())
	return PackedVector3Array(array)


func get_Packed_color_array() -> PackedColorArray:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_color())
	return PackedColorArray(array)


func get_object(object_name: String) -> Object:
	assert(ClassDB.class_exists(object_name), "Class doesn't exists.")
	if object_name == "PhysicsDirectSpaceState3D" || object_name == "PhysicsDirectSpaceState2D":
		return BoxShape3D.new()

	var a = 0
	if random:
		var classes = ClassDB.get_inheriters_from_class("Node") + ClassDB.get_inheriters_from_class("Reference")

		if object_name == "Object":
			while true:
				var choosen_class: String = classes[randi() % classes.size()]
				if (
					ClassDB.can_instance(choosen_class)
					&& (ClassDB.is_parent_class(choosen_class, "Node") || ClassDB.is_parent_class(choosen_class, "Reference"))
					&& !(choosen_class in BasicData.disabled_classes)
				):
					return ClassDB.instance(choosen_class)

		if ClassDB.is_parent_class(object_name, "Node") || ClassDB.is_parent_class(object_name, "Reference"):
			if should_be_always_valid:
				var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
				to_use_classes.append(object_name)
				if !ClassDB.can_instance(object_name) && object_name in BasicData.disabled_classes:
					assert(to_use_classes.size() > 0, "Cannot find proper instantable child for ")

				while true:
					a += 1
					if a > 50:
						# Object doesn't have children which can be instanced
						# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
						assert(false, "Cannot find proper instantable child for ")
					var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
					if ClassDB.can_instance(choosen_class) && !(choosen_class in BasicData.disabled_classes):
						return ClassDB.instance(choosen_class)
			else:
				while true:
					a += 1
					if a > 50:
						assert(false, "Cannot find proper instantable child for ")
					var choosen_class: String = classes[randi() % classes.size()]
					if ClassDB.can_instance(choosen_class) && !ClassDB.is_parent_class(choosen_class, object_name) && !(choosen_class in BasicData.disabled_classes):
						return ClassDB.instance(choosen_class)

		# Non Node/Resource object
		var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
		to_use_classes.append(object_name)
		if !ClassDB.can_instance(object_name) && object_name in BasicData.disabled_classes:
			assert(to_use_classes.size() > 0, "Cannot find proper instantable child for ")

		while true:
			a += 1
			if a > 50:
				# Object doesn't have children which can be instanced
				# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
				assert(false, "Cannot find proper instantable child for ")
			var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
			if ClassDB.can_instance(choosen_class) && !(choosen_class in BasicData.disabled_classes):
				return ClassDB.instance(choosen_class)

	else:
		if ClassDB.can_instance(object_name):  # E.g. Texture is not instantable or shouldn't be, but LargeTexture is
			return ClassDB.instance(object_name)
		else:  # Found child of non instantable object
			var list_of_class = ClassDB.get_inheriters_from_class(object_name)
			assert(list_of_class.size() > 0, "Cannot find proper instantable child for ")  # Number of inherited class of non instantable class must be greater than 0, otherwise this function would be useless
			for i in list_of_class:
				if ClassDB.can_instance(i) && (ClassDB.is_parent_class(i, "Node") || ClassDB.is_parent_class(i, "Reference")):
					return ClassDB.instance(i)
			assert(false, "Cannot find proper instantable child for ")

	assert(false, "Cannot find proper instantable child for ")
	return BoxShape3D.new()


# TODO Update this with upper implementation
func get_object_string(object_name: String) -> String:
	assert(ClassDB.class_exists(object_name))

	var a = 0
	if random:
		var classes = ClassDB.get_inheriters_from_class("Node") + ClassDB.get_inheriters_from_class("Reference")

		if object_name == "Object":
			while true:
				var choosen_class: String = classes[randi() % classes.size()]
				if ClassDB.can_instance(choosen_class) && (ClassDB.is_parent_class(choosen_class, "Node") || ClassDB.is_parent_class(choosen_class, "Reference")):
					return choosen_class

		if ClassDB.is_parent_class(object_name, "Node") || ClassDB.is_parent_class(object_name, "Reference"):
			if should_be_always_valid:
				var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
				to_use_classes.append(object_name)
				if !ClassDB.can_instance(object_name):
					assert(to_use_classes.size() > 0, "Cannot find proper instantable child for ")

				while true:
					a += 1
					if a > 30:
						# Object doesn't have children which can be instanced
						# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
						assert(false, "Cannot find proper instantable child for ")
					var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
					if ClassDB.can_instance(choosen_class):
						return choosen_class
			else:
				while true:
					a += 1
					if a > 30:
						assert(false, "Cannot find proper instantable child for ")
					var choosen_class: String = classes[randi() % classes.size()]
					if !ClassDB.is_parent_class(choosen_class, object_name):
						return choosen_class

		# Non Node/Resource object
		var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
		to_use_classes.append(object_name)
		if !ClassDB.can_instance(object_name) && object_name in BasicData.disabled_classes:
			assert(to_use_classes.size() > 0, "Cannot find proper instantable child for ")

		while true:
			a += 1
			if a > 50:
				# Object doesn't have children which can be instanced
				# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
				assert(false, "Cannot find proper instantable child for ")
			var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
			if ClassDB.can_instance(choosen_class) && !(choosen_class in BasicData.disabled_classes):
				return choosen_class

	else:
		if ClassDB.can_instance(object_name):  # E.g. Texture is not instantable or shouldn't be, but LargeTexture is
			return object_name
		else:  # Found child of non instantable object
			var list_of_class = ClassDB.get_inheriters_from_class(object_name)
			assert(list_of_class.size() > 0, "Cannot find proper instantable child for ")  # Number of inherited class of non instantable class must be greater than 0, otherwise this function would be useless
			for i in list_of_class:
				if ClassDB.can_instance(i) && (ClassDB.is_parent_class(i, "Node") || ClassDB.is_parent_class(i, "Reference")):
					return i
			assert(false, "Cannot find proper instantable child for ")

	assert(false, "Cannot find proper instantable child for ")
	return "BoxMesh"
