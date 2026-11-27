@tool
extends Area3D


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		collision_layer = 0
		collision_mask = 0
		set_collision_mask_value(4, true)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(4, true)
	
	if owner is not VehicleBody3D:
		push_error("Owner is not VehicleBody3D") 
		set_process(false)
		return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	pass


func _on_body_entered(body: Node3D):
	if Engine.is_editor_hint():
		return
	if body is not Player:
		return
	
	var player = body as Player
	player.enter_vehicle(owner as VehicleBody3D)


func _on_body_exited(body: Node3D):
	if Engine.is_editor_hint():
		return
	if body is not Player:
		return
	
	var player = body as Player
	player.exit_vehicle()
