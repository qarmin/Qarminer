extends Node
# Test physics nodes due adding and removing them from scene, moving them and executing random functions on them

# 0 - no info, 1 - basic info about executed functions, 2 - prints also info about moved nodes etc., 3 - all with also printing executed functions
var debug_level: int = 2

var number_of_showed_frames: int = 10000
var used_nodes: int = 100  # Use 100 objects, when using more delete some
var nodes_created_each_turn: int = 10
var nodes_moved_each_turn: int = 10
var max_collision_shapes: int = 2

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
# 	Move nodes with set_position, add_force or similar
#	Random Functions Executor - will probably show the biggest number of crashes, so for now it is better to disable it and fix rest of crashes. It execute on object all available functions without Object and Node functions.
#	Delete some nodes - Randomly deletes nodes


# Function collects names of nodes which will be later used to create its instances
func _ready() -> void:
	if BasicData.regression_test_project:
		ValueCreator.random = false  # Results in RegressionTestProject must be always reproducible
	else:
		ValueCreator.random = true

	ValueCreator.number = 10
	ValueCreator.should_be_always_valid = false

	for name_of_class in BasicData.get_list_of_available_classes():
		if !ClassDB.can_instance(name_of_class):
			continue
		if ClassDB.is_parent_class(name_of_class, "CollisionObject"):
			physics_nodes_3d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "CollisionObject2D"):
			physics_nodes_2d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "Joint"):
			joint_3d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "Joint2D"):
			joint_2d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "Shape"):
			shape_3d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "Shape2D"):
			shape_2d.append(name_of_class)

	all_physical = physics_nodes_3d + physics_nodes_2d + joint_2d + joint_3d

	assert(all_physical.size() > 0)
	assert((shape_2d + shape_3d).size() > 0)

	if debug_level >= 1:
		print("Collected this items:")
		print("CollisionObject: ")
		for i in physics_nodes_3d:
			print("-- " + i)
		print("CollisionObject2D: ")
		for i in physics_nodes_2d:
			print("-- " + i)
		print("Joint: ")
		for i in joint_3d:
			print("-- " + i)
		print("Joint2D: ")
		for i in joint_2d:
			print("-- " + i)
		print("Shape: ")
		for i in shape_3d:
			print("-- " + i)
		print("Shape2D: ")
		for i in shape_2d:
			print("-- " + i)


# Enable this after testing
#func _process(_delta: float) -> void:
#	process_nodes()


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
#	random_functions()
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
		elif ClassDB.is_parent_class(name_of_class, "Spatial"):
			is_2d = false
		else:
			assert(false, "Used class isn't child of Node2D or Spatial")

		created_nodes += 1
		created_objects += 1

		if debug_level >= 2:
			print("-- Creating - " + name_of_class)

		var node: Node = ClassDB.instance(name_of_class)

		if name_of_class in joint_2d or name_of_class in joint_3d:
			# TODO add something for joint
			pass
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
			elif child is Spatial:
				child.set_translation(ValueCreator.get_vector3())

		if child is KinematicBody:
			child.move_and_slide(ValueCreator.get_vector3(), ValueCreator.get_vector3(), ValueCreator.get_bool(), ValueCreator.get_int(), ValueCreator.get_bool())
		elif child is KinematicBody2D:
			child.move_and_slide(ValueCreator.get_vector2(), ValueCreator.get_vector2(), ValueCreator.get_bool(), ValueCreator.get_int(), ValueCreator.get_bool())
		elif child is RigidBody:
			child.add_force(ValueCreator.get_vector3(), ValueCreator.get_vector3())
		elif child is RigidBody2D:
			child.add_force(ValueCreator.get_vector2(), ValueCreator.get_vector2())
		elif child is Joint:
			var nodea: Node = get_child(randi() % get_child_count())
			var nodeb: Node = get_child(randi() % get_child_count())
			assert(child.get_node("../" + nodea.get_name()) != null)
			child.set_node_a("../" + nodea.get_name())
			child.set_node_b("../" + nodeb.get_name())
		elif child is Joint2D:
			var nodea: Node = get_child(randi() % get_child_count())
			var nodeb: Node = get_child(randi() % get_child_count())
			assert(child.get_node("../" + nodea.get_name()) != null)
			child.set_node_a("../" + nodea.get_name())
			child.set_node_b("../" + nodeb.get_name())

	if debug_level:
		print("--- Ended Moving Nodes ---")


func random_functions() -> void:
	if debug_level:
		print("--- Started Random Function Execution ---")

	for child in get_children():
		var name_of_class: String = child.get_class()

		var list_of_methods: Array = ClassDB.class_get_method_list(name_of_class, true)
		for method_data in list_of_methods:
			# Don't use methods from Object or Node, because them ingerate too much with project
			if ClassDB.class_has_method("Object", method_data["name"]) || ClassDB.class_has_method("Node", method_data["name"]):
				continue

			if method_data["name"] in BasicData.function_exceptions:
				continue

			var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, name_of_class, debug_level >= 3)
			child.callv(method_data["name"], arguments)

			for argument in arguments:
				if argument != null:
					if argument is Node:
						argument.queue_free()
					elif argument is Object && !(argument is Reference):
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
			cs.set_shape(ClassDB.instance(shape_2d[randi() % shape_2d.size()]))
			return cs
		else:
			if debug_level >= 2:
				print("-- Created CollisionPolygon2D")
			var cp = CollisionPolygon2D.new()
			cp.set_polygon(ValueCreator.get_pool_vector2_array())
			return cp
	else:
		if randi() % 2:
			if debug_level >= 2:
				print("-- Created CollisionShape")
			var cs = CollisionShape.new()
			cs.set_shape(ClassDB.instance(shape_3d[randi() % shape_3d.size()]))
			return cs
		else:
			if debug_level >= 2:
				print("-- Created CollisionPolygon")
			var cp = CollisionPolygon.new()
			cp.set_polygon(ValueCreator.get_pool_vector2_array())
			return cp
