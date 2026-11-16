extends Control

@onready var id_edit: LineEdit = $VBoxContainer/IDEdit
@onready var error_label: Label = $ErrorLabel
@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var host_button: Button = $VBoxContainer/HostButton

const DEBUG_SESSION_ID_FILE = "user://debug_session_id.txt"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.tube_client.session_created.connect(_on_tube_client_session_created)
	Global.tube_client.session_joined.connect(_on_tube_client_session_joined)
	Global.tube_client.error_raised.connect(_on_tube_client_error_raised)
	
	join_button.pressed.connect(_on_join_button_pressed)
	host_button.pressed.connect(_on_host_button_pressed)
	
	var args = OS.get_cmdline_args()
	if args.has("--server"):
		DisplayServer.window_set_title("Host")
		Global.tube_client.create_session()
		await get_tree().create_timer(0.5).timeout
		get_window().grab_focus()
	elif args.has("--client"):
		DisplayServer.window_set_title("Client")
		_delay_join_debug_server()


func _delay_join_debug_server():
	await get_tree().create_timer(1.5).timeout
	
	if FileAccess.file_exists(DEBUG_SESSION_ID_FILE):
		var file = FileAccess.open(DEBUG_SESSION_ID_FILE, FileAccess.READ)
		var session_id = file.get_as_text()
		
		Global.tube_client.join_session(session_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_join_button_pressed() -> void:
	join_session(id_edit.text.to_upper())


func _on_host_button_pressed() -> void:
	create_session()


func join_session(session_id: String) -> void:
	Global.tube_client.join_session(session_id)


func create_session():
	Global.tube_client.create_session()



func _on_tube_client_session_created() -> void:
	get_tree().change_scene_to_file("res://src/main.tscn")


func _on_tube_client_session_joined() -> void:
	get_tree().change_scene_to_file("res://src/main.tscn")


func _on_tube_client_error_raised(code: TubeClient.SessionError, message: String) -> void:
	error_label.text = "Error: " + message
