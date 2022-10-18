extends Node2D

var counter = 0
var test_gdscript: bool = false

var allowed_functions: Array = []

var excluded_functions: Array = [
	# Crashes
	"open_midi_inputs",  #52821
	"set_window_mouse_passthrough",  #66754
	"lock",  # 66758
	# OTHER
	"set_window_size",  # Can crash OS/DE, hard to find exact values to crash
	"print_resources_by_type",  # Prints
	"print_all_textures_by_size",  # Prints
	"print_all_resources",  # Create files
	"move_to_trash",  # Moves to trash
	"make_sphere_mesh",  # Slow
	"free",  # Not enabled
	"warp_mouse",  # Warping
	"crash",  # Crash
	"alert",  # Show useless message
	"kill",  # Kills random process
	"execute",  # Open random app
	"shell_open",  # Opens file exporer
	"delay_msec",  # Sleep
	"delay_usec",  # Sleep
	"set_exit_code",  # Always should return valid code, not changed one
	"dump_memory_to_file",  # create file
	"dump_resources_to_file",  # create file
	"set_low_processor_usage_mode",  # Freeze
	"set_low_processor_usage_mode_sleep_usec",  # Freeze
	# MEMORY LEAK
	"init",  # Quite specific function, which probably needs to be instanced only once
	"space_create",
	"get_white_texture",
	"get_test_texture",
	"body_create",
	"scenario_create",
	"canvas_occluder_polygon_create",
	"area_create",
	"viewport_create",
	"sky_create",
	"capsule_shape_create",
	"convex_polygon_shape_create",
	"segment_shape_create",
	"add_bus",
	"canvas_light_create",
	"shape_create",
	"circle_shape_create",
	"ray_shape_create",
	"rectangle_shape_create",
	"reflection_probe_create",
	"immediate_create",
	"region_create",
	"mesh_create",
	"canvas_light_occluder_create",
	"skeleton_create",
	"canvas_create",
	"gi_probe_create",
	"lightmap_capture_create",
	"camera_create",
	"omni_light_create",
	"spot_light_create",
	"texture_create",
	"map_create",
	"material_create",
	"agent_create",
	"multimesh_create",
	"shader_create",
	"particles_create",
	"canvas_item_create",
	"environment_create",
	"instance_create",
	"concave_polygon_shape_create",
	"directional_light_create",
	"instance_create2",
	"line_shape_create",
	# GODOT 4
	# CRASHES
	"bake_render_uv2", # 67067
	"create_sub_window", # 67030
	"cursor_set_custom_image",  #66605
	"create_local_rendering_device",  #  #66372
	"texture_replace",  # 66373
	"texture_2d_update",  # 66374
	"canvas_texture_set_shading_parameters",  #66375
	"canvas_texture_set_texture_filter",  #66375
	"canvas_texture_set_texture_repeat",  #66375
	"canvas_texture_set_channel",  #66375
	"register_script_language", # 67065
	# LEAK
	"texture_2d_create", 
	"link_create",
	"joint_create",
	"separation_ray_shape_create",
	"sphere_shape_create",
	"world_boundary_shape_create",
	"cylinder_shape_create",
	"box_shape_create",
	"heightmap_shape_create",
	"generate_bus_layout",
	"add_task",  # Thread Woker leak
	"add_group_task",  # Thread Woker leak
	"load_threaded_request",  # Leak
	"texture_2d_layered_create",  # RID Leak
	"texture_3d_create",  # RID Leak
	"texture_proxy_create",  # RID leak
	"texture_2d_placeholder_create",  # RID Leak
	"texture_3d_placeholder_create",  # RID Leak
	"texture_2d_layered_placeholder_create",  # RID Leak
	"mesh_create_from_surfaces",  # RID Leak
	"decal_create",  # RID Leak
	"voxel_gi_create",  # RID Leak
	"lightmap_create",  # RID Leak
	"particles_collision_create",  # RID Leak
	"fog_volume_create",  # RID Leak
	"visibility_notifier_create",  # RID Leak
	"occluder_create",  # RID Leak
	"camera_attributes_create",  # RID Leak
	"canvas_texture_create",  # RID Leak
	#Other
	"set_primary_interface",# crash, but probably expected
	"read_string_from_stdin", # Freeze
	"warp_mouse",  # Warping
	"create_process",
	"create_instance",
	"free_rid",  # Just no, may free valid rid
	"set_restart_on_exit",
]


