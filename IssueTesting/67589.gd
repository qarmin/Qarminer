extends Node
func _process(delta):
	var temp_variable1 = AudioStreamPlayer.new()
	add_child(temp_variable1)
	temp_variable1.set_stream(AudioStreamWAV.new())
	temp_variable1.is_playing()
	temp_variable1._set_playing(true)
	temp_variable1.queue_free()
