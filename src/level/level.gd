extends Node3D

@onready var label: Label = $HUD/Label
@onready var label_right: Label = $HUD/LabelRight
@onready var actors: Node3D = $Actors

const PLAYER = preload("uid://bt05aaf5nwip")
const DEBUG_SESSION_ID_FILE = "user://debug_session_id.txt"

var current_player: Player

func _enter_tree() -> void:
	pass


func _ready() -> void:
	start()
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	if is_multiplayer_authority():
		_on_tube_client_session_created()


func _process(delta: float) -> void:
	current_player = actors.get_node_or_null(str(multiplayer.get_unique_id()))
	
	label_right.text = ""
	if current_player:
		label_right.text += "picked_up_object: %s\n" % [current_player.picked_up_object]
	label_right.text += "\n" % []


func _on_tube_client_session_created() -> void:
	spawn_player(multiplayer.get_unique_id())
	start()
	
	var args = OS.get_cmdline_args()
	if args.has("--server"):
		var file = FileAccess.open(DEBUG_SESSION_ID_FILE, FileAccess.WRITE)
		file.store_string(Global.tube_client.session_id)


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
	
	actors.add_child(player, true)
	
	if peer_id == multiplayer.get_unique_id():
		current_player = player


func start():
	label.text = "Session ID: " + Global.tube_client.session_id + "\n"
	if multiplayer.is_server():
		DisplayServer.clipboard_set(Global.tube_client.session_id)
		label.text += "Copied to clipboard\n"
	label.text += "\n"
	label.text += "Username: %s (%s)\n" % [OSUtil.get_system_username(), multiplayer.get_unique_id()]
