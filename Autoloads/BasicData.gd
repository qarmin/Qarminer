extends Node

### Contains basic data about disabled things like functions etc.

var custom_classes: Array = []  # List of all allowed classes that user choosed

var all_available_classes: Array = []  # List of all classes that are instantable
var base_classes: Array = []  # List of all allowed classes which can be used as Class.something else
var argument_classes: Array = []  # Allowed classes that can be used as arguments, in normal usage this and base_classes are equal, but it is needed for custom classes e.g. custom_classes are [A,B] but this can be executed A.f(C)
var allowed_thing: Dictionary = {}  # List of all classes with

# Globablly disabled functions for all classes
var function_exceptions: Array = [
	###
	### Input crashes, still are some problems TODO
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
	"lightmap_unwrap",  # 52929
	"replace_by",  #53775
	"bake",  #53774
	"create_debug_tangents",  #53182
	"create_from_mesh",  #53181
	"remove_line",  # 49571 - Memory leak
	"connect_to_signal",  # 53622
	"set_extra_cull_margin",  # 53623
	"_thread_done",  #53621
	"set_physics_enabled",  #53620
	"_iter_init",  #53554
	"set_block_signals",  #53553
	"make_atlas",  #51154
	"set_basic_type",  #53456
	"set_custom_viewport",  #53445
	"_draw_soft_mesh",  #53437
	"light_unwrap",  #52929
	"create_action",  #50769
	"_editor_settings_changed",  # 45979
	"set_script",  #46120
	"set_icon",  #46189
	"set_editor_hint",  #46252 - Fixed only for master(due compatibility)
	"set_probe_data",  #46570
	"add_vertex",  #47066
	"create_shape_owner",  #47135
	"shape_owner_get_owner",  #47135
	"get_bind_bone",  #47358
	"get_bind_name",  #47358
	"get_bind_pose",  #47358
	"decompress",  #50787
	"convert",  # 46479
	"save_png_to_buffer",  # 50787
	###
	### Not worth to check, cause a lot of crashes but it is very unlikelly that users will use them
	###
	"propagate_notification",
	"notification",
	###
	### Error spam when using it TODO
	###
	"get_recognized_extensions_for_type",  # Spam
	"load",  # Spam - _ResourceLoader
	"add_sphere",
	"_update_inputs",
	"update_bitmask_region",
	"set_enabled_inputs",
	###
	### Slow Function
	###
	"set_pre_process_time",
	"create_convex_collision",
	"create_multiple_convex_collisions",
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
	"poll",
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
	#####
	##### Goost
	##### TODO: these take too long to execute, does not make sense to limit number of iterations ether.
	#####
	"smooth_polyline_approx",
	"smooth_polygon_approx",
]

# List of all functions that can freeze Godot when working with really big numbers
var too_big_arguments: Array = [
	"get_seamless_image",
	"generate_rsa",  # TODO
	"set_map_width",
	"get_image",
	"set_width",
	"set_height",
	"create",
	"set_radial_segments",
	"set_subdivide_depth",
	"set_custom_aabb",
	"set_subdivide_height",
	"set_subdivide_width",
	"set_rect",
	"set_sides",
	"set_ring_sides",
	"create_convex_shape",
	"create_trimesh_shape",
	"get_method_list",
	# Spam
	"_get_custom_data_array",
	"_get_color_array",
]
# List of all functions that can freeze Godot when working with really big numbers
var too_big_classes: Array = [
	"VisibilityEnabler2D",
	"VisibilityEnabler",
	"VisibilityEnabler3D",
	"VisibilityNotifier2D",
	"VisibilityNotifier3D",
	"VisibilityNotifier",
]

var return_value_exceptions: Array = [
	"get_viewport",  # Node
	"get_parent",  # Node
	"get_tree",  # Node but only when adding to tree
	"get_main_loop",  # _Engine.get_main_loop - not good idea to remove main loop
	"get_direct_space_state",
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
	"Engine",  # Crashes only in Godot 4 but not really usable
	###
	### JavaClass is only functions that returns Null when using JavaClass.new().get_class
	###
	"JavaClass",
	###
	### Android
	###
	"JavaClassWrapper",  # Looks that JavaClassWrapper.new() crashes android
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
	### Mono
	###
	"_GodotSharp",
	## TODOGODOT4
	#	###
	#	### Godot 4.0
	#	###
	#	"OS",
	#	"Thread",
	#	"Semaphore",
	#	"Mutex",
	#	"GodotSharp",
	#	###
	#	### Godot 4.0 Additional
	#	###
	#	"TextServer", # RefCounted Server
	#	"TextServerAdvanced", # RefCounted Server
	#	"TextServerExtension", # RefCounted Server
	#	"TextServer", # RefCounted Server
	#	"TextEdit",  # Crashes 52876
	#	"CodeEdit",  # Also 52876
	#	"FontData",  # A lot of crashes 52817
	#	"InputEventShortcut",  # 52191
	#	"MultiplayerAPI",  # Crashes TODO
	#	"InputMap",
	#	"GPUParticles3D",  # 53004
	###
	### TODO
	###
	"ImmediateGeometry",  #53623
	"ItemList",  # Big numbers
	"_ResourceLoader",  #Spams
	"ResourceLoader",  #Spams
	"PackedDataContainer",  #53554 - more crashes
	"ProximityGroup",  # Not cherrypicked yet
	###
	### Exported build - some checks are disabled in exported build due to too big performance impact
	###
	"Image",
	#	###
	#	### Godot 4.0
	#	###
	#	"OS",
	#	"Thread",
	#	"Semaphore",
	#	"Mutex",
	#	"GodotSharp",
	#	###
	#	### Godot 4.0 Additional
	#	###
	#	"Engine",  # This should be added also to Godot 3
	#	"GodotSharp",  # TODO, also to Godot 3 add
	#	"TextServer",  # RefCounted Server
	#	"TextServerAdvanced",  # RefCounted Server
	#	"TextServerExtension",  # RefCounted Server
	#	"TextServer",  # RefCounted Server
	#	"EngineDebugger",  # Crashes in exported project, not very usable
	#	"InputMap",
	#	"FontData",  # 53846
	#	"MultiplayerAPI",  # Crashes TODO
	#	"VisibleOnScreenEnabler3D",  #53565
	#	"VisibleOnScreenEnabler2D",  #53565
	#	"AudioStreamPlayer3D",  #53567
	#	"AudioStreamPlayer2D",  #53567
	#	"VideoPlayer",  #53568
	#	"ImageTexture3D",  #53721
	#	"XRCamera3D",  #53725
	#	"CurveTexture",  #54477
	#	"CurveXYZTexture",  #54477
	#	"FogMaterial",  #54478
]

# Exceptions for e.g. float, String or int functions
var variant_exceptions: Array = [
# TODO
]

# User defined allowed functions, empty means that this won't work
var allowed_functions: Array = [
#	"notification",
#	"propagate_notification",
]
