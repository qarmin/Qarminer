extends Node2D

var dictionary : Dictionary = {
	"Array" : [
		{"name" : "append", "args" : [TYPE_NIL], "flags" :METHOD_FLAGS_DEFAULT}
	]
	
	
	
	
}

func _ready() -> void:
	for i in dictionary:
		print(i)
	pass 
