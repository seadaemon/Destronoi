extends Node3D
"""
Author: George Power <george@georgepower.dev>
"""
## Script for the Demo scene; to showcase and test destructible objects

var base_object: RigidBody3D # The object to be destroyed
var demo_objects = [] # objects at the start of the scene
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
	#get_node("Destructibles").add_child(cylinder_instance)
	#get_node("Destructibles").add_child(cube_instance)
	demo_objects = get_node("Destructibles").get_children()
	base_object = demo_objects[0]
	
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
		#print("foo")
		if(base_object != null):
			
			var destronoi: DestronoiNode = base_object.get_node("DestronoiNode")
			destronoi.destroy(1,1)
	
	if(Input.is_action_just_pressed("reload_scene")):
		get_tree().reload_current_scene()
