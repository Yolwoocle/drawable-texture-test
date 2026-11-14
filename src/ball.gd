extends RigidBody3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var label_3d: Label3D = $Label3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_multiplayer_authority():
		process_mode = Node.PROCESS_MODE_DISABLED
	
	var id = str(get_path()).hash()
	var mat: StandardMaterial3D = mesh_instance_3d.mesh.surface_get_material(0)
	mat.albedo_color = ([
		Color.ORANGE_RED,
		Color.YELLOW,
		Color.CORNFLOWER_BLUE,
		Color.FOREST_GREEN
	])[id % 4]
	mesh_instance_3d.mesh.surface_set_material(0, mat)


func _process(delta: float) -> void:
	label_3d.global_position = global_position + Vector3(0, 0.3, 0)
	label_3d.text = name
