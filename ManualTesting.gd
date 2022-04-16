extends Node2D

var counter = 0

var allowed_functions: Array = []

var excluded_functions: Array = [
	# Crashes
	"set_custom_mouse_cursor",  #60112
	"area_get_space",  #60113
	"mesh_surface_get_format_offset",  #60114
	"mesh_surface_get_format_stride",  #60114
	# OTHER
	"make_sphere_mesh",  # Slow
	"free",  # Not enabled
	"warp_mouse_position",  # Warping
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
]


func _ready():
	# Classes that exists also as objects so they can't be used in this tool and must be manually created if needed
	# GDScript, ResourceLoader, ResourceSaver
	var list_of_singletons = [
		"Performance",
		"IP",
		"ProjectSettings",
		"Geometry",
		"OS",
		"Engine",
		"ClassDB",
		"Marshalls",
		"TranslationServer",
		"Input",
		"InputMap",
		"JSON",
		"Time",
		"JavaClassWrapper",
		"JavaScript",
		"NavigationMeshGenerator",
		"VisualScriptEditor",
		"VisualServer",
		"AudioServer",
		"PhysicsServer",
		"Physics2DServer",
		"NavigationServer",
		"Navigation2DServer",
		"ARVRServer",
		"CameraServer"
	]
	list_of_singletons.sort()

	var file_handler = File.new()
	var ret = file_handler.open("SingletonTesting.gd", File.WRITE)
	assert(ret == OK)

	file_handler.store_string(
		"""extends Node
func _ready() -> void:
	ValueCreator.number = [1,10,100,1000,10000,100000,100000][randi() % 7]

func _process(_delta) -> void:
	f_GDScript()
"""
	)

	for name_of_class in list_of_singletons:
		if !ClassDB.class_exists(name_of_class) && !ClassDB.class_exists("_" + name_of_class):
			print("Class " + name_of_class + " not exists!!!!!!!!!")
			assert(false)
		file_handler.store_string("\tf_" + name_of_class + "()\n")
	file_handler.store_string("\n")

	for name_of_class in list_of_singletons:
		var argument_number: int = 0

		var functions_info = ClassDB.class_get_method_list(name_of_class, true)

#		print("----------------------------- " + name_of_class)
		file_handler.store_string("func f_" + name_of_class + "() -> void:\n")
		for function_data in functions_info:
			if function_data.name in allowed_functions:
				pass
			else:
				if allowed_functions.empty():
					if function_data.name in excluded_functions:
						continue
				else:
					continue

			var arguments: Array = ParseArgumentType.parse_and_return_functions_to_create_object(function_data, name_of_class, false)

			var creation_of_arguments: String = ""
			var variable_names: Array = []
			var deleting_arguments: String = ""
			for argument in arguments:
				argument_number += 1
				var variable_name = "temp_variable" + str(argument_number)
				creation_of_arguments += "\tvar " + variable_name + " = " + argument + "\n"
				creation_of_arguments += '\tprint("var ' + variable_name + ' = " + ParseArgumentType.return_gdscript_code_which_run_this_object(' + variable_name + "))\n"

				variable_names.append(variable_name)

				if argument.find("get_object") != -1:
					deleting_arguments += "\tHelpFunctions.remove_thing(" + variable_name + ")\n"
					deleting_arguments += "\tprint('" + variable_name + "'+ HelpFunctions.remove_thing_string(" + variable_name + "))\n"

			file_handler.store_string(creation_of_arguments)

			var to_execute = name_of_class + "." + function_data.name + "("
			for name_index in variable_names.size():
				to_execute += variable_names[name_index]
				if name_index + 1 != variable_names.size():
					to_execute += ","
			to_execute += ")"
			file_handler.store_string("\tprint('" + to_execute + "')\n")
			file_handler.store_string("\t" + to_execute + "\n")

			file_handler.store_string(deleting_arguments + "\n")

		file_handler.store_string("\tpass\n\n")

	file_handler.store_string(manual_functions)

	get_tree().quit()


