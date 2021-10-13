extends Node2D
var debug_print

var save_to_file: bool = true
var file_handler: File = File.new()
var to_print: String = ""
var number: int = 0


func _ready():
	if save_to_file:
		file_handler.open("results.txt", File.WRITE)
	HelpFunctions.initialize_list_of_available_classes()


func _process(delta):
	for name_of_class in BasicData.base_classes:
		number += 1
		to_print = "########### " + name_of_class + "\n"
		to_print += "\tvar thing" + str(number) + ' = ClassDB.instantiate("' + name_of_class + '")\n'
		to_print += "\tstr(thing" + str(number) + ")"

		if save_to_file:
			file_handler.store_string(to_print + "\n")
		print(to_print)

		var thing = ClassDB.instantiate(name_of_class)
		str(thing)

		if thing is Node:
			to_print = "\tadd_child(thing" + str(number) + ")\n"
			to_print += "\tthing" + str(number) + ".queue_free()"
			if save_to_file:
				file_handler.store_string(to_print + "\n")
			print(to_print)
			thing.queue_free()
		elif thing is Object && !(thing is RefCounted):
			to_print = "\tthing" + str(number) + ".free()"
			if save_to_file:
				file_handler.store_string(to_print + "\n")
			print(to_print)
			thing.free()
