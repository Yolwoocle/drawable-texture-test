@icon("./multiplayer_character_body_3d_synchronizer.svg")
class_name MultiplayerCharacterBody3DSynchronizer
extends MultiplayerSynchronizer

var _body_parent: CharacterBody3D

@export var interpolation_enabled: bool = true
@export var interpolation_speed: float = 15.0
@export var snap_distance: float = 4.0

var sync_position: Vector3 
var sync_rotation: Quaternion
var sync_velocity: Vector3

var _relative_object_path: NodePath: set = _set_relative_object_path
var relative_object: Node3D

func _enter_tree() -> void:
	replication_config = SceneReplicationConfig.new()
	replication_config.add_property(NodePath(name + ":sync_position"))
	replication_config.add_property(NodePath(name + ":sync_rotation"))
	replication_config.add_property(NodePath(name + ":sync_velocity"))
	replication_config.add_property(NodePath(name + ":_relative_object_path"))


func _ready() -> void:
	if get_parent() is not CharacterBody3D:
		push_error("Parent is not CharacterBody3D")
		set_physics_process(false)
		return
	_body_parent = get_parent() as CharacterBody3D
	
	sync_position = _body_parent.global_position
	sync_rotation = _body_parent.global_transform.basis.get_rotation_quaternion()
	sync_velocity = _body_parent.velocity


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		_sync_from_authority()
	else:
		_sync_as_authority(delta)


func _sync_from_authority() -> void:
	var offset_tranform = Transform3D.IDENTITY
	if is_instance_valid(relative_object): # Translate relative transform to global
		offset_tranform = relative_object.global_transform.affine_inverse()
	var final_transform = offset_tranform * _body_parent.global_transform
	
	sync_position = final_transform.origin
	sync_rotation = final_transform.basis.get_rotation_quaternion()
	sync_velocity = _body_parent.velocity


func _sync_as_authority(delta: float) -> void:
	var interp_weight: float = 1.0 - exp(-interpolation_speed * delta)
	var target_position = sync_position
	var target_rotation = sync_rotation.normalized()
	
	var offset_tranform = Transform3D.IDENTITY
	if is_instance_valid(relative_object): # Translate relative transform to global
		offset_tranform = relative_object.global_transform
	var target_transform = offset_tranform * Transform3D(Basis(target_rotation), target_position)
	target_position = target_transform.origin
	target_rotation = target_transform.basis.get_rotation_quaternion()
	
	if not interpolation_enabled or target_position.distance_squared_to(_body_parent.global_position) > snap_distance * snap_distance:
		_body_parent.global_position = target_position
		_body_parent.global_transform.basis = Basis(target_rotation)
		
	else:
		_body_parent.global_position = _body_parent.global_position.lerp(target_position, interp_weight)
		
		var par_rot: Quaternion = _body_parent.global_transform.basis.get_rotation_quaternion()
		_body_parent.global_transform.basis = Basis(par_rot.slerp(target_rotation, interp_weight))
	
	_body_parent.velocity = sync_velocity


func _input(event: InputEvent) -> void:
	pass
	#if event.is_action_pressed("debug_toggle_interpolation"):
		#interpolation_enabled = not interpolation_enabled


func set_relative_object(value: Node3D) -> void:
	if value:
		_relative_object_path = value.get_path()
	else:
		_relative_object_path = ""


func _set_relative_object_path(value: NodePath) -> void:
	_relative_object_path = value
	if value.is_empty() or not is_inside_tree():
		relative_object = null
	else:
		relative_object = get_node_or_null(value)