var manual_functions: String = """
func f_GDScript() -> void:	
	print("Color8")
	Color8(ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int())
	print("ColorN")
	ColorN(ValueCreator.get_string(),ValueCreator.get_float())
	
	print("abs")
	abs(ValueCreator.get_float())
	print("acos")
	acos(ValueCreator.get_float())
	print("asin")
	asin(ValueCreator.get_float())
	print("assert")
	assert(true)
	
	print("atan")
	atan(ValueCreator.get_float())
	print("atan2")
	atan2(ValueCreator.get_float(),ValueCreator.get_float())
	
#	print("bytes2var")
#	bytes2var(ValueCreator.get_poolbytearray(),ValueCreator.get_bool()) # Editor error
	print("cartesian2polar")
	cartesian2polar(ValueCreator.get_float(),ValueCreator.get_float())
	print("ceil")
	ceil(ValueCreator.get_float())
	print("char")
	char(ValueCreator.get_int())
	print("clamp")
	clamp(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
#	print("convert")
#	convert(null,randi() % TYPE_MAX) # Editor error

	print("cos")
	cos(ValueCreator.get_float())
	print("cosh")
	cosh(ValueCreator.get_float())
	
	print("db2linear")
	db2linear(ValueCreator.get_float())
	
	print("decimals")
	decimals(ValueCreator.get_float())
	print("dectime")
	dectime(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
	var obj1 = ValueCreator.get_object("Node")
	var obj2 = ValueCreator.get_object("Node")
	print("deep_equal")
	deep_equal(obj1,obj2)
	HelpFunctions.remove_thing(obj1)
	HelpFunctions.remove_thing(obj2)
	
	print("deg2rad")
	deg2rad(ValueCreator.get_float())
#	print("dict2inst")
#	dict2inst(ValueCreator.get_dictionary()) # Editor error
	print("ease")
	ease(ValueCreator.get_float(),ValueCreator.get_float())
	print("exp")
	exp(ValueCreator.get_float())
	print("floor")
	floor(ValueCreator.get_float())
	print("fmod")
	fmod(ValueCreator.get_float(),ValueCreator.get_float())
	print("fposmod")
	fposmod(ValueCreator.get_float(),ValueCreator.get_float())
	print("funcref")
	funcref(self,ValueCreator.get_string())
	print("get_stack")
	get_stack()
	
	var obj3 = ValueCreator.get_object("Node")
	print("hash")
	hash(obj3)
	HelpFunctions.remove_thing(obj3)
	
#	print("inst2dict")
#	inst2dict(ValueCreator.get_object("Node")) # Editor error
	print("instance_from_id")
	instance_from_id(ValueCreator.get_int())
	
	print("inverse_lerp")
	inverse_lerp(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
	print("is_equal_approx")
	is_equal_approx(ValueCreator.get_float(),ValueCreator.get_float())
	print("is_inf")
	is_inf(ValueCreator.get_float())
	print("is_instance_valid")
	is_instance_valid(self)
	print("is_nan")
	is_nan(ValueCreator.get_float())
	print("is_zero_approx")
	is_zero_approx(ValueCreator.get_float())
	
	print("len")
	len(ValueCreator.get_string())
	
	print("lerp")
	lerp(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("lerp_angle")
	lerp_angle(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
	print("linear2db")
	linear2db(ValueCreator.get_float())
	print("load")
	load(ValueCreator.get_string())
	print("log")
	log(ValueCreator.get_float())
	print("max")
	max(ValueCreator.get_float(),ValueCreator.get_float())
	print("min")
	min(ValueCreator.get_float(),ValueCreator.get_float())
	print("move_toward")
	move_toward(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("nearest_po2")
	nearest_po2(ValueCreator.get_int())
	print("parse_json")
	parse_json(ValueCreator.get_string())
	print("polar2cartesian")
	polar2cartesian(ValueCreator.get_float(),ValueCreator.get_float())
#	print("posmod") # 43932
#	posmod(ValueCreator.get_int(),ValueCreator.get_int())
	print("pow")
	pow(ValueCreator.get_float(),ValueCreator.get_float())
#	print("preload")
#	preload(ValueCreator.get_string()) # Constant expected
	
	# Print spam
	print("if")
	if false:
		print("print")
		print(ValueCreator.get_string())
		print("print_debug")
		print_debug(ValueCreator.get_string())
		print("print_stack")
		print_stack()
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
		
	print("rad2deg")
	rad2deg(ValueCreator.get_float())
	
	print("rand_range")
	rand_range(ValueCreator.get_int(),ValueCreator.get_int())
	print("rand_seed")
	rand_seed(ValueCreator.get_int())
	print("randf")
	randf()
	print("randi")
	randi()
	print("randomize")
	randomize()
	print("range")
	range(ValueCreator.get_int(),ValueCreator.get_int(),max(ValueCreator.get_int(),1))
	print("range_lerp")
	range_lerp(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
	print("round")
	round(ValueCreator.get_float())
	print("seed")
	seed(ValueCreator.get_int())
	print("sign")
	sign(ValueCreator.get_float())
	
	print("sin")
	sin(ValueCreator.get_float())
	print("sinh")
	sinh(ValueCreator.get_float())
	
	print("smoothstep")
	smoothstep(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("sqrt")
	sqrt(ValueCreator.get_float())
	
	print("step_decimals")
	step_decimals(ValueCreator.get_float())
	print("stepify")
	stepify(ValueCreator.get_float(),ValueCreator.get_float())
	
	print("str")
	str(ValueCreator.get_string())
	print("str2var")
	str2var(ValueCreator.get_string())
	
	print("tan")
	tan(ValueCreator.get_float())
	print("tanh")
	tanh(ValueCreator.get_float())
	
	print("to_json")
	to_json(ValueCreator.get_string())
	
	print("type_exists")
	type_exists(ValueCreator.get_string())
	print("typeof")
	typeof(ValueCreator.get_string())
	
	print("validate_json")
	validate_json(ValueCreator.get_string())
	
	print("var2bytes")
	var2bytes(ValueCreator.get_bool())
	print("var2str")
	var2str(ValueCreator.get_string())
	
	print("weakref")
	weakref(get_parent())
	
	print("wrapf")
	wrapf(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	print("wrapi")
	wrapi(ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int())
	
#	print("yield")
#	yield(self,ValueCreator.get_string()) # 
"""