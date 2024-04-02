@icon("destronoi_icon.svg")
class_name Destronoi extends Node
"""
Author: 
	George Power 
	<georgepower@cmail.carleton.ca>
"""
## Creates a binary Voronoi Subdivision Tree (VST) from a sibling MeshInstance3D node
##
## INTENDED USE:
## To use the Destronoi node, it must be a child of a RigidBody3D with a single
## MeshInstance3D as a child. The Mesh associated with the MeshInstance3D MUST
## be ArrayMesh or the script will not work.
## 
## When the Destronoi node is loaded it will create a VST which is accessible
## through the _root.

## === VARIABLES ===
var _root: VSTNode = null ## Root node of the Voronoi Subdivision Tree

## === MEMBER FUNCTIONS ===
func _ready():
	# Set root geometry to sibling MeshInstance3D
	_root = VSTNode.new(get_parent().get_node("MeshInstance3D"))
	# Plot 2 sites for the subdivision
	plot_sites_random(_root)
	# Generate 2 children from the root
	bisect(_root)
	
	# generate 2^{n+1} pieces
	# dont go above 4 unless you want to crash
	var n = 2
	
	for i in range(n):
		var leaves = []
		_root.get_leaf_nodes(_root,leaves);
		for leaf in range(leaves.size()):
			await plot_sites_random(leaves[leaf])
			bisect(leaves[leaf])


## Manually plot sites for the subdivision; 
## Site coordinates are relative to the centre of the mesh; Overwrites existing sites
func plot_sites(vst_node: VSTNode, site1: Vector3, site2: Vector3):
	#print(vst_node._mesh_instance.global_position.)
	#vst_node._mesh_instance.position + 
	vst_node._sites = [vst_node._mesh_instance.position + site1, vst_node._mesh_instance.position + site2]

## Randomly plot sites for the subdivision using rejection sampling
## Site coordinates are relative to the centre of the mesh; Overwrites existing sites
func plot_sites_random(vst_node: VSTNode):
	# clear existing sites
	vst_node._sites = []

	var site : Vector3
	
	# MeshDataTool used to parse the mesh faces
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(vst_node._mesh_instance.mesh,0)
	
	# Bounding box used to get range of random points
	var aabb : AABB = vst_node._mesh_instance.get_aabb()
	var min_vec : Vector3 = aabb.position
	var max_vec : Vector3 = aabb.end
	
	# keep generating sites until they are within the mesh
	while vst_node._sites.size() < 2:
		site = Vector3(randf_range(min_vec.x + 0.45*(max_vec.x-min_vec.x),max_vec.x - 0.45*(max_vec.x-min_vec.x)),
						randf_range(min_vec.y + 0.0*(max_vec.y-min_vec.y),max_vec.y - 0.0*(max_vec.y-min_vec.y)),
						randf_range(min_vec.z + 0.45*(max_vec.z-min_vec.z),max_vec.z - 0.45*(max_vec.z-min_vec.z)))
		
		var num_intersections = 0
		for tri in range(mdt.get_face_count()):
			var face_v_ids = [mdt.get_face_vertex(tri,0),mdt.get_face_vertex(tri,1),mdt.get_face_vertex(tri,2)]
			var verts = [mdt.get_vertex(face_v_ids[0]),mdt.get_vertex(face_v_ids[1]),mdt.get_vertex(face_v_ids[2])]
			if(Geometry3D.ray_intersects_triangle(site, Vector3.UP, verts[0], verts[1], verts[2])):
				num_intersections += 1
		
		if(num_intersections == 1):
			#print("hit! site plotted")
			vst_node._sites.append(site)

