extends Node

var regression_test_project : bool = false # Set it to true in RegressionTestProject

### Contains info about disabled classes and allows to take info about allowed methods

# Globablly disabled functions for all classes
var function_exceptions : Array = [
	# Image todo
	"adjust_bcs",
	"compress_from_channels",
	"compress",
	"decompress",
	"save_png_to_buffer",
	"convert",
	"",
	
	
	# GODOT 4.0
	"set_gradient", # 49569
	"set_enabled_inputs", # Probably error spam
	"load_threaded_request", # 46762 - Memory leak
	"_update_texture", # 49563
	"_activate", # 45984
	"_gui_input", # TODO Było wcześniej, ale nie naprawione 
	

	"_editor_settings_changed",# GH 45979
	"_submenu_timeout", # GH 45981
	"_thread_done", #GH 46000
	"_proximity_group_broadcast", #GH 46002
	"_set_tile_data", #GH 46015
	"instance_has", #GH 46020
	"get_var", #GH 46096
	"set_script", #GH 46120
	"set_icon", #GH 46189
	"get_latin_keyboard_variant", #GH  TODO Memory Leak
	"set_editor_hint", #GH 46252
	"get_item_at_position", #TODO hard to find
	"set_probe_data", #GH 46570
	"_range_click_timeout", #GH 46648
	"add_vertex", #GH 47066
	"create_client", # TODO, strange memory leak
	"create_shape_owner", #47135
	"shape_owner_get_owner", #47135

	"get_bind_bone", #GH 47358
	"get_bind_name", #GH 47358
	"get_bind_pose", #GH 47358

	# TODO Check this later
	"propagate_notification",
	"notification",

	# TODO Adds big spam when i>100 - look for possiblity to 
	"add_sphere",
	"_update_inputs", # Cause big spam with add_input
	# Spam when i~1000 - change to specific 
	"update_bitmask_region",
	"set_enabled_inputs",

	# Slow Function
	"_update_sky",

	# Undo/Redo function which doesn't provide enough information about types of objects, probably due vararg(variable size argument)
	"add_do_method",
	"add_undo_method",

	# Do not save files and create files and folders
	"pck_start",
	"save",
	"save_png",
	"save_to_wav",
	"save_to_file",
	"make_dir",
	"make_dir_recursive",
	"save_encrypted",
	"save_encrypted_pass",
	"save_exr",
	"dump_resources_to_file",
	"dump_memory_to_file",
	# This also allow to save files
	"open",
	"open_encrypted",
	"open_encrypted_with_pass",
	"open_compressed",

	# Do not warp mouse
	"warp_mouse",
	"warp_mouse_position",

	# OS
	"kill",
	"shell_open",
	"execute",
	"delay_usec",
	"delay_msec",
	"alert", # Stupid alert window opens

	# Godot Freeze
	"wait_to_finish",
	"accept_stream",
	"connect_to_stream",
	"discover",
	"wait",
	"debug_bake",
	"bake",

	"_create", # TODO Check


	"set_gizmo", # Stupid function, needs as parameter an object which can't be instanced # TODO, create issue to hide it 

	# Spams Output
	"print_tree",
	"print_stray_nodes",
	"print_tree_pretty",
	"print_all_textures_by_size",
	"print_all_resources",
	"print_resources_in_use",

	# Do not call other functions
	"_call_function",
	"call",
	"call_deferred",
	"callv",
	# Looks like a bug in FuncRef, probably but not needed, because it call other functions
	"call_func",

	# Too dangerous, because add, mix and remove randomly nodes and objects
	"replace_by",
	"create_instance",
	"set_owner",
	"set_root_node",
	"instance",
	"init_ref",
	"reference",
	"unreference",
	"new",
	"duplicate",
	"queue_free",
	"free",
	"remove_and_skip",
	"remove_child",
	"move_child",
	"raise",
	"add_child",
	"add_child_below_node",
	"add_sibling",
]

