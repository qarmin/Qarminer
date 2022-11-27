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
	### Godot 4.0 - Expected things
	###
	"instantiate",  # Hmmm...
	"warp_mouse_position",  # Hmmm ..
	"print_stray_nodes",  # Hmmm ..
	"add_child_below_node",  # Hmm ..
	"to_node",  # Leak
	"sample_baked",  # Freeze
	"sample_baked_up_vector",  # Freeze
	"get_parent",  # ? - why this is not available on 3.x?
	"save_jpg", # create files
	"set_font_size", # SLOOOOOOW function
	"tessellate_even_length", # Too slow
	###
	### Godot 4.0 MSAN
	###
	"set_font_names",
	"create_client",
	"connect_to_url",
	# TODO ZipReader use uniitalized memory
	###
	### Godot 4.0
	###
	"window_get_native_handle", # 68525
	"push_paragraph", # 68242
	"do_indent", # 68176
	"unindent_lines", # 68176
	"update_code_completion_options", # 68176
	"get_line_width", # 68156
	"do_unindent", # 68154
	"create_convex_collision",  # 60357
	"set_process_material",  # 67954, 54478
	"append_from_file",  # 67951
	"add_file",  # 67613
	"_set_playing",  #67589
	"play",  #  67589
	"save_jpg_to_buffer",  # 67586
	"set_current",  # 67442
	"set_follow_camera_enabled",  # 66986
	"set_scroll_past_end_of_file_enabled",  # 66937
	"set_fit_content_height_enabled",  # 66937
	"set_line_wrapping_mode",  # 66937
	"generate_triangle_mesh",  # 66699
	"get_faces",  #66699
	"create_trimesh_shape",  # 66699
	"_get_light_textures_data",  # 66002
	"get_seamless_image",  # 61044
	"set_buffer",  # 65964
	"compress",  # 62097
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
	### Reported crashes
	###
	"bake", # 69229
	"set_enabled_inputs",  # 69230
	"_gui_input",  # 69214
	"set_avoidance_enabled",  #68022
	"agent_set_callback",  # 68013
	"create_convex_collision",  # 60357
	"tts_set_utterance_callback",  # 66821
	"set_window_mouse_passthrough",  # 66754
	"open_midi_inputs",  # 52821, 69180
	"set_custom_minimum_size",  #60326 - 60376
	"set_custom_viewport",  #60052
	"create_convex_shape",  # 60357
	"get_debug_mesh",  #60337
	"set_radial_initial_angle",  #60338
	"process_action",  #60297
	"replace_by",  #53775
	"set_block_signals",  #53553
	"make_atlas",  #51154
	"set_script",  #46120
	"set_icon",  #46189
	"set_size",  #60325
	"popup_centered_minsize",  # 60326
	"set_zoom",  # 60492
	"set_end",  # 60492
	"set_zoom_min",  # 60492
	"set_zoom_max",  # 60492
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
	"add_child_below_node"
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
	"set_pre_process_time",
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
	"_GodotSharp",
	"_Thread",
	"_Semaphore",
	"_Mutex",
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
	"XROrigin3D",  # 67442
	"FogMaterial",  # 67954
	"VisibleOnScreenEnabler3D",  # 53565
	"VisibleOnScreenEnabler2D",  # 53565
	"ImageTexture3D",  # 53721
	"GraphNode",  # 65557
	"AudioStreamGenerator",  # TODO threading crash
	"AudioStreamGeneratorPlayback",  # TODO threading crash
	"MultiplayerAPI",  # Crashes TODO
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
