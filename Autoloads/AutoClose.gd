extends Node

# Singleton to automatically close project after some amount of time
# By default closing is disabled

var close_order: bool = false

var start_time: int

var time_to_show: int = 1 * 1000  # How long test works in miliseconds


func _init():
	start_time = OS.get_ticks_msec()

	for argument in OS.get_cmdline_args():
		if argument.is_valid_float():  # Ignore all non numeric arguments
			close_order = true
			time_to_show = int(argument.to_float() * 1000)
			print("Time set to: " + str(time_to_show / 1000.0) + " seconds.")
			break  # We only need to take first argument


func _process(delta: float) -> void:
	var current_run_time: int = OS.get_ticks_msec() - start_time

	if close_order && current_run_time > time_to_show:
		print("######################## Ending test ########################")
		get_tree().quit()
