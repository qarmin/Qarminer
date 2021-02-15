extends Node

var base_dir : String = "res://Project/"
	
class ClassData:
	var name : String = ""
	var function_names : Array = []
	var arguments : Array = []

var classes : Array 

var list_of_all_files = {
	"2D" : [],
	"3D" : [],
	"Node" : [],
	"Other" : [],
	"Control" : [],
	"Resource" : [],
	"Reference" : [],
}

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
			
			# TODO - Currently objects are not supported, because they must have exactly same type as expected by function
			var found_object : bool = false
			for i in method_data["args"]:
				if i["type"] == TYPE_OBJECT:
					found_object = true
					break
				arguments.push_back(i["type"])
				
			if found_object:
				continue
			class_data.arguments.append(arguments)
			
			class_data.function_names.append(method_data["name"])
			
		classes.append(class_data)
	
	

func remove_files_recursivelly(to_delete : String) -> void:
	var directory : Directory = Directory.new()
	
	assert(directory.open(to_delete) == OK)
	assert(directory.list_dir_begin() == OK)
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
				assert(directory.remove(file_name) == OK)
			
			assert(file_name.find("/./") == -1 && file_name.begins_with("res://") && file_name.begins_with(base_dir) && file_name.find("//",6) == -1)
		file_name = directory.get_next()

#	print(to_delete)
	assert(to_delete.find("/./") == -1 && to_delete.begins_with("res://") && to_delete.begins_with(base_dir) && to_delete.find("//",6) == -1)
	assert(directory.remove(to_delete) == OK) # TODO, Test This

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
	
	assert(file.open(base_dir + "project.godot",File.WRITE) == OK)
	file.store_string("config_version=4\n")
	file.store_string("[application]\n")
	file.store_string("run/main_scene=\"res://2D.tscn\"\n")
	

	for class_data in classes:
		var data_to_save : String  = ""
		var file_name : String = base_dir
		
		if ClassDB.is_parent_class(class_data.name,"Spatial"): # TODO Fix in Godot 4.0
			file_name += "3D" + "/" + class_data.name + ".gd"
			list_of_all_files["3D"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name,"Node2D"):
			file_name += "2D" + "/" + class_data.name + ".gd"
			list_of_all_files["2D"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name,"Control"):
			file_name += "Control" + "/" + class_data.name + ".gd"
			list_of_all_files["Control"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name,"Node"):
			file_name += "Node" + "/" + class_data.name + ".gd"
			list_of_all_files["Node"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name,"Resource"):
			file_name += "Resource" + "/" + class_data.name + ".gd"
			list_of_all_files["Resource"].append(file_name)
		elif ClassDB.is_parent_class(class_data.name,"Reference"):
			file_name += "Reference" + "/" + class_data.name + ".gd"
			list_of_all_files["Reference"].append(file_name)
		else:
			file_name += "Other" + "/" + class_data.name + ".gd"
			list_of_all_files["Other"].append(file_name)
		
		
		var object_name = "q_" + class_data.name
		
		data_to_save += "extends Node2D\n\n"
		data_to_save += "var ||| : {} = {}.new()\n\n".replace("{}",class_data.name).replace("|||",object_name)
		data_to_save += "func _ready() -> void:\n"
		data_to_save += "\tif !is_visible():\n"
		data_to_save += "\t\tset_process(false)\n\n"
		data_to_save += "func _process(_delta : float) -> void:\n"
		for i in range(class_data.function_names.size()):
			data_to_save += "\tif randi() % 2 == 0:\n"
			data_to_save += "\t\t" + object_name + "."+ class_data.function_names[i] + "(" + convert_arguments_to_string(class_data.arguments[i]) + ")\n"
		data_to_save += "\tpass"
		
		assert(file.open(file_name,File.WRITE) == OK)
		file.store_string(data_to_save)

func convert_arguments_to_string(arguments : Array) -> String:
	
	var return_string : String = ""
	
	ValueCreator.number = 100
	ValueCreator.random = true
	
	
	var argument_number : int = 0
	
	for argument in arguments:
