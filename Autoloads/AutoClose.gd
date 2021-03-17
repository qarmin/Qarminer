extends Node

var close_order: bool = false
var duration_time: float = 10

var start_time: int
var end_time: int


func _ready() -> void:
	# TODO Parse arguments

	start_time = 0  # TODO ADD THIS
	end_time = start_time + duration_time
	pass
