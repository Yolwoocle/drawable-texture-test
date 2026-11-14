extends RigidBody3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var label_3d: Label3D = $Label3D

@export var sync_position: Vector3 
@export var sync_rotation: Quaternion
@export var sync_linear_velocity: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var id = str(get_path()).hash()
	var mat: StandardMaterial3D = mesh_instance_3d.mesh.surface_get_material(0)
	mat.albedo_color = ([
		Color.ORANGE_RED,
		Color.YELLOW,
		Color.CORNFLOWER_BLUE,
		Color.FOREST_GREEN
	])[id % 4]
	mesh_instance_3d.mesh.surface_set_material(0, mat)


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		sync_position = global_position
		sync_rotation = global_transform.basis.get_rotation_quaternion()
		sync_linear_velocity = linear_velocity
	
	label_3d.global_position = global_position + Vector3.UP * 0.3
	label_3d.text = name


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not is_multiplayer_authority():
		var new_transform = state.transform
		new_transform.origin = sync_position
		new_transform.basis = Basis(sync_rotation)
		
		state.transform = new_transform
		state.linear_velocity = sync_linear_velocity
