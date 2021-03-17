extends Node

var number_of_external_resources : int = 0

class SingleArgument:
	var name : String # E.G. var roman, can be empty, so temp variable isn't created(nodes and objects must be created with temp_variable due to memory leaks)
	var type : String # np. Vector2 or Object
	var value : String # np. randi() % 100 or
	var is_object : bool = false # Check if this is object e.g. Node not Vector2
	var is_only_object : bool = false # Only needs to freed with .free()
	var is_only_reference : bool = false # Don't needs to be removed manually
	var is_only_node : bool = false # Needs to be removed with .queue_free()
	
func get_object_folder(name_of_class  : String) -> String:
	assert(ClassDB.class_exists(name_of_class))
	if ClassDB.is_parent_class(name_of_class, "Spatial"):  # TODO Fix in Godot 4.0
		return "3D"
	elif ClassDB.is_parent_class(name_of_class, "Node2D"):
		return "2D"
	elif ClassDB.is_parent_class(name_of_class, "Control"):
		return "Control"
	elif ClassDB.is_parent_class(name_of_class, "Node"):
		return "Node"
	elif ClassDB.is_parent_class(name_of_class, "Resource"):
		return "Resource"
	elif ClassDB.is_parent_class(name_of_class, "Reference"):
		return "Reference"
	else:
		return "Object"
	

