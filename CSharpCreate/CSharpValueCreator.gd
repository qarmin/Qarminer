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


func get_transform() -> Transform3D:
	return Transform3D(get_vector3(), get_vector3(), get_vector3(), get_vector3())


func get_transform_string() -> String:
	return "Transform3D(" + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ")"


func get_transform_string_csharp() -> String:
	return "new Transform3D(" + get_vector3_string_csharp() + ", " + get_vector3_string_csharp() + ", " + get_vector3_string_csharp() + ", " + get_vector3_string() + ")"


func get_transform2d() -> Transform2D:
	return Transform2D(get_vector2(), get_vector2(), get_vector2())


func get_transform2d_string() -> String:
	return "Transform2D(" + get_vector2_string() + ", " + get_vector2_string() + ", " + get_vector2_string() + ")"


func get_transform2d_string_csharp() -> String:
	return "new Transform2D(" + get_vector2_string_csharp() + ", " + get_vector2_string_csharp() + ", " + get_vector2_string_csharp() + ")"


func get_plane() -> Plane:
	return Plane(get_vector3(), get_vector3(), get_vector3())


func get_plane_string() -> String:
	return "Plane(" + get_vector3_string() + ", " + get_vector3_string() + ", " + get_vector3_string() + ")"


func get_plane_string_csharp() -> String:
	return "new Plane(" + get_vector3_string_csharp() + ", " + get_vector3_string_csharp() + ", " + get_vector3_string_csharp() + ")"


func get_quat() -> Quaternion:
	return Quaternion(get_vector3())


func get_quat_string() -> String:
	return "Quaternion(" + get_vector3_string() + ")"


func get_quat_string_csharp() -> String:
	return "new Quaternion(" + get_vector3_string_csharp() + ")"


func get_basis() -> Basis:
	return Basis(get_vector3(), get_vector3(), get_vector3())


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
			return '"."'
		elif randi() % 3 == 0:
			return '""'
		else:
			return "str(randi() / 100)"
	return '""'


# TODO
func get_nodepath() -> NodePath:
	return NodePath(get_string())


# TODO
func get_nodepath_string_csharp() -> String:
	return 'new NodePath(".")'


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
			return Dictionary({"roman": 22, 22: 25, BoxShape3D.new(): BoxShape3D.new()})
	return Dictionary({})


func get_packed_string_array() -> PackedStringArray:
	var array: Array = []
	if random && randi() % 2:
		return PackedStringArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_string())
	return PackedStringArray(array)


func get_packed_int_array() -> PackedInt32Array:
	var array: Array = []
	if random && randi() % 2:
		return PackedInt32Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PackedInt32Array(array)


func get_packed_byte_array() -> PackedByteArray:
	var array: Array = []
	if random && randi() % 2:
		return PackedByteArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_int())
	return PackedByteArray(array)


func get_packed_real_array() -> PackedFloat32Array:
	var array: Array = []
	if random && randi() % 2:
		return PackedFloat32Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_float())
	return PackedFloat32Array(array)


func get_packed_vector2_array() -> PackedVector2Array:
	var array: Array = []
	if random && randi() % 2:
		return PackedVector2Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector2())
	return PackedVector2Array(array)


func get_packed_vector3_array() -> PackedVector3Array:
	var array: Array = []
	if random && randi() % 2:
		return PackedVector3Array(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_vector3())
	return PackedVector3Array(array)


func get_packed_color_array() -> PackedColorArray:
	var array: Array = []
	if random && randi() % 2:
		return PackedColorArray(array)
	for _i in range(int(min(max_array_size, number))):
		array.append(get_color())
	return PackedColorArray(array)


