class_name Caravan
extends VehicleBody3D

@export var engine_power = 1200.0
@export_range(0.0, 360.0, 0.1, "radians_as_degrees") var max_steer = PI * 0.15
@export var steer_speed = 5.0

@onready var label_3d: Label3D = $Label3D
@onready var sit_area: SitArea = $SitArea

var driver: Player

var steer_input: float = 0.0
var throttle_input: float = 0.0

func _ready() -> void:
	sit_area.player_entered.connect(_on_sit_area_player_entered)
	sit_area.player_exited.connect(_on_sit_area_player_exited)


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	steering = move_toward(steering, steer_input * max_steer, delta * steer_speed)
	engine_force = throttle_input * engine_power
	
	label_3d.text = str(sit_area.sat_player)


func _on_sit_area_player_entered(player: Player):
	driver = player


func _on_sit_area_player_exited(player: Player):
	driver = null


@rpc("any_peer", "call_local")
func set_steer_input(steer: float, throttle: float):
	if not is_multiplayer_authority():
		return
	
	steer_input = steer
	throttle_input = throttle
