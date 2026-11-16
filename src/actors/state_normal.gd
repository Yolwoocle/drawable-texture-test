extends State

@onready var interaction_area: InteractionArea3D = %InteractionArea3D
@onready var body: RigidBody3D = owner

func _ready() -> void:
	super()


func _on_enter_state(params: Dictionary = {}):
	pass


func _on_exit_state():
	pass
