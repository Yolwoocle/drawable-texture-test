class_name StateDriving
extends StateSitting

var vehicle: VehicleBody3D
var _sync_timer = 0.0

const SYNC_INTERVAL = 0.1 

func _ready() -> void:
	super()


func _on_enter_state(params: Dictionary = {}):
	if not is_multiplayer_authority():
		return
	super(params)
	
	vehicle = (sit_area.owner as Caravan)


func _on_exit_state():
	if not is_multiplayer_authority():
		return
	
	super()


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if not vehicle:
		return
	
	super(delta)
	
	_sync_timer -= delta 
	if _sync_timer <= 0.0:
		_sync_timer = SYNC_INTERVAL
		var steer = Input.get_axis("left", "right")
		var throttle = Input.get_axis("up", "down")
		
		vehicle.set_steer_input.rpc_id(1, steer, throttle)


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	super(delta)


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	
	super(event)
