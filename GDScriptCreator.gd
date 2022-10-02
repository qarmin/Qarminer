extends Node

var classes: Array = []

var things: Array = ["var", "=", "func", "export", "in", "match", "pass", ",", "(", ")", "[", "]", "enum", "const", "{", "}", "yield", "await", ":", "()", "{}", "[]", "."]
var names: Array = ["Źdźbło", "Kasztan", "Krokiet", "Krokiew", "Krotka"]
var variants: Array = ["void", "Vector2", "int", "float", "String", "Array", "File", "Object"]

var file_handler: File = File.new()

var number_of_tabs: int = 5
var string_tabs: String = ""

var file_number: int = 0

var test_gdscript_in_the_fly: bool = true  # If true, project must be run outside editor
var print_gdscript: bool = true


func _ready() -> void:
	randomize()

	classes = Array(ClassDB.get_class_list())
	classes.sort()

	# Create
	var dir: Directory = Directory.new()

	for base_dir in ["res://test_gdscript/.import/", "res://test_gdscript/.godot/", "res://test_gdscript/"]:
		if dir.open(base_dir) == OK:
			var _unused = dir.list_dir_begin(true, false)
			var file_name: String = dir.get_next()
			while file_name != "":
				if file_name != ".." && file_name != ".":
					var rr: int = dir.remove(base_dir + file_name)
					assert(rr == OK)
				file_name = dir.get_next()
			var ret2: int = dir.remove(base_dir)
			assert(ret2 == OK)

	var ret: int = dir.make_dir("res://test_gdscript")
	assert(ret == OK)
	ret = File.new().open("res://test_gdscript/.gdignore", File.WRITE)
	assert(ret == OK)
	ret = File.new().open("res://test_gdscript/project.godot", File.WRITE)
	assert(ret == OK)


#func get_thing() -> String:
#	things


func tabs() -> void:
	for i in number_of_tabs:
		string_tabs += "\t"


func get_random_number():
	if randi() % 2 == 0:
		return ""


func _process(_delta: float) -> void:
	for _u in range(100):
		file_number += 1
		file_handler.open("res://test_gdscript/gdscript" + str(file_number) + ".gd", File.WRITE)

		var gdscript: GDScript = GDScript.new()
		gdscript.set_source_code('extends Objec\nfunc _process(_delta : float):\n\tprint("PRINT")')

		var source_code: String = ""

		source_code += "extends " + classes[randi() % classes.size()] + "\n"

		if randi() % 100 > 10:
			var func_name: String = ""

			func_name = "func _ready() -> void:\n\t"
			source_code += func_name

		if randi() % 10 == 0:
			for _i in range(randi() % 10):
				var ran = randi() % 100
				if ran < 90:
					source_code += things[randi() % things.size()]
				elif ran < 95:
					source_code += names[randi() % names.size()]
				else:
					source_code += variants[randi() % variants.size()]

				source_code += " "
				if randi() % 50 > 45:
					source_code += "\n"
					if randi() % 10 != 1:
						source_code += "\t"
					else:
						for _j in range(randi() % 3):
							source_code += "\t"
		# Trying to create proper GDScript
		else:
			var current_tab_number: int = 1
			var had_proper_tab: bool = true
			var must_have
			for i in range(10):
				source_code += "\n"
				for _k in range(current_tab_number):
					source_code += "\t"
					had_proper_tab = true
				for _z in range(5):
					var thing = get_thing("random", randi() % 3 + 1)
					source_code += thing
					if thing.find("if") != -1 || thing.find("match") != -1:
						current_tab_number += 1
						had_proper_tab = false
					if had_proper_tab && current_tab_number > 1:
						if randi() % 3 == 1:
							current_tab_number -= 1

		# TODO Save here results to a file
		file_handler.store_string(source_code)
		if print_gdscript && test_gdscript_in_the_fly:
			print("############# START")
			print(source_code)
			print("############# STOP")
		print("Testing GDScript" + str(file_number) + ".gd")
		if test_gdscript_in_the_fly:
			gdscript.set_source_code(source_code)
			gdscript.reload(true)


func get_thing(what: String, depth: int) -> String:
	if depth == 0:
		return ""
	if what == "random":
		if return_true(70):
			what = "random_thing"
		elif return_true(95):
			what = "random_variants"
		else:
			what = "random_names"
	if what == "random_thing":
		what = things[randi() % things.size()]
	if what == "random_names":
		return names[randi() % names.size()] + " "
	if what == "random_variants":
		return variants[randi() % names.size()] + " "
	match what:
		"{}":
			var ret: String = "{"
			for i in range(10):
				ret += get_thing("random", depth - 1)
				ret += ":"
				ret += get_thing("random", depth - 1)
				if i != 9:
					ret += ","
			ret += "}"

			return ret
		"()":
			var ret: String = "("
			for i in range(10):
				ret += get_thing("random", depth - 1)
				ret += ":"
				ret += get_thing("random", depth - 1)
				if i != 9:
					ret += ","
			ret += ") "
		"[]":
			var ret: String = "["
			for i in range(10):
				ret += get_thing("random", depth - 1)
				ret += ":"
				ret += get_thing("random", depth - 1)
				if i != 9:
					ret += ","
			ret += "] "

#	assert(false, "Invalid thing")
	return what + " "


func return_true(percentage: int) -> bool:
	return (randi() % 100) < percentage
