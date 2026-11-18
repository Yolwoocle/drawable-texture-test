extends Control

@onready var id_edit: LineEdit = $VBoxContainer/IDEdit
@onready var error_label: Label = $ErrorLabel
@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var host_button: Button = $VBoxContainer/HostButton

@onready var game: Node = $".."

func _ready() -> void:
	join_button.pressed.connect(_on_join_button_pressed)
	host_button.pressed.connect(_on_host_button_pressed)
	Global.tube_client.error_raised.connect(_on_tube_client_error_raised)

	#id_edit.text_changed.connect(func(text: String): id_edit.text = text.to_upper())


func _on_host_button_pressed() -> void:
	game.create_session()


func _on_join_button_pressed() -> void:
	game.join_session(id_edit.text.to_upper())


func _on_tube_client_error_raised(code: TubeClient.SessionError, message: String) -> void:
	error_label.text = "Error: " + message
