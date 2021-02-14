extends Node2D


func _ready() -> void:
#	NoiseTexture::_thread_done
#	var aa = BoxShape.new()
#	SurfaceTool.new().create_from(aa,0)
#	Tree.new().get_column_width(0)
	tests_all_functions()


# TODO - Think about adding 'add_child', to test nodes in scene tree
# Test all functions which takes 0 arguments
func tests_all_functions() -> void:
	var debug_print : bool = true
	var use_parent_methods : bool = false # Allows Node2D use Node methods etc. - it is a little slow option
	var number_of_loops : int = 1 # Can be executed in multiple loops
	var use_always_new_object : bool = true # Don't allow to "remeber" other function effects
	
#	var sss = 0
	for name_of_class in Autoload.get_list_of_available_classes():
#		sss += 1
#		if sss != 220:
#			continue
		# Instance object to be able to execute on it specific functions and later delete to prevent memory leak if it is a Node
		var object : Object = ClassDB.instance(name_of_class)
		if object is Node:
			add_child(object)
		assert(object != null) # This should be checked before when collectiong functions
		var method_list : Array = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)
		for exception in Autoload.function_exceptions:
			var index : int = -1
			for method_index in range(method_list.size()):
				if method_list[method_index]["name"] == exception:
					index = method_index
					break
			if index != -1:
				method_list.remove(index)
		
		
		for _i in range(number_of_loops):
			for method_data in method_list:
				if true:#method_data["args"].size() != 0: # Todo remove this, for now is used to execute non zero len functiions which were tested, later it can be renamed instead removing to use zero len 
					# Function is virtual, so we just skip it
					if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
						continue 
					
					
					if debug_print:
						print("##### - " + name_of_class)
	#					print(method_data)
						print(method_data["name"])
#						print(method_data["args"])
						
					var arguments : Array = return_for_all(method_data)
					object.callv(method_data["name"], arguments)
					
					for argument in arguments:
						if argument is Node:
							argument.queue_free()
					
					if use_always_new_object:
						if object is Node:
							object.queue_free()
						object = ClassDB.instance(name_of_class)
					
		if object is Node: # Just prevent memory leak
			object.queue_free()

# TODO add option to generate random data or only basic data e.g. Vector2() instead Vector(2.52,525.2)
func return_for_all(method_data : Dictionary) -> Array:
	var arguments_array : Array = []
	
	for argument in method_data["args"]:
		match argument.type:
			TYPE_NIL: # Looks that this means VARIANT not null
				arguments_array.push_back(false)
#				assert(false)
			TYPE_MAX:
				assert(false)
			TYPE_AABB:
				arguments_array.push_back(AABB())
			TYPE_ARRAY:
				arguments_array.push_back(Array())
			TYPE_BASIS:
				arguments_array.push_back(Basis())
			TYPE_BOOL:
				arguments_array.push_back(bool())
			TYPE_COLOR:
				arguments_array.push_back(Color())
			TYPE_COLOR_ARRAY:
				arguments_array.push_back(PoolColorArray([]))
			TYPE_DICTIONARY:
				arguments_array.push_back(Dictionary())
			TYPE_INT:
				arguments_array.push_back(int())
			TYPE_INT_ARRAY:
				arguments_array.push_back(PoolIntArray())
			TYPE_NODE_PATH:
				arguments_array.push_back(NodePath())
			TYPE_OBJECT:
				arguments_array.push_back(BoxShape.new()) # TODO something better should be done
			TYPE_PLANE:
				arguments_array.push_back(Plane())
			TYPE_QUAT:
				arguments_array.push_back(Quat())
			TYPE_RAW_ARRAY:
				arguments_array.push_back(PoolByteArray([]))
			TYPE_REAL:
				arguments_array.push_back(float())
			TYPE_REAL_ARRAY:
				arguments_array.push_back(PoolRealArray())
			TYPE_RECT2:
				arguments_array.push_back(Rect2())
			TYPE_RID:
				arguments_array.push_back(RID())
			TYPE_STRING:
				arguments_array.push_back(String())
			TYPE_STRING_ARRAY:
				arguments_array.push_back(PoolStringArray())
			TYPE_TRANSFORM:
				arguments_array.push_back(Transform())
			TYPE_TRANSFORM2D:
				arguments_array.push_back(Transform2D())
			TYPE_VECTOR2:
				arguments_array.push_back(Vector2())
			TYPE_VECTOR2_ARRAY:
				arguments_array.push_back(PoolVector2Array())
			TYPE_VECTOR3:
				arguments_array.push_back(Vector3())
			TYPE_VECTOR3_ARRAY:
				arguments_array.push_back(PoolVector3Array())
			_:
				assert(false) # Missed some types, add it
	
#	print("Parameters " + str(arguments_array))
	return arguments_array
	
