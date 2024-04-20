extends Node3D
"""
Author: George Power
		<georgepower@cmail.carleton.ca>
"""
## Script for the Demo scene; to showcase and test destructible objects

var base_object: RigidBody3D # The object to be destroyed
var weak_ref; # weak reference for deleting objects 
var demo_objects = [] # objects at the start of the scene
var x = 0 # used when multiple objects are loaded
var cube = preload("res://scenes/cube.tscn")
var cube_instance = cube.instantiate()
var cylinder = preload("res://scenes/cylinder.tscn")
var cylinder_instance = cylinder.instantiate()
var sphere = preload("res://scenes/sphere.tscn")
var sphere_instance = sphere.instantiate()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	RenderingServer.set_debug_generate_wireframes(true)
	# set the destructible objects
	get_node("Destructibles").add_child(sphere_instance)
	demo_objects = get_node("Destructibles").get_children()
	base_object = demo_objects[0]
	weak_ref = weakref(base_object)
	

# handle user input
func _process(delta):
	if(Input.is_action_just_pressed("toggle_draw_wireframe")):
		if(get_viewport().debug_draw == Viewport.DEBUG_DRAW_WIREFRAME):
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
		else:
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	
	if(Input.is_action_just_pressed("toggle_draw_overdraw")):
		if(get_viewport().debug_draw == Viewport.DEBUG_DRAW_OVERDRAW):
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
		else:
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_OVERDRAW

	if(Input.is_action_pressed("pause_key")):
		get_tree().paused = false
		await get_tree().create_timer(0.05).timeout
		get_tree().paused = true
	if(Input.is_action_just_pressed("unpause_key")):
		get_tree().paused = false

	if(Input.is_action_just_pressed("destroy_key")):
		destroy()
	
	if(Input.is_action_just_pressed("reload_scene")):
		get_tree().reload_current_scene()

# creates rigid bodies for fragment geometry and swaps out the original mesh
func destroy():
	# early return if the mesh is already destroyed
	if(!weak_ref.get_ref()):
		#weak_ref = weakref(base_object)
		return
	
	var destronoi: Destronoi = base_object.get_node("Destronoi")
	var vst_root: VSTNode = destronoi._root
	
	var vst_leaves := []
	var current_node: VSTNode = vst_root
	current_node.get_right_leaf_nodes(current_node, vst_leaves)

	# Create rigid bodies for the fragments
	var new_rigid_bodies := []
	var sum_mass = 0
	for vst_leaf in range(vst_leaves.size()):
		var new_body: RigidBody3D = RigidBody3D.new()
		new_body.name = "VFragment_{id}".format({"id": vst_leaf})
		
		new_body.position = base_object.transform.origin
		
		var new_mesh_instance = vst_leaves[vst_leaf]._mesh_instance
		new_mesh_instance.name = "MeshInstance3D"
		new_body.add_child(new_mesh_instance)
		
		# Create collision geometry
		var new_body_mesh_instance : MeshInstance3D = new_body.get_child(0)
		var new_collision_shape: CollisionShape3D = CollisionShape3D.new()
		new_collision_shape.name = "CollisionShape3D"

		var velocity_dir = new_body_mesh_instance.mesh.get_aabb().get_center() - base_object.position;
		velocity_dir = velocity_dir.normalized()
		
		new_body.mass = max(new_body_mesh_instance.mesh.get_aabb().get_volume(),0.1)
		sum_mass += new_body.mass
		
		# find the vector pointing from the base object's center, to the new fragment's center
		# fragments should go outward, as if the object has combusted
		var endpoints = []
		var estim_dir = Vector3(0,0,0)
		for i in range(8):
			var current_endpoint = new_body.get_node("MeshInstance3D").mesh.get_aabb().get_endpoint(i)
			current_endpoint = current_endpoint.normalized()
			var current_dot = current_endpoint.dot(base_object.transform.origin.normalized())
			if abs(current_dot) > 0.0:
				endpoints.append(current_endpoint)
		
		for x in range(endpoints.size()):
			estim_dir += endpoints[x]
			
		if(endpoints.size() > 0):
			estim_dir /= endpoints.size()
		
		estim_dir = estim_dir.normalized()
		new_body.set_axis_velocity(10.0 * estim_dir)
		#new_body.angular_velocity = Vector3(randfn(2.0, 2.0), randfn(2.0, 2.0), randfn(2.0, 2.0)).normalized()
		
		new_collision_shape.shape = new_body_mesh_instance.mesh.create_convex_shape(false,false)
		
		new_body.add_child(new_collision_shape)
		new_rigid_bodies.append(new_body)
	
	for body in new_rigid_bodies:
		# scale masses to match the base object
		body.mass = body.mass * (base_object.mass/sum_mass)
		add_child(body)
	
	base_object.free()
	x += 1
	if(x < demo_objects.size()):
		base_object = demo_objects[x]
		weak_ref = weakref(base_object)
