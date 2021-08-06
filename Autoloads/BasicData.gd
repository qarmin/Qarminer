extends Node

var regression_test_project : bool = false # Set it to true in RegressionTestProject

### Contains info about disabled classes and allows to take info about allowed methods

# Globablly disabled functions for all classes
var function_exceptions : Array = [
	# Dommy Rasterizer
	"set_data", # ImageTexture
	"set_YCbCr_imgs", # CameraFeed

	"remove_line", # 49571
	
	# Image functions
	"compress",
	"decompress",
	"convert",
	"save_png_to_buffer", # uses decompress
	
	"create_client",#51196
	"add_node", #51189
	 
	# Input crashes, not cherrypicked #GH 47636
	"_gui_input", 
	"_input",
	"_unhandled_input", 
	"_unhandled_key_input",
	"_vp_input",
	"_vp_unhandled_input",
	"_direct_state_changed", #GH 46003 - Not cherrypicked
	"connect_to_signal", # GH 47572 - Not cherrypicked
	
	"set_function", # not cherrypick
	# They exists without assigment like Class.method, because they may be a parent of other objects and children also should have disabled child.method, its children also etc. which is too much to do

	"_editor_settings_changed",# GH 45979
	"_submenu_timeout", # GH 45981
	"_thread_done", #GH 46000
	"_proximity_group_broadcast", #GH 46002
	"_set_tile_data", #GH 46015
	"set_script", #GH 46120
	"set_icon", #GH 46189
	"set_editor_hint", #GH 46252
	"set_probe_data", #GH 46570
	"_range_click_timeout", #GH 46648
	"add_vertex", #GH 47066
	"create_shape_owner", #47135
	"shape_owner_get_owner", #47135
	"generate_mipmaps", #GH 46485
	"start", #GH 50120
	"add_undo_reference", #GH 48756

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
	"load_webp_from_buffer",
	"_update_sky",
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
	"is_on_screen",

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

	# Godot Freeze/Very slow
	"wait_to_finish",
	"accept_stream",
	"connect_to_stream",
	"discover",
	"wait",
	"debug_bake",
	"bake",

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

	# Goost
	# TODO: these take too long to execute, does not make sense to limit number of iterations ether.
	"smooth_polyline_approx",
	"smooth_polygon_approx",
	# TODO: infinite spam of errors
	"stamp_rect",
	"blend_rect",
]

# Globally disabled classes which causes bugs or are very hard to us
var disabled_classes : Array = [
	"ProjectSettings", # Don't mess with project settings, because they can broke entire your workflow
	"EditorSettings", # Also don't mess with editor settings
	"_OS", # This may sometimes crash compositor, but it should be tested manually sometimes
	"GDScript", # Broke script
	"SceneTree",
	"JNISingleton", # Freeze - who use it?
	
	# Only one class - JavaClass returns Null when using JavaClass.new().get_class
	"JavaClass",
	
	# Just don't use these because they are not normal things 
	"_Thread",
	"_Semaphore",
	"_Mutex",
]
var variant_exceptions : Array =  [
	# TODO
]

