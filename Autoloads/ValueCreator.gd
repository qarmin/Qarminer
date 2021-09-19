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


func get_float() -> float:
	if random:
		return (randf() * number) - (number / 2.0)
	else:
		return number


func get_bool() -> bool:
	if random:
		if number < 2:
			return bool()
		return bool(randi() % 2)
	else:
		return bool()


func get_vector2() -> Vector2:
	return Vector2(get_float(), get_float())


func get_vector2i() -> Vector2i:
	return Vector2i(get_int(), get_int())


func get_vector3() -> Vector3:
	return Vector3(get_float(), get_float(), get_float())


func get_vector3i() -> Vector3i:
	return Vector3i(get_int(), get_int(), get_int())


func get_aabb() -> AABB:
	return AABB(get_vector3(), get_vector3())


func get_transform() -> Transform3D:
	return Transform3D(get_vector3(), get_vector3(), get_vector3(), get_vector3())


func get_transform2D() -> Transform2D:
	return Transform2D(get_vector2(), get_vector2(), get_vector2())


func get_plane() -> Plane:
	return Plane(get_vector3(), get_vector3(), get_vector3())


func get_quat() -> Quaternion:
	return Quaternion(get_vector3())


func get_basis() -> Basis:
	return Basis(get_vector3())


func get_rect2() -> Rect2:
	return Rect2(get_vector2(), get_vector2())


func get_rect2i() -> Rect2i:
	return Rect2i(get_vector2i(), get_vector2i())


func get_color() -> Color:
	return Color(get_float(), get_float(), get_float())


# TODO
func get_string() -> String:
	if random:
		if randi() % 2 == 0:
			return String(".")
		else:
			return str(randi())
	return String()


func get_string_name() -> StringName:
	return StringName(get_string())


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


func get_packed_string_array() -> PackedStringArray:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_string())
	return PackedStringArray(array)


func get_packed_int32_array() -> PackedInt32Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PackedInt32Array(array)


func get_packed_int64_array() -> PackedInt32Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PackedInt32Array(array)


func get_packed_byte_array() -> PackedByteArray:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PackedByteArray(array)


func get_packed_float32_array() -> PackedFloat32Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_float())
	return PackedFloat32Array(array)


func get_packed_float64_array() -> PackedFloat64Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_float())
	return PackedFloat64Array(array)


func get_packed_vector2_array() -> PackedVector2Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector2())
	return PackedVector2Array(array)


func get_packed_vector3_array() -> PackedVector3Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector3())
	return PackedVector3Array(array)


func get_packed_color_array() -> PackedColorArray:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_color())
	return PackedColorArray(array)


func get_object(object_name: String) -> Object:
	assert(ClassDB.class_exists(object_name))  #, "Class " + object_name + " doesn't exists.")
	if object_name == "PhysicsDirectSpaceState3D" || object_name == "PhysicsDirectSpaceState2D":
		return null

	var a = 0
	if random:
		if randi() % 4 == 0:
			return null

		var arr: Array = ClassDB.get_inheriters_from_class("Object")

		var element: String = arr[randi() % arr.size()]

		if ClassDB.can_instantiate(element) && element in BasicData.classes:
			return ClassDB.instantiate(element)
		return null

	else:
		if ClassDB.can_instantiate(object_name):  # E.g. Texture2D is not instantable or shouldn't be, but ImageTexture is
			return ClassDB.instantiate(object_name)
		else:  # Found child of non instantable object
			var list_of_class = ClassDB.get_inheriters_from_class(object_name)
			for i in list_of_class:
				if ClassDB.can_instantiate(i) && (ClassDB.is_parent_class(i, "Node") || ClassDB.is_parent_class(i, "RefCounted")):
					return ClassDB.instantiate(i)

	assert(false)  #, "Cannot find proper instantable child for " + object_name)
	return null
