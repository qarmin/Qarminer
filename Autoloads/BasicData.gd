extends Node

var regression_test_project : bool = false # Set it to true in RegressionTestProject

# Contains info about disabled classes 
# Also allows to get list of available classes

var properties_exceptions : Array = [
	"user_data",
	"config_file",
	"",
	"",
]
var function_exceptions : Array = [
	"_set_user_data",
	"get_packet", # TODO
	"create_from_mesh",
	# They exists without assigment like Class.method, because they may be a parent of other objects and children also should have disabled child.method, its children also etc. which is too much to do
	"connect_to_signal", # GH 47572
	"set_config_file", # GH 45997
	"class_get_property", # GH 47573
	"class_set_property", # GH 47573
	"_editor_settings_changed",# GH 45979
	"_submenu_timeout", # GH 45981
	"_gui_input", # GH 45998
	"_unhandled_key_input", # GH 45998
	"_thread_done", #GH 46000
	"generate", #GH 46001
	"_proximity_group_broadcast", #GH 46002
	"_direct_state_changed", #GH 46003
	"create_from", #GH 46004
	"create_from_blend_shape", #GH 46004
	"append_from", #GH 46004
	"_unhandled_input", # TODO
	"_input", # TODO
	"_set_tile_data", #GH 46015
	"get", #GH 46019
	"instance_has", #GH 46020
	"get_var", #GH 46096
	"force_drag", #GH 46114
	"set_script", #GH 46120
	"getvar", #GH 46019
	"get_available_chars", #GH 46118
	"open_midi_inputs", #GH 46183
	"set_icon", #GH 46189
	"get_latin_keyboard_variant", #GH  TODO Memory Leak
	"set_editor_hint", #GH 46252
	"get_item_at_position", #TODO hard to find
	"set_probe_data", #GH 46570
	"_range_click_timeout",
	"draw", #GH 46648
	"get_indexed", #GH 46019
	"_vp_input", # TODO
	"_vp_unhandled_input", # TODO
	"remove_joy_mapping", #GH 46754
	"add_joy_mapping", #GH 46754
	"add_vertex", #GH 47066
	"create_client", # TODO, strange memory leak
	"create_shape_owner", #47135
	"shape_owner_get_owner", #47135

	"collide", #GH 46137
	"collide_and_get_contacts", #GH 46137
	"collide_with_motion", #GH 46137
	"collide_with_motion_and_get_contacts", #GH 46137

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
]
var exported : Array = [
	"get_bind_bone",
	"get_bind_name",
	"get_bind_pose",
]

# List of slow functions, which may frooze project(not simple executing each function alone)
var slow_functions : Array = [
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
var only_instance : Array = [
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
# Used only in ValueCreator
var disabled_classes : Array = [
	"ProjectSettings", # Don't mess with project settings, because they can broke entire your workflow
	"EditorSettings", # Also don't mess with editor settings
	"_OS", # This may sometimes crash compositor, but it should be tested manually sometimes
	"GDScript", # Broke script
	
	# This classes have problems with static/non static methods
	"PhysicsDirectSpaceState",
	"Physics2DDirectSpaceState",
	"PhysicsDirectBodyState",
	"Physics2DDirectBodyState",
	"BulletPhysicsDirectSpaceState",
	"InputDefault",
	"IP_Unix",
	"JNISingleton",
	
	
	# Just don't use these because they are not normal things 
	"_Thread",
	"_Semaphore",
	"_Mutex",
]

# GH 47358
func _init(): 
	function_exceptions.append_array(exported)

# Checks if function can be executed
# Looks at its arguments an
func check_if_is_allowed(method_data : Dictionary) -> bool:
	# Function is virtual, so we just skip it
	if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
		return false
		
	for arg in method_data["args"]:
		var name_of_class : String = arg["class_name"]
		if name_of_class.empty():
			continue
		if name_of_class in disabled_classes:
			return false
		if name_of_class.find("Server") != -1 && ClassDB.class_exists(name_of_class) && !ClassDB.is_parent_class(name_of_class,"Reference"):
			return false
		if name_of_class.find("Editor") != -1: # TODO not sure about it
			return false
			
		#This is only for RegressionTestProject, because it needs for now clear visual info what is going on screen, but some nodes broke view
		if regression_test_project:
			if !ClassDB.is_parent_class(name_of_class, "Node") && !ClassDB.is_parent_class(name_of_class, "Reference"):
				return false
			
		# In case of adding new type, this prevents from crashing due not recognizing this type
		var t : int = arg["type"]
		if !(t == TYPE_NIL || t == TYPE_AABB || t == TYPE_ARRAY || t == TYPE_BASIS || t == TYPE_BOOL || t == TYPE_COLOR || t == TYPE_COLOR_ARRAY || t == TYPE_DICTIONARY || t == TYPE_INT || t == TYPE_INT_ARRAY || t == TYPE_NODE_PATH || t == TYPE_OBJECT || t == TYPE_PLANE || t == TYPE_QUAT || t == TYPE_RAW_ARRAY || t == TYPE_REAL || t == TYPE_REAL_ARRAY || t == TYPE_RECT2 || t == TYPE_RID || t == TYPE_STRING || t == TYPE_TRANSFORM || t == TYPE_TRANSFORM2D || t == TYPE_VECTOR2 || t == TYPE_VECTOR2_ARRAY || t == TYPE_VECTOR3 || t == TYPE_VECTOR3_ARRAY):
			print("----------------------------------------------------------- TODO - MISSING TYPE, ADD SUPPORT IT")
			return false
			
	
	return true

# Return all available classes to instance and test
func get_list_of_available_classes(must_be_instantable : bool = true) -> Array:
	var full_class_list : Array = Array(ClassDB.get_class_list())
	var classes : Array = []
	full_class_list.sort()
	var c = 0
	var rr = 0
	for name_of_class in full_class_list:
		rr += 1
		if name_of_class in disabled_classes:
			continue
		
#		if rr < 550:
#			continue	

		#This is only for RegressionTestProject, because it needs for now clear visual info what is going on screen, but some nodes broke view
		if regression_test_project:
			if !ClassDB.is_parent_class(name_of_class, "Node") && !ClassDB.is_parent_class(name_of_class, "Reference"):
				continue

		if name_of_class.find("Server") != -1 && !ClassDB.is_parent_class(name_of_class,"Reference"):
			continue
		if name_of_class.find("Editor") != -1: # TODO not sure about it
			continue
			
			
		if !must_be_instantable || ClassDB.can_instance(name_of_class):
			classes.push_back(name_of_class)
			c+= 1
			
	print(str(c) + " choosen classes from all " + str(full_class_list.size()) + " classes.")
	return classes
