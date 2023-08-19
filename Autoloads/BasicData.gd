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
	### Timer - slow functions that sometimes probably cause CI failure(due too long of time checking) > 0.5 second 
	###
	"draw_multiline_string_outline", # FontVariation
	"inspect_native_shader_code", # ORMMaterial3D 
	"_im_update", #Label3D
	"_generate_texture", # NoiseTexture2D
	"draw_string_outline", # FontVariation
	"_update_texture", #NoiseTexture2D
	"NoiseTexture2D", # StreamPeerBuffer
	"get_utf8_string", # StreamPeerBuffer
	"draw_multiline_string", # FontVariation
	"get_var",  #StreamPeerTLS
	"get_string", #StreamPeerTLS
	"set_input_count", #AnimationNodeTransition.new().set_input_count(-24) Error spam
	###
	### Godot 4.0 - Expected things
	###
	"reparent", 
	"set_base", # Dangerous, change base and creates memory leak
	"instantiate",  # Hmmm...
	"print_orphan_nodes",  # Hmmm ..
	"sample_baked",  # Freeze
	"sample_baked_up_vector",  # Freeze
	"get_parent",  # ? - why this is not available on 3.x?
	"save_jpg",  # create files
	"set_font_size",  # SLOOOOOOW function
	"tessellate_even_length",  # Too slow
	"save_webp",  # Saves file to FS
	"save_support_data",  # Saves file to FS
	"set_is_setup",  # Just don't use, in SkeletonModification crashes a lot without reason
	###
	### Godot 4.0 MSAN
	###
	"set_font_names",
	"create_client",
	"connect_to_url",
	###
	### Godot 4.0
	###
	"string_get_character_breaks", # 80776
	"remove_paragraph", # 79409
	"set_data",  # 78414
	"set_process_thread_group",  # 77029
	"get_format", # TODO crashes in CI, but cannot really reproduce
	"get_seamless_image_3d", # TODO Timeout
	"propagate_call", #
	"notify_thread_safe", # 
	"set_deferred", # 77029
	"clear_bones_global_pose_override", # 77057
	"set_deferred_thread_group", # 77029
	"notify_deferred_thread_group", # 77029
	"call_deferred_thread_group", # 77029
	"begin_complex_operation", # 73202
	"do_indent", # 73202
	"window_set_mouse_passthrough", #66754
	"push_hint", # 72232
	"add_image", # 72232
	"save_webp_to_buffer", # 72230
	"property_get_revert", # 71863
	"initialize", # 71150
	"set_custom_minimum_size", # TODO - probably is fixed, but I still have crashes
	"_get_drag_data_fw", # 70005
	"create_font",  # TODO TextServerAdvanced
	"create_shaped_text",  # TODO TextServerAdvanced
	"pack",  # 69258
	"set_extra_cull_margin",  # 69258
	"get_line_width",  # 68156
	"set_process_material",  # 67954, 54478, 61175
	"append_from_file",  # 67951
	"_set_playing",  #67589
	"save_jpg_to_buffer",  # 67586
	"set_current",  # 67442
	"set_follow_camera_enabled",  # 66986
	"set_scroll_past_end_of_file_enabled",  # 66937
	"set_fit_content_height_enabled",  # 66937
	"set_line_wrapping_mode",  # 66937
	"_get_light_textures_data",  # 66002
	"set_visibility_range_begin_margin",  #54655
	"set_visibility_range_begin",  #54655
	"broadcast",  #53873
	"get_property_list",  #53604
	"set_projector",  #53604
	"add_node",  #53558
	"load_threaded_request",  #46762
	### INF 4
	"_set_size", # TODO 2 - GraphEdit
	"set_global_position", # TODO 1 - GraphEdit
	"set_scroll_ofs", # TODO 1 - GraphEdit
	"clip_polyline_with_polygon",  #60324
	"clip_polygons",  #60324
	"offset_polyline",  #60324
	"offset_polygon",  #60324
	"exclude_polygons",  #60324
	"intersect_polyline_with_polygon",  #60324
	"merge_polygons",  #60324
	"intersect_polygons",  #60324
	###
	### Reported crashes
	###
	"_gui_input",  # 70097
	"set_avoidance_enabled", # 68022 TODO wait for PR for 3.6, 69629
	"agent_set_callback", # 68013 TODO wait for PR for 3.6, 69629
	"set_enabled_inputs",  # 69230
	"tts_set_utterance_callback",  # 66821
	"set_window_mouse_passthrough",  # 66754
	"open_midi_inputs",  # 52821, 69180
	"set_custom_viewport",  #60052
	"process_action",  #60297
	"set_block_signals",  #53553
	"make_atlas",  #51154
	"set_script",  #46120
	"set_icon",  #46189
	### Partial INF - Freeezes sometimes without INF
	"set_zoom",  # 60492
	"set_end",  # 60492
	"set_zoom_min",  # 60492
	"set_zoom_max",  # 60492
	"set_begin", # 70147
	"set_zoom_step", # 70147
	"_zoom_minus", # 70147
	"_zoom_plus", # 70147
	### INF Crashes
	"resize", # 70187
	"play", # 70140
	"set_pitch_scale", # 70140
	"set_begin", # 70147
	"set_zoom_step", # 70147
	"update_bitmask_area", # 70139
	"update_bitmask_region", # 70139
	"get_debug_mesh",  #60337
	"set_points", # 60337
	"create_convex_collision",  # 60357
	"create_convex_shape",  # 60357
	"set_radial_initial_angle",  #60338
	"append_from", # 60325 - MergeVertsFast, thirdparty/misc/mikktspace.c
	"generate_tangents", # 60325
	"begin", # 60325
	"set_size",  #60325
	"set_spin_degrees", # 60325
	"set_outer_radius",  #60325
	"set_polygon",  #60325
	"set_depth",  #60325
	"set_radius",  #60325
	"set_width",  #60325
	"set_height",  #60325
	"set_inner_radius",  #60325
	"clip_polyline_with_polygon_2d",  #60324
	"clip_polygons_2d",  #60324
	"offset_polyline_2d",  #60324
	"offset_polygon_2d",  #60324
	"exclude_polygons_2d",  #60324
	"intersect_polyline_with_polygon_2d",  #60324
	"merge_polygons_2d",  #60324
	"intersect_polygons_2d",  #60324
	###
	### Expected Crashes
	###
	"_editor_settings_changed",  # Fixed only for master
	"set_editor_hint",  #46252 - Fixed only for master(due compatibility)- do not use
	###
	### Not worth to check, cause a lot of crashes but it is very unlikelly that users will use them
	###
	"propagate_notification",
	"notification",
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
	"crash",
	"move_to_trash",
	###
	### Godot freeze or run very slow
	###
	"set_pre_process_time", # CPUParticles freeze
	"poll",
	"delay_usec",
	"delay_msec",
	"wait_to_finish",
	"accept_stream",
	"connect_to_stream",
	"discover",
	"wait",
	"set_gizmo",  # Stupid function, needs as parameter an object which can't be instanced in GDScript
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
	"call",
	"call_deferred",
	"callv",
	"call_func",
	"call_funcv",
	"call_native",
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
	"to_node", # GLTFLight creates new Node
]

