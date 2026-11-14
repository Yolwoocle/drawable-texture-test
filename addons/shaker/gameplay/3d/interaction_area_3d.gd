@icon("./interaction_area_3d.svg")
class_name InteractionArea3D
extends Area3D

signal focused 
signal unfocused 
signal activated 

var interacted_raycast: InteractionRaycast3D
var interact_point: Vector3


func _update_focus(new_interact_point: Vector3) -> void:
	interact_point = new_interact_point


func _focus(raycast: InteractionRaycast3D) -> void:
	interacted_raycast = raycast


func _unfocus() -> void:
	interacted_raycast = null
