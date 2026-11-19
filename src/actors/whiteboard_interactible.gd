class_name WhiteboardInteractible
extends Pickupable

@export var color: Color = Color.BLACK: set = _set_color
@export var is_eraser: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


func _set_color(value: Color):
	color = value
