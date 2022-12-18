extends Node2D

var ignored = [
	# Non existent - maybe bug?
	"config/features",
	"config/name",
	"limits/time/time_rollover_secs",

	# Never enable
	"run/disable_stdout", # Disable prints to terminal
	"run/disable_stderr", # Disable prints to terminal
	"run/main_loop_type", # Hard error/message box
	"limits/message_queue/max_size_kb", # Cause out of memory
	"rendering_device/staging_buffer/block_size_kb", # Out of memory and freeze with negative numbers

	"rendering_device/driver", # TODO shows info about missing driver, probably this is proper info
	"rendering_device/driver.windows",
	"rendering_device/driver.android",
	"rendering_device/driver.ios",
	"rendering_device/driver.macos",
	"rendering_device/driver.linuxbsd",
	
	# Only do stupid thins, may be enabled in futures
	"run/low_processor_mode", # Freeze, low performance
	"run/low_processor_mode_sleep_usec", # Freeze, low performance
	"settings/stdout/verbose_stdout", # Verbose printing, not needed
	"run/max_fps", # Slow as hellgod
	
	# TODO 
	"rendering_device/staging_buffer/texture_upload_region_size_px", # Freeze when adding to this texture
	
	# Reported bugs
	"renderer/rendering_method", # 69815
	"mouse_cursor/custom_image", # 68472
	"driver/mix_rate", # 69819
]

var ValueCreator

# Called when the node enters the scene tree for the first time.
func _ready():
#	randomize()
#	for i in ProjectSettings.get_settings():
#		if String(i["name"]).begins_with("autoload/"):
#			continue
#		var short_name_parts = String(i["name"]).split("/")
#		short_name_parts.remove_at(0)
#		var short_name = "/".join(short_name_parts)
#		if short_name in ignored:
#			continue
#
#		ProjectSettings.clear(i["name"])
#		if i["type"] == TYPE_DICTIONARY:
#			continue # TODO fix this, currently objects inside not works
#
##		if randi() % 10 != 0:
##			continue
#
#		#ProjectSettings.set_setting(i["name"], get_object(i["type"]))#randi() % 50)
#		#print(i)
#	var r = ProjectSettings.save()
#	print(r)

	get_tree().quit()
	
	
func get_object(type: int):
	var obj
	match type:
		TYPE_NIL:  # Looks that this means VARIANT not null
			if randi() % 3:
				obj = get_array()
			elif randi() % 3:
				obj = get_string()
			elif randi() % 3:
				obj = get_int()
			else:
				obj = get_basis()
		TYPE_AABB:
			obj = get_aabb()
		TYPE_ARRAY:
			obj = get_array()
		TYPE_BASIS:
			obj = get_basis()
		TYPE_BOOL:
			obj = get_bool()
		TYPE_COLOR:
			obj = get_color()
		TYPE_PACKED_COLOR_ARRAY:
			obj = get_packed_color_array()
		TYPE_DICTIONARY:
			obj = get_dictionary()
		TYPE_INT:
			obj = get_int()
		TYPE_PACKED_INT32_ARRAY:
			obj = get_packed_int32_array()
		TYPE_NODE_PATH:
			obj = get_nodepath()
		TYPE_OBJECT:
			obj = null
		TYPE_PLANE:
			obj = get_plane()
		TYPE_QUATERNION:
			obj = get_quaternion()
		TYPE_PACKED_BYTE_ARRAY:
			obj = get_packed_byte_array()
		TYPE_FLOAT:
			obj = get_float()
		TYPE_PACKED_FLOAT32_ARRAY:
			obj = get_packed_float32_array()
		TYPE_RECT2:
			obj = get_rect2()
		TYPE_RID:
			obj = RID()
		TYPE_STRING:
			obj = get_string()
		TYPE_PACKED_STRING_ARRAY:
			obj = get_packed_string_array()
		TYPE_TRANSFORM3D:
			obj = get_transform3d()
		TYPE_TRANSFORM2D:
			obj = get_transform2d()
		TYPE_VECTOR2:
			obj = get_vector2()
		TYPE_PACKED_VECTOR2_ARRAY:
			obj = get_packed_vector2_array()
		TYPE_VECTOR3:
			obj = get_vector3()
		TYPE_PACKED_VECTOR3_ARRAY:
			obj = get_packed_vector3_array()
#			# TODOGODOT4
		TYPE_CALLABLE:
			obj = Callable(BoxMesh.new(), "Rar")
		TYPE_VECTOR2I:
			obj = get_vector2i()
		TYPE_VECTOR3I:
			obj = get_vector3i()
		TYPE_VECTOR4:
			obj = get_vector4()
		TYPE_VECTOR4I:
			obj = get_vector4i()
		TYPE_STRING_NAME:
			obj = get_string_name()
		TYPE_RECT2I:
			obj = get_rect2i()
		TYPE_PACKED_FLOAT64_ARRAY:
			obj = get_packed_float64_array()
		TYPE_PACKED_INT64_ARRAY:
			obj = get_packed_int64_array()
		TYPE_SIGNAL:
			obj = get_signal()
		TYPE_PROJECTION:
			obj = get_projection()
		_:
			assert(false)  #,"Missing type --" + str(argument.type) + "-- needs to be added to project")
	return obj


var number: float = 0.0

var max_array_size: int = 25


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
		assert(false)
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
			return "Eyes" #get_dictionary()
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
