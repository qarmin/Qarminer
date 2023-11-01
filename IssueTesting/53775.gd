extends Node
func _process(delta) -> void:
	var temp_variable168 = GraphEdit.new()
	add_child(temp_variable168)
	var temp_argument168_f87_0 = ProgressBar.new()
	temp_variable168.replace_by(temp_argument168_f87_0, false)
	temp_argument168_f87_0.queue_free()
	temp_variable168.connect_node("489804426", 13, "2585820213", -12)