# List of slow functions, which may frooze project(not simple executing each function alone)
var project_resources_exclusion : Array = [
	"interpolate_baked",
	"get_baked_length",
	"get_baked_points",
	"get_closest_offset",
	"get_closest_point", # Only Curve, but looks that a lot of other classes uses this
	"get_baked_up_vectors",
	"interpolate_baked_up_vector",
	"tessellate",
	"get_baked_tilts",
	"set_enabled_inputs",
	"grow_mask",
	"force_update_transform",
	
	
	# In 3d view some options are really slow, needs to be limited
	"set_rings",
	"set_amount", # Particles


	# Just a little slow functions
	"is_enabler_enabled",
	"set_enabler",
	"get_aabb",
	"set_aabb",
	"is_on_screen"
]
# Specific classes which are initialized in specific way e.g. var undo_redo = get_undo_redo() instead var undo_redo = UndoRedo.new()
# It is used when generating project
var project_only_instance : Array = [
	"UndoRedo",
	"Object",
	"JSONRPC",
	"MainLoop",
	"SceneTree",
	"ARVRPositionalTracker",
]
var invalid_signals : Array = [
	"multi_selected",
	"item_collapsed",
	"button_pressed",
	"",
	"",
	"",
	
	
	# Probably Vararg
	"tween_step",
	"tween_completed",
	"tween_started",
	"data_channel_received",
	"",
]
var properties_exceptions : Array = [
	"user_data",
	"config_file",
	"",
	"",
]

var variant_exceptions : Array = [
	"get_named_color_name",
	"get_named_color",
]

# Globally disabled classes which causes bugs or are very hard to us
var disabled_classes : Array = [
	"ProjectSettings", # Don't mess with project settings, because they can broke entire your workflow
	"EditorSettings", # Also don't mess with editor settings
	"_OS", # This may sometimes crash compositor, but it should be tested manually sometimes
	"GDScript", # Broke script
	
	# This classes have problems with static/non static methods
	"PhysicsDirectSpaceState",
	"PhysicsDirectSpaceState2D",
	"PhysicsDirectBodyState",
	"PhysicsDirectBodyState2D",
	"BulletPhysicsDirectSpaceState",
	"InputDefault",
	"IP_Unix",
	"JNISingleton",
	"JavaClass",
	
		# Godot 4.0 Leaks, crashes etc.
	"World3D",
	"GPUParticlesCollisionHeightField", #4.0 Crash
	"NavigationAgent2D",
	"NavigationAgent3D",
	"Image",
	"GIProbe",
	
	# Just don't use these because they are not normal things 
	"_Thread",
	"_Semaphore",
	"_Mutex",	
	
	
	# Creating them is really slow in Godot 4.0
	"ColorPicker",
	"FileDialog",
	"ColorPickerButton",
	"PhysicalSkyMaterial",
	"ProceduralSkyMaterial",
	
	# Thread related crashes, hard to find
	"NavigationRegion3D",
	"SceneTree", # Related to BVH crash with World 3D
	"SkeletonModification2DJiggle", #  Później sprawdze
	"SkeletonModification2DLookAt",
	"SkeletonModification2DPhysicalBones",
	"SkeletonModification2DStackHolder",
	"MultiMesh", # TODO
	"CodeEdit",
	"UndoRedo",
	
	
	
	# Temporary
	"BoxMesh",
]

