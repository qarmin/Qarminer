extends Node

var files_to_load: Array = []


func _ready():
	load_from_file()


#	load_resources()


# Loading resources from test_resources folder
func load_resources():
	var resources = []
	for i in ["res://test_resources"]:
		var dir = DirAccess.open(i)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				resources.append(file_name)
			file_name = dir.get_next()

	var ff = FontFile.new()
	for i in resources:
		var file_name = "res://test_resources/" + i
		print("----- " + file_name)
		var rr = load(file_name)

		# Loading fonts
		if rr is Node:
			rr.queue_free()
		elif rr != null and rr is Object and not (rr is RefCounted):
			rr.free()


#		ff.load_bitmap_font(file_name)
#		Image.load_from_file(file_name)


# Loading normal resources
func load_from_file():
	var file_handler = FileAccess.open("/home/rafal/Projekty/Rust/Rozne/images.txt", FileAccess.READ)
	var results = FileAccess.open("res://results.txt", FileAccess.WRITE)
	files_to_load = file_handler.get_as_text().split("\n")

	var line_index: int = 0
	var all_lines: int = files_to_load.size()

	print("Loading " + str(files_to_load.size()) + " images")

	print(load("/home/rafal/Desktop/gltf.gltf"))

	var ff = FontFile.new()
#	for i in files_to_load:
#		line_index += 1
#		print("Loading line " + str(line_index) + "/" + str(all_lines) + " --- " + i)
#		results.store_string(i)

#		# Image
#		Image.load_from_file(i)
#
#		# Normal loading
#		load(i)
#
#		# Font loading
#		ff.load_bitmap_font(i)
#
#		# GLTF loading scene files
#		var sc = load(i)
#		if sc != null:
#			var s = sc.instantiate()
#
	print("==================================================== ENDING =======================================")
	get_tree().quit()
