extends Control
"""
Author: George Power
		<georgepower@cmail.carleton.ca>
"""
## Sets the version number in the UI
func _ready():
	var version_label : RichTextLabel = get_node("TopContainer/VBoxContainer/Version Label")
	version_label.text = "Destronoi [i]v" + ProjectSettings.get_setting("application/config/version", "") + "[/i]"