func create_basic_files() -> void:
	var file: File = File.new()
	var self_file : File = File.new()

	for class_data in CreateProjectBase.classes:
		var data_to_save: String = ""
		var file_name: String = CreateProjectBase.base_path

		var prefix = get_object_folder(class_data.name)
		file_name += prefix + "/" + class_data.name + ".gd"
		CreateProjectBase.list_of_all_files[prefix].append(file_name)

		var object_type = class_data.name.trim_prefix("_")  # Change _Directory to Directory etc
		var can_be_instanced : bool
		var is_static : bool # Can execute static functions on it
		var object_name
		if (
			ClassDB.can_instance(class_data.name) &&(
			ClassDB.is_parent_class(class_data.name, "Node")
			|| ClassDB.is_parent_class(class_data.name, "Reference")
			|| (ClassDB.is_parent_class(class_data.name, "Object") 
			&& ClassDB.class_has_method(class_data.name, "new"))
			)
		):
			object_name = "q_" + object_type
			can_be_instanced = true
			is_static = false
		elif ClassDB.is_parent_class(class_data.name, "Node") || ClassDB.is_parent_class(class_data.name, "Reference") || (ClassDB.is_parent_class(class_data.name, "Object") && ClassDB.class_has_method(class_data.name, "new")):
			object_name = "q_" + object_type
			can_be_instanced = false
			is_static = false
		else:
			object_name = object_type
			can_be_instanced = false
			is_static = true
		
		### Create file, which allow to open
		if ClassDB.is_parent_class(class_data.name, "Node"):
			var data_self = ""
			data_self += "extends " + class_data.name + "\n\n"
			data_self += "func _process(_delta: float) -> void:\n"
			data_self += "\tload(\"res://" + prefix + "/"+ class_data.name +".gd\").modify_object(self)"
			
			assert(self_file.open("res://GDScript/Self/"+ class_data.name + ".gd", File.WRITE) == OK)
			self_file.store_string(data_self)
			 
		
		### Global
		data_to_save += "extends Node2D\n\n"
		if can_be_instanced:
			data_to_save += "var ||| : {} = {}.new()\n\n".replace("{}", object_type).replace("|||", object_name)

		### Ready function
		if can_be_instanced || is_static:
			data_to_save += "func _ready() -> void:\n"
			data_to_save += "\tif !is_visible():\n"
			data_to_save += "\t\tset_process(false)\n"
			if ClassDB.is_parent_class(class_data.name, "Node"):
				data_to_save += "\t\t" + object_name + ".queue_free()\n"
			data_to_save += "\t\treturn\n\n"
			if ClassDB.is_parent_class(class_data.name, "Node"):
				data_to_save += "\tadd_child(" + object_name + ")\n\n"

		### Process Function
		if can_be_instanced || is_static: # Disallow to use it for e.g. non instantable CollisionObject
			data_to_save += "func _process(_delta : float) -> void:\n"
			if CreateProjectBase.allow_to_replace_old_with_new_objects:
				if can_be_instanced:
					data_to_save += "\tif randi() % 10 == 0:\n"
				if ClassDB.is_parent_class(class_data.name, "Node"):
					data_to_save += "\t\t" + object_name + ".queue_free()\n"
				if (
					can_be_instanced
					&& !(ClassDB.is_parent_class(class_data.name, "Reference"))
					&& !(ClassDB.is_parent_class(class_data.name, "Node"))
				):
					data_to_save += "\t\t" + object_name + ".free()\n"
				if can_be_instanced:
					data_to_save += "\t\t" + object_name + " = " + object_type + ".new()\n"
				if ClassDB.is_parent_class(class_data.name, "Node"):
					data_to_save += "\t\tadd_child(" + object_name + ")\n\n"
				
				## Execution of function
				if can_be_instanced:
					data_to_save += "\tmodify_object(|||)\n\n".replace("|||", object_name)
				else:
					data_to_save += "\tmodify_object()\n\n"
		
		### Function which execute
		if !is_static:
			data_to_save += "static func modify_object(||| : {}) -> void:\n".replace("{}", object_type).replace("|||", object_name)
		else:
			data_to_save += "static func modify_object() -> void:\n"
		
		if !(class_data.name in ["PhysicsDirectBodyState","PhysicsDirectSpaceState","Physics2DDirectBodyState","Physics2DDirectSpaceState","TreeItem", "Image"]): # Some functions are static, but some needs to work on objects etc.., TODO Remove Image when it will be enough stable
			for i in range(class_data.function_names.size()):
				var function_use_objects : bool = false
			
				data_to_save += "\tif randi() % 2 == 0:\n"
				if CreateProjectBase.debug_in_runtime:
					data_to_save += "\t\tprint(\"Executing " + object_type + "." + class_data.function_names[i] + "\")\n"

				var arguments := create_arguments(class_data.arguments[i])

				for argument in arguments:
					if argument.is_object:
						assert(ClassDB.class_exists(argument.type))
						if argument.is_only_reference && CreateProjectBase.use_loaded_resources:
							data_to_save += "\t\tvar " + argument.name + ": " + argument.type + " = " + " load(\"res://Resources/" + argument.type + ".res\")\n"
						else:
							data_to_save += "\t\tvar " + argument.name + ": " + argument.type.trim_prefix("_") + " = " + argument.type.trim_prefix("_") + ".new()\n"
					else:
						if argument.type == "Variant":
							data_to_save += "\t\tvar " + argument.name + " = " + argument.value + "\n"
						else:
							data_to_save += "\t\tvar " + argument.name + ": " + argument.type + " = " + argument.value + "\n"
				
				if CreateProjectBase.debug_in_runtime:
					data_to_save += "\t\tprint(\"Parameters["
					for j in arguments.size():
						data_to_save += "\" + str(" + arguments[j].name + ") + \""
						if j != arguments.size() - 1:
							data_to_save += ", "
					data_to_save += "]\")\n"
				
				# Apply data
				if function_use_objects:
					if number_of_external_resources > 0:
						data_to_save += "\t\tfor _i in range(|||):\n".replace("|||",str(number_of_external_resources))
						for argument in arguments:
							if !argument.name.empty() && argument.name != class_data.name: # Do not allow to recursive execute functions
								data_to_save += "\t\t\tload(\"res://|||/{}.gd\").modify_object(;;;)\n".replace("|||",get_object_folder(argument.type)).replace("{}",argument.type).replace(";;;",argument.name)
						data_to_save += "\t\t\tpass\n"
							

				var string_new_arguments: String = ""
				for j in range(arguments.size()):
					if arguments[j].name.empty():
						string_new_arguments += arguments[j].value
					else:
						string_new_arguments += arguments[j].name
					if j != (arguments.size() - 1):
						string_new_arguments += ", "

				data_to_save += "\t\t" + object_name + "." + class_data.function_names[i] + "(" + string_new_arguments + ")\n"

				# Delete all temporary objects
				for argument in arguments:
					if argument.is_only_node:
						data_to_save += "\t\t" + argument.name + ".queue_free()\n"
					elif argument.is_only_object:
						data_to_save += "\t\t" + argument.name + ".queue_free()\n"

				data_to_save += "\n"
		data_to_save += "\tpass\n\n"

		if can_be_instanced && !ClassDB.is_parent_class(class_data.name, "Node") && !ClassDB.is_parent_class(class_data.name, "Reference"):
			data_to_save += "func _exit_tree() -> void:\n"
			data_to_save += "\t" + object_name + ".free()\n"

		assert(file.open(file_name, File.WRITE) == OK)
		file.store_string(data_to_save)


