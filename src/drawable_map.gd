class_name DrawableMap
extends Area3D

var drawable_texture: DrawableTexture2D

@export var size: Vector2 = Vector2.ONE
@export var background_texture: Texture2D
@export var pen_texture: Texture2D
@export var eraser_texture: Texture2D
@export var collision_margin: float = 1.1

@onready var _mesh_inst: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var main: Node3D = $".."

var _last_draw_pos: Vector2i
var _is_drawing: bool = false

var draw_color: Color = Color.BLACK
var is_eraser: bool = false

var _mesh: PlaneMesh

var eraser_material: BlitMaterial

func _ready() -> void:
	input_event.connect(_on_input_event)
	
	drawable_texture = DrawableTexture2D.new()
	drawable_texture.setup(background_texture.get_width(), background_texture.get_height(), DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color.TRANSPARENT)
	
	var mat: ShaderMaterial = _mesh_inst.mesh.surface_get_material(0)
	mat.set_shader_parameter("fg_texture", drawable_texture)
	mat.set_shader_parameter("bg_texture", background_texture)
	
	_mesh = _mesh_inst.mesh
	_mesh.size = size
	
	(collision_shape_3d.shape as BoxShape3D).size = Vector3(size.x, 0.1, size.y)
	
	eraser_material = BlitMaterial.new()
	eraser_material.blend_mode = BlitMaterial.BLEND_MODE_SUB


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var key = (event as InputEventKey).keycode
		match key:
			Key.KEY_1:
				draw_color = Color.BLACK
				is_eraser = false
				main.select_hotbar(0)
			Key.KEY_2:
				draw_color = Color.RED
				is_eraser = false
				main.select_hotbar(1)
			Key.KEY_3:
				draw_color = Color.BLUE
				is_eraser = false
				main.select_hotbar(2)
			Key.KEY_4:
				draw_color = Color.GREEN
				is_eraser = false
				main.select_hotbar(3)
			Key.KEY_5:
				draw_color = Color.WHITE
				is_eraser = true
				main.select_hotbar(4)


@rpc("any_peer", "call_local")
func _interpolate_draw(pos1: Vector2i, pos2: Vector2i, color: Color, eraser: bool) -> void:
	var steps = max(pos2.distance_to(pos1), 1.0)
	for i in steps:
		var pos = lerp(Vector2(pos1), Vector2(pos2), float(i) / float(steps))
		var tex = eraser_texture if eraser else pen_texture
		var mat = eraser_material if eraser else null 
		
		drawable_texture.blit_rect(Rect2i(pos - tex.get_size()/2, tex.get_size()), tex, color, 0, mat)


func interact_at(event_position: Vector3):
	if not _is_drawing:
		return
	
	var transf_pos = (transform.affine_inverse() * event_position)
	var uv_pos = (Vector2(transf_pos.x, transf_pos.z) / size) + Vector2(0.5, 0.5)
	var tex_pos = uv_pos * background_texture.get_size()
	
	if _last_draw_pos == Vector2i.MAX:
		_last_draw_pos = tex_pos
	_interpolate_draw.rpc(_last_draw_pos, tex_pos, draw_color, is_eraser)
	_last_draw_pos = tex_pos


func release_pen():
	_is_drawing = false


func put_pen():
	_is_drawing = true
	_last_draw_pos = Vector2i.MAX


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
	pass
