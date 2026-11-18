extends State

@onready var body: Pickupable = owner
var holder_player: Player

func _on_enter_state(params: Dictionary = {}):
	if not is_multiplayer_authority():
		return
	
	body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	body.freeze = true


func _on_exit_state():
	if not is_multiplayer_authority():
		return
	
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	body.freeze = false


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	body.rotation.y = body.holder_player.rotation.y
	
	body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	body.freeze = true
	body.linear_velocity = Vector3.ZERO
	body.global_position = body.holder_player.hand_marker.global_position