# List of all functions that can freeze Godot when working with really big numbers
var too_big_arguments: Array = [
	# GODOT 4
	"sample_baked_with_rotation",
	# GODOT 3
	"_update_sky",
	"create_convex_collision",
	"create_multiple_convex_collisions",
	"tessellate",
	"interpolate_baked_up_vector",
	"interpolate_baked",
	"get_baked_length",
	"get_baked_points",
	"get_closest_offset",
	"get_closest_point",  # Only Curve, but looks that a lot of other classes uses this
	"get_baked_up_vectors",
	"debug_bake",
	"bake",
	"bake_navigation_mesh",  # Threading problem, needs to find exact steps to reproduce
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
	"set_grid_radius",  # ProximyGroup, freeze entire calculations
	"set_panorama",
	"load_webp_from_buffer",
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
	### Normal
	###
	"EditorSettings",  # Also don't mess with editor settings
	"GDScript",  # Broke script
	"SceneTree",
	"JNISingleton",  # Freeze - who use it?
	"JavaClassWrapper",  # Looks that JavaClassWrapper.new() crashes android
	"JavaClass",  # JavaClass is only functions that returns Null when using JavaClass.new().get_class
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
	"CompressedCubemapArray", # 77762
	"CubemapArray",  # 77762
	"PlaceholderCubemapArray", # 77762
	"Skeleton3D", # 77057
	"XROrigin3D",  # 67442
	"FogMaterial",  # 67954
	"VisibleOnScreenEnabler3D",  # 53565
	"VisibleOnScreenEnabler2D",  # 53565
	"ImageTexture3D",  # 53721
	"GraphNode",  # 65557
	"AudioStreamGenerator",  # TODO threading crash
	"AudioStreamGeneratorPlayback",  # TODO threading crash
	"MultiplayerAPI",  # Crashes TODO
	"OpenXRInteractionProfileMetaData", # TODO Heap use after free
	"EngineDebugger",  # Crashes in exported project, not very usable
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

var csharp_function_exceptions: Array = [
	"ResChanged",  # AnimatedSprite2D
]
