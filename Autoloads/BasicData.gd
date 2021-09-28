extends Node

### Contains basic data about disabled things like functions etc.

var regression_test_project: bool = false  # Set it to true in RegressionTestProject
var classes: Array = []  # List of all allowed classes
var allowed_thing: Dictionary = {}  # List of all classes with

# Globablly disabled functions for all classes
var function_exceptions: Array = [
	###
	### GODOT 4.0 CRASHES
	###
	"set_texture", #46828
	"save_scene",
	"_activate",
	"get_singleton",
	"set_singleton",
	"get_menu",
	"compress_from_channels",  # Image
	"open_midi_inputs",
	"load_threaded_request",
	"generate_lod", # 53011
	###
	### Crashes TODO
	###
	"follow_property",  #
	"poll",  # FREEZE
	"_thread_done",  #
	###
	### Dummy Rasterizer(CRASHES)
	###
	"create_debug_tangents", #53182
	"create_from_mesh", #53181
#	"set_data",  # ImageTexture
#	"set_YCbCr_imgs",  # CameraFeed
	###
	### Image functions(CRASHES)
	###
	"compress",
	"decompress",
	"convert",
	"save_png_to_buffer",  # uses decompress
	###
	### Input crashes, still are some problems
	###
	"_gui_input",
	"_input",
	"_unhandled_input",
	"_unhandled_key_input",
	"_vp_input",
	"_vp_unhandled_input",
	###
	### Reported crashes
	###
	"_direct_state_changed",  #46003 - Not cherrypicked
	"connect_to_signal",  # 47572 - Not cherrypicked
	"set_function",  # not cherrypick
	"_editor_settings_changed",  # 45979
	"set_script",  #46120
	"set_icon",  #46189
	"set_editor_hint",  #46252
	"set_probe_data",  #46570
	"add_vertex",  #47066
	"create_shape_owner",  #47135
	"shape_owner_get_owner",  #47135
	"get_bind_bone",  #47358
	"get_bind_name",  #47358
	"get_bind_pose",  #47358
	###
	### Crashes due removing values returned by function
	###
	"get_main_loop",  # _Engine.get_main_loop - not good idea to remove main loop
	"get_direct_space_state",
	###
	### Not worth to check, because users rarely us this
	###
	"propagate_notification",
	"notification",
	###
	### Error spam when using it TODO
	###
	"add_sphere",
	"_update_inputs",
	"update_bitmask_region",
	"set_enabled_inputs",
	###
	### Slow Function
	###
	"load_webp_from_buffer",
	"_update_sky",
	"interpolate_baked",
	"get_baked_length",
	"get_baked_points",
	"get_closest_offset",
	"get_closest_point",  # Only Curve, but looks that a lot of other classes uses this
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
	###
	### Do not save files and create files and folders, this probably can be enabled in CI
	###
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
	###
	### This also allow to save files
	###
	"open",
	"open_encrypted",
	"open_encrypted_with_pass",
	"open_compressed",
	###
	### Do not warp mouse, because I'm unable to do anything
	###
	"warp_mouse",
	"warp_mouse_position",
	###
	### OS
	###
	"kill",
	"shell_open",
	"execute",
	"alert",  # Stupid alert window opens
	###
	### Godot freeze or run very cslow
	###
	"delay_usec",
	"delay_msec",
	"wait_to_finish",
	"accept_stream",
	"connect_to_stream",
	"discover",
	"wait",
	"debug_bake",
	"bake",
	"set_gizmo",  # Stupid function, needs as parameter an object which can't be instanced # TODO, create issue to hide it
	###
	### Spams Output and aren't very useful
	###
	"print_tree",
	"print_stray_nodes",
	"print_tree_pretty",
	"print_all_textures_by_size",
	"print_all_resources",
	"print_resources_in_use",
	###
	### Can call other functions and broke everything
	###
	"_call_function",
	"call",
	"call_deferred",
	"callv",
	"call_func",
	###
	### Too dangerous, because add, mix and remove randomly nodes and objects
	###
	"replace_by",
	"create_instance",
	"set_owner",
	"set_root_node",
	"instantiate",
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
	"add_sibling",
	"add_sibling",
	#####
	##### Goost
	##### TODO: these take too long to execute, does not make sense to limit number of iterations ether.
	#####
	"smooth_polyline_approx",
	"smooth_polygon_approx",
]

# Globally disabled classes which causes bugs
var disabled_classes: Array = [
	###
	### Crashes, Freezes
	###
	"ProjectSettings",  # Don't mess with project settings, because they can broke entire your workflow
	"EditorSettings",  # Also don't mess with editor settings
	"GDScript",  # Broke script
	"SceneTree",
	"JNISingleton",  # Freeze - who use it?
	###
	### JavaClass is only functions that returns Null when using JavaClass.new().get_class
	###
	"JavaClass",
	###
	### Just don't use these because they are not normal things
	###
	"_Thread",
	"_Semaphore",
	"_Mutex",
	###
	### OS - in normal testing, can broke everything, but can be used in CI
	###
	"_OS",
	###
	### Godot 4.0
	###
	"OS", # Without underscore
	"Thread", # Without underscore
	"Mutex", # Without underscore
	"Semaphore", # Without underscore
	
	"TextEdit", # Crashes 52876
	"CodeEdit", # Also 52876
	"FontData",  # A lot of crashes 52817
	"InputEventShortcut",  # 52191
	"MultiplayerAPI",  # Crashes TODO
#	"SkeletonModificationStack3D",  # TOO MUCH CRASHES
#	"SkeletonModification2DPhysicalBones",
#	"SkeletonModification2DLookAt",
#	"SkeletonModification2DTwoBoneIK",
#	"SkeletonModification2DCCDIK",
	"InputMap",
	"GPUParticles3D", # 53004

]

# Exceptions for e.g. float, String or int functions
var variant_exceptions: Array = [
# TODO
]
