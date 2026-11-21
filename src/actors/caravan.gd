class_name Caravan
extends VehicleBody3D

@export var engine_power = 1200.0
@export_range(0.0, 360.0, 0.1, "radians_as_degrees") var max_steer = PI * 0.15
@export var steer_speed = 5.0

@onready var label_3d: Label3D = $Label3D
@onready var sit_area: SitArea = $SitArea

func _physics_process(delta: float) -> void:
	var steer_input = Input.get_axis("debug_car_left", "debug_car_right")
	var throttle_input = Input.get_axis("debug_car_front", "debug_car_back")
	
	steering = move_toward(steering, steer_input * max_steer, delta * steer_speed)
	engine_force = throttle_input * engine_power
	
	label_3d.text = str(sit_area.sat_player)