# Checks if function can be executed
func check_if_is_allowed(method_data : Dictionary) -> bool:
	# Function is virtual or vararg, so we just skip it
	if method_data.get("flags") == method_data.get("flags") | METHOD_FLAG_VIRTUAL:
		return false
	if method_data.get("flags") == method_data.get("flags") | 128: # VARARG TODO, Godot issue, add missing flag binding
		return false
		
	for arg in method_data.get("args"):
		var name_of_class : String = arg.get("class_name")
		if name_of_class.is_empty():
			continue
		if name_of_class in disabled_classes:
			return false
		if name_of_class.find("Server") != -1 && ClassDB.class_exists(name_of_class) && !ClassDB.is_parent_class(name_of_class,"RefCounted"):
			return false
		# Editor stuff usually aren't good choice for arhuments	
		if name_of_class.find("Editor") != -1 || name_of_class.find("SkinReference") != -1:
			return false
			
		# In case of adding new type, this prevents from crashing due not recognizing this type
		# In case of removing/rename type, just comment e.g. TYPE_ARRAY and all occurencies on e.g. switch statement with it
		# In case of adding new type, this prevents from crashing due not recognizing this type
		var t : int = arg.get("type")
		
		if !(t == TYPE_NIL|| t == TYPE_CALLABLE || t == TYPE_MAX|| t == TYPE_AABB|| t == TYPE_ARRAY|| t == TYPE_BASIS|| t == TYPE_BOOL|| t == TYPE_COLOR|| t == TYPE_COLOR_ARRAY|| t == TYPE_DICTIONARY|| t == TYPE_INT|| t == TYPE_INT32_ARRAY|| t == TYPE_INT64_ARRAY|| t == TYPE_NODE_PATH|| t == TYPE_OBJECT|| t == TYPE_PLANE|| t == TYPE_QUATERNION|| t == TYPE_RAW_ARRAY|| t == TYPE_FLOAT|| t == TYPE_FLOAT32_ARRAY|| t == TYPE_FLOAT64_ARRAY|| t == TYPE_RECT2|| t == TYPE_RECT2I|| t == TYPE_RID|| t == TYPE_STRING|| t == TYPE_STRING_NAME|| t == TYPE_STRING_ARRAY|| t == TYPE_TRANSFORM3D|| t == TYPE_TRANSFORM2D|| t == TYPE_VECTOR2|| t == TYPE_VECTOR2I|| t == TYPE_VECTOR2_ARRAY|| t == TYPE_VECTOR3|| t == TYPE_VECTOR3I|| t == TYPE_VECTOR3_ARRAY):
			print("----------------------------------------------------------- TODO - MISSING TYPE, ADD SUPPORT IT")
			return false
			
		#This is only for RegressionTestProject, because it needs for now clear visual info what is going on screen, but some nodes broke view
		if regression_test_project:
			# That means that this is constant, not class
			if !ClassDB.class_exists(name_of_class):
				continue
			if !ClassDB.is_parent_class(name_of_class, "Node") && !ClassDB.is_parent_class(name_of_class, "RefCounted"):
				return false
	
	return true

func remove_disabled_methods(method_list : Array, exceptions : Array) -> void:
	for exception in exceptions:
		var index: int = -1
		for method_index in range(method_list.size()):
			if method_list[method_index].get("name") == exception:
				index = method_index
				break
		if index != -1:
			method_list.remove(index)

# Return all available classes which can be used
func get_list_of_available_classes(must_be_instantable : bool = true) -> Array:
	var full_class_list : Array = Array(ClassDB.get_class_list())
	var classes : Array = []
	full_class_list.sort()
	var c = 0
#	var rr = 0
	for name_of_class in full_class_list:
#		rr += 1
		if name_of_class in disabled_classes:
			continue
		
#		if rr < 550:
#			continue	

		#This is only for RegressionTestProject, because it needs for now clear visual info what is going on screen, but some nodes broke view
		if regression_test_project:
			if !ClassDB.is_parent_class(name_of_class, "Node") && !ClassDB.is_parent_class(name_of_class, "RefCounted"):
				continue

		if name_of_class.find("Server") != -1 && !ClassDB.is_parent_class(name_of_class,"RefCounted"):
			continue
		if name_of_class.find("Editor") != -1 && regression_test_project:
			continue
			
			
		if !must_be_instantable || ClassDB.can_instantiate(name_of_class):
			classes.push_back(name_of_class)
			c+= 1
			
	print(str(c) + " choosen classes from all " + str(full_class_list.size()) + " classes.")
	
	classes = classes.slice(300,600)
	return classes
