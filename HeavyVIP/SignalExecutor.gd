extends Node
#######

### DOESN"T WORK, DON"T USE FOR NOW
### FROM MY TESTING IT DOENS'T FIND ANY CRASHES OR SIMILAR THINGS

######
#var debug_print: bool = true
#var add_to_tree : bool = true # Adds nodes to tree
#var use_parent_methods: bool = false  # Allows Node2D use Node methods etc. - it is a little slow option which rarely shows
#var use_always_new_object: bool = true  # Don't allow to "remeber" other function effects
#
#func _ready() -> void:
#	tests_all_signals()
#
#
## Test all signals
#func tests_all_signals() -> void:
#	for name_of_class in BasicData.get_list_of_available_classes():
#		if name_of_class == "_OS": # Do not change size of window
#			continue
#
#		# Instance object to be able to execute on it specific signals and later delete to prevent memory leak if it is a Node
#		var object: Object = ClassDB.instance(name_of_class)
#		if add_to_tree:
#			if object is Node:
#				add_child(object)
#		assert(object != null)  # This shxzould be checked before when collectiong signals
#		var signal_list: Array = ClassDB.class_get_signal_list(name_of_class, ! use_parent_methods)
#
#		## Exception
#		for exception in BasicData.invalid_signals:
#			var index: int = -1
#			for signal_index in range(signal_list.size()):
#				if signal_list[signal_index]["name"] == exception:
#					index = signal_index
#					break
#			if index != -1:
#				signal_list.remove(index)
#
#		if debug_print:
#			print("############### CLASS ############### - " + name_of_class)
#
#		for signal_data in signal_list:
#			if debug_print:
#				print(signal_data["name"])
#
#			var arguments: Array = ParseArgumentType.(signal_data)
#			object.emit_signal(signal_data["name"], arguments)
#
#			for argument in arguments:
#				assert(argument != null)
#				if argument is Node:
#					argument.queue_free()
#				elif argument is Object && !(argument is Reference):
#					argument.free()
#
#			if use_always_new_object:
#				assert(object != null)
#				if object is Node:
#					object.queue_free()
#				elif object is Object && !(object is Reference):
#					object.free()
#
#				object = ClassDB.instance(name_of_class)
#
#		if object is Node:  # Just prevent memory leak
#			object.queue_free()
#			object = null
#		elif object is Object && !(object is Reference):
#			object.free()
#			object = null
#
#
