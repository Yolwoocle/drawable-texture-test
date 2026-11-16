class_name Player
extends CharacterBody3D

const normal_mouse_sensitivity: float = 0.015
const draw_mouse_sensitivity: float = 0.005
var mouse_sensitivity = normal_mouse_sensitivity

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera: Camera3D = $Camera3D
@onready var camera_raycast: InteractionRayCast3D = $Camera3D/CameraRaycast
@onready var label_3d: Label3D = $Label3D
@onready var sprite_3d: Sprite3D = $Camera3D/Sprite3D
@onready var spawn_marker: Marker3D = $Camera3D/SpawnMarker
@onready var hand_marker: Marker3D = $HandPosition

const BALL = preload("uid://cs8xyd0piode7")

var interacted_object: InteractionArea3D
var picked_up_object: Pickupable

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _ready() -> void:
	if not OS.get_cmdline_args().has("--client"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if is_multiplayer_authority():
		camera.make_current()
	else:
		camera.current = false


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	sprite_3d.hide()
	label_3d.text = "%s\n(%s)" % [ OSUtil.get_system_username(), multiplayer.get_unique_id()]
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouse_sensitivity = draw_mouse_sensitivity
		var hit_object = get_interacted_object()
		var hit_pos = get_interacted_position()
		
		if hit_object and hit_object is DrawableMap:
			hit_object.interact_at(hit_pos)
		
	else:
		mouse_sensitivity = normal_mouse_sensitivity


func get_interacted_object():
	if camera_raycast.is_colliding():
		return camera_raycast.get_collider()
	return null


func get_interacted_position():
	if camera_raycast.is_colliding():
		return camera_raycast.get_collision_point()
	return null


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("interact"):
		if picked_up_object:
			picked_up_object.use()
		
		var obj = camera_raycast.target_area
		if obj:
			interacted_object = obj
			camera_raycast.start_interact()
			if obj.owner is Pickupable and not picked_up_object:
				pick_up(obj.owner)
	
	if event.is_action_released("interact"):
		camera_raycast.end_interact()
		interacted_object = null
	
	
	if event.is_action_pressed("throw"):
		#if interacted_object and interacted_object.owner is DrawableMap:
			#interacted_object.release_pen()
		if picked_up_object:
			drop()
		
	if event.is_action_released("spawn_ball"):
		_spawn_ball.rpc_id(1, spawn_marker.global_position)


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
	picked_up_object.drop.rpc()
	picked_up_object = null


@rpc("any_peer", "call_local")
func clear_pick_up() -> void:
	picked_up_object = null
