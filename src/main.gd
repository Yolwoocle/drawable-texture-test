extends Node3D

@onready var label: Label = $HUD/Label
@onready var tube_client: TubeClient = %TubeClient
@onready var hotbar: HBoxContainer = %Hotbar

const PLAYER = preload("uid://bt05aaf5nwip")

const DEBUG_SESSION_ID_FILE = "user://debug_session_id.txt"

func _ready() -> void:
	select_hotbar(0)
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	var args = OS.get_cmdline_args()
	if args.has("--server"):
		DisplayServer.window_set_title("Host")
		tube_client.create_session()
	elif args.has("--client"):
		DisplayServer.window_set_title("Client")
		_delay_join_debug_server()


func _on_tube_client_session_created() -> void:
	spawn_player(multiplayer.get_unique_id())
	start()
	
	var args = OS.get_cmdline_args()
	if args.has("--server"):
		var file = FileAccess.open(DEBUG_SESSION_ID_FILE, FileAccess.WRITE)
		file.store_string(tube_client.session_id)


func _delay_join_debug_server():
	await get_tree().create_timer(1.5).timeout
	
	if FileAccess.file_exists(DEBUG_SESSION_ID_FILE):
		var file = FileAccess.open(DEBUG_SESSION_ID_FILE, FileAccess.READ)
		var session_id = file.get_as_text()
		
		tube_client.join_session(session_id)


func _on_tube_client_session_joined() -> void:
	start()


func _on_peer_connected(id: int) -> void:
	if multiplayer.is_server():
		spawn_player(id)


func _on_peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		var player_node = get_node_or_null(str(id))
		if player_node:
			player_node.queue_free()


func spawn_player(peer_id: int):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player, true)


func join_session(session_id: String) -> void:
	tube_client.join_session(session_id)


func create_session():
	tube_client.create_session()


func start():
	label.text = "Session ID: " + tube_client.session_id + "\nCopied to clipboard"
	DisplayServer.clipboard_set(tube_client.session_id)


func select_hotbar(index: int):
	for i in hotbar.get_child_count():
		var texture_rect: TextureRect = hotbar.get_child(i).get_node("TextureRect")
		if i == index:
			texture_rect.offset_transform_position_ratio.y = 0.0
		else:
			texture_rect.offset_transform_position_ratio.y = 0.3
