@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("DestronoiNode", "Node", preload("DestronoiNode.gd"), preload("./destronoi_icon.svg"))
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	pass
