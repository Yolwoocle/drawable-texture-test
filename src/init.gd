extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#await get_tree().create_timer(randf_range(0.05, 0.4)).timeout
	
	# Parse arguments
	var arguments = OSUtil.parse_cmd_args()
	if arguments.has("window"):
		if arguments["window"] == "0":
			WindowUtil.dock_window_to_quarter(WindowUtil.QUARTER_TOPLEFT, get_window())
		elif arguments["window"] == "1":
			WindowUtil.dock_window_to_quarter(WindowUtil.QUARTER_TOPRIGHT, get_window())




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
