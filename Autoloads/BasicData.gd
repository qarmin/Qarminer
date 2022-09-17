extends Node

### Contains basic data about disabled things like functions etc.

var custom_classes: Array = []  # List of all allowed classes that user choosed

var all_available_classes: Array = []  # List of all classes that are instantable
var base_classes: Array = []  # List of all allowed classes which can be used as Class.something else
var argument_classes: Array = []  # Allowed classes that can be used as arguments, in normal usage this and base_classes are equal, but it is needed for custom classes e.g. custom_classes are [A,B] but this can be executed A.f(C)
var allowed_thing: Dictionary = {}  # List of all classes with

# Globablly disabled functions for all classes
# TODOGODOT4
var function_exceptions: Array = [
	###
	### Godot 4.0
	###
	"_get_light_textures_data", # 66002
	"get_seamless_image", # 61044
	"set_buffer",  # 65964
	"set_process_mode",  #61474
	"get_mesh_arrays",  # 64122
	"confirm_code_completion",  # 62199
	"update_code_completion_options",  # 62199
	"compress",  # 62097
	"set_disable_mode",  # 61474
	"set_process_material",  #61175
	"_update_texture",  # 61044
	"_generate_texture",  # 61044
	"set_zoom",  # 60492
	"set_end",  # 60492
	"set_size",  # 60326, 60325
	"set_points",  # 60337
	"set_custom_viewport",  #60052
	"set_visibility_range_begin_margin",  #54655
	"set_visibility_range_begin",  #54655
	"_broadcast",  #53873
	"set_base",  #53723
	"set_polygon",  #53722
	"add_bone",  #53646
	"set_bone_children",  #53646
	"global_pose_z_forward_to_bone_forward",  #53646
	"lightmap_unwrap",  # 52929
	"get_property_list",  #53604
	"set_projector",  #53604
	"commit",  #53191
	"commit_to_arrays",  #53191
	"shaped_text_draw_outline",  #53562
	"set_input_as_handled",  #53560
	"add_node",  #53558
	"set_texture",  #46828
	"compress_from_channels",  # Image
	"open_midi_inputs",  #52821
	"load_threaded_request",  #46762
	"bake_navigation_mesh",  # TODO too hard to find for now
	"set_is_setup",  # Just don't use, in SkeletonModification crashes a lot without reason
	"_update_shape",  # TODO, probably crashes exported build
	"get_custom_monitor",  # TODO crashes only in exported build
	"clip_polyline_with_polygon",  #60324
	"clip_polygons",  #60324
	"offset_polyline",  #60324
	"offset_polygon",  #60324
	"exclude_polygons",  #60324
	"intersect_polyline_with_polygon",  #60324
	"merge_polygons",  #60324
	"intersect_polygons",  #60324
	"popup_centered_clamped",  # 60326
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
	### Freeze
	###
	"popup_centered_minsize",  # 60326
	###
	### Reported crashes
	###
	"set_zoom_min",  # 60492
	"set_zoom_max",  # 60492
	"open_midi_inputs",  # 52821
	"set_window_size",  # 60466
	"set_zoom",  # 60492
	"set_end",  # 60492
	"find_interaction_profile",  # 60375
	"find_action_set",  #60374
	"set_custom_minimum_size",  #60376
	"set_size",  #60325
	"set_custom_viewport",  #60052
	"create_convex_shape",  # TODO
	"get_debug_mesh",  #60337
	"set_radial_initial_angle",  #60338
	"set_outer_radius",  #60325
	"set_polygon",  #60325
	"set_depth",  #60325
	"set_radius",  #60325
	"set_inner_radius",  #60325
	"clip_polyline_with_polygon_2d",  #60324
	"clip_polygons_2d",  #60324
	"offset_polyline_2d",  #60324
	"offset_polygon_2d",  #60324
	"exclude_polygons_2d",  #60324
	"intersect_polyline_with_polygon_2d",  #60324
	"merge_polygons_2d",  #60324
	"intersect_polygons_2d",  #60324
	"process_action",  #60297
	"remove_line",  #59935
	"bake_navigation_mesh",  # Threading problem, needs to find exact steps to reproduce
	"get_bind_bone",  # Fixed only in master
	"get_bind_name",  # Fixed only in master
	"get_bind_pose",  # Fixed only in master
	"create_from_mesh",  # TODO
	"reset_instance_physics_interpolation",  #58293
	"lightmap_unwrap",  # 52929
	"replace_by",  #53775
	"set_extra_cull_margin",  # 53623
	"set_block_signals",  #53553
	"make_atlas",  #51154
	"light_unwrap",  #52929
	"_editor_settings_changed",  # 45979
	"set_script",  #46120
	"set_icon",  #46189
	"set_editor_hint",  #46252 - Fixed only for master(due compatibility)
	"set_probe_data",  #46570
	"add_vertex",  #47066
	"convert",  # 46479
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
	"sample_baked_up_vector",
	"sample_baked",
	"convert_to_image",
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
	### Godot freeze or run very slow
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
	"print_orphan_nodes",
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
	"to_node",
	"replace_by",
	"create_instance",
	"set_owner",
	"set_root_node",
	"instantiate",
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
	##### Crash and Trash
	#####
	"crash",
	"move_to_trash",
	#####
	##### Goost
	##### TODO: these take too long to execute, does not make sense to limit number of iterations ether.
	##### TODO - remove this and put it into setting file
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
	"VisibleOnScreenEnabler2D",
	"VisibleOnScreenEnabler3D",
	"VisibilityEnabler3D",
	"VisibleOnScreenNotifier2D",
	"VisibleOnScreenNotifier3D",
	"VisibleOnScreenNotifier3D",
]

