class_name InteractionRaycast3D
extends RayCast3D

signal focused(area: InteractionArea3D)
signal unfocused(area: InteractionArea3D)

var is_focused: bool = false
var target_area: InteractionArea3D
var target_point: Vector3

func _physics_process(delta: float) -> void:
	_update_collider(delta)
	
	if target_area:
		target_area._update_focus(target_point)


func _update_collider(delta):
	target_point = get_collision_point()
	
	var new_collider = get_collider()
	if is_colliding() and get_collider() is InteractionArea3D:
		is_focused = true
		if new_collider != target_area:
			focused.emit(new_collider)
		target_area = new_collider
		target_area._focus(self)
		target_area._update_focus(target_point)
		
	else:
		is_focused = false
		if new_collider != target_area:
			unfocused.emit(target_area)
		if target_area:
			target_area._unfocus()
		target_area = null
