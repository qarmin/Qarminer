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
#       replace all with new nodes(change also name) and old remove_at with queue_free()
#   - Get another random node
#   - If nodes are the same, add node to root one(cannot set self as self parent) and repeat steps
#   - If second node is child of first, add first node to root one(prevents from memory leaks due invalid reparenting)
#   - At the end add first random node as child of second

var number_of_nodes: int = 0

var debug_enabled: bool = true

var number_of_variables: int = 0

var to_print: String = ""
var debug_print: bool = true

var save_data_to_file: bool = true
var file_handler: FileAccess


func _ready() -> void:
	if save_data_to_file:
		file_handler = FileAccess.open("res://results.txt", FileAccess.WRITE)

	HelpFunctions.initialize_list_of_available_classes()

	var temp_classes: Array = []
	for name_of_class in BasicData.base_classes:
		if ClassDB.is_parent_class(name_of_class, "Node"):
			temp_classes.append(name_of_class)
	BasicData.base_classes = temp_classes
#	BasicData.base_classes = ["AnimatedSprite2D"]

#	if debug_enabled:
#		var to_print: String = 'DEBUG: List of classes used in ReparentingDeleting scene"' + str(BasicData.base_classes.size()) + '":\n'
#		to_print += "DEBUG: ["
#		for index in range(BasicData.base_classes.size()):
#			to_print += '"' + BasicData.base_classes[index] + '"'
#			if index != BasicData.base_classes.size() - 1:
#				to_print += ", "
#		to_print = "\tvar available_classes : Array = ["
#		for index in range(BasicData.base_classes.size()):
#			to_print += '"' + BasicData.base_classes[index] + '"'
#			if index != BasicData.base_classes.size() - 1:
#				to_print += ", "
#		to_print += "]"
#		save_to_file_to_screen("\n" + to_print,to_print)

	number_of_nodes = 5
	for i in range(number_of_nodes):
		var index: int = randi() % BasicData.base_classes.size()

		var child: Node = ClassDB.instantiate(BasicData.base_classes[index])
		var name_to_set: String = "Special Node " + str(i)
		child.set_name(name_to_set)
		if debug_enabled:
			to_print = "\tvar variable" + str(number_of_variables) + ' = ClassDB.instantiate("' + BasicData.base_classes[index] + '")\n'
			to_print += "\tvariable" + str(number_of_variables) + '.set_name("' + name_to_set + '")\n'
			to_print += "\tadd_child(variable" + str(number_of_variables) + ")"
			save_to_file_to_screen("\n" + to_print, to_print)
			number_of_variables += 1
		add_child(child)


func _process(delta: float) -> void:
	var choosen_node: Node
	var parent_node: Node
	for i in range(2):
		number_of_variables += 1
		var choosen_node_name: String = "Special Node " + str(randi() % number_of_nodes)
		choosen_node = find_child(choosen_node_name, true, false)
		var choosen_node_variable_name: String = "var" + str(number_of_variables) + "choosen"
		assert(choosen_node != null)

		var parent_node_name: String = choosen_node.get_parent().get_name()
		parent_node = choosen_node.get_parent()
		var parent_node_variable_name: String = "var" + str(number_of_variables) + "parent"
		assert(parent_node != null)

		var random_node_name: String = "Special Node " + str(randi() % number_of_nodes)
		var random_node: Node = find_child(random_node_name, true, false)
		var random_node_variable_name: String = "var" + str(number_of_variables) + "random"
		assert(random_node != null)

		if debug_enabled:
			to_print = "\t##########\n"
			to_print += "\tprint_tree_pretty()\n"
			to_print += "\tvar " + choosen_node_variable_name + ' = find_node("' + choosen_node_name + '", true, false) #' + choosen_node.get_class() + "\n"
			to_print += "\tassert(" + choosen_node_variable_name + "!= null)\n"
			to_print += "\tvar " + parent_node_variable_name + " = " + choosen_node_variable_name + ".get_parent() #" + parent_node.get_class() + " - " + parent_node_name + "\n"
			to_print += "\tassert(" + parent_node_variable_name + "!= null)\n"
			to_print += "\tvar " + random_node_variable_name + ' = find_node("' + random_node_name + '", true, false) #' + random_node.get_class() + "\n"
			to_print += "\tassert(" + random_node_variable_name + "!= null)\n"

			to_print += "\t" + parent_node_variable_name + ".remove_child(" + choosen_node_variable_name + ")"
			save_to_file_to_screen("\n" + to_print, to_print)

		parent_node.remove_child(choosen_node)

		if randi() % 6 == 0:  # 16% chance to remove_at node with children
			var names_to_remove: Array = find_all_special_children_names(choosen_node)
