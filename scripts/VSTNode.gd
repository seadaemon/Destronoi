class_name VSTNode
const Laterality = preload("res://scripts/Laterality.gd")
"""
Author: George Power
		<georgepower@cmail.carleton.ca>
"""
## A node in a Voronoi Subdivision Tree
##
## Only supports a binary tree (at most 2 children/node), a given node has:
## - A MeshInstance3D to derive the mesh data
## - Two sites to defiane a bisector plane
## - Two children, left and right, nodes in the binary tree

var _mesh_instance: MeshInstance3D = null
var _sites: PackedVector3Array = []
var _left: VSTNode = null
var _right: VSTNode = null
#var _parent: VSTNode = null
var _level: int = 0
var _laterality: int = Laterality.NONE
## === METHODS ===
	
## VSTNode initialization requires some base mesh to be provided
func _init(mesh_instance: MeshInstance3D, level: int = 0, lat: int = Laterality.NONE):
	_mesh_instance = mesh_instance
	_level = level
	_laterality = lat

## Return surface material override, for a specific index (0 default)
## returns null if index is out of bounds
func get_override_material(index: int = 0):
	if index > _mesh_instance.get_surface_override_material_count() - 1: return null 
	var mat := _mesh_instance.get_surface_override_material(index)
	return mat

## Return the number of sites
func get_site_count():
	return _sites.size()

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

func get_right_leaf_nodes(root: VSTNode = null, out_arr: Array = [], level: int = 0):
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

func _to_string():
	return "VSTNode {mesh}".format({"mesh":_mesh_instance})
