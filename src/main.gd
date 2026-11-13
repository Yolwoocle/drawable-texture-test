extends Node3D

@onready var label: Label = $HUD/Label
@onready var tube_client: TubeClient = %TubeClient
@onready var hotbar: HBoxContainer = %Hotbar

const PLAYER = preload("uid://bt05aaf5nwip")

func _ready() -> void:
	select_hotbar(0)
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_tube_client_session_created() -> void:
	spawn_player(multiplayer.get_unique_id())
	start()


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
	add_child(player)


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
	