#			if debug_enabled:
#				to_print = "\t#names_to_remove = " + str(names_to_remove)
#				save_to_file_to_screen("\n" + to_print,to_print)
			var temp_counter: int = 0
			for name_to_remove in names_to_remove:
				var node_class: String = BasicData.base_classes[randi() % BasicData.base_classes.size()]

				if debug_enabled:
					var temp_variable_name: String = "var" + str(number_of_variables) + "_temp" + str(temp_counter)
					to_print = "\tvar " + temp_variable_name + " = " + node_class + ".new()\n"
					if choosen_node_name != name_to_remove:
						to_print += "\t" + choosen_node_variable_name + '.find_node("' + name_to_remove + '").set_name("' + temp_variable_name + '")\n'
					else:
						to_print += "\t" + choosen_node_variable_name + '.set_name("' + temp_variable_name + '")\n'
					to_print += "\t" + temp_variable_name + '.set_name("' + name_to_remove + '")\n'
					to_print += "\tadd_child(" + temp_variable_name + ")"
#					if choosen_node_name != name_to_remove:
#						choosen_node.find_node(name_to_remove,true,false).set_name(temp_variable_name)
#					else:
#						choosen_node.set_name(temp_variable_name)
					save_to_file_to_screen("\n" + to_print, to_print)

				var node: Node = ClassDB.instantiate(node_class)
				node.set_name(name_to_remove)
				add_child(node)
				temp_counter += 1
			if debug_enabled:
				to_print = "\t" + choosen_node_variable_name + ".queue_free()"
				save_to_file_to_screen("\n" + to_print, to_print)
			choosen_node.queue_free()
			continue

		if choosen_node.find_child(random_node.get_name(), true, false):  # Cannot set as node parent one of its child
			if debug_enabled:
				to_print = "\tadd_child(" + choosen_node_variable_name + ")"
				save_to_file_to_screen("\n" + to_print, to_print)
			add_child(choosen_node)
			continue
		if choosen_node == random_node:  # Do not reparent node to self
			if debug_enabled:
				to_print = "\tadd_child(" + choosen_node_variable_name + ")"
				save_to_file_to_screen("\n" + to_print, to_print)
			add_child(choosen_node)
			continue

		if debug_enabled:
			to_print = "\t" + random_node_variable_name + ".add_child(" + choosen_node_variable_name + ")"
			save_to_file_to_screen("\n" + to_print, to_print)
		random_node.add_child(choosen_node)

	save_to_file_to_screen("\n\n\tawait get_tree().idle_frame\n", '\t\n\tyield(get_tree(), "idle_frame")\n')


# Finds recusivelly all child nodes which will be also removed to be able to add
# exactly same number of nodes in replacement.
func find_all_special_children_names(node: Node) -> Array:
	var array: Array = []
	array.append(String(node.get_name()))
	for child in node.get_children():
		if String(child.get_name()).begins_with("Special Node"):
			array.append_array(find_all_special_children_names(child))

	return array


func save_to_file_to_screen(text_to_save_to_file: String, text_to_print_on_screen: String) -> void:
	if save_data_to_file:
		file_handler.store_string(text_to_save_to_file)
		file_handler.flush()
	if debug_print:
		print(text_to_print_on_screen)
