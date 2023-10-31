extends Node
func _process(delta):
	print("AAAAA")
	
	var temp_variable377464 = Camera3D.new()
	add_child(temp_variable377464)

	var temp_variable377558 = GPUParticlesCollisionHeightField3D.new()
	add_child(temp_variable377558)
	temp_variable377558.set_basis(Basis(Vector3(0.27226126194, -0.77507317066193, -0.57020646333694), Vector3(-0.58526027202606, -0.62486499547958, 0.51673418283463), Vector3(81.6701049804688, -90.2818756103516, 68.8228759765625)))
	temp_variable377558.set_follow_camera_enabled(true)
