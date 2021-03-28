extends Node

var debug_print: bool = true
var add_to_tree: bool = true  # Adds nodes to tree
var use_parent_methods: bool = false  # Allows Node2D use Node methods etc. - it is a little slow option which rarely shows
var use_always_new_object: bool = true  # Don't allow to "remeber" other function effects
var exiting: bool = false

var used_nodes: int = 100  # Use 100 objects, when using more delete some
var nodes_created_each_turn: int = 10
var nodes_moved_each_turn: int = 10
var max_collision_shapes: int = 10

var physics_nodes_3d: Array = []
var physics_nodes_2d: Array = []
var shape_3d: Array = []
var shape_2d: Array = []

var created_objects = 0

# Loop - Maybe allow to work
# 	Create some nodes
# 	Move this nodes
#	Delete some nodes


func _ready() -> void:
	ValueCreator.number = 100
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


func _process(delta: float) -> void:
	process_nodes()


func _physics_process(delta: float) -> void:
	process_nodes()


var i: int = 0


func process_nodes() -> void:  # Replace this with _ready in RegressionTestProject
	i += 1
	if i >= 100:
		get_tree().quit()
	create_nodes()
	move_nodes()
	delete_nodes()


func create_nodes():
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


func move_nodes():
	for i in nodes_moved_each_turn:
		var index: int = randi() % get_child_count()
		var child: Node = get_child(index)

		if randi() % 2:
			if child is Node2D:
				child.set_position(Vector2())
			elif child is Spatial:
				child.set_translation(Vector3())

		if child is KinematicBody:
			child.move_and_slide(ValueCreator.get_vector3(), ValueCreator.get_vector3(), ValueCreator.get_bool(), ValueCreator.get_int(), ValueCreator.get_bool())
		elif child is KinematicBody2D:
			child.move_and_slide(ValueCreator.get_vector2(), ValueCreator.get_vector2(), ValueCreator.get_bool(), ValueCreator.get_int(), ValueCreator.get_bool())
		elif child is RigidBody:
			child.add_force(ValueCreator.get_vector3(), ValueCreator.get_vector3())
		elif child is RigidBody2D:
			child.add_force(ValueCreator.get_vector2(), ValueCreator.get_vector2())


func delete_nodes() -> void:
	if get_child_count() > used_nodes:
		for i in range(get_child_count() - used_nodes):
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
