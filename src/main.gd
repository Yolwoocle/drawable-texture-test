class_name Main
extends Node

@onready var game_container: Node3D = $GameContainer
@onready var join_menu: Control = $JoinMenu

const DEBUG_SESSION_ID_FILE = "user://debug_session_id.txt"
const GAME = preload("uid://c8hla63rn7ie4")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.tube_client.session_created.connect(_on_tube_client_session_created)
	Global.tube_client.session_joined.connect(_on_tube_client_session_joined)
	Global.tube_client.session_left.connect(_on_tube_client_session_left)
	
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
		
		join_session(session_id)


func _on_tube_client_session_created() -> void:
	var level = GAME.instantiate()
	game_container.add_child(level, true)
	
	join_menu.queue_free()


func _on_tube_client_session_joined() -> void:
	pass
	
	join_menu.hide()


func _on_tube_client_session_left() -> void:
	join_menu.show()


func join_session(session_id: String) -> void:
	Global.tube_client.join_session(session_id)


func create_session():
	Global.tube_client.create_session()
