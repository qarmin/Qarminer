extends Node

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
	if random:
		if randi() % 2:
			return Vector2(get_float(), get_float()).normalized()
	return Vector2(get_float(), get_float())


func get_vector2_string() -> String:
	if random:
		if randi() % 2:
			return "Vector2(" + get_float_string() + ", " + get_float_string() + ").normalized()"
	return "Vector2(" + get_float_string() + ", " + get_float_string() + ")"


func get_vector2_string_csharp() -> String:
	if random:
		if randi() % 2:
			return "new Vector2(" + get_float_string() + ", " + get_float_string() + ").Normalized()"
	return "new Vector2(" + get_float_string() + ", " + get_float_string() + ")"


func get_vector3() -> Vector3:
	if random:
		if randi() % 2:
			return Vector3(get_float(), get_float(), get_float()).normalized()
	return Vector3(get_float(), get_float(), get_float())


func get_vector3_string() -> String:
	if random:
		if randi() % 2:
			return "Vector3(" + get_float_string() + ", " + get_float_string() + ", " + get_float_string() + ").normalized()"
	return "Vector3(" + get_float_string() + ", " + get_float_string() + ", " + get_float_string() + ")"


func get_vector3_string_csharp() -> String:
	if random:
		if randi() % 2:
			return "new Vector3(" + get_float_string() + ", " + get_float_string() + ", " + get_float_string() + ").Normalized()"
	return "new Vector3(" + get_float_string() + ", " + get_float_string() + ", " + get_float_string() + ")"


func get_aabb() -> AABB:
	return AABB(get_vector3(), get_vector3())


func get_aabb_string() -> String:
	return "AABB(" + get_vector3_string() + ", " + get_vector3_string() + ")"


func get_aabb_string_csharp() -> String:
	return "new AABB(" + get_vector3_string_csharp() + ", " + get_vector3_string_csharp() + ")"


func get_transform() -> Transform:
	return Transform(get_vector3(), get_vector3(), get_vector3(), get_vector3())


func get_transform_string() -> String:
	return "Transform(" + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ")"


func get_transform_string_csharp() -> String:
	return "new Transform(" + get_vector3_string_csharp() + ", " + get_vector3_string_csharp() + ", " + get_vector3_string_csharp() + ", " + get_vector3_string() + ")"


func get_transform2D() -> Transform2D:
	return Transform2D(get_vector2(), get_vector2(), get_vector2())


func get_transform2D_string() -> String:
	return "Transform2D(" + get_vector2_string() + ", " + get_vector2_string() + ", " + get_vector2_string() + ")"


func get_transform2D_string_csharp() -> String:
	return "new Transform2D(" + get_vector2_string_csharp() + ", " + get_vector2_string_csharp() + ", " + get_vector2_string_csharp() + ")"


func get_plane() -> Plane:
	return Plane(get_vector3(), get_vector3(), get_vector3())


func get_plane_string() -> String:
	return "Plane(" + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ")"


func get_plane_string_csharp() -> String:
	return "new Plane(" + get_vector3_string_csharp() + ", " + get_vector3_string_csharp() + ", " + get_vector3_string_csharp() + ")"


func get_quat() -> Quat:
	return Quat(get_vector3())


func get_quat_string() -> String:
	return "Quat(" + get_vector3_string() + ")"


func get_quat_string_csharp() -> String:
	return "new Quat(" + get_vector3_string_csharp() + ")"


func get_basis() -> Basis:
	return Basis(get_vector3())


func get_basis_string() -> String:
	return "Basis(" + get_vector3_string() + ")"


func get_basis_string_csharp() -> String:
	return "new Basis(" + get_vector3_string_csharp() + ")"


func get_rect2() -> Rect2:
	return Rect2(get_vector2(), get_vector2())


func get_rect2_string() -> String:
	return "Rect2(" + get_vector2_string() + ", " + get_vector2_string() + ")"


func get_rect2_string_csharp() -> String:
	return "new Rect2(" + get_vector2_string_csharp() + ", " + get_vector2_string_csharp() + ")"


func get_color() -> Color:
	return Color(get_float(), get_float(), get_float())


func get_color_string() -> String:
	return "Color(" + get_float_string() + ", " + get_float_string() + ", " + get_float_string() + ")"


