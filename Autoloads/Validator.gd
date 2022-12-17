extends Node

var validate: bool = false

func _ready():
	if !validate:
		return
	
	var classes_to_test: Array = BasicData.disabled_classes
	var classes_names: Dictionary = {}
	for i in classes_to_test:
		if !ClassDB.class_exists(i) && !ClassDB.class_exists("_" + i):
			validator_print(i + ": not exists")
		if i in classes_names.keys():
			validator_print(i + ": is duplicated")
		classes_names[i] = true
	
	
	var functions_to_test: Array = BasicData.function_exceptions
	var functions_names: Dictionary = {}
	
	var function_all_list: Dictionary = {}
	
	for i in ClassDB.get_class_list():
		var methods = ClassDB.class_get_method_list(i, true)
		for method in methods:
			function_all_list[method["name"]] = true

	for i in functions_to_test: 
		if !(i in function_all_list.keys()):
			validator_print(i + ": not exists")
		if i in functions_names.keys():
			validator_print(i + ": is duplicated")
		functions_names[i] = true
	
	get_tree().quit()


func validator_print(to_print: String):
	print("VALIDATOR:   " + to_print)

