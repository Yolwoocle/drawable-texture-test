extends Node3D

@onready var label: Label = $HUD/Label
@onready var tube_client: TubeClient = %TubeClient
@onready var player: CharacterBody3D = $Player
@onready var hotbar: HBoxContainer = %Hotbar


func _ready() -> void:
	select_hotbar(0)


func _on_tube_client_session_created() -> void:
	start()


func _on_tube_client_session_joined() -> void:
	start()


func start():
	label.text = "Session ID: " + tube_client.session_id + "\nCopied to clipboard"
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.enable()
	DisplayServer.clipboard_set(tube_client.session_id)


func select_hotbar(index: int):
	for i in hotbar.get_child_count():
		var texture_rect: TextureRect = hotbar.get_child(i).get_node("TextureRect")
		if i == index:
			texture_rect.offset_transform_position_ratio.y = 0.0
		else:
			texture_rect.offset_transform_position_ratio.y = 0.3
	
