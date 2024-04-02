class_name VSTNode
"""
Author: 
	George Power 
	<georgepower@cmail.carleton.ca>
"""
## A node in a Voronoi Subdivision Tree
##
## Only supports a binary tree, a given node has:
## - A MeshInstance3D to derive the mesh data as well as its current material
## - Two sites to create a subdivision
## - Two children, left and right, nodes in the binary tree

## === MEMBER VARIABLES ===
var _mesh_instance: MeshInstance3D = null
var _sites: PackedVector3Array = []
var _left: VSTNode = null
var _right: VSTNode = null
	
## VSTNode initialization requires some base mesh to be provided
func _init(mesh_instance: MeshInstance3D):
	_mesh_instance = mesh_instance.duplicate()

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

func _to_string():
	return "VSTNode {mesh}".format({"mesh":_mesh_instance})

# verbose print
#func _to_string():
	#var output = "VSTNode {\n\t_mesh_data: {mesh}\n\t_sites: {sites}\n\n\t_left: {left}\n\t_right: {right}\n}"
	#return output.format({"mesh": _mesh_instance,"sites": _sites,"left": _left,"right": _right})
