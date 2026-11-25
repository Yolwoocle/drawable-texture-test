class_name Handbrake
extends Node3D

signal changed_state(new_state: bool)

@export var active: bool = true
var _pending_requests: int = 0

@onready var handle: Node3D = $Handle
@onready var interaction_area: InteractionArea3D = $InteractionArea3D
@onready var label_3d: Label3D = $Label3D

const handle_rot_active = Vector3(0.434587, 0.0, 0.0)
const handle_rot_inactive = Vector3(0.0, 0.0, 0.0)

func _ready() -> void:
	_apply_state(active)
	interaction_area.interacted.connect(_on_interaction_area_interacted)


func _process(delta: float) -> void:
	label_3d.text = str(active)


@rpc("any_peer", "call_local")
func request_set_active(value: bool) -> void:
	if multiplayer.is_server():
		set_active.rpc(value, multiplayer.get_remote_sender_id())


@rpc("authority", "call_local")
func set_active(new_value: bool, requester: int) -> void:
	if multiplayer.get_unique_id() == requester:
		_pending_requests = maxi(_pending_requests - 1, 0)
	if _pending_requests > 0: 
		# Ignore every self request to avoid echoes, except the last one 
		# (in case you were the last one to send a request, so that you don't 
		# ignore the final decision)
		return
	_apply_state(new_value)
	

func _apply_state(new_value):
	if new_value == active:
		return
	active = new_value
	
	_animate_handle(new_value)
	changed_state.emit(active)


func _animate_handle(new_state: bool):
	if new_state:
		handle.rotation = handle_rot_active
	else:
		handle.rotation = handle_rot_inactive


func _on_interaction_area_interacted(raycast: InteractionRayCast3D, target_point: Vector3):
	var new_state = not active
	_pending_requests += 1
	_apply_state(new_state)
	request_set_active.rpc_id(1, new_state)
