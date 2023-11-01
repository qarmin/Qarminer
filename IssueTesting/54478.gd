extends Node
func _process(delta) -> void:
	for i in range(40):
		var rr = AudioStreamPlayer.new()
		rr.notification(10, false)
		rr.queue_free()
