@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("DestronoiNode", "Node", preload("DestronoiNode.gd"), preload("./destronoi_icon.svg"))

func _exit_tree():
	remove_custom_type("DestronoiNode")
