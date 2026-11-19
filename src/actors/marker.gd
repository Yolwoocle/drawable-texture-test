@tool
class_name Marker
extends WhiteboardInteractible


func _ready() -> void:
	super()
	
	var cylinder: MeshInstance3D = $Visuals/marker/Cylinder
	var mat: ShaderMaterial = cylinder.get_surface_override_material(0)
	mat.set_shader_parameter("color", color)
	cylinder.set_surface_override_material(0, mat)


func _set_color(value: Color):
	super(value)