## Bisect the mesh of a VSTNode. Will return an error if there are fewer than 2 sites
## Will overrite children if they already exist
func bisect(vst_node: VSTNode):
	
	# Colors for the new geometry
	var color_purple := Color(0.3,0.2,1)
	var color_red := Color(1,0,0)
	var color_yellow := Color(1,1,0)
	
	if vst_node.get_site_count() != 2 :
		return "Bisection aborted! Must have exactly 2 sites"
	
	# Create the plane
	# Equidistant from both sites; normal vector towards to site B
	var site_a := vst_node._sites[0]
	var site_b := vst_node._sites[1]
	var plane_normal := (site_b - site_a).normalized() # a to b
	var plane_position := site_a + 0.5*(site_b - site_a) # halfway between a,b
	var plane = Plane(plane_normal, plane_position)
	
	# Create MeshDataTool to parse mesh data of current VSTNode
	var data_tool := MeshDataTool.new()
	data_tool.create_from_surface(vst_node._mesh_instance.mesh, 0)
	
	# Create SurfaceTool to construct the ABOVE mesh
	var surface_tool_a := SurfaceTool.new()
	surface_tool_a.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool_a.set_material(vst_node.get_override_material())
	surface_tool_a.set_smooth_group(-1)
	
	# Create SurfaceTool to construct the BELOW mesh
	var surface_tool_b := SurfaceTool.new()
	surface_tool_b.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool_b.set_material(vst_node.get_override_material())
	surface_tool_b.set_smooth_group(-1)
	
	## GENERATE CHILD MESHES
	# ITERATE OVER EACH FACE OF THE PARENT MESH
	for side in range(2):
		# Intermediate surface tool to construct the new mesh
		var surface_tool := SurfaceTool.new()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface_tool.set_material(vst_node._mesh_instance.get_active_material(0))
		surface_tool.set_smooth_group(-1)
		
		# invert normal for other side
		if(side == 1):
			plane.normal = -plane.normal
			plane.d = -plane.d
			surface_tool.set_color(color_red)
		else:
			surface_tool.set_color(color_purple)
		
		var coplanar_vertices := [] # new vertices which intersect the plane
		
		for face in range(data_tool.get_face_count()):
			var face_vertices := []
			var vertices_above_plane := []
			var intersection_points := []
			
			# ITERATE OVER EACH VERTEX AND DETERMINE "ABOVENESS"
			for vertex_index in range(3):
				var vertex_id := data_tool.get_face_vertex(face, vertex_index)
				face_vertices.append(vertex_id)
				if plane.is_point_over(data_tool.get_vertex(vertex_id)):
					vertices_above_plane.append(vertex_id)
			
			# INTERSECTION CASE 0/0.5: ALL or NOTHING above the plane
			if(vertices_above_plane.size() == 0):
				continue
			if(vertices_above_plane.size() == 3):
				for v_id in face_vertices:
					#surface_tool.set_uv(data_tool.get_vertex_uv(v_id))
					if data_tool.get_vertex_color(v_id) == color_yellow:
						surface_tool.set_color(color_yellow)
					surface_tool.add_vertex(data_tool.get_vertex(v_id))
				continue
			
			# INTERSECTION CASE 1: ONE point above the plane
			# Find intersection points and append them in cw winding order
			if(vertices_above_plane.size() == 1):
				var index_before: int = -1
				var index_after: int = -1
				for index in range(3):
					if vertices_above_plane[0] == face_vertices[index]:
						index_after = (index + 1) % 3
						index_before = (index + 2) % 3
						break
				var intersection_after = plane.intersects_segment(data_tool.get_vertex(vertices_above_plane[0]), data_tool.get_vertex(face_vertices[index_after]))
				intersection_points.append(intersection_after)
				var intersection_before = plane.intersects_segment(data_tool.get_vertex(vertices_above_plane[0]), data_tool.get_vertex(face_vertices[index_before]))
				intersection_points.append(intersection_before)
				coplanar_vertices.append(intersection_after)
				coplanar_vertices.append(intersection_before)
				
				# TRIANGLE CREATION
				#surface_tool.set_uv(data_tool.get_vertex_uv(vertices_above_plane[0]))
				if data_tool.get_vertex_color(vertices_above_plane[0]) == color_yellow:
					surface_tool.set_color(color_yellow)
				surface_tool.add_vertex(data_tool.get_vertex(vertices_above_plane[0]))
				
				surface_tool.add_vertex(intersection_points[0])
				surface_tool.add_vertex(intersection_points[1])
				continue
			
			# INTERSECTION CASE 2: TWO points above the plane
			if(vertices_above_plane.size() == 2):
				var index_remaining: int = -1 # index of the point below the plane
				# Ensure vertices are in the cyclic cw winding order
				if(vertices_above_plane[0] != face_vertices[1] && vertices_above_plane[1] != face_vertices[1]):
					vertices_above_plane.reverse()
					index_remaining = 1
				elif(vertices_above_plane[0] != face_vertices[0] && vertices_above_plane[1] != face_vertices[0]):
					index_remaining = 0
				else:
					index_remaining = 2
				
				var intersection_after = plane.intersects_segment(data_tool.get_vertex(vertices_above_plane[1]), data_tool.get_vertex(face_vertices[index_remaining]))
				intersection_points.append(intersection_after)
				var intersection_before = plane.intersects_segment(data_tool.get_vertex(vertices_above_plane[0]), data_tool.get_vertex(face_vertices[index_remaining]))
				intersection_points.append(intersection_before)
				coplanar_vertices.append(intersection_after)
				coplanar_vertices.append(intersection_before)
				# find shortest 'cross-length' to make 2 triangles from 4 pounds
				var index_shortest := 0;
				var dist_0 = data_tool.get_vertex(vertices_above_plane[0]).distance_to(intersection_points[0])
				var dist_1 = data_tool.get_vertex(vertices_above_plane[1]).distance_to(intersection_points[1])
				if dist_1 > dist_0 : index_shortest = 1;
				
				#TRIANGLE 1
				#surface_tool.set_uv(data_tool.get_vertex_uv(vertices_above_plane[0]))
				if data_tool.get_vertex_color(vertices_above_plane[0]) == color_yellow:
					surface_tool.set_color(color_yellow)
				surface_tool.add_vertex(data_tool.get_vertex(vertices_above_plane[0]))
				
				#surface_tool.set_uv(data_tool.get_vertex_uv(vertices_above_plane[1]))
				if data_tool.get_vertex_color(vertices_above_plane[1]) == color_yellow:
					surface_tool.set_color(color_yellow)
				surface_tool.add_vertex(data_tool.get_vertex(vertices_above_plane[1]))
				
				surface_tool.add_vertex(intersection_points[index_shortest])
				
				# TRIANGLE 2
				surface_tool.add_vertex(intersection_points[0])
				surface_tool.add_vertex(intersection_points[1])
				#surface_tool.set_uv(data_tool.get_vertex_uv(vertices_above_plane[index_shortest]))
				surface_tool.add_vertex(data_tool.get_vertex(vertices_above_plane[index_shortest]))
				continue
		# END for face in range(data_tool.get_face_count()):
		
		var centroid := Vector3(0,0,0)
		for vertices in coplanar_vertices:
			centroid += vertices
		centroid /= coplanar_vertices.size()
		
		# DEFINE NEW FACE
		# FIND CENTROID
		#APPEND NEW TRIANGLES
		surface_tool.set_color(color_yellow)
		for i in range(coplanar_vertices.size() - 1):
			if(i % 2 != 0): continue;
			#surface_tool.set_uv(Vector2(0,0))
			surface_tool.add_vertex(centroid)
			#surface_tool.set_uv(Vector2(0,0))
			surface_tool.add_vertex(coplanar_vertices[i + 1])
			#surface_tool.set_uv(Vector2(0,0))
			surface_tool.add_vertex(coplanar_vertices[i])
			i = i + 1
		
		if(side == 0):
			surface_tool_a = surface_tool
		if(side == 1):
			surface_tool_b = surface_tool
	# END for side in range(2):
		
	surface_tool_a.index()
	surface_tool_a.generate_normals()
	surface_tool_b.index()
	surface_tool_b.generate_normals()
	
	var mesh_instance_above := MeshInstance3D.new()
	mesh_instance_above.mesh = surface_tool_a.commit()
	vst_node._left = VSTNode.new(mesh_instance_above)
	
	var mesh_instance_below := MeshInstance3D.new()
	mesh_instance_below.mesh = surface_tool_b.commit()
	vst_node._right = VSTNode.new(mesh_instance_below)
	
	return "Bisection successful!"
