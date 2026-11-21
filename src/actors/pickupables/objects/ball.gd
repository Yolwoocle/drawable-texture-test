extends Pickupable

@onready var mesh_instance: MeshInstance3D = $Visuals/MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	var id = str(get_path()).hash()
	var mat: StandardMaterial3D = mesh_instance.mesh.surface_get_material(0)
	mat.albedo_color = ([
		Color.ORANGE_RED,
		Color.YELLOW,
		Color.CORNFLOWER_BLUE,
		Color.FOREST_GREEN
	])[id % 4]
	mesh_instance.mesh.surface_set_material(0, mat)
