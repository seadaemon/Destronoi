# Destronoi

Destronoi is an plugin for Godot 4.2.x that allows for the fragmentation of [RigidBody3D](https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html) objects. When triggered, the object can be swapped out with pseudorandomly generated fragments to simulate destruction. Destronoi is a portmanteau of "destroy" and "Voronoi," as the fragmentation algorithm is based on Voronoi cells.

<font color="yellow">**WARNING:**</font> This plugin is currently in **beta** and is likely to contain bugs, which may negatively impact performance under certain circumstances.

### Acknowledgements
This project would not be possible without the hard work and dedication of Matthew Clothier and Mike Bailey of Oregon State University. While looking for algorithms to create this project, I found great inspiration from Clothier's paper "Creating Destructible Objects Using a 3D Voronoi Subdivison (sic) Tree". I was pleased that Clothier and Bailey had several other documents on the same topic (cited below), which were extremely valuable during the development of this project. Clothier even submitted a PhD dissertation titled "3D Voronoi Subdivision for Simulating Destructible and Granular Materials".

Destronoi is more-or-less a Godot-specific implementation of Clothier's algorithms. I could not find any source code for any of his papers. So, while my actual code is original, the core processes that make this plugin possible are heavily derived from Clothier's work. I want to thank Clothier and Bailey for their work.

**Note:** The Destronoi project has no affiliation with Oregon State University.

## Limitations
Destronoi uses a custom node, `DestronoiNode`, to create fragments and initiate the destruction of objects. Fragments are generated when the `DestronoiNode` is loaded into the scene.

A `DestronoiNode` must be a child of a `RigidBody3D`.

A `DestronoiNode` must have a `MeshInstance3D` as its sibling.

The `MeshInstance3D.mesh` must be an `ArrayMesh`. The easiest way to create an `ArrayMesh` is to import an mesh file (e.g. OBJ) into the `MeshInstance3D` object.

The `ArrayMesh` must be *convex* rather than *concave*. There is **no support** for concave meshes. (i.e. spheres, cubes, prisms, etc. will work just fine. However, shapes such as toruses, stars, cups, etc. will not work.)

The UV mapping on the original `ArrayMesh` will not carry over to the fragments. Coloring/shading/texturing of fragments is not officially implemented and is in a limited state.

## Getting Started

### Installation

1) Download the latest release
2) Copy `addons/destronoi` to the root directory of your project
3) In the top-left of the Godot editor, go to `Project->Project Settings...->Plugins` and enable the plugin.

### Basic Use
Chose a standard `RigidBody3D` node with a valid `MeshInstance3D` child, and add a `DestronoiNode` as another child.

The number of fragments generated is determined by the `DestronoiNode.tree_height`, which can be tweaked in the editor when the node is selected. 

The `DestronoiNode` produces a binary tree of fragments. The tree contains `2^n` nodes where `n` is the `tree_height`. So a `tree_height` of 1 results in 2 fragments, but a tree height of 5 results in 32 fragments. Tree heights beyond 6 are considered to be slow to generate. Tree heights beyond 10 are unstable and may cause the program to crash. Even without crashing, they will take significantly longer to generate.

Once a tree height is selected, the `DestronoiNode.destroy()` function is be used to execute the fragmentation. Here is a basic example:

```Go
var base_object = get_node("MyObject")

var destronoi_node = base_object.get_node("DestronoiNode")

destronoi_node.destroy(5,5, 10.0)
```

The `destroy(left_val, right_val, combust_velocity)` function takes three parameters. 

`left_val` and `right_val` determine the number of fragments to be loaded when the function is executed. These values are in terms of the tree height (e.g. a value of 3 would result in 8 fragments being loaded). 

`combust_velocity` determines how fast the fragments are pushed from the center of the original `RigidBody3D` object. Setting `combust_velocity` to 0 causes fragments to be swapped in without any additional velocity (other than from gravity). Any values greater than 0 cause the fragments to propel outward, resulting in a "explosive" effect.

For easy clean-up, I recommend making the destructible `RigidBody3D` a child of a `Node` so that fragments can be deleted in a convenient fashion. 

### References
[1] M. M. Clothier and M. Bailey, “Creating Destructible Objects Using a 3D Voronoi Subdivison Tree,” in *2015 15th International Conference on Computational Science and Its Applications*, Banff, AB, Canada: IEEE,
Jun. 2015, pp. 42–46, isbn: 978-1-4673-7367-8. doi: 10.1109/ICCSA.2015.26. [Online]. Available: http://ieeexplore.ieee.org/document/7166162/ (visited on 01/15/2024).

[2] M. Clothier and M. Bailey, “3D Voronoi Subdivision Tree for granular materials,” in *2015 6th International Conference on Computing, Communication and Networking Technologies (ICCCNT)*, Dallas-Fortworth, TX, USA: IEEE, Jul. 2015, pp. 1–7, isbn: 978-1-4799-7984-4. doi: 10.1109/ICCCNT.2015.7395194. [Online]. Available: http://ieeexplore.ieee.org/document/7395194/ (visited on 02/27/2024).

[3] M. M. Clothier and M. J. Bailey, “Using exemplars to create predictable volumetric diversity in object volumes with a 3D Voronoi Subdivison Tree,” in *2015 International Conference and Workshop on Computing and Communication (IEMCON)*, Vancouver, BC, Canada: IEEE, Oct. 2015, pp. 1–5, isbn: 978-1-4799-6908-1. doi: 10.1109/IEMCON.2015.7344425. [Online]. Available: http://ieeexplore.ieee.org/document/7344425/ (visited on 02/27/2024).

[4] M. M. Clothier, “3D Voronoi Subdivision for Simulating Destructible and Granular Materials,” Oregon State University, Dec. 2017. [Online]. Available: https://ir.library.oregonstate.edu/concern/graduate_thesis_or_dissertations/ww72bh34b (visited on 01/19/2024).

[5] M. M. Clothier and M. J. Bailey, “Subdividing non-convex object meshes using a 3D Voronoi volume,” in *2016 IEEE 7th Annual Information Technology, Electronics and Mobile Communication Conference (IEMCON)*, Vancouver, BC, Canada: IEEE, Oct. 2016, pp. 1–6, isbn: 978-1-5090-0996-1. doi: 10.1109/IEMCON.
2016.7746305. [Online]. Available: http://ieeexplore.ieee.org/document/7746305/ (visited on 01/22/2024).