extends Node

var base_dir : String = "res://Project/"
	
class ClassData:
	var name : String = ""
	var function_names : Array = []
	var arguments : Array = []

var classes : Array 

func collect_data() -> void:
	var use_parent_methods : bool = false # Allows Node2D use Node methods etc. - it is a little slow option
	
	for name_of_class in Autoload.get_list_of_available_classes():
		var class_data : ClassData = ClassData.new()
		class_data.name = name_of_class
		
		var method_list : Array = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)
		for exception in Autoload.function_exceptions:
			var index : int = -1
			for method_index in range(method_list.size()):
				if method_list[method_index]["name"] == exception:
					index = method_index
					break
			if index != -1:
				method_list.remove(index)
		
		
		for method_data in method_list:
			# Function is virtual, so we just skip it
			if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
				continue 
			
			var arguments : Array = []
			
			
			class_data.function_names.append(method_data["name"])
			for i in method_data["args"]:
				arguments.push_back(i["type"])
			class_data.arguments.append(arguments)
			
		classes.append(class_data)
	
	

func remove_files_recursivelly(to_delete : String) -> void:
	var directory : Directory = Directory.new()
	
	assert(directory.open(to_delete) == OK)
	directory.list_dir_begin()
	var file_name : String = directory.get_next()
	while file_name != "":
		if file_name != "." && file_name != "..":
			if directory.current_is_dir():
				file_name = to_delete + file_name + "/"
				remove_files_recursivelly(file_name)
			else:
				file_name = to_delete + file_name
				assert(file_name.find("/./") == -1 && file_name.begins_with("res://") && file_name.begins_with(base_dir) && file_name.find("//",6) == -1)
#				print(file_name)
				directory.remove(file_name)
			
			assert(file_name.find("/./") == -1 && file_name.begins_with("res://") && file_name.begins_with(base_dir) && file_name.find("//",6) == -1)
		file_name = directory.get_next()

#	print(to_delete)
	assert(to_delete.find("/./") == -1 && to_delete.begins_with("res://") && to_delete.begins_with(base_dir) && to_delete.find("//",6) == -1)
	directory.remove(to_delete) # TODO, Test This

func create_basic_files() -> void:
	var directory : Directory = Directory.new()
	assert(directory.make_dir_recursive(base_dir + "2D/") == OK)
	assert(directory.make_dir_recursive(base_dir + "3D/") == OK)
	assert(directory.make_dir_recursive(base_dir + "Node/") == OK)
	assert(directory.make_dir_recursive(base_dir + "Other/") == OK)
	assert(directory.make_dir_recursive(base_dir + "Control/") == OK)
	assert(directory.make_dir_recursive(base_dir + "Resource/") == OK)
	assert(directory.make_dir_recursive(base_dir + "Reference/") == OK)

	var file : File = File.new()
	
	
	for class_data in classes:
		var data_to_save : String  = ""
		var file_name : String = base_dir
		
		if ClassDB.is_parent_class(class_data.name,"Spatial"): # TODO Fix in Godot 4.0
			file_name += "3D"
		elif ClassDB.is_parent_class(class_data.name,"Node2D"):
			file_name += "2D"
		elif ClassDB.is_parent_class(class_data.name,"Control"):
			file_name += "Control"
		elif ClassDB.is_parent_class(class_data.name,"Node"):
			file_name += "Node"
		elif ClassDB.is_parent_class(class_data.name,"Resource"):
			file_name += "Resource"
		elif ClassDB.is_parent_class(class_data.name,"Reference"):
			file_name += "Reference"
		else:
			file_name += "Other"
		
		file_name += "/" + class_data.name
		
		data_to_save += "extends Node\n\n"
		data_to_save += "var object : {} = {}.new()\n\n".replace("{}",class_data.name)
		data_to_save += "func _ready():\n"
		for i in range(class_data.function_names.size()):
			data_to_save += "\tif randi() % 2 == 0:\n"
			data_to_save += "\t\tobject." + class_data.function_names[i] + "(" + str(class_data.arguments[i]) + ")\n"
		
		assert(file.open(file_name,File.WRITE) == OK)
		file.store_string(data_to_save)


func _ready() -> void:
	collect_data()
	if Directory.new().dir_exists(base_dir):
		remove_files_recursivelly(base_dir)
	create_basic_files()
	
	
	
	pass # Replace with function body.
