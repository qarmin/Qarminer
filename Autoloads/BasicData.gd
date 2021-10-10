extends Node

### Contains basic data about disabled things like functions etc.

var regression_test_project: bool = false  # Set it to true in RegressionTestProject
var base_classes: Array = []  # List of all allowed classes which can be used as Class.something else
var argument_classes: Array = []  # Allowed classes that can be used as arguments, in normal usage this and base_classes are equal, but it is needed for custom classes e.g. custom_classes are [A,B] but this can be executed A.f(C)
var allowed_thing: Dictionary = {}  # List of all classes with

# Globablly disabled functions for all classes
var function_exceptions: Array = [
	###
	### Godot 4.0
	###
	"add_bone", #53646
	"set_bone_children", #53646
	"global_pose_z_forward_to_bone_forward", #53646
	"lightmap_unwrap",  # 52929
	"get_render_info",  #53644
	"set_pre_process_time",  # CPUParticles3D Freeze - disable also in Godot 3
	"add_source",  #53624
	"set_source_id",  #53624
	"get_property_list",  #53604
	"set_projector",  #53604
	"set_instance_count",  #53603
	"set_use_colors",  #53603
	"set_transform_format",  #53603
	"push_input",  #53601
	"push_unhandled_input",  # Probably same as above, but TODO
	"is_input_handled",  #53600
	"commit",  #53191
	"commit_to_arrays",  #53191
	"popup_centered_ratio",  #53566
	"get_pyramid_shape_rid",  # 53564
	"set_stream",  #52853
	"shaped_text_draw_outline",  #53562
	"import_post",  #53561
	"set_input_as_handled",  #53560
	"add_node",  #53558
	"as_text",  #53224
	"get_image",  # 53214
	"set_language",  #53218
	"set_texture",  #46828
	"_activate",  #45984
	#"get_singleton", # TODO
	#"set_singleton", # TODO
	#"get_menu", # TODO
	"compress_from_channels",  # Image
	"open_midi_inputs",  #52821
	"load_threaded_request",  #46762
	"generate_lod",  # 53011
	"create_font",  # TODO TextServerAdvanced - probably memory leak
	###
	### Other TODO
	###
	"get_recognized_extensions_for_type",  # Spam
	"load",  # Spam - _ResourceLoader
	"poll",  # FREEZE
	#"set_function",  # Not cherrypicked
	###
	### Image functions(CRASHES)
	###
	"decompress",  #50787
	"convert",  # 46479
	"save_png_to_buffer",  # 50787
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
	"new",
	"duplicate",
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
	### Godot 4.0
	###
	"OS",
	"Thread",
	"Semaphore",
	"Mutex",
	###
	### Godot 4.0 Additional
	###
	"TextServer",  # RefCounted Server
	"TextServerAdvanced",  # RefCounted Server
	"TextServerExtension",  # RefCounted Server
	"TextServer",  # RefCounted Server
	"TextEdit",  # Crashes 52876
	"CodeEdit",  # Also 52876
	"FontData",  # A lot of crashes 52817
	"InputEventShortcut",  # 52191
	"MultiplayerAPI",  # Crashes TODO
	"InputMap",
	"GPUParticles3D",  # 53004
	"VisibleOnScreenEnabler3D",  #53565
	"VisibleOnScreenEnabler2D",  #53565
	"AudioStreamPlayer3D",  #53567
	"AudioStreamPlayer2D",  #53567
	"VideoPlayer",  #53568
	"SoftDynamicBody3D",  # TODO, softbody crashes
	###
	### TODO
	###
	"_ResourceLoader",  #Spams
	"ResourceLoader",  #Spams
	"PackedDataContainer",  #53554 - more crashes
	"ProximityGroup3D",  # Not cherrypicked yet
	###
	### Big numbers - only enabled when arguments can be >100, because can freeze entire project
	###
	#	"OpenSimplexNoise",
	#	"HeightMapShape3D",
	#	"BitMap",
	#	"CPUParticles3D",
	###
	### Exported build - some checks are disabled in exported build due to too big performance impact
	###
	"Image",
]

# Exceptions for e.g. float, String or int functions
var variant_exceptions: Array = [
# TODO
]
