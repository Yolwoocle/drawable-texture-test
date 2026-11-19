class_name Whiteboard
extends Node3D

var drawable_texture: DrawableTexture2D

@export var size: Vector2 = Vector2.ONE
@export var background_texture: Texture2D
@export var pen_texture: Texture2D
@export var eraser_texture: Texture2D
@export var collision_margin: float = 1.1

@onready var _mesh_inst: MeshInstance3D = $MeshInstance3D
@onready var interaction_area: InteractionArea3D = $InteractionArea3D
@onready var collision_shape_3d: CollisionShape3D = $InteractionArea3D/CollisionShape3D
@onready var main: Node3D = $".."

var _last_draw_pos: Vector2i
var _is_drawing: bool = false

var _mesh: PlaneMesh

var _interact_raycast: InteractionRayCast3D
var _interact_marker: WhiteboardInteractible

var eraser_material: BlitMaterial

func _ready() -> void:
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
	
	interaction_area.interacted.connect(_on_interact)
	interaction_area.interaction_ended.connect(_on_interact_end)


func _process(delta: float) -> void:
	if _is_drawing and _interact_raycast:
		interact_at(_interact_raycast.target_point)


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
	var draw_color = _interact_marker.color
	var is_eraser = _interact_marker.is_eraser
	
	if _last_draw_pos == Vector2i.MAX:
		_last_draw_pos = tex_pos
	_interpolate_draw.rpc(_last_draw_pos, tex_pos, draw_color, is_eraser)
	_last_draw_pos = tex_pos


func release_pen():
	_is_drawing = false


func put_pen():
	_is_drawing = true
	_last_draw_pos = Vector2i.MAX


func _on_interact(raycast: InteractionRayCast3D, pos: Vector3):
	if raycast.owner is not Player:
		return
	var player = (raycast.owner as Player)
	var object_used = player.picked_up_object
	if object_used is not WhiteboardInteractible:
		return
	
	put_pen()
	_interact_raycast = raycast
	_interact_marker = object_used


func _on_interact_end(raycast: InteractionRayCast3D):
	release_pen()
	_interact_raycast = null
