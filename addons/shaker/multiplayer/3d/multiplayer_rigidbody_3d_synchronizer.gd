@icon("./multiplayer_rigidbody_3d_synchronizer.svg")
class_name MultiplayerRigidbody3DSynchronizer
extends MultiplayerSynchronizer

var _body_parent: RigidBody3D

@export var sync_position: Vector3 
@export var sync_rotation: Quaternion
@export var sync_linear_velocity: Vector3
@export var sync_angular_velocity: Vector3

func _ready() -> void:
	replication_config = SceneReplicationConfig.new()
	replication_config.add_property(NodePath(name + ":sync_position"))
	replication_config.add_property(NodePath(name + ":sync_rotation"))
	replication_config.add_property(NodePath(name + ":sync_linear_velocity"))
	replication_config.add_property(NodePath(name + ":sync_angular_velocity"))
	
	if get_parent() is not RigidBody3D:
		push_error("Parent is not RigidBody3D")
	_body_parent = get_parent() as RigidBody3D
	
	if not is_multiplayer_authority():
		_body_parent.freeze = true
		_body_parent.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		sync_position = _body_parent.global_position
		sync_rotation = _body_parent.global_transform.basis.get_rotation_quaternion()
		sync_linear_velocity = _body_parent.linear_velocity
		sync_angular_velocity = _body_parent.angular_velocity
		
	else:
		_body_parent.global_position = sync_position
		_body_parent.global_transform.basis = Basis(sync_rotation)
		_body_parent.linear_velocity = sync_linear_velocity
		_body_parent.angular_velocity = sync_angular_velocity
