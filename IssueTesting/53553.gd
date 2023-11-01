extends Node
func _process(delta):
	var temp_variable1714 = AnimatedSprite.new()
	add_child(temp_variable1714)
	temp_variable1714.set_block_signals(true)
	temp_variable1714.queue_free()

	var temp_variable1715 = VisibilityEnabler2D.new()
	add_child(temp_variable1715)
	temp_variable1715.queue_free()
