extends Node3D
"""
Author: George Power
		<georgepower@cmail.carleton.ca>
"""
## Script for the Demo scene; to showcase and test destructible objects

# === GLOBAL VARIABLES ===

var base_object: RigidBody3D # The object to be destroyed
var weak_ref; # weak reference for deleting objects 

# === METHODS ===

func _ready():
	# always process user input & enable wireframe draw
	process_mode = Node.PROCESS_MODE_ALWAYS
	RenderingServer.set_debug_generate_wireframes(true)
	
	var demo_objects = [get_node("Cube")]
	base_object = demo_objects[0]
	weak_ref = weakref(base_object)
	
var x = 0
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


func destroy():
	if(!weak_ref.get_ref()):
		return
	var destronoi: Destronoi = base_object.get_node("Destronoi")
	var vst_root: VSTNode = destronoi._root
	
	var vst_sites = vst_root._sites
	
	# points
	var sphere = MeshInstance3D.new()
	sphere.mesh = SphereMesh.new()
	var scale_sph = 0.2
	sphere.scale_object_local(Vector3(scale_sph, scale_sph, scale_sph))
	var s1 = StaticBody3D.new()
	s1.add_child(sphere.duplicate())
	var s2 = StaticBody3D.new()
	s2.add_child(sphere.duplicate())
	var sites = [s1, s2]
	sites[0].position = base_object.position + vst_sites[0]
	sites[1].position = base_object.position + vst_sites[1]
	
	#plane
	#var plane_mi = MeshInstance3D.new()
	#plane_mi.mesh = PlaneMesh.new()
	#var plane = StaticBody3D.new()
	#plane.add_child(plane_mi)
	#plane.position = base_object.position + (sites[0].position + 0.5*(sites[1].position - sites[0].position))
	#plane.global_basis = Basis(Vector3(0,0,1), 45.0)
	
	var vst_leaves := []
	#var valid = true
	var current_node: VSTNode = vst_root
	current_node.get_right_leaf_nodes(current_node, vst_leaves)
	#vst_leaves.append(current_node._left)
	# Create rigid bodies for the fragments
	var new_rigid_bodies := []
	var sum_mass = 0
	for vst_leaf in range(vst_leaves.size()):
		var new_body: RigidBody3D = RigidBody3D.new()
		new_body.name = "VFragment_{id}".format({"id": vst_leaf})
		
		new_body.position = base_object.position
		
		var new_mesh_instance = vst_leaves[vst_leaf]._mesh_instance
		new_mesh_instance.name = "MeshInstance3D"
		new_body.add_child(new_mesh_instance)
		
		# Create collision geometry
		var new_body_mesh_instance : MeshInstance3D = new_body.get_child(0)
		var new_collision_shape: CollisionShape3D = CollisionShape3D.new()
		new_collision_shape.name = "CollisionShape3D"

		var velocity_dir = new_body_mesh_instance.mesh.get_aabb().get_center() - base_object.global_position;
		velocity_dir = velocity_dir.normalized()
		
		new_body.mass = max(new_body_mesh_instance.mesh.get_aabb().get_volume(),0.1)

		sum_mass += new_body.mass
		var endpoints = []
		var estim_dir = Vector3(0,0,0)
		for i in range(8):
			var current_endpoint = new_body_mesh_instance.mesh.get_aabb().get_endpoint(i)
			var current_dot = current_endpoint.dot(base_object.global_position)
			if current_dot > 0.0:
				endpoints.append(current_endpoint)
		
		for x in range(endpoints.size()):
			estim_dir += endpoints[x]
			
		if(endpoints.size() > 0):
			estim_dir /= endpoints.size()
		
		estim_dir = estim_dir.normalized()
		new_body.set_axis_velocity(10.0 * estim_dir)
		new_body.angular_velocity = Vector3(randfn(0.0, 1.0), randfn(0.0, 1.0), randfn(0.0, 1.0)).normalized()
		
		new_collision_shape.shape = new_body_mesh_instance.mesh.create_convex_shape(false,false)
		
		new_body.add_child(new_collision_shape)
		
		new_rigid_bodies.append(new_body)
	
	for body in new_rigid_bodies:
		body.mass = body.mass * (base_object.mass/sum_mass)
		add_child(body)
	
	#for s in sites:
	#	add_child(s)
	#add_child(plane)
	
	
	base_object.free()
