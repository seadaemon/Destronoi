extends Node3D

var destroy_button: Button
var base_object: RigidBody3D
var weak_ref;
# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_debug_generate_wireframes(true)
	
	destroy_button = get_node("UI/HBoxContainer/Button")
	destroy_button.connect("button_up", on_destroy_button_up)

	var demo_objects = [get_node("Cube"), get_node("Sphere")]
	#base_object = get_node("Cube")
	base_object = demo_objects[1]
	weak_ref = weakref(base_object)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("toggle_debug_draw")):
		if(get_viewport().debug_draw == Viewport.DEBUG_DRAW_WIREFRAME):
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
		else:
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME

	if(Input.is_action_just_pressed("ui_up")):
		get_tree().reload_current_scene()

func get_leaf_nodes(root: VSTNode = null, out_arr: Array = []):
	if(root == null):
		return [];
	if(root._left == null && root._right == null):
		out_arr.append(root)
		return [root]
	if(root._left != null):
		get_leaf_nodes(root._left, out_arr)
	if(root._right != null):
		get_leaf_nodes(root._right, out_arr)
	return []
	

func on_destroy_button_up():
	#await get_tree().reload_current_scene()
	if(!weak_ref.get_ref()):
		return
	var destronoi: Destronoi = base_object.get_node("Destronoi")
	var vst_root: VSTNode = destronoi._root
	
	var vst_leaves := []
	var valid = true
	var current_node: VSTNode = vst_root
	get_leaf_nodes(current_node, vst_leaves)
	
	# Create rigid bodies for the fragments
	var new_rigid_bodies := []
	for vst_leaf in range(vst_leaves.size()):
		var new_body: RigidBody3D = RigidBody3D.new()
		new_body.name = "VFragment_{id}".format({"id": vst_leaf})
		
		#print(base_object.position)
		new_body.position = base_object.position
		
		new_body.set_axis_velocity(Vector3(randf_range(-3,3),randf_range(4,7),randf_range(-3,3)))
		
		
		var new_mesh_instance = vst_leaves[vst_leaf]._mesh_instance
		new_mesh_instance.name = "MeshInstance3D"
		new_body.add_child(new_mesh_instance)
		#print(new_body.center_of_mass)
		
		# Create collision geometry
		var new_body_mesh_instance : MeshInstance3D = new_body.get_child(0)
		var new_collision_shape: CollisionShape3D = CollisionShape3D.new()
		new_collision_shape.name = "CollisionShape3D"
		var new_mesh : Mesh = new_body_mesh_instance.mesh
		
		# TRIMESH IS CONCAVE | CONCAVE COLLISION SHAPES DO NOT DETECT EACHOTHER
		
		#new_collision_shape.shape = new_body_mesh_instance.mesh.create_trimesh_shape()
		#new_body_mesh_instance.mesh.get_aabb().get_center()
		#new_body.set_axis_velocity(Vector3(randf_range(-3,3),randf_range(4,7),randf_range(-3,3)))
		new_body.set_axis_velocity(new_body_mesh_instance.mesh.get_aabb().end - base_object.global_position)
		new_collision_shape.shape = new_body_mesh_instance.mesh.create_convex_shape(false,false)
		new_body.add_child(new_collision_shape)
		#var colsh = new_body.get_node("CollisionShape3D")
		#colsh.make_convex_from_siblings()
		
		new_rigid_bodies.append(new_body)
	
	#add_child(left_fragment)
	#add_child(right_fragment)
	#add_child(new_rigid_bodies[3])
	for body in new_rigid_bodies:
		add_child(body)
	
	#await get_tree().create_timer(1).timeout
	#print(base_object.global_position)
	#print(get_node("VFragment_1/CollisionShape3D").global_position)
	#var child_nodes = get_children()
	#print(child_nodes)
	
	#print(vst_root._sites)
	base_object.free()
	