func _ready():
	# Classes that exists also as objects so they can't be used in this tool and must be manually created if needed
	# GODOT4 change
	var list_of_singletons = Array(Engine.get_singleton_list())
	list_of_singletons.sort()
	list_of_singletons.erase("Geometry2D")  # Already tested and contains a lot of bugs
	list_of_singletons.erase("Geometry3D")  # Already tested and contains a lot of bugs
	list_of_singletons.erase("Engine")  # Only test this manually
	list_of_singletons.erase("ProjectSettings")  # Mess project.godot
#	list_of_singletons = list_of_singletons.slice(20,25) # TODO
#	list_of_singletons = ["Engine"]
	print(list_of_singletons)

	var file_handler = FileAccess.open("SingletonTesting.gd", FileAccess.WRITE)
	assert(file_handler.is_open())

	file_handler.store_string(
		"""extends Node
		
var file_handler: FileAccess

func save_and_print(message: String):
	file_handler.store_string("\\t" + message + "\\n")
	file_handler.flush()
	print("\\t" + message)

var argument_index = 0
func get_next_argument_index():
	argument_index += 1
	return argument_index

func _process(_delta) -> void:
	ValueCreator.number = [1,10,100,1000,10000,100000,100000][randi() % 7]
	file_handler = FileAccess.open("results.txt", FileAccess.WRITE)
	file_handler.store_string("\\n\\n\\n\\n\\n############# NEW RUN \\n\\n\\n\\n\\n")
	for _i in range(5):
		f_GDScript()
"""
	)

	for name_of_class in list_of_singletons:
		if !ClassDB.class_exists(name_of_class) && !ClassDB.class_exists("_" + name_of_class):
			print("Class " + name_of_class + " not exists!!!!!!!!!")
			assert(false)
		file_handler.store_string("\t\tf_" + name_of_class + "()\n")
	file_handler.store_string("\t\tfor i in range(5):\n")
	file_handler.store_string("\t\t\tsave_and_print('')")
	file_handler.store_string("\n")

	var argument_number: int = 0
	for name_of_class in list_of_singletons:
		var functions_info
		if ClassDB.class_exists(name_of_class):
			functions_info = ClassDB.class_get_method_list(name_of_class, true)
		else:
			functions_info = ClassDB.class_get_method_list("_" + name_of_class, true)

#		print("----------------------------- " + name_of_class)
		file_handler.store_string("func f_" + name_of_class + "() -> void:\n")
		for function_data in functions_info:
			if function_data.name in allowed_functions:
				pass
			else:
				if allowed_functions.is_empty():
					if function_data.name in excluded_functions:
						continue
				else:
					continue

			var arguments: Array = ParseArgumentType.parse_and_return_functions_to_create_object(function_data, name_of_class, false)

			var creation_of_arguments: String = ""
			var variable_names: Array = []
			var deleting_arguments: String = ""

			creation_of_arguments += "\tif randi() % 3 == 0:\n"
			for argument in arguments:
				argument_number += 1
				var variable_name = "temp_variable" + str(argument_number)
				creation_of_arguments += "\t\tvar " + variable_name + " = " + argument + "\n"
				creation_of_arguments += "\t\tvar ARG_" + variable_name + " = \"temp_variable\" + str(get_next_argument_index())\n"
				creation_of_arguments += '\t\tsave_and_print("var " + ARG_' + variable_name + ' + " = " + ParseArgumentType.return_gdscript_code_which_run_this_object(' + variable_name + "))\n"

				variable_names.append(variable_name)

				if argument.find("get_object") != -1:
					deleting_arguments += "\t\tHelpFunctions.remove_thing(" + variable_name + ")\n"
					deleting_arguments += "\t\tsave_and_print(ARG_" + variable_name + "+ HelpFunctions.remove_thing_string(" + variable_name + "))\n"

			file_handler.store_string(creation_of_arguments)

			var to_execute = name_of_class + "." + function_data.name + "("
			var to_execute_str = to_execute + "' + "
			for name_index in variable_names.size():
				to_execute += variable_names[name_index]
				to_execute_str += "ARG_" + variable_names[name_index]
				if name_index + 1 != variable_names.size():
					to_execute += ","
					to_execute_str += "+ ',' + "
			if variable_names.size() > 0:
				to_execute_str += " + "
			to_execute += ")"
			to_execute_str += "')"
			file_handler.store_string("\t\tsave_and_print('" + to_execute_str + "')\n")
			file_handler.store_string("\t\t" + to_execute + "\n")

			file_handler.store_string(deleting_arguments + "\n")

		file_handler.store_string("\tpass\n\n")

	file_handler.store_string(manual_functions)

	get_tree().quit()

