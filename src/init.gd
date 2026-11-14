extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Parse arguments
	WindowUtil.setup_multi_window(get_window())
