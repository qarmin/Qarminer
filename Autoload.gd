extends Node

var function_exceptions : Array = [
# They exists without assigment like Class.method, because they may be a parent of other objects and children also should have disabled child.method, its children also etc. which is too much to do

"draw_multiline_string",
"draw_font",

"align",# GH 45976
"_screen_pick_pressed",# GH 45977
"debug_bake",# GH 45978
"bake", # GH 45978
"_editor_settings_changed",# GH 45979
"_mesh_changed",# GH 45980
"_submenu_timeout", # GH 45981
"set_data", # GH 45995 - probably this will cause a lot of different errors in other classes
"_set_user_data", # GH 45996
"set_config_file", # GH 45997
"_gui_input", # GH 45998
"_unhandled_key_input", # GH 45998
"navpoly_add", #GH 43288
"create_from_mesh", #GH 45999
"_thread_done", #GH 46000
"generate", #GH 46001
"_proximity_group_broadcast", #GH 46002
"_direct_state_changed", #GH 46003
"create_from", #GH 46004
"create_from_blend_shape", #GH 46004
"append_from", #GH 46004
"get_column_width", #GH 46005
"_unhandled_input", # TODO
"_input", # TODO
"lightmap_unwrap", #GH 46007 - memory leak
"_input_type_changed", #GH 46011
"add_node", #GH 46012
"play", #GH 46013
"connect_nodes_forced", #GH 46014
"_set_tile_data", #GH 46015
"add_image", #GH 46016
"_edit_set_state", #GH 46017
"_edit_set_position", #GH 46018
"_edit_set_rect", #GH 46018
"get", #GH 46019
"instance_has", #GH 46020
"_update_shader", #GH 46062
"generate_tangents", #GH 46059
"get_var", #GH 46096
"force_drag", #GH 46114
"set_script", #GH 46120
"getvar", #GH 46019
"get_available_chars", #GH 46118
"set_primary_interface", #GH 46180
"add_feed", #GH 46181
"open_midi_inputs", #GH 46183
"get_unix_time_from_datetime", #GH 46188
"set_icon", #GH 46189
"set_window_size", #GH 46187
"get_screen_size", #GH 46186
"get_screen_position", #GH 46185
"set_current_screen", #GH 46184
"build_capsule_planes", #GH 
"build_cylinder_planes", #GH 
"get_latin_keyboard_variant", #GH  TODO Memory Leak
"add_feed", #GH 
"poll", #GH - HTTP CLIENT 
"make_atlas", #GH 
"set_editor_hint", #GH 
"", #GH 

#GODOT 4.0
"create_from_image",
"set_point_position",
"connect", # OTHER THINGS
"set_base",
"particles_collision_set_height_field_resolution",
"set_deconstruct_type",
"set_constant_type",
"",


"add_string",
"draw_string",
"set_dropcap",
"",

"collide", #GH 46137
"collide_and_get_contacts", #GH 46137
"collide_with_motion", #GH 46137
"collide_with_motion_and_get_contacts", #GH 46137


# TODO Check this later
"propagate_notification",
"notification",

# TODO is workaround for removing memory leak in Thread::start, should be fixed by GH 45618
"start",

# TODO Adds big spam when i>100 - look for possiblity to 
"add_sphere",
# Spam when i~1000 - change to specific 
"update_bitmask_region",

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
"open", # This also allow to save files
"dump_resources_to_file",
"dump_memory_to_file",

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
"set_gizmo", # Stupid function, needs as parameter an object which can't be instanced # TODO, create issue to hide it 

"_create",

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

# List of slow functions, which may frooze project
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
	
	
	# In 3d view some options are really slow
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

var disabled_classes : Array = [
	"AudioServer", # Crash GH #45972
	"ProjectSettings", # Don't mess with project settings, because they can broke entire your workflow
	"EditorSettings",
	"NetworkedMultiplayerENet", 
	"TranslationServer", # TODO Freeing instance, delete static object
	"UndoRedo",  # TODO Looks that may cause crash, and this needs to be fixed
	"CameraServer", # TODO - Some strange and random crash in contructor of CameraFeed, probably because CameraServer can be deleted
	"TextServerManager", # 4.0 Crash
	"GdNavigationServer",
]

# Return all available classes to instance and test
func get_list_of_available_classes() -> Array:
	var full_class_list : Array = Array(ClassDB.get_class_list())
	var classes : Array = []
	full_class_list.sort()
	var c = 0
	var rr = 0
	for name_of_class in full_class_list:
		if name_of_class in disabled_classes:
			continue
			
		if ClassDB.can_instance(name_of_class):
			classes.push_back(name_of_class)
			c+= 1
			
	print(str(c) + " choosen classes from all " + str(full_class_list.size()) + " classes.")
	return classes
