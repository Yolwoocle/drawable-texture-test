class_name Game
extends Node3D

@onready var label: Label = $HUD/Label
@onready var label_right: Label = %LabelRight
@onready var actors: Node3D = $Actors

const PLAYER = preload("uid://bt05aaf5nwip")
const DEBUG_SESSION_ID_FILE = "user://debug_session_id.txt"

var current_player: Player

var ping_ms := 0.0
var _ping_timer := 0.0

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
	Global.current_player = current_player
	
	if not multiplayer.is_server():
		_ping_timer += delta
		if _ping_timer >= 1.0:
			_ping_timer = 0.0
			_ping.rpc_id(1, Time.get_ticks_msec())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle_ui"):
		label.visible = not label.visible
		label_right.visible = not label_right.visible


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
		print("deco")
		var player_node = actors.get_node_or_null(str(id))
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


@rpc("any_peer", "call_remote", "unreliable")
func _ping(time: int):
	if multiplayer.is_server():
		_pong.rpc_id(multiplayer.get_remote_sender_id(), time)

@rpc("authority", "call_remote", "unreliable")
func _pong(time: int):
	ping_ms = Time.get_ticks_msec() - time