var return_value_exceptions: Array = [
	"get_viewport",  # Node
	"get_parent",  # Node
	"get_tree",  # Node but only when adding to tree
	"get_main_loop",  # _Engine.get_main_loop - not good idea to remove_at main loop
	"get_direct_space_state",
]

# Globally disabled classes which causes bugs
# TODOGODOT4
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
	###
	### TODO
	###
	"ParallaxBackground",  # TODO threading problem, cannot reproduce
	"ImmediateMesh",  #53623
	"ItemList",  # Big numbers
	"_ResourceLoader",  #Spams
	"ResourceLoader",  #Spams
	"PackedDataContainer",  #53554 - more crashes
	"ProximityGroup",  # Not cherrypicked yet
	###
	### Exported build - some checks are disabled in exported build due to too big performance impact
	###
	"Image",
	# Backported Node3D changes also backport bugged classes
	"NavigationAgent2D",
	"NavigationAgent3D",
	# TODOGODOT4 - update here exluded list from Godot4
	###
	### Godot 4.0
	###
	"OS",
	"Thread",
	"Semaphore",
	"Mutex",
	"GodotSharp",
	###
	### Godot 4.0 Additional
	###
	#
	"ConfigFile",  # 65316
	"ThemeDB",  # Singleton 4
	"SystemFont",  # 64698
	"TextServer",  # RefCounted Server
	"TextServerAdvanced",  # RefCounted Server
	"TextServerExtension",  # RefCounted Server
	"TextServer",  # RefCounted Server
	"EngineDebugger",  # Crashes in exported project, not very usable
	# Functions to be enabled(somewhere)
	"InputMap",  # Strange crashes
	"MultiplayerAPI",  # Crashes TODO
	"VisibleOnScreenEnabler3D",  #53565
	"VisibleOnScreenEnabler2D",  #53565
	"ImageTexture3D",  #53721
	"XRCamera3D",  #53725
	"FogMaterial",  #54478
	"AudioStreamGenerator",  # TODO threading crash
	"AudioStreamGeneratorPlayback",  # TODO threading crash
]

# Exceptions for e.g. float, String or int functions
# TODOGODOT4
var variant_exceptions: Array = [
# TO FIND
]

# User defined allowed functions, empty means that this won't work
var allowed_functions: Array = [
# TO FIND
]