# Checks if function can be executed
# Looks at its arguments an
func check_if_is_allowed(method_data : Dictionary) -> bool:
	# Function is virtual or vararg, so we just skip it
	if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
		return false
	if method_data["flags"] == method_data["flags"] | 128: # VARARG TODO, Godot issue, add missing flag binding
		return false
		
	for arg in method_data["args"]:
		var name_of_class : String = arg["class_name"]
		if name_of_class.empty():
			continue
		if name_of_class in disabled_classes:
			return false
		if name_of_class.find("Server") != -1 && ClassDB.class_exists(name_of_class) && !ClassDB.is_parent_class(name_of_class,"Reference"):
			return false
		# Editor stuff usually aren't good choice for arhuments	
		if name_of_class.find("Editor") != -1 || name_of_class.find("SkinReference") != -1:
			return false
			
		# In case of adding new type, this prevents from crashing due not recognizing this type
		# In case of removing/rename type, just comment e.g. TYPE_ARRAY and all occurencies on e.g. switch statement with it
		var t : int = arg["type"]
		if !(t == TYPE_NIL || t == TYPE_AABB || t == TYPE_ARRAY || t == TYPE_BASIS || t == TYPE_BOOL || t == TYPE_COLOR || t == TYPE_COLOR_ARRAY || t == TYPE_DICTIONARY || t == TYPE_INT || t == TYPE_INT_ARRAY || t == TYPE_NODE_PATH || t == TYPE_OBJECT || t == TYPE_PLANE || t == TYPE_QUAT || t == TYPE_RAW_ARRAY || t == TYPE_REAL || t == TYPE_REAL_ARRAY || t == TYPE_RECT2 || t == TYPE_RID || t == TYPE_STRING || t == TYPE_TRANSFORM || t == TYPE_TRANSFORM2D || t == TYPE_VECTOR2 || t == TYPE_VECTOR2_ARRAY || t == TYPE_VECTOR3 || t == TYPE_VECTOR3_ARRAY):
			print("----------------------------------------------------------- TODO - MISSING TYPE, ADD SUPPORT IT") # Add assert here to get info which type is missing
			return false
			
		#This is only for RegressionTestProject, because it needs for now clear visual info what is going on screen, but some nodes broke view
		if regression_test_project:
			# That means that this is constant, not class
			if !ClassDB.class_exists(name_of_class):
				continue
			if !ClassDB.is_parent_class(name_of_class, "Node") && !ClassDB.is_parent_class(name_of_class, "Reference"):
				return false
	
	return true

# Return GDScript code which create this object
func get_gdscript_class_creation(name_of_class : String) -> String:
	if (
		ClassDB.is_parent_class(name_of_class, "Object")
		&& !ClassDB.is_parent_class(name_of_class, "Node")
		&& !ClassDB.is_parent_class(name_of_class, "Reference")
		&& !ClassDB.class_has_method(name_of_class, "new")
	):
		return "ClassDB.instance(\"" + name_of_class + "\")"
	else:
		return name_of_class.trim_prefix("_") + ".new()"

func remove_disabled_methods(method_list : Array, exceptions : Array) -> void:
	for exception in exceptions:
		var index: int = -1
		for method_index in range(method_list.size()):
			if method_list[method_index]["name"] == exception:
				index = method_index
				break
		if index != -1:
			method_list.remove(index)

func remove_thing(thing : Object) -> void:
	if !thing:
		return
	if !is_instance_valid(thing):
		return
	if thing is Node:
		thing.queue_free()
	elif thing is Object && !(thing is Reference):
		thing.free()

# Return all available classes which can be used
func get_list_of_available_classes(must_be_instantable : bool = true, allow_editor : bool = true) -> Array:
	var full_class_list : Array = Array(ClassDB.get_class_list())
	var classes : Array = []
	full_class_list.sort()
	
	var custom_classes : Array = []
	var file = File.new()
	if file.file_exists("res://classes.txt"):
		file.open("res://classes.txt", File.READ)
		while !file.eof_reached():
			var cname = file.get_line()
			var internal_cname = "_" + cname
			# The declared class may not exist, and it may be exposed as `_ClassName` rather than `ClassName`.
			if !ClassDB.class_exists(cname) && !ClassDB.class_exists(internal_cname):
				continue
			if ClassDB.class_exists(internal_cname):
				cname = internal_cname
			custom_classes.push_back(cname)
		file.close()

	for name_of_class in full_class_list:
		if name_of_class in disabled_classes:
			continue

		#This is only for RegressionTestProject, because it needs for now clear visual info what is going on screen, but some nodes broke view
		if regression_test_project:
			if !ClassDB.is_parent_class(name_of_class, "Node") && !ClassDB.is_parent_class(name_of_class, "Reference"):
				continue

		if name_of_class.find("Server") != -1 && !ClassDB.is_parent_class(name_of_class,"Reference"):
			continue
		if name_of_class.find("Editor") != -1 && (regression_test_project || !allow_editor):
			continue

		if !custom_classes.empty() and !(name_of_class in custom_classes):
			continue

		if !must_be_instantable || ClassDB.can_instance(name_of_class):
			classes.push_back(name_of_class)

#	classes = classes.slice(0, 200)
	
	print(str(classes.size()) + " choosen classes from all " + str(full_class_list.size()) + " classes.")
	
	return classes
