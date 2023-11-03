extends Node
func _process(delta):
	var temp_variable60676 = AudioStreamPlayer.new()
	add_child(temp_variable60676)
	temp_variable60676.set_stream(AudioStreamMicrophone.new())
	temp_variable60676.seek(-76.8111363053322)
	temp_variable60676.play(-26.7877578735352)
	temp_variable60676.set_bus(StringName(""))
	temp_variable60676.queue_free()