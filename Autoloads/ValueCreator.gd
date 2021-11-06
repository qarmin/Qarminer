extends Node

# Creates random or not objects, variables etc.

var number: float = 0.0
var random: bool = false

var max_array_size: int = 25


func _ready() -> void:
	randomize()


# TODO re-enable when notification will be available
func get_int() -> int:
	if random:
		if int(number) == 0:
			return 0
#		while true:
		var temp_number: int = (randi() % int(number * 2)) - int(number)
#			if !(
#				temp_number
#				in [
#					26,
#					41,
#					13,
#					10,
#					26,
#					33,
#					11,
#					32,
#					30,
#				]
#			):  # TODO this are reported notification crashes
#			if !(temp_number in [
#				26, # 54100
#				41, # 54094
#				13, # 54142
#				10, # 54093
#				26, # 54100
#				33, # 54168
#				11, # 54169
#				32, # TODO
#				30, # TODO
#				]):  # TODO this are reported notification crashes
		return temp_number

	else:
		return int(number)


#	return 0


func get_float() -> float:
	if random:
		return (randf() * number * 2) - (number)
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
	if random:
		if randi() % 2:
			return Vector2(get_float(), get_float()).normalized()
	return Vector2(get_float(), get_float())


func get_vector3() -> Vector3:
	if random:
		if randi() % 2:
			return Vector3(get_float(), get_float(), get_float()).normalized()
	return Vector3(get_float(), get_float(), get_float())


func get_aabb() -> AABB:
	return AABB(get_vector3(), get_vector3())


func get_transform3d() -> Transform:
	return Transform(get_vector3(), get_vector3(), get_vector3(), get_vector3())


func get_transform2D() -> Transform2D:
	return Transform2D(get_vector2(), get_vector2(), get_vector2())


func get_plane() -> Plane:
	return Plane(get_vector3(), get_vector3(), get_vector3())


func get_quaternion() -> Quat:
	return Quat(get_vector3())


func get_basis() -> Basis:
	return Basis(get_vector3())


func get_rect2() -> Rect2:
	return Rect2(get_vector2(), get_vector2())


func get_color() -> Color:
	return Color(get_float(), get_float(), get_float())


func get_string() -> String:
	if random:
		if randi() % 2 == 0:
			return String(".")
		else:
			return str(randi())
	return String()


func get_nodepath() -> NodePath:
	return NodePath(get_string())


func get_array() -> Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		if random && randi() % 2:
			array.append(randi() % 100)
		else:
			array.append([])
	return Array([])


func get_dictionary() -> Dictionary:
	if random:
		if randi() % 2:
			return Dictionary({"roman": 22, 22: 25, BoxShape.new(): BoxShape.new()})
	return Dictionary({})


func get_packed_string_array() -> PoolStringArray:
	var array: Array = []
	if random && randi() % 2:
		return PoolStringArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_string())
	return PoolStringArray(array)


func get_packed_int32_array() -> PoolIntArray:
	var array: Array = []
	if random && randi() % 2:
		return PoolIntArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PoolIntArray(array)


func get_packed_byte_array() -> PoolByteArray:
	var array: Array = []
	if random && randi() % 2:
		return PoolByteArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PoolByteArray(array)


func get_packed_float32_array() -> PoolRealArray:
	var array: Array = []
	if random && randi() % 2:
		return PoolRealArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_float())
	return PoolRealArray(array)


func get_packed_vector2_array() -> PoolVector2Array:
	var array: Array = []
	if random && randi() % 2:
		return PoolVector2Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector2())
	return PoolVector2Array(array)


func get_packed_vector3_array() -> PoolVector3Array:
	var array: Array = []
	if random && randi() % 2:
		return PoolVector3Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector3())
	return PoolVector3Array(array)


func get_packed_color_array() -> PoolColorArray:
	var array: Array = []
	if random && randi() % 2:
		return PoolColorArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_color())
	return PoolColorArray(array)


# TODOGODOT4

#func get_string_name() -> StringName:
#	return StringName(get_string())
#
#func get_vector2i() -> Vector2i:
#	return Vector2i(get_int(), get_int())
#
#func get_vector3i() -> Vector3i:
#	return Vector3i(get_int(), get_int(), get_int())
#
#func get_rect2i() -> Rect2i:
#	return Rect2i(get_vector2i(), get_vector2i())
#
#func get_packed_int64_array() -> PackedInt64Array:
#	var array: Array = []
#	for _i in range(int(min(max_array_size, number))):
#		array.append(get_int())
#	return PackedInt64Array(array)
#
#func get_packed_float64_array() -> PackedFloat64Array:
#	var array: Array = []
#	for _i in range(int(min(max_array_size, number))):
#		array.append(get_float())
#	return PackedFloat64Array(array)
#
#func get_signal() -> Signal:
#	return Signal()


func get_object(object_name: String) -> Object:
	assert(ClassDB.class_exists(object_name), "Class " + object_name + " doesn't exists.")
	if object_name == "PhysicsDirectSpaceState" || object_name == "Physics2DDirectSpaceState":
		return null

	if random:
		if randi() % 4 == 0:
			return null

		var arr: Array = ClassDB.get_inheriters_from_class(object_name)

		# If allowed argument classes is smaller than available arguments then we filter this things, because it would cause too many null returned things
		if arr.size() > BasicData.argument_classes.size() * 4:
			var new_arr: Array = []
			for i in arr:
				if i in BasicData.argument_classes:
					new_arr.append(i)
			arr = new_arr

		if arr.empty():
			return null

		var element: String = arr[randi() % arr.size()]

		if ClassDB.can_instance(element) && element in BasicData.argument_classes:
			return ClassDB.instance(element)
		return null

	else:
		if ClassDB.can_instance(object_name):  # E.g. Texture is not instantable or shouldn't be, but LargeTexture is
			return ClassDB.instance(object_name)
		else:  # Found child of non instantable object
			var list_of_class = ClassDB.get_inheriters_from_class(object_name)
			for i in list_of_class:
				if ClassDB.can_instance(i) && (ClassDB.is_parent_class(i, "Node") || ClassDB.is_parent_class(i, "Reference")):
					return ClassDB.instance(i)

	assert(false, "Cannot find proper instantable child for " + object_name)
	return null