func get_color_string_csharp() -> String:
	return "new Color(" + get_float_string() + ", " + get_float_string() + ", " + get_float_string() + ")"


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
		if randi() % 3 == 0:
			return "\".\""
		elif randi() % 3 == 0:
			return "\"\""
		else:
			return "str(randi() / 100)"
	return "\"\""


# TODO
func get_nodepath() -> NodePath:
	return NodePath(get_string())


# TODO
func get_nodepath_string_csharp() -> String:
	return "new NodePath(\".\")"


# TODO
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
			return Dictionary({"roman": 22,22: 25,BoxShape.new():BoxShape.new()})
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
	assert(ClassDB.class_exists(object_name))
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
					&& !(choosen_class in Autoload.disabled_classes)
				):
					return ClassDB.instance(choosen_class)

		if ClassDB.is_parent_class(object_name, "Node") || ClassDB.is_parent_class(object_name, "Reference"):
			if should_be_always_valid:
				var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
				to_use_classes.append(object_name)
				if !ClassDB.can_instance(object_name) && object_name in Autoload.disabled_classes:
					assert(to_use_classes.size() > 0)

				while true:
					a += 1
					if a > 50:
						# Object doesn't have children which can be instanced
						# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
						assert(false)
					var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
					if ClassDB.can_instance(choosen_class) && !(choosen_class in Autoload.disabled_classes):
						return ClassDB.instance(choosen_class)
			else:
				while true:
					a += 1
					if a > 50:
						assert(false)
					var choosen_class: String = classes[randi() % classes.size()]
					if ClassDB.can_instance(choosen_class) && !ClassDB.is_parent_class(choosen_class, object_name) && !(choosen_class in Autoload.disabled_classes):
						return ClassDB.instance(choosen_class)

		# Non Node/Resource object
		var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
		to_use_classes.append(object_name)
		if !ClassDB.can_instance(object_name) && object_name in Autoload.disabled_classes:
			assert(to_use_classes.size() > 0)

		while true:
			a += 1
			if a > 50:
				# Object doesn't have children which can be instanced
				# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
				assert(false)
			var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
			if ClassDB.can_instance(choosen_class) && !(choosen_class in Autoload.disabled_classes):
				return ClassDB.instance(choosen_class)

	else:
		if ClassDB.can_instance(object_name):  # E.g. Texture is not instantable or shouldn't be, but LargeTexture is
			return ClassDB.instance(object_name)
		else:  # Found child of non instantable object
			var list_of_class = ClassDB.get_inheriters_from_class(object_name)
			assert(list_of_class.size() > 0)  # Number of inherited class of non instantable class must be greater than 0, otherwise this function would be useless
			for i in list_of_class:
				if ClassDB.can_instance(i) && (ClassDB.is_parent_class(i, "Node") || ClassDB.is_parent_class(i, "Reference")):
					return ClassDB.instance(i)
			assert(false)

	assert(false)
	return BoxShape.new()


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
					assert(to_use_classes.size() > 0)

				while true:
					a += 1
					if a > 30:
						# Object doesn't have children which can be instanced
						# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
						assert(false)
					var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
					if ClassDB.can_instance(choosen_class):
						return choosen_class
			else:
				while true:
					a += 1
					if a > 30:
						assert(false)
					var choosen_class: String = classes[randi() % classes.size()]
					if !ClassDB.is_parent_class(choosen_class, object_name):
						return choosen_class

		# Non Node/Resource object
		var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
		to_use_classes.append(object_name)
		if !ClassDB.can_instance(object_name) && object_name in Autoload.disabled_classes:
			assert(to_use_classes.size() > 0)

		while true:
			a += 1
			if a > 50:
				# Object doesn't have children which can be instanced
				# This shouldn't happens, but sadly happen with e.g. SpatialGizmo
				assert(false)
			var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
			if ClassDB.can_instance(choosen_class) && !(choosen_class in Autoload.disabled_classes):
				return choosen_class

	else:
		if ClassDB.can_instance(object_name):  # E.g. Texture is not instantable or shouldn't be, but LargeTexture is
			return object_name
		else:  # Found child of non instantable object
			var list_of_class = ClassDB.get_inheriters_from_class(object_name)
			assert(list_of_class.size() > 0)  # Number of inherited class of non instantable class must be greater than 0, otherwise this function would be useless
			for i in list_of_class:
				if ClassDB.can_instance(i) && (ClassDB.is_parent_class(i, "Node") || ClassDB.is_parent_class(i, "Reference")):
					return i
			assert(false)

	assert(false)
	return "BoxMesh"
