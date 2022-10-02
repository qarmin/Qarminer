extends Node

var available_nodes: Array = []

var disabled_classes: Array = [
	"ShapeCast2D",  #61925
	"ScrollContainer",  #61927
	"MissingNode",  # Vanished messages
]

var max_children: int = 500
var master_child: Node


func _ready():
	var dir = Directory.new()
	dir.make_dir("res://T/")
	create_available()
	populate()
	save_scene()


func create_available():
	master_child = Node.new()
	add_child(master_child)
	var classes = ClassDB.get_class_list()
	for name_of_class in classes:
		if ClassDB.can_instance(name_of_class) && ClassDB.is_parent_class(name_of_class, "Node"):
			if !(name_of_class in disabled_classes):
				available_nodes.push_back(name_of_class)
	available_nodes.sort()


func populate():
	create_children(master_child, 20)


func assert_if_false(error: int) -> void:
	if error != OK:
		assert(false)


func save_scene():
	var random_number = str(randi())
	print(random_number)
	var packed_scene = PackedScene.new()
	packed_scene.pack(master_child)
	assert_if_false(ResourceSaver.save("res://ABCD.tscn", packed_scene))
	assert_if_false(ResourceSaver.save("res://T/" + random_number + ".tscn", packed_scene))
	assert_if_false(get_tree().change_scene("res://ABCD.tscn"))
	#get_tree().quit()


func create_children(parent: Node, number_of_childrens: int):
	for i in number_of_childrens:
		if max_children < 0:
			return

		var node = ClassDB.instance(available_nodes[randi() % available_nodes.size()])
		node.set_name(str(max_children))
		max_children -= 1
		parent.add_child(node)
		node.set_owner(master_child)

		var child_number = randi() % 10
		if randi() % 3 != 0:
			child_number = 0
		create_children(node, child_number)