func get_object(object_name: String) -> Object:
	assert(ClassDB.class_exists(object_name))  #,"Class " + object_name + " doesn't exists.")
	if object_name == "PhysicsDirectSpaceState3D" || object_name == "PhysicsDirectSpaceState2D":
		return BoxShape3D.new()

	var a = 0
	if random:
		var classes = ClassDB.get_inheriters_from_class("Node") + ClassDB.get_inheriters_from_class("RefCounted")

		if object_name == "Object":
			while true:
				var choosen_class: String = classes[randi() % classes.size()]
				if (
					ClassDB.can_instantiate(choosen_class)
					&& (ClassDB.is_parent_class(choosen_class, "Node") || ClassDB.is_parent_class(choosen_class, "RefCounted"))
					&& !(choosen_class in BasicData.disabled_classes)
				):
					return ClassDB.instantiate(choosen_class)

		if ClassDB.is_parent_class(object_name, "Node") || ClassDB.is_parent_class(object_name, "RefCounted"):
			if should_be_always_valid:
				var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
				to_use_classes.append(object_name)
				if !ClassDB.can_instantiate(object_name) && object_name in BasicData.disabled_classes:
					assert(to_use_classes.size() > 0)  #,"Cannot find proper instantable child for " + object_name)

				while true:
					a += 1
					if a > 50:
						# Object doesn't have children which can be instanced
						# This shouldn't happens, but sadly happen with e.g. Node3DGizmo
						assert(false)  #,"Cannot find proper instantable child for " + object_name)
					var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
					if ClassDB.can_instantiate(choosen_class) && !(choosen_class in BasicData.disabled_classes):
						return ClassDB.instantiate(choosen_class)
			else:
				while true:
					a += 1
					if a > 50:
						assert(false)  #,"Cannot find proper instantable child for " + object_name)
					var choosen_class: String = classes[randi() % classes.size()]
					if ClassDB.can_instantiate(choosen_class) && !ClassDB.is_parent_class(choosen_class, object_name) && !(choosen_class in BasicData.disabled_classes):
						return ClassDB.instantiate(choosen_class)

		# Non Node/Resource object
		var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
		to_use_classes.append(object_name)
		if !ClassDB.can_instantiate(object_name) && object_name in BasicData.disabled_classes:
			assert(to_use_classes.size() > 0)  #,"Cannot find proper instantable child for " + object_name)

		while true:
			a += 1
			if a > 50:
				# Object doesn't have children which can be instanced
				# This shouldn't happens, but sadly happen with e.g. Node3DGizmo
				assert(false)  #,"Cannot find proper instantable child for " + object_name)
			var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
			if ClassDB.can_instantiate(choosen_class) && !(choosen_class in BasicData.disabled_classes):
				return ClassDB.instantiate(choosen_class)

	else:
		if ClassDB.can_instantiate(object_name):  # E.g. Texture2D is not instantable or shouldn't be, but ImageTexture is
			return ClassDB.instantiate(object_name)
		else:  # Found child of non instantable object
			var list_of_class = ClassDB.get_inheriters_from_class(object_name)
			assert(list_of_class.size() > 0)  # Number of inherited class of non instantable class must be greater than 0, otherwise this function would be useless#,"Cannot find proper instantable child for " + object_name)
			for i in list_of_class:
				if ClassDB.can_instantiate(i) && (ClassDB.is_parent_class(i, "Node") || ClassDB.is_parent_class(i, "RefCounted")):
					return ClassDB.instantiate(i)
			assert(false)  #,"Cannot find proper instantable child for " + object_name)

	assert(false)  #,"Cannot find proper instantable child for " + object_name)
	return BoxShape3D.new()


# TODO Update this with upper implementation
func get_object_string(object_name: String) -> String:
	assert(ClassDB.class_exists(object_name))

	var a = 0
	if random:
		var classes = ClassDB.get_inheriters_from_class("Node") + ClassDB.get_inheriters_from_class("RefCounted")

		if object_name == "Object":
			while true:
				var choosen_class: String = classes[randi() % classes.size()]
				if ClassDB.can_instantiate(choosen_class) && (ClassDB.is_parent_class(choosen_class, "Node") || ClassDB.is_parent_class(choosen_class, "RefCounted")):
					return choosen_class

		if ClassDB.is_parent_class(object_name, "Node") || ClassDB.is_parent_class(object_name, "RefCounted"):
			if should_be_always_valid:
				var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
				to_use_classes.append(object_name)
				if !ClassDB.can_instantiate(object_name):
					assert(to_use_classes.size() > 0)  #,"Cannot find proper instantable child for " + object_name)

				while true:
					a += 1
					if a > 30:
						# Object doesn't have children which can be instanced
						# This shouldn't happens, but sadly happen with e.g. Node3DGizmo
						assert(false)  #,"Cannot find proper instantable child for " + object_name)
					var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
					if ClassDB.can_instantiate(choosen_class):
						return choosen_class
			else:
				while true:
					a += 1
					if a > 30:
						assert(false)  #,"Cannot find proper instantable child for " + object_name)
					var choosen_class: String = classes[randi() % classes.size()]
					if !ClassDB.is_parent_class(choosen_class, object_name):
						return choosen_class

		# Non Node/Resource object
		var to_use_classes = ClassDB.get_inheriters_from_class(object_name)
		to_use_classes.append(object_name)
		if !ClassDB.can_instantiate(object_name) && object_name in BasicData.disabled_classes:
			assert(to_use_classes.size() > 0)  #,"Cannot find proper instantable child for " + object_name)

		while true:
			a += 1
			if a > 50:
				# Object doesn't have children which can be instanced
				# This shouldn't happens, but sadly happen with e.g. Node3DGizmo
				assert(false)  #,"Cannot find proper instantable child for " + object_name)
			var choosen_class: String = to_use_classes[randi() % to_use_classes.size()]
			if ClassDB.can_instantiate(choosen_class) && !(choosen_class in BasicData.disabled_classes):
				return choosen_class

	else:
		if ClassDB.can_instantiate(object_name):  # E.g. Texture2D is not instantable or shouldn't be, but ImageTexture is
			return object_name
		else:  # Found child of non instantable object
			var list_of_class = ClassDB.get_inheriters_from_class(object_name)
			assert(list_of_class.size() > 0)  # Number of inherited class of non instantable class must be greater than 0, otherwise this function would be useless#,"Cannot find proper instantable child for " + object_name)
			for i in list_of_class:
				if ClassDB.can_instantiate(i) && (ClassDB.is_parent_class(i, "Node") || ClassDB.is_parent_class(i, "RefCounted")):
					return i
			assert(false)  #,"Cannot find proper instantable child for " + object_name)

	assert(false)  #,"Cannot find proper instantable child for " + object_name)
	return "BoxMesh"
