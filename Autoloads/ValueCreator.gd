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


func get_transform() -> Transform:
	return Transform(get_vector3(), get_vector3(), get_vector3(), get_vector3())


func get_transform2D() -> Transform2D:
	return Transform2D(get_vector2(), get_vector2(), get_vector2())


func get_plane() -> Plane:
	return Plane(get_vector3(), get_vector3(), get_vector3())


func get_quat() -> Quat:
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


func get_pool_string_array() -> PoolStringArray:
	var array: Array = []
	if random && randi() % 2:
		return PoolStringArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_string())
	return PoolStringArray(array)


func get_pool_int_array() -> PoolIntArray:
	var array: Array = []
	if random && randi() % 2:
		return PoolIntArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PoolIntArray(array)


func get_pool_byte_array() -> PoolByteArray:
	var array: Array = []
	if random && randi() % 2:
		return PoolByteArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PoolByteArray(array)


func get_pool_real_array() -> PoolRealArray:
	var array: Array = []
	if random && randi() % 2:
		return PoolRealArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_float())
	return PoolRealArray(array)


func get_pool_vector2_array() -> PoolVector2Array:
	var array: Array = []
	if random && randi() % 2:
		return PoolVector2Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector2())
	return PoolVector2Array(array)


func get_pool_vector3_array() -> PoolVector3Array:
	var array: Array = []
	if random && randi() % 2:
		return PoolVector3Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector3())
	return PoolVector3Array(array)


func get_pool_color_array() -> PoolColorArray:
	var array: Array = []
	if random && randi() % 2:
		return PoolColorArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_color())
	return PoolColorArray(array)


func get_object(object_name: String) -> Object:
	assert(ClassDB.class_exists(object_name), "Class " + object_name + " doesn't exists.")
	if object_name == "PhysicsDirectSpaceState" || object_name == "Physics2DDirectSpaceState":
		return BoxShape.new()

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
					assert(to_use_classes.size() > 0, "Cannot find proper instantable child for " + object_name)

				while true:
					a += 1
					if a > 50:
						# Object doesn't have children which can be instanced
						# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
						assert(false, "Cannot find proper instantable child for " + object_name)
					var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
					if ClassDB.can_instance(choosen_class) && !(choosen_class in BasicData.disabled_classes):
						return ClassDB.instance(choosen_class)
			else:
				while true:
					a += 1
					if a > 50:
						assert(false, "Cannot find proper instantable child for " + object_name)
					var choosen_class: String = classes[randi() % classes.size()]
					if ClassDB.can_instance(choosen_class) && !ClassDB.is_parent_class(choosen_class, object_name) && !(choosen_class in BasicData.disabled_classes):
						return ClassDB.instance(choosen_class)

		# Non Node/Resource object
		var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
		to_use_classes.append(object_name)
		if !ClassDB.can_instance(object_name) && object_name in BasicData.disabled_classes:
			assert(to_use_classes.size() > 0, "Cannot find proper instantable child for " + object_name)

		while true:
			a += 1
			if a > 50:
				# Object doesn't have children which can be instanced
				# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
				assert(false, "Cannot find proper instantable child for " + object_name)
			var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
			if ClassDB.can_instance(choosen_class) && !(choosen_class in BasicData.disabled_classes):
				return ClassDB.instance(choosen_class)

	else:
		if ClassDB.can_instance(object_name):  # E.g. Texture is not instantable or shouldn't be, but LargeTexture is
			return ClassDB.instance(object_name)
		else:  # Found child of non instantable object
			var list_of_class = ClassDB.get_inheriters_from_class(object_name)
			assert(list_of_class.size() > 0, "Cannot find proper instantable child for " + object_name)  # Number of inherited class of non instantable class must be greater than 0, otherwise this function would be useless
			for i in list_of_class:
				if ClassDB.can_instance(i) && (ClassDB.is_parent_class(i, "Node") || ClassDB.is_parent_class(i, "Reference")):
					return ClassDB.instance(i)
			assert(false, "Cannot find proper instantable child for " + object_name)

	assert(false, "Cannot find proper instantable child for " + object_name)
	return BoxShape.new()