var manual_functions: String = """
	
func f_GDScript() -> void:
	return;
"""
var manual_functions2: String = """

func f_GDScript() -> void:
	return;
	print("Color8")
	Color8(ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int())
	
	print("abs")
	abs(ValueCreator.get_float())
	print("absf")
	absf(ValueCreator.get_float())
	print("absi")
	absi(ValueCreator.get_float())
	print("acos")
	acos(ValueCreator.get_float())
	print("asin")
	asin(ValueCreator.get_float())
	print("atan")
	atan(ValueCreator.get_float())
	print("atan2")
	atan2(ValueCreator.get_float(),ValueCreator.get_float())
	
	print("bezier_interpolate")
	bezier_interpolate(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
#	print("bytes_to_var")
#	bytes_to_var(ValueCreator.get_packed_byte_array()) # Editor error
#	print("bytes_to_var_with_objects")
#	bytes_to_var_with_objects(ValueCreator.get_packed_byte_array()) # Editor error

	print("ceil")
	ceil(ValueCreator.get_float())
	print("ceilf")
	ceilf(ValueCreator.get_float())
	print("ceili")
	ceili(ValueCreator.get_float())
	
	print("clamp")
	clamp(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("clampf")
	clampf(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("clampi")
	clampi(ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int())
	
	print("cos")
	cos(ValueCreator.get_float())
	print("cosh")
	cosh(ValueCreator.get_float())
	
	print("cubic_interpolate")
	cubic_interpolate(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("cubic_interpolate_angle")
	cubic_interpolate_angle(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("cubic_interpolate_angle_in_time")
	cubic_interpolate_angle_in_time(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("cubic_interpolate_in_time")
	cubic_interpolate_in_time(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
	
	print("db_to_linear")
	db_to_linear(ValueCreator.get_float())
	print("deg_to_rad")
	deg_to_rad(ValueCreator.get_float())
#	print("dict_to_inst")
#	dict_to_inst(ValueCreator.get_dictionary()) # Editor error
	print("ease")
	ease(ValueCreator.get_float(),ValueCreator.get_float())
	print("error_string")
	error_string(ValueCreator.get_int())
	print("exp")
	exp(ValueCreator.get_float())
	
	print("floor")
	floor(ValueCreator.get_float())
	print("floorf")
	floorf(ValueCreator.get_float())
	print("floori")
	floori(ValueCreator.get_int())
	
	print("fmod")
	fmod(ValueCreator.get_float(),ValueCreator.get_float())
	print("fposmod")
	fposmod(ValueCreator.get_float(),ValueCreator.get_float())
	print("get_stack")
	get_stack()

# TODO uses variable which not use valid name notation(name should be unique in different runs)
#	var obj3 = ValueCreator.get_object("Node")
#	print("hash")
#	hash(obj3)
#	HelpFunctions.remove_thing(obj3)
	
#	print("inst_to_dict")
#	inst_to_dict(ValueCreator.get_object("Node")) # Editor error
	print("instance_from_id")
	instance_from_id(ValueCreator.get_int())
	print("inverse_lerp")
	inverse_lerp(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
	print("is_equal_approx")
	is_equal_approx(ValueCreator.get_float(),ValueCreator.get_float())
	print("is_inf")
	is_inf(ValueCreator.get_float())
	print("is_instance_id_valid")
	is_instance_valid(ValueCreator.get_int())
	print("is_instance_valid")
	is_instance_valid(self)
	print("is_nan")
	is_nan(ValueCreator.get_float())
	print("is_zero_approx")
	is_zero_approx(ValueCreator.get_float())
	
	print("lerp")
	lerp(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("lerp_angle")
	lerp_angle(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("lerpf")
	lerpf(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
	print("linear_to_db")
	linear_to_db(ValueCreator.get_float())
	print("log")
	log(ValueCreator.get_float())
	
	print("max")
	max(ValueCreator.get_float(),ValueCreator.get_float())
	print("maxf")
	maxf(ValueCreator.get_float(),ValueCreator.get_float())
	print("maxi")
	maxi(ValueCreator.get_int(),ValueCreator.get_int())
	
	print("min")
	min(ValueCreator.get_float(),ValueCreator.get_float())
	print("minf")
	minf(ValueCreator.get_float(),ValueCreator.get_float())
	print("mini")
	mini(ValueCreator.get_int(),ValueCreator.get_int())
	
	print("move_toward")
	move_toward(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("nearest_po2")
	nearest_po2(ValueCreator.get_int())
#	print("posmod") # 43932
#	posmod(ValueCreator.get_int(),ValueCreator.get_int())
	print("pow")
	pow(ValueCreator.get_float(),ValueCreator.get_float())
	
	# Print spam
	if false:
		print("print")
		print(ValueCreator.get_string())
		print("print_rich")
		print_rich(ValueCreator.get_string())
		print("print_verbose")
		print_verbose(ValueCreator.get_string())
		print("printerr")
		printerr(ValueCreator.get_string())
		print("printraw")
		printraw(ValueCreator.get_string())
		print("prints")
		prints(ValueCreator.get_string())
		print("printt")
		
		printt(ValueCreator.get_string())
		print("push_error")
		push_error(ValueCreator.get_string())
		print("push_warning")
		push_warning(ValueCreator.get_string())
		
	print("rad_to_deg")
	rad_to_deg(ValueCreator.get_float())
			
	print("rand_from_seed")
	rand_from_seed(ValueCreator.get_int())

	print("randf")
	randf()
	print("randf_range")
	randf_range(ValueCreator.get_float(),ValueCreator.get_float())
	print("randfn")
	randfn(ValueCreator.get_float(),ValueCreator.get_float())
	print("randi")
	randi()
	print("randi_range")
	randi_range(ValueCreator.get_int(),ValueCreator.get_int())
	print("randomize")
	randomize()
	
#	print("remap") # TODO strange bug
#	range(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())

	
	print("rid_allocate_id")
	rid_allocate_id()
	print("rid_from_int64")
	rid_from_int64(ValueCreator.get_int())
	
	print("round")
	round(ValueCreator.get_float())
	print("roundf")
	roundf(ValueCreator.get_float())
	print("roundi")
	roundi(ValueCreator.get_int())
	
	print("seed")
	seed(ValueCreator.get_int())
	
	print("sign")
	sign(ValueCreator.get_float())
	print("signf")
	signf(ValueCreator.get_float())
	print("signi")
	signi(ValueCreator.get_int())
	
	print("sin")
	sin(ValueCreator.get_float())
	print("sinh")
	sinh(ValueCreator.get_float())
	
	print("smoothstep")
	smoothstep(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("snapped")
	snapped(ValueCreator.get_float(),ValueCreator.get_float())
	print("sqrt")
	sqrt(ValueCreator.get_float())
	print("step_decimals")
	step_decimals(ValueCreator.get_float())
	
	print("str")
	str(ValueCreator.get_string())
	print("str_to_var")
	str_to_var(ValueCreator.get_string())
	
	print("tan")
	tan(ValueCreator.get_float())
	print("tanh")
	tanh(ValueCreator.get_float())
	
	print("typeof")
	typeof(ValueCreator.get_string())
	
	print("var_to_bytes")
	var_to_bytes(ValueCreator.get_int())
	print("var_to_bytes_with_objects")
	var_to_bytes_with_objects(ValueCreator.get_int())
	print("var_to_str")
	var_to_str(ValueCreator.get_string())
	
	print("weakref")
	weakref(get_parent())
	
	print("wrap")
	wrap(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("wrapf")
	wrapf(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("wrapi")
	wrapi(ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int())
	
	# Normal GDScript, Above are globals
	print("Color8")
	Color8(ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int())
	print("assert")
	assert(true) # TODO must be constant, ValueCreator.get_string())
	print("char")
	char(ValueCreator.get_int())	
#	print("convert")
#	convert(null,randi() % TYPE_MAX) # Editor error
#	print("dist_to_inst")
#	dist_to_inst(ValueCreator.get_dictionary())
	print("get_stack")
	get_stack()
	print("inst_to_dict")
	inst_to_dict(ValueCreator.get_object("RefCounted"))
	print("len")
	len(ValueCreator.get_string())
	#print("load")
	#load(ValueCreator.get_string())
	#print("preload")
	#preload(ValueCreator.get_string())
	#print("print_debug")
	#print_debug(ValueCreator.get_string())
	#print("print_stack")
	#print_stack()
	print("range")
	range(ValueCreator.get_int())
	print("str")
	str(ValueCreator.get_string())
	print("type_exists")
	type_exists(ValueCreator.get_string())
"""
