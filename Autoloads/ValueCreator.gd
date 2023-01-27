extends Node

# Creates random or not objects, variables etc.

var number: float = 0.0

var max_array_size: int = 25


func _ready() -> void:
	randomize()


func get_int() -> int:
	if int(number) == 0:
		return 0
	return (randi() % int(number * 2)) - int(number)


func get_float() -> float:
	var numm = randi() % 100
	if numm == 0:
#		return -INF # TODO Reenable after fixing  60492, 60466, 60357, 60338, 60326
#	elif numm == 1:
#		return INF
#	elif numm == 2:
#		return NAN
#	elif numm == 3:
#		return -NAN
#	elif numm == 4:
		return 0.0
	elif numm == 5:
		return -0.0
	return (randf() * number * 2) - (number)


func get_bool() -> bool:
	if number < 2:
		return bool()
	return bool(randi() % 2)


func get_vector2() -> Vector2:
	if randi() % 2:
		return Vector2(get_float(), get_float()).normalized()
	return Vector2(get_float(), get_float())


func get_vector3() -> Vector3:
	if randi() % 2:
		return Vector3(get_float(), get_float(), get_float()).normalized()
	return Vector3(get_float(), get_float(), get_float())


func get_aabb() -> AABB:
	return AABB(get_vector3(), get_vector3())


func get_transform3d() -> Transform3D:
	return Transform3D(get_vector3(), get_vector3(), get_vector3(), get_vector3())


func get_transform2d() -> Transform2D:
	return Transform2D(get_vector2(), get_vector2(), get_vector2())


func get_plane() -> Plane:
	return Plane(get_vector3(), get_vector3(), get_vector3())


func get_quaternion() -> Quaternion:
	return Quaternion(get_vector3(), get_float())


func get_basis() -> Basis:
	return Basis(get_vector3(), get_vector3(), get_vector3())


func get_rect2() -> Rect2:
	return Rect2(get_vector2(), get_vector2())


func get_color() -> Color:
	return Color(get_float(), get_float(), get_float())


var resources_string_array: Array = [
	"res://resources/item.jpg",
	"res://resources/item.png",
	"res://resources/item.fbx",
	"res://resources/item.gltf",
	"res://resources/item.ttf",
	"res://resources/item.xml",
	"res://resources/item.json",
	"res://resources/item.tscn",
]


func get_string() -> String:
	var numm = randi() % 6
	if numm == 0:
		return String(".")
	elif numm == 1:
		return str(randi())
	elif numm == 2:
		return "5555"
	elif numm == 3:
		return "127.0.0.1"
	#elif numm == 4: # 65484 - should fix memory leak
	#	resources_string_array[randi() % resources_string_array.size()]
	return String()


func get_nodepath() -> NodePath:
	return NodePath(get_string())


func get_array() -> Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		if randi() % 10:
			array.append([])
		else:
			array.append(randi() % 100)
	return array


func get_dictionary() -> Dictionary:
	if randi() % 2:
		return Dictionary({"roman": 22, 22: 25, BoxShape3D.new(): BoxShape3D.new()})
	elif randi() % 2:
		var dict = {}
		var things = ["date", "month", "day", "year"]
		for i in randi() % 10:
			var key = things[randi() % things.size()]
			var value = get_int()
			dict[key] = value
		return dict

	return Dictionary({})


func get_packed_string_array() -> PackedStringArray:
	var array: Array = []
	if randi() % 2:
		return PackedStringArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_string())
	return PackedStringArray(array)


func get_packed_int32_array() -> PackedInt32Array:
	var array: Array = []
	if randi() % 2:
		return PackedInt32Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PackedInt32Array(array)


func get_packed_byte_array() -> PackedByteArray:
	var array: Array = []
	if randi() % 2:
		return PackedByteArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PackedByteArray(array)


func get_packed_float32_array() -> PackedFloat32Array:
	var array: Array = []
	if randi() % 2:
		return PackedFloat32Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_float())
	return PackedFloat32Array(array)


func get_packed_vector2_array() -> PackedVector2Array:
	var array: Array = []
	if randi() % 2:
		return PackedVector2Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector2())
	return PackedVector2Array(array)


func get_packed_vector3_array() -> PackedVector3Array:
	var array: Array = []
	if randi() % 2:
		return PackedVector3Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector3())
	return PackedVector3Array(array)


func get_packed_color_array() -> PackedColorArray:
	var array: Array = []
	if randi() % 2:
		return PackedColorArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_color())
	return PackedColorArray(array)


func get_variant():
	match randi() % 23:
		0:
			return get_int()
		1:
			return get_bool()
		2:
			return get_vector2()
		3:
			return get_vector3()
		4:
			return get_aabb()
		5:
			return get_transform2d()
		6:
			return get_transform3d()
		7:
			return get_plane()
		8:
			return get_rect2()
		9:
			return get_color()
		10:
			return get_string()
		11:
			return get_nodepath()
		12:
			return get_array()
		13:
			return get_dictionary()
		14:
			return get_packed_byte_array()
		15:
			return get_packed_color_array()
		16:
			return get_packed_float32_array()
		17:
			return get_packed_int32_array()
		18:
			return get_packed_string_array()
		19:
			return get_packed_vector2_array()
		20:
			return get_packed_vector3_array()
		21:
			return get_projection()
		22:
			return get_object("RefCounted")
	return "A"


# TODOGODOT4


func get_string_name() -> StringName:
	return StringName(get_string())


func get_vector2i() -> Vector2i:
	return Vector2i(get_int(), get_int())


func get_vector3i() -> Vector3i:
	return Vector3i(get_int(), get_int(), get_int())


func get_rect2i() -> Rect2i:
	return Rect2i(get_vector2i(), get_vector2i())


func get_packed_int64_array() -> PackedInt64Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PackedInt64Array(array)


func get_packed_float64_array() -> PackedFloat64Array:
	var array: Array = []
	for _i in range(int(min(max_array_size, number))):
		array.append(get_float())
	return PackedFloat64Array(array)


func get_signal() -> Signal:
	return Signal()


func get_vector4() -> Vector4:
	if randi() % 2:
		return Vector4(get_float(), get_float(), get_float(), get_float()).normalized()
	return Vector4(get_float(), get_float(), get_float(), get_float())


#
func get_vector4i() -> Vector4i:
	return Vector4i(get_int(), get_int(), get_int(), get_int())


func get_projection() -> Projection:
	return Projection(get_vector4(), get_vector4(), get_vector4(), get_vector4())


func get_object(object_name: String) -> Object:
	assert(ClassDB.class_exists(object_name))  #,"Class " + object_name + " doesn't exists.") # TODO this is quite useless, because cannnot use with reference
	if object_name == "PhysicsDirectSpaceState3D" || object_name == "PhysicsDirectSpaceState2D":
		return null

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

	if arr.is_empty():
		return null

	var element: String = arr[randi() % arr.size()]

	if ClassDB.can_instantiate(element) && element in BasicData.argument_classes:
		return ClassDB.instantiate(element)
	return null
