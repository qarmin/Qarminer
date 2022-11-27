extends Node

var images_to_load: Array = []


func _ready():
	var file_handler = FileAccess.open("/home/rafal/Projekty/Rust/Rozne/images.txt", FileAccess.READ)
	var results = FileAccess.open("res://results.txt", FileAccess.WRITE)
	images_to_load = file_handler.get_as_text().split("\n")

	var line_index: int = 0
	var all_lines: int = images_to_load.size()

	print("Loading " + str(images_to_load.size()) + " images")
	# Image
#	for i in images_to_load:
#		line_index += 1
#		print("Loading line " + str(line_index) +"/"+str(all_lines)+ " --- " + i)
#		Image.load_from_file(i)

	# Load normal
	#for i in images_to_load:
	#	line_index += 1
	#	print("Loading line " + str(line_index) + "/" + str(all_lines) + " --- " + i)
	#	load(i)

	# Load Fond
	var ff = FontFile.new()
	for i in images_to_load:
		line_index += 1
		print("Loading line " + str(line_index) + "/" + str(all_lines) + " --- " + i)
		results.store_string(i)
		ff.load_bitmap_font(i)
	print("==================================================== ENDING =======================================")
	get_tree().quit()
