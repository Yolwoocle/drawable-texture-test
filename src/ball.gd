extends RigidBody3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_multiplayer_authority():
		process_mode = Node.PROCESS_MODE_DISABLED
	
	var mat: StandardMaterial3D = mesh_instance_3d.mesh.surface_get_material(0)
	mat.albedo_color = ([
		Color.ORANGE_RED,
		Color.YELLOW,
		Color.CORNFLOWER_BLUE,
		Color.FOREST_GREEN
	])[randi_range(0, 3)]
	mesh_instance_3d.mesh.surface_set_material(0, mat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
