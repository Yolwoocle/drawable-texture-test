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


func _on_exit_state():
	if not is_multiplayer_authority():
		return
	sit_area._player_exit(player)


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
