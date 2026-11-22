class_name Player
extends CharacterBody3D

signal mic_changed(enabled: bool)

var normal_mouse_sensitivity: float = 0.01
var draw_mouse_sensitivity: float = 0.005
var mouse_sensitivity = normal_mouse_sensitivity

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var camera_raycast: InteractionRayCast3D = $Head/CameraRaycast
@onready var label_3d: Label3D = $Label3D
@onready var sprite_3d: Sprite3D = $Head/Sprite3D
@onready var spawn_marker: Marker3D = $Head/SpawnMarker
@onready var hand_marker: Marker3D = $HandPosition
@onready var voice_chat: VoiceChat3D = $VoiceChat3D
@onready var state_machine: StateMachine = $StateMachine

const BALL = preload("uid://y0nej82nqnnk")

var interacted_object: InteractionArea3D
var picked_up_object: Pickupable

var current_vehicle: VehicleBody3D
var _last_vehicle_transform: Transform3D = Transform3D.IDENTITY

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _ready() -> void:
	if is_multiplayer_authority():
		camera.make_current()
	else:
		camera.current = false
		camera.queue_free()
		set_process_input(false)
	
	voice_chat.mic_changed.connect(func(x): mic_changed.emit(x))
	
	if OS.get_cmdline_args().has("--mute"):
		voice_chat.mute()


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	#
	if current_vehicle:
		if _last_vehicle_transform != Transform3D.IDENTITY:
			var delta_transf = current_vehicle.global_transform * _last_vehicle_transform.affine_inverse()
			global_position = delta_transf * global_position
			rotate_y(delta_transf.basis.get_euler().y)
		
		_last_vehicle_transform = current_vehicle.global_transform
	
	sprite_3d.hide()
	label_3d.text = "%s\n(%s)\n%s" % [ OSUtil.get_system_username(), multiplayer.get_unique_id(), 
		("📢" if voice_chat.current_volume > 0.01 else " ") if voice_chat.mic_enabled else "🔇"
	]


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouse_sensitivity = draw_mouse_sensitivity
		var hit_object = get_interacted_object()
		var hit_pos = get_interacted_position()
		
		if hit_object and hit_object is Whiteboard:
			hit_object.interact_at(hit_pos)
		
	else:
		mouse_sensitivity = normal_mouse_sensitivity


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("interact"):
		if picked_up_object:
			picked_up_object.use()
		
		var obj = camera_raycast.target_area
		if obj:
			_on_interact(obj)
	
	if event.is_action_released("interact"):
		camera_raycast.end_interact()
		interacted_object = null
	
	if event.is_action_pressed("throw"):
		#if interacted_object and interacted_object.owner is Whiteboard:
			#interacted_object.release_pen()
		if picked_up_object:
			drop()
		
	if event.is_action_released("spawn_ball"):
		_spawn_ball.rpc_id(1, spawn_marker.global_position)
	
	if event.is_action_pressed("toggle_mic"):
		voice_chat.mic_enabled = not voice_chat.mic_enabled


func get_interacted_object():
	if camera_raycast.is_colliding():
		return camera_raycast.get_collider()
	return null


func get_interacted_position():
	if camera_raycast.is_colliding():
		return camera_raycast.get_collision_point()
	return null


func enter_vehicle(vehicle: VehicleBody3D):
	current_vehicle = vehicle
	_last_vehicle_transform = vehicle.global_transform


func exit_vehicle():
	current_vehicle = null
	_last_vehicle_transform = Transform3D.IDENTITY


func _on_interact(object: InteractionArea3D) -> void:
	interacted_object = object
	camera_raycast.start_interact()
	if object.owner is Pickupable and not picked_up_object:
		pick_up(object.owner)
	elif object is SitArea:
		state_machine.travel_to("Sitting", {"target": object})
	else:
		pass


@rpc("authority", "call_local")
func _spawn_ball(spawn_pos: Vector3):
	var ball = BALL.instantiate()
	get_parent().add_child(ball, true)
	ball.global_position = spawn_pos


func pick_up(obj: Pickupable) -> void:
	if obj.is_picked_up:
		obj.holder_player.clear_pick_up.rpc()
	
	picked_up_object = obj
	obj.pick_up.rpc(get_path(), multiplayer.get_unique_id())


func drop() -> void:
	picked_up_object.drop.rpc(picked_up_object.global_transform)
	picked_up_object = null


@rpc("any_peer", "call_local")
func clear_pick_up() -> void:
	picked_up_object = null