func create_arguments(arguments: Array) -> Array:
	var return_array: PoolStringArray = PoolStringArray([])
	
	var argument_array : Array = []
	
	ValueCreator.number = 10
	ValueCreator.random = true
	ValueCreator.should_be_always_valid = true  # DO NOT CHANGE, BECAUSE NON VALID VALUES WILL SHOW GDSCRIPT ERRORS!


	var counter = 0
	for argument in arguments:
		counter += 1
		var sa : SingleArgument = SingleArgument.new()
		sa.name = "variable" + str(counter)
		match argument["type"]:
			TYPE_NIL:  # Looks that this means VARIANT not null
				sa.type = "Variant"
				sa.value = "false"
				return_array.append("false")  # TODO add some randomization
			TYPE_AABB:
				sa.type = "AABB"
				sa.value = ValueCreator.get_aabb_string()
			TYPE_ARRAY:
				sa.type = "Array"
				sa.value = "[]"
			TYPE_BASIS:
				sa.type = "Basis"
				sa.value = ValueCreator.get_basis_string()
			TYPE_BOOL:
				sa.type = "bool"
				sa.value = ValueCreator.get_bool_string().to_lower()
			TYPE_COLOR:
				sa.type = "Color"
				sa.value = ValueCreator.get_color_string()
			TYPE_COLOR_ARRAY:
				sa.type = "PoolColorArray"
				sa.value = "PoolColorArray([])"
			TYPE_DICTIONARY:
				sa.type = "Dictionary"
				sa.value = "{}" # TODO Why not all use ValueCreator?
			TYPE_INT:
				sa.type = "int"
				sa.value = ValueCreator.get_int_string()
			TYPE_INT_ARRAY:
				sa.type = "PoolIntArray"
				sa.value = "PoolIntArray([])"
			TYPE_NODE_PATH:
				sa.type = "NodePath"
				sa.value = "NodePath(\".\")"
			TYPE_OBJECT:
				sa.type = ValueCreator.get_object_string(argument["class_name"])
				sa.value = sa.type + ".new()"
				
				sa.is_object = true
				if ClassDB.is_parent_class(sa.type, "Node"):
					sa.is_only_node = true
				elif ClassDB.is_parent_class(sa.type, "Reference"):
					sa.is_only_reference = true
				else:
					sa.is_only_object = true
				
			TYPE_PLANE:
				sa.type = "Plane"
				sa.value = ValueCreator.get_plane_string()
			TYPE_QUAT:
				sa.type = "Quat"
				sa.value = ValueCreator.get_quat_string()
			TYPE_RAW_ARRAY:
				sa.type = "PoolByteArray"
				sa.value = "PoolByteArray([])"
			TYPE_REAL:
				sa.type = "float"
				sa.value = ValueCreator.get_float_string()
			TYPE_REAL_ARRAY:
				sa.type = "PoolRealArray"
				sa.value = "PoolRealArray([])"
			TYPE_RECT2:
				sa.type = "Rect2"
				sa.value = ValueCreator.get_rect2_string()
			TYPE_RID:
				sa.type = "RID"
				sa.value = "RID()"
			TYPE_STRING:
				sa.type = "String"
				sa.value = ValueCreator.get_string_string()
			TYPE_STRING_ARRAY:
				sa.type = "PoolStringArray"
				sa.value = "PoolStringArray([])"
			TYPE_TRANSFORM:
				sa.type = "Transform"
				sa.value = ValueCreator.get_transform_string()
			TYPE_TRANSFORM2D:
				sa.type = "Transform2D"
				sa.value = ValueCreator.get_transform2D_string()
			TYPE_VECTOR2:
				sa.type = "Vector2"
				sa.value = ValueCreator.get_vector2_string()
			TYPE_VECTOR2_ARRAY:
				sa.type = "PoolVector2Array"
				sa.value = "PoolVector2Array([])"
			TYPE_VECTOR3:
				sa.type = "Vector3"
				sa.value = ValueCreator.get_vector3_string()
			TYPE_VECTOR3_ARRAY:
				sa.type = "PoolVector3Array"
				sa.value = "PoolVector3Array([])"
			_:
				assert(false)  # Missed some types, add it
		argument_array.append(sa)

	return argument_array

