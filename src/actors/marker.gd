@tool
class_name Marker
extends Pickupable

@export var color: Color = Color.BLACK: set = _set_color

@onready var cylinder: MeshInstance3D = $Visuals/marker/Cylinder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


func _set_color(value: Color):
	color = value
	if not is_node_ready():
		await ready
	
	var mat: ShaderMaterial = cylinder.get_surface_override_material(0)
	mat.set_shader_parameter("color", color)
	cylinder.set_surface_override_material(0, mat)
