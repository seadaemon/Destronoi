# Destronoi
Procedural mesh fragmentation algorithm for Godot 4.2
Author: George Power

HOW TO USE:

1) Open project.godot (only tested on Godot 4.2)
2) Run the scene "demo.tscn" with the play button (top right) or press F5
3) The UI displays some controls, the main two being T and R

Use T to trigger the destruction of the object
Use R to reload the scene, so that you may destroy it again
New fragments are generated every time the scene is reloaded

Edit the demo.gd script to load different objects for destruction. A cube, cylinder, and sphere are available


Modify the number of fragments an object will break into, by adjusting the tree height.
To do this, open the objects scene file, e.g. sphere.tscn, and on the left-hand side, select the "Destronoi" node.
On the right-hand panel there should be an option to change the tree height. Tree heights beyond 6 are considered to be slow to generate.
Tree heights beyond 10 are unstable and may cause the program to crash. Even without crashing, they will take significantly longer to generate.

Ideally keep the tree height around 1-7, perhaps 8 if you have a faster machine.