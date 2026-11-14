extends CanvasLayer

@onready var tube_client: TubeClient = %TubeClient
@onready var ip_edit: LineEdit = $JoinMenu/VBoxContainer/IPEdit
@onready var error_label: Label = $JoinMenu/ErrorLabel
@onready var main: Node3D = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_join_button_pressed() -> void:
	main.join_session(ip_edit.text.to_upper())


func _on_host_button_pressed() -> void:
	main.create_session()


func _on_tube_client_session_created() -> void:
	hide()


func _on_tube_client_session_joined() -> void:
	hide()


func _on_tube_client_error_raised(code: TubeClient.SessionError, message: String) -> void:
	error_label.text = "Error: " + message
