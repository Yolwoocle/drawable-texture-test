class_name Caravan
extends VehicleBody3D

var engine_power = 1200.0
@onready var label_3d: Label3D = $Label3D
@onready var sit_area: SitArea = $SitArea

func _physics_process(delta: float) -> void:
	var steer_input = Input.get_axis("debug_car_left", "debug_car_right")
	var throttle_input = Input.get_axis("debug_car_front", "debug_car_back")
	
	engine_force = throttle_input * engine_power
	
	label_3d.text = str(sit_area.sat_player)
