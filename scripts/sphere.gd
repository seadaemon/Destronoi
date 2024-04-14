extends RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var my_mesh : Mesh = get_node("MeshInstance3D").mesh
	var vol = my_mesh.get_aabb().get_volume()
	if vol != 0:
		mass = 3.0 * vol
	#print(mass)
	#var mdt := MeshDataTool.new()
	#mdt.create_from_surface(my_mesh, 0)
	#print(mdt.get_face_count()) 
	#print(mass)
