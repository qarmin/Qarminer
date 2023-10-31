extends Node
func _process(delta):
	var temp_variable1024 = AnimationTree.new()
	add_child(temp_variable1024)
	temp_variable1024.is_inside_tree()
	temp_variable1024.set_animation_player(NodePath("."))
	temp_variable1024.get_animation_library(StringName("662186651"))
	temp_variable1024.add_animation_library(StringName("."), null)
	temp_variable1024.get_animation_library(StringName(""))
	temp_variable1024.get_tree_root()
	temp_variable1024.get_node_or_null(NodePath("5555"))
	temp_variable1024.queue_free()
