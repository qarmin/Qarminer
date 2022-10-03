extends Node
# Test physics nodes due adding and removing them from scene, moving them and executing random functions checked them

# 0 - no info, 1 - basic info about executed functions, 2 - prints also info about moved nodes etc., 3 - all with also printing executed functions
var debug_level: int = 3

var number_of_showed_frames: int = 10000
var used_nodes: int = 100  # Use 100 objects, when using more delete some
var nodes_created_each_turn: int = 30
var nodes_moved_each_turn: int = 10
var max_collision_shapes: int = 10

var physics_nodes_3d: Array = []
var physics_nodes_2d: Array = []
var shape_3d: Array = []
var shape_2d: Array = []
var joint_3d: Array = []
var joint_2d: Array = []

var all_physical: Array = []

var created_objects = 0

# Algorithm(each step may be disabled when needed):

# Loop - exit after X frames
# 	Create some physics nodes and add them to scene tree
# 	Move nodes with set_position, apply_force or similar
#	Random Functions Executor - will probably show the biggest number of crashes, so for now it is better to disable it and fix rest of crashes. It execute checked object all available functions without Object and Node functions.
#	Delete some nodes - Randomly deletes nodes


# Function collects names of nodes which will be later used to create its instances
func _ready() -> void:
	ValueCreator.number = 10

	HelpFunctions.initialize_list_of_available_classes()
	HelpFunctions.initialize_array_with_allowed_functions(false, BasicData.function_exceptions)

	for name_of_class in BasicData.base_classes:
		if !ClassDB.can_instantiate(name_of_class):
			continue
		if ClassDB.is_parent_class(name_of_class, "CollisionObject3D"):
			physics_nodes_3d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "CollisionObject2D"):
			physics_nodes_2d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "Joint3D"):
			joint_3d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "Joint2D"):
			joint_2d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "Shape3D"):
			shape_3d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "Shape2D"):
			shape_2d.append(name_of_class)

	all_physical = physics_nodes_3d + physics_nodes_2d + joint_2d + joint_3d

	assert(all_physical.size() > 0)
	assert((shape_2d + shape_3d).size() > 0)

	if debug_level >= 1:
		print("Collected this items:")
		print("CollisionObject3D: ")
		for i in physics_nodes_3d:
			print("-- " + i)
		print("CollisionObject2D: ")
		for i in physics_nodes_2d:
			print("-- " + i)
		print("Joint3D: ")
		for i in joint_3d:
			print("-- " + i)
		print("Joint2D: ")
		for i in joint_2d:
			print("-- " + i)
		print("Shape3D: ")
		for i in shape_3d:
			print("-- " + i)
		print("Shape2D: ")
		for i in shape_2d:
			print("-- " + i)


# Enable this after testing
func _process(_delta: float) -> void:
	process_nodes()


func _physics_process(_delta: float) -> void:
	process_nodes()


var times_executed: int = 0


func process_nodes() -> void:
	if debug_level:
		print("--- Starting Processing Data ---")

	times_executed += 1
	if times_executed >= number_of_showed_frames:
		get_tree().quit()
	create_nodes()
	move_nodes()
	#random_functions()
	delete_nodes()
	if debug_level:
		print("--- Ended Processing Data ---")


func create_nodes():
	if debug_level:
		print("--- Started Creating Nodes ---")
	var created_nodes: int = 0

	while true:
		if created_nodes == nodes_created_each_turn:
			break

		var name_of_class: String = all_physical[randi() % all_physical.size()]

		var is_2d: bool = false
		if ClassDB.is_parent_class(name_of_class, "Node2D"):
			is_2d = true
		elif ClassDB.is_parent_class(name_of_class, "Node3D"):
			is_2d = false
		else:
			assert(false)  #,"Used class isn't child of Node2D or Node3D")

		created_nodes += 1
		created_objects += 1

		if debug_level >= 2:
			print("-- Creating - " + name_of_class)

		var node: Node = ClassDB.instantiate(name_of_class)

		if name_of_class in joint_2d or name_of_class in joint_3d:
			for i in randi() % max_collision_shapes:
				node.add_child(create_collision_object(is_2d))
		else:
			for i in randi() % max_collision_shapes:
				node.add_child(create_collision_object(is_2d))
		node.set_name("Special Node " + str(created_objects))
		add_child(node)

	if debug_level:
		print("--- Ended Creating Nodes ---")


