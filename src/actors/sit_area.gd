class_name SitArea
extends InteractionArea3D

signal player_entered(player: Player)
signal player_exited(player: Player)

var sat_player: Player

func _ready() -> void:
	interacted.connect(_on_interacted)


func _on_interacted(raycast: InteractionRayCast3D):
	pass


func _player_enter(player: Player):
	sat_player = player
	player_entered.emit(player)


func _player_exit(player: Player):
	sat_player = null
	player_exited.emit(player)
