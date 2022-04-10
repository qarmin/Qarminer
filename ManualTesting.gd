extends Node2D

var counter = 0

#func _ready():
#	ValueCreator.random = true
#	ValueCreator.number = 10

func _process(_delta):
	f_GDSCRIPT()
	
func f_GDSCRIPT() -> void:
	counter += 1
	print("START" + str(counter))
	
	Color8(ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int())
	ColorN(ValueCreator.get_string(),ValueCreator.get_float())
	
	abs(ValueCreator.get_float())
	acos(ValueCreator.get_float())
	asin(ValueCreator.get_float())
	assert(true)
	
	atan(ValueCreator.get_float())
	atan2(ValueCreator.get_float(),ValueCreator.get_float())
	
#	bytes2var(ValueCreator.get_poolbytearray(),ValueCreator.get_bool()) # Editor error
	cartesian2polar(ValueCreator.get_float(),ValueCreator.get_float())
	ceil(ValueCreator.get_float())
	char(ValueCreator.get_int())
	clamp(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
#	convert(null,randi() % TYPE_MAX) # Editor error

	cos(ValueCreator.get_float())
	cosh(ValueCreator.get_float())
	
	db2linear(ValueCreator.get_float())
	
	decimals(ValueCreator.get_float())
	dectime(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
	var obj1 = ValueCreator.get_object("Node")
	var obj2 = ValueCreator.get_object("Node")
	deep_equal(obj1,obj2)
	HelpFunctions.remove_thing(obj1)
	HelpFunctions.remove_thing(obj2)
	
	deg2rad(ValueCreator.get_float())
#	dict2inst(ValueCreator.get_dictionary()) # Editor error
	ease(ValueCreator.get_float(),ValueCreator.get_float())
	exp(ValueCreator.get_float())
	floor(ValueCreator.get_float())
	fmod(ValueCreator.get_float(),ValueCreator.get_float())
	fposmod(ValueCreator.get_float(),ValueCreator.get_float())
	funcref(self,ValueCreator.get_string())
	get_stack()
	
	var obj3 = ValueCreator.get_object("Node")
	hash(obj3)
	HelpFunctions.remove_thing(obj3)
	
#	inst2dict(ValueCreator.get_object("Node")) # Editor error
	instance_from_id(ValueCreator.get_int())
	
	inverse_lerp(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
	is_equal_approx(ValueCreator.get_float(),ValueCreator.get_float())
	is_inf(ValueCreator.get_float())
	is_instance_valid(self)
	is_nan(ValueCreator.get_float())
	is_zero_approx(ValueCreator.get_float())
	
	len(ValueCreator.get_string())
	
	lerp(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	lerp_angle(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
	linear2db(ValueCreator.get_float())
	load(ValueCreator.get_string())
	log(ValueCreator.get_float())
	max(ValueCreator.get_float(),ValueCreator.get_float())
	min(ValueCreator.get_float(),ValueCreator.get_float())
	move_toward(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	nearest_po2(ValueCreator.get_int())
	parse_json(ValueCreator.get_string())
	polar2cartesian(ValueCreator.get_float(),ValueCreator.get_float())
	posmod(ValueCreator.get_int(),ValueCreator.get_int())
	pow(ValueCreator.get_float(),ValueCreator.get_float())
#	preload(ValueCreator.get_string()) # Constant expected
	
	# Print spam
	if false:
		print(ValueCreator.get_string())
		print_debug(ValueCreator.get_string())
		print_stack()
		printerr(ValueCreator.get_string())
		printraw(ValueCreator.get_string())
		prints(ValueCreator.get_string())
		printt(ValueCreator.get_string())
		push_error(ValueCreator.get_string())
		push_warning(ValueCreator.get_string())
		
	rad2deg(ValueCreator.get_float())
	
	rand_range(ValueCreator.get_int(),ValueCreator.get_int())
	rand_seed(ValueCreator.get_int())
	randf()
	randi()
	randomize()
	range(ValueCreator.get_int(),ValueCreator.get_int(),max(ValueCreator.get_int(),1))
	range_lerp(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	
	round(ValueCreator.get_float())
	seed(ValueCreator.get_int())
	sign(ValueCreator.get_float())
	
	sin(ValueCreator.get_float())
	sinh(ValueCreator.get_float())
	
	smoothstep(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	sqrt(ValueCreator.get_float())
	
	step_decimals(ValueCreator.get_float())
	stepify(ValueCreator.get_float(),ValueCreator.get_float())
	
	str(ValueCreator.get_string())
	str2var(ValueCreator.get_string())
	
	tan(ValueCreator.get_float())
	tanh(ValueCreator.get_float())
	
	to_json(ValueCreator.get_string())
	
	type_exists(ValueCreator.get_string())
	typeof(ValueCreator.get_string())
	
	validate_json(ValueCreator.get_string())
	
	var2bytes(ValueCreator.get_bool())
	var2str(ValueCreator.get_string())
	
	weakref(get_parent())
	
	wrapf(ValueCreator.get_float(),ValueCreator.get_float(),ValueCreator.get_float())
	wrapi(ValueCreator.get_int(),ValueCreator.get_int(),ValueCreator.get_int())
	
#	yield(self,ValueCreator.get_string()) # 
	
	print("END" + str(counter))
