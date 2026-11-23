class_name StateSitting
extends State

@onready var player: Player = $"../.."

var sit_area: SitArea

func _ready() -> void:
	super()


func _on_enter_state(params: Dictionary = {}):
	if not is_multiplayer_authority():
		return
	
	sit_area = params["target"]
	sit_area._player_enter(player)
	player.global_position = sit_area.global_position
	
	if sit_area.constrain_look_range:
		player.constrain_y_rot = true
		player.constrain_y_rot_min = -sit_area.look_range
		player.constrain_y_rot_max = sit_area.look_range
		player.constrain_y_rot_relative_obj = sit_area


func _on_exit_state():
	if not is_multiplayer_authority():
		return
	
	sit_area._player_exit(player)
	
	if sit_area.constrain_look_range:
		player.constrain_y_rot = false


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	player.global_position = sit_area.global_position


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	
	if event.is_action_pressed("jump"):
		travel_to("Moving")
