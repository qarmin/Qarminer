extends Node

# Script first adds nodes to scene, then choose some random nodes and reparents
# them or delete and replace with new ones

## Algorithm
# - Add multiple nodes to scene
# - Set name to each
# - In _process
#   - Get random node
#   - Detach it from its parent
#   - Play with a russian roulette:
#     - If node will be deleted, be sure to get list of its all children and then
#       replace all with new nodes(change also name) and old remove with queue_free()
#   - Get another random node
#   - If nodes are the same, add node to root one(cannot set self as self parent) and repeat steps
#   - If second node is child of first, add first node to root one(prevents from memory leaks due invalid reparenting)
#   - At the end add first random node as child of second

var number_of_nodes: int = 0

var debug_enabled: bool = true

var number_of_variables: int = 0

var to_print: String = ""


func _ready() -> void:
	HelpFunctions.initialize_list_of_available_classes(true, true, [])

	var temp_classes: Array = []
	for name_of_class in BasicData.base_classes:
		if ClassDB.is_parent_class(name_of_class, "Node"):
			temp_classes.append(name_of_class)
	BasicData.base_classes = temp_classes

	if debug_enabled:
		var to_print: String = 'DEBUG: List of classes used in ReparentingDeleting scene"' + str(BasicData.base_classes.size()) + '":\n'
		to_print += "DEBUG: ["
		for index in range(BasicData.base_classes.size()):
			to_print += '"' + BasicData.base_classes[index] + '"'
			if index != BasicData.base_classes.size() - 1:
				to_print += ", "
		print(to_print)

	number_of_nodes = max(BasicData.base_classes.size(), 200)  # Use at least all nodes, or more if you want(168 is probably number of all nodes)
	for i in range(number_of_nodes):
		var index = i
		if i >= BasicData.base_classes.size():  # Wrap values
			index = i % BasicData.base_classes.size()

		var child: Node = ClassDB.instantiate(BasicData.base_classes[index])
		var name_to_set: String = "Special Node " + str(i)
		child.set_name(name_to_set)
		if debug_enabled:
			to_print = "\tvar variable" + str(number_of_variables) + ' = ClassDB.instantiate("' + BasicData.base_classes[index] + '")\n'
			to_print += "\tvar variable" + str(number_of_variables) + ".set_name(" + name_to_set + ")\n"
			to_print += "\tadd_child(variable" + str(number_of_variables) + ")"
			print(to_print)
			number_of_variables += 1
		add_child(child)


func _process(delta: float) -> void:
	var choosen_node: Node
	var parent_of_node: Node
	for i in range(5):
		number_of_variables += 1
		var choosen_node_name: String = "Special Node " + str(randi() % number_of_nodes)
		choosen_node = find_node(choosen_node_name, true, false)
		var parent_node_name: String = choosen_node.get_parent().get_name()
		parent_of_node = choosen_node.get_parent()

		var random_node_name: String = "Special Node " + str(randi() % number_of_nodes)
		var random_node: Node = find_node(random_node_name, true, false)

		if debug_enabled:
			to_print = "\tvar variable" + str(number_of_variables) + "choosen = find_node(" + choosen_node_name + ", true, false) #" + choosen_node.get_class() + "\n"
			to_print += (
				"\tvar variable"
				+ str(number_of_variables)
				+ "parent = var variable"
				+ str(number_of_variables)
				+ "choosen.get_parent()#"
				+ parent_of_node.get_class()
				+ " - "
				+ String(parent_of_node.get_name())
				+ "\n"
			)
			to_print += (
				"\tvariable"
				+ str(number_of_variables)
				+ "random(variable"
				+ str(number_of_variables)
				+ "choosen = find_node("
				+ random_node_name
				+ ", true, false) #"
				+ random_node.get_class()
				+ "\n"
			)
			to_print += "\tvariable" + str(number_of_variables) + "parent.remove_child(variable" + str(number_of_variables) + "choosen\n"
			print(to_print)

		parent_of_node.remove_child(choosen_node)

		if randi() % 6 == 0:  # 16% chance to remove node with children
			var names_to_remove: Array = find_all_special_children_names(choosen_node)
			var temp_counter: int = 0
			for name_to_remove in names_to_remove:
				var node_class: String = BasicData.base_classes[randi() % BasicData.base_classes.size()]

#				if debug_enabled:
#					to_print = "\tvar variable"+ # TODO
				var node: Node = ClassDB.instantiate(node_class)
				node.set_name(name_to_remove)
				add_child(node)
				temp_counter += 1
			choosen_node.queue_free()
			continue

		if choosen_node.find_node(random_node.get_name(), true, false) != null:  # Cannot set as node parent one of its child
			if debug_enabled:
				to_print = "\tadd_child(variable" + str(number_of_variables) + "choosen)"
				print(to_print)
			add_child(choosen_node)
			continue
		if choosen_node == random_node:  # Do not reparent node to self
			if debug_enabled:
				to_print = "\tadd_child(variable" + str(number_of_variables) + "choosen)"
				print(to_print)
			add_child(choosen_node)
			continue

		if debug_enabled:
			to_print = "\tadd_child(variable" + str(number_of_variables) + "choosen)"
			print(to_print)
		random_node.add_child(choosen_node)


#	await get_tree().idle_frame  # TODO Add this to generated code


# Finds recusivelly all child nodes which will be also removed to be able to add
# exactly same number of nodes in replacement.
func find_all_special_children_names(node: Node) -> Array:
	var array: Array = []
	array.append(node.get_name())
	for child in node.get_children():
		if String(child.get_name()).begins_with("Special Node"):
			array.append_array(find_all_special_children_names(child))

	return array