func create_self_scene() -> void:
	var scene: File = File.new()
	assert(scene.open("res://GDScript/Self.tscn", File.WRITE) == OK)
	var data_to_save : String = """[gd_scene load_steps=2 format=2]

[ext_resource path="res://Self.gd" type="Script" id=1]

[node name="Self" type="Node"]
script = ExtResource( 1 )"""
	scene.store_string(data_to_save)
	
	assert(scene.open("res://GDScript/Self.gd", File.WRITE) == OK)
	data_to_save  = """extends Node

var number_of_nodes : int = 0

var collected_nodes : Array = []
var disabled_classes : Array = [
	"ReflectionProbe", # Cause errors, not sure about it
] # Just add name of any class if cause problems

func collect() -> void:
	var classes : Array = ClassDB.get_class_list()
	classes.sort()
	for name_of_class in classes:
		if ClassDB.is_parent_class(name_of_class,"Node"):
			if name_of_class.find("Editor") != -1: # We don't want to test editor nodes
				continue
			if disabled_classes.has(name_of_class): # Class is disabled
				continue
			if ClassDB.can_instance(name_of_class): # Only instantable nodes can be used
				collected_nodes.append(name_of_class)

func _ready() -> void:
	seed(405)
	collect()
	number_of_nodes = max(collected_nodes.size(),200) # Use at least all nodes, or more if you want(168 is probably number nodes)
	for i in range(number_of_nodes): 
		var index = i
		if i >= collected_nodes.size(): # Wrap values
			index = i % collected_nodes.size()
		
		var child : Node = get_special_node(collected_nodes[index])
		child.set_name("Special Node " + str(i))
		add_child(child)

func _process(delta: float) -> void:
#	assert(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT) == 0) # Don't work good with running more than 1 this scene
	
	var choosen_node : Node
	var parent_of_node : Node
	for i in range(5):
		var number : String = "Special Node " + str(randi() % number_of_nodes)
		choosen_node = find_node(number,true,false)
		parent_of_node = choosen_node.get_parent()
		
		var random_node = find_node("Special Node " + str(randi() % number_of_nodes),true,false)
		parent_of_node.remove_child(choosen_node)
		
		if randi() % 6 == 0: # 16% chance to remove node with children
			var names_to_remove : Array = find_all_special_children_names(choosen_node)
			for name_to_remove in names_to_remove:
				var node : Node = get_special_node(collected_nodes[randi() % collected_nodes.size()])
				node.set_name(name_to_remove)
				add_child(node)
			choosen_node.queue_free()
			continue
		
		
		if choosen_node.find_node(random_node.get_name(),true,false) != null: # Cannot set as node parent one of its child
			add_child(choosen_node)
			continue
		if choosen_node == random_node: # Do not reparent node to self
			add_child(choosen_node)
			continue
		random_node.add_child(choosen_node)

# Finds recusivelly all child nodes which are not internal
func find_all_special_children_names(node : Node) -> Array:
	var array : Array = []
	array.append(node.get_name())
	for child in node.get_children():
		if child.get_name().begins_with("Special Node"):
			array.append_array(find_all_special_children_names(child))
	
	return array

func get_special_node(var name_of_class : String) -> Node:
	assert(ClassDB.can_instance(name_of_class))
	assert(ClassDB.is_parent_class(name_of_class, "Node"))
	var node : Node = ClassDB.instance(name_of_class)
	node.set_script(load("res://Self/" + name_of_class + ".gd"))
	return node
	"""
	scene.store_string(data_to_save)
	

func _ready() -> void:
	CreateProjectBase.use_gdscript = true
	CreateProjectBase.base_path = "res://GDScript/"
	CreateProjectBase.base_dir = "GDScript/"

	CreateProjectBase.collect_data()
	if Directory.new().dir_exists(CreateProjectBase.base_path):
		CreateProjectBase.remove_files_recursivelly(CreateProjectBase.base_path)
	CreateProjectBase.create_basic_structure()
	create_basic_files()
	CreateProjectBase.create_scene_files()
	create_self_scene()
	print("Created test GDScript project")
	get_tree().quit()
