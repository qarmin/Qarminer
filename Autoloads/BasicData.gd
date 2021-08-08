extends Node

### Contains basic data about disabled things like functions etc.

var regression_test_project : bool = false # Set it to true in RegressionTestProject

# Globablly disabled functions for all classes
# Should be better if they would be disabled in this way - Class.Method, because 
# now it is possible to block Node2D.new() if we just want to block only Node3D.new()
var function_exceptions : Array = [
	# Dummy Rasterizer - TODO
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

	# Crashes due removing values returned by function
	"get_main_loop", # _Engine.get_main_loop - not good idea to remove main loop
	"get_direct_space_state",

	# TODO Check this later, but not sure if this is worth to check
	"propagate_notification",
	"notification",

	# Error spam when using it, maybe it would be good to report also this as issues
	"add_sphere",
	"_update_inputs",
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
	"is_enabler_enabled",
	"set_enabler",
	"get_aabb",
	"set_aabb",
	"is_on_screen",
	"set_rings",
	"set_amount",

	# Undo/Redo function which doesn't provide enough information about types of objects, probably due vararg(variable size argument)
#	"add_do_method",
#	"add_undo_method",

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
#	"new",
#	"duplicate",
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
