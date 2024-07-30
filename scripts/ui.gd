extends Control
@warning_ignore("unused_parameter")
"""
Author: George Power <george@georgepower.dev>
"""

@onready var fps_label : RichTextLabel = get_node("VBoxContainer2/FPS Label")
## Sets the version number and FPS in the UI

func _ready():
	var version_label : RichTextLabel = get_node("TopContainer/VBoxContainer/Version Label")
	version_label.text = "Destronoi [i]v" + ProjectSettings.get_setting("application/config/version", "") + "[/i]"

func _process(_delta):
	fps_label.text = "[right]%3d FPS[/right]" % int(Engine.get_frames_per_second())
