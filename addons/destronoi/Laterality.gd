@tool
"""
Author: George Power <george@georgepower.dev>
"""
## An enum for tracking relationships in a binary tree
## e.g. A VSTNode with a LEFT laterality, is the left child of its parent
## Left and right are somewhat arbitrary as VSTNodes are in 3-D space.
enum {NONE = 0, LEFT, RIGHT}
