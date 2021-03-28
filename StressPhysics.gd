extends Node

# TODO Remove randi to be able to use it inside CI

var debug_print: bool = true

var used_nodes: int = 100  # Use 100 objects, when using more delete some
var nodes_created_each_turn: int = 10
var nodes_moved_each_turn: int = 10
var max_collision_shapes: int = 10

var physics_nodes_3d: Array = []
var physics_nodes_2d: Array = []
var shape_3d: Array = []
var shape_2d: Array = []

var created_objects = 0

# Algorithm(each step may be disabled when needed):

# Loop - exit after X frames
# 	Create some physics nodes and add to them 
# 	Move nodes with set_position, add_force or similar
#	Random Functions Executor - will probably show the biggest number of crashes, so for now it is better to disable it and fix rest of crashes. It execute on object all available functions without Object and Node functions.
#	Delete some nodes - Randomly deletes nodes


# Function collects names of nodes which will be later used to create its instances
func _ready() -> void:
	ValueCreator.number = 10
	ValueCreator.random = true
	ValueCreator.should_be_always_valid = true  # Not used here

	for name_of_class in BasicData.get_list_of_available_classes():
		if !ClassDB.can_instance(name_of_class):
			continue
		if ClassDB.is_parent_class(name_of_class, "CollisionObject"):
			physics_nodes_3d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "CollisionObject2D"):
			physics_nodes_2d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "Shape"):
			shape_3d.append(name_of_class)
		if ClassDB.is_parent_class(name_of_class, "Shape2D"):
			shape_2d.append(name_of_class)


func _process(_delta: float) -> void:
	process_nodes()

func _physics_process(_delta: float) -> void:
	process_nodes()

var times_executed: int = 0

func process_nodes() -> void:
	if debug_print:
		print("--- Starting Processing Data ---")
		
	times_executed += 1
	if times_executed >= 100:
		get_tree().quit()
	create_nodes()
	move_nodes()
	random_functions()
	delete_nodes()
	if debug_print:
		print("--- Ended Processing Data ---")


func create_nodes():
	if debug_print:
		print("--- Started Creating Nodes ---")
	var created_nodes: int = 0

	while true:
		if created_nodes == nodes_created_each_turn:
			break

		var name_of_class: String = (physics_nodes_3d + physics_nodes_2d)[randi() % (physics_nodes_3d.size() + physics_nodes_2d.size())]

		var is_2d: bool = false
		if ClassDB.is_parent_class(name_of_class, "Node2D"):
			is_2d = true
		elif ClassDB.is_parent_class(name_of_class, "Spatial"):
			is_2d = false
		else:
			assert(false)

		created_nodes += 1
		created_objects += 1

		var node: Node = ClassDB.instance(name_of_class)
		for i in randi() % max_collision_shapes:
			node.add_child(create_collision_object(is_2d))
		node.set_name("Special Node " + str(created_objects))
		add_child(node)
		
	if debug_print:
		print("--- Ended Creating Nodes ---")


func move_nodes()-> void:
	if debug_print:
		print("--- Started Moving Nodes ---")
	for i in nodes_moved_each_turn:
		var index: int = randi() % get_child_count()
		var child: Node = get_child(index)

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
			
	if debug_print:
		print("--- Ended Creating Nodes ---")

func random_functions() -> void:
	if debug_print:
		print("--- Started Random Function Execution ---")
		
	for child in get_children():
		var name_of_class : String = child.get_class()
		
		var list_of_methods : Array = ClassDB.class_get_method_list(name_of_class, true)
		for method_data in list_of_methods:
			# Function is virtual, so we just skip it
			if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
				continue
				
			# Don't use methods from Object or Node, because them ingerate too much with project
			if ClassDB.class_has_method("Object", method_data["name"]) || ClassDB.class_has_method("Node", method_data["name"]):
				continue
				
			if method_data["name"] in BasicData.function_exceptions:
				continue

			if debug_print:
				print(name_of_class + "." + method_data["name"])

			var arguments: Array = ParseArgumentType.parse_and_return_objects(method_data, debug_print)
			child.callv(method_data["name"], arguments)

			for argument in arguments:
				assert(argument != null)
				if argument is Node:
					argument.queue_free()
				elif argument is Object && !(argument is Reference):
					argument.free()
					
	if debug_print:
		print("--- Ended Random Function Execution ---")
		

func delete_nodes() -> void:
	if get_child_count() > used_nodes:
		for _i in range(get_child_count() - used_nodes):
			var index: int = randi() % get_child_count()
			var child: Node = get_child(index)
			child.queue_free()


func create_collision_object(is_2d: bool):
	if is_2d:
		if randi() % 2:
			var cs = CollisionShape2D.new()
			cs.set_shape(ClassDB.instance(shape_2d[randi() % shape_2d.size()]))
			return cs
		else:
			var cp = CollisionPolygon2D.new()
			cp.set_polygon(ValueCreator.get_pool_vector2_array())
			return cp
	else:
		if randi() % 2:
			var cs = CollisionShape.new()
			cs.set_shape(ClassDB.instance(shape_3d[randi() % shape_3d.size()]))
			return cs
		else:
			var cp = CollisionPolygon.new()
			cp.set_polygon(ValueCreator.get_pool_vector2_array())
			return cp