#		print(argument)
		if argument_number != 0:
			return_string += ", "
		match argument:
			TYPE_NIL: # Looks that this means VARIANT not null
				return_string += "false" # TODO aadd some randomization
#				assert(false)
			TYPE_MAX:
				assert(false)
			TYPE_AABB:
				return_string += ValueCreator.get_aabb_string()
			TYPE_ARRAY:
				return_string += "[]"
			TYPE_BASIS:
				return_string += ValueCreator.get_basis_string()
			TYPE_BOOL:
				return_string += ValueCreator.get_bool_string()
			TYPE_COLOR:
				return_string += ValueCreator.get_color_string()
			TYPE_COLOR_ARRAY:
				return_string += "PoolColorArray([])"
			TYPE_DICTIONARY:
				return_string += "{}"
			TYPE_INT:
				return_string += ValueCreator.get_int_string()
			TYPE_INT_ARRAY:
				return_string += "PoolIntArray([])"
			TYPE_NODE_PATH:
				return_string += "NodePath(\".\")"
			TYPE_OBJECT:
				return_string += "BoxShape.new()"
			TYPE_PLANE:
				return_string += ValueCreator.get_plane_string()
			TYPE_QUAT:
				return_string += ValueCreator.get_quat_string()
			TYPE_RAW_ARRAY:
				return_string += "PoolByteArray([])"
			TYPE_REAL:
				return_string += ValueCreator.get_float_string()
			TYPE_REAL_ARRAY:
				return_string += "PoolRealArray([])"
			TYPE_RECT2:
				return_string += ValueCreator.get_rect2_string()
			TYPE_RID:
				return_string += "RID()"
			TYPE_STRING:
				return_string += ValueCreator.get_string_string()
			TYPE_STRING_ARRAY:
				return_string += "PoolStringArray([])"
			TYPE_TRANSFORM:
				return_string += ValueCreator.get_transform_string()
			TYPE_TRANSFORM2D:
				return_string += ValueCreator.get_transform2D_string()
			TYPE_VECTOR2:
				return_string += ValueCreator.get_vector2_string()
			TYPE_VECTOR2_ARRAY:
				return_string += "PoolVector2Array([])"
			TYPE_VECTOR3:
				return_string += ValueCreator.get_vector3_string()
			TYPE_VECTOR3_ARRAY:
				return_string += "PoolVector3Array([])"
			_:
				assert(false) # Missed some types, add it
				
		argument_number += 1
				
	return return_string

func create_scene_files() -> void:
	var directory : Directory = Directory.new()
	var file : File = File.new()
	
	for type in ["2D", "3D", "Node", "Control", "Resource", "Reference"]:
		var external_dependiences : String = ""
		var node_data : String = ""
		
		assert(file.open(base_dir + str(type) + ".tscn",File.WRITE) == OK)
		file.store_string("[gd_scene load_steps=1000 format=2]\n\n")
		var counter : int = 1
		for file_name in list_of_all_files[type]:
			var split : PoolStringArray = file_name.rsplit("/")
			var latest_name : String = split[split.size() - 1].trim_suffix(".gd")
			
			external_dependiences += "[ext_resource path=\"_PATH_\" type=\"Script\" id=COUNTER]\n".replace("COUNTER",str(counter)).replace("_PATH_", file_name.replace("Project/",""))
			node_data += "[node name=\"FILE_NAME\" type=\"Node2D\" parent=\".\"]\n".replace("FILE_NAME",latest_name)
			node_data += "script = ExtResource( COUNTER )\n\n".replace("COUNTER", str(counter))

			counter += 1
		
		file.store_string(external_dependiences)
		file.store_string("\n")
		file.store_string("[node name=\"Root\" type=\"Node2D\"]")
		file.store_string("\n\n")
		file.store_string(node_data)
		
	

func _ready() -> void:
	collect_data()
	if Directory.new().dir_exists(base_dir):
		remove_files_recursivelly(base_dir)
	create_basic_files()
	create_scene_files()