func move_nodes() -> void:
	if debug_level:
		print("--- Started Moving Nodes ---")
	for i in nodes_moved_each_turn:
		var index: int = randi() % get_child_count()
		var child: Node = get_child(index)

		if debug_level >= 2:
			print("-- Moving - " + child.get_class())

		if randi() % 2:
			if child is Node2D:
				child.set_position(ValueCreator.get_vector2())
			elif child is Node3D:
				child.set_position(ValueCreator.get_vector3())

		if child is CharacterBody3D:
			child.set_velocity(ValueCreator.get_vector3())
			child.set_up_direction(ValueCreator.get_vector3())
			child.set_floor_stop_on_slope_enabled(ValueCreator.get_bool())
			child.set_max_slides(ValueCreator.get_int())
			child.set_floor_max_angle(ValueCreator.get_bool())
			child.move_and_slide()
			child.velocity
		elif child is CharacterBody2D:
			child.set_velocity(ValueCreator.get_vector2())
			child.set_up_direction(ValueCreator.get_vector2())
			child.set_floor_stop_on_slope_enabled(ValueCreator.get_bool())
			child.set_max_slides(ValueCreator.get_int())
			child.set_floor_max_angle(ValueCreator.get_bool())
			child.move_and_slide()
			child.velocity
		elif child is RigidBody3D:
			child.apply_force(ValueCreator.get_vector3(), ValueCreator.get_vector3())
		elif child is RigidBody2D:
			child.apply_force(ValueCreator.get_vector2(), ValueCreator.get_vector2())
		elif child is Joint3D:
			var nodea: Node = get_child(randi() % get_child_count())
			var nodeb: Node = get_child(randi() % get_child_count())
			assert(child.get_node("../" + String(nodea.get_name())) != null)
			child.set_node_a("../" + String(nodea.get_name()))
			child.set_node_b("../" + String(nodeb.get_name()))
		elif child is Joint2D:
			var nodea: Node = get_child(randi() % get_child_count())
			var nodeb: Node = get_child(randi() % get_child_count())
			assert(child.get_node("../" + String(nodea.get_name())) != null)
			child.set_node_a("../" + String(nodea.get_name()))
			child.set_node_b("../" + String(nodeb.get_name()))

	if debug_level:
		print("--- Ended Moving Nodes ---")


func random_functions() -> void:
	if debug_level:
		print("--- Started Random Function Execution ---")

	for child in get_children():
		var name_of_class: String = child.get_class()

		var method_list: Array = BasicData.allowed_thing[name_of_class]

		for method_data in method_list:
			# Don't use methods from Object or Node, because them ingerate too much with project
			if ClassDB.class_has_method("Object", method_data["name"]) || ClassDB.class_has_method("Node", method_data["name"]):
				continue

			var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, name_of_class, debug_level >= 3)
			child.callv(method_data["name"], arguments)

			for argument in arguments:
				if argument != null:
					if argument is Node:
						argument.queue_free()
					elif argument is Object && !(argument is RefCounted):
						argument.free()

	if debug_level:
		print("--- Ended Random Function Execution ---")


func delete_nodes() -> void:
	if get_child_count() > used_nodes:
		for _i in range(get_child_count() - used_nodes):
			var index: int = randi() % get_child_count()
			var child: Node = get_child(index)
			if debug_level >= 2:
				print("-- Deleting - " + child.get_class())
			child.queue_free()


func create_collision_object(is_2d: bool):
	if is_2d:
		if randi() % 2:
			if debug_level >= 2:
				print("-- Created CollisionShape2D")
			var cs = CollisionShape2D.new()
			cs.set_shape(ClassDB.instantiate(shape_2d[randi() % shape_2d.size()]))
			return cs
		else:
			if debug_level >= 2:
				print("-- Created CollisionPolygon2D")
			var cp = CollisionPolygon2D.new()
			cp.set_polygon(ValueCreator.get_packed_vector2_array())
			return cp
	else:
		if randi() % 2:
			if debug_level >= 2:
				print("-- Created CollisionShape3D")
			var cs = CollisionShape3D.new()
			cs.set_shape(ClassDB.instantiate(shape_3d[randi() % shape_3d.size()]))
			return cs
		else:
			if debug_level >= 2:
				print("-- Created CollisionPolygon3D")
			var cp = CollisionPolygon3D.new()
			cp.set_polygon(ValueCreator.get_packed_vector2_array())
			return cp
