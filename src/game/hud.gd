extends Control

@onready var game: Game = $".."
@onready var mic_icon: TextureRect = %MicIcon
@onready var mic_volume: ProgressBar = %MicVolume
@onready var mic_label: Label = $MarginContainer/HBoxContainer/MicLabel
@onready var label_right: Label = %LabelRight

const texture_mic_off = preload("uid://dsxlqyjr4d4th")
const texture_mic_on = preload("uid://cy3gja4a4uxsd")

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if game.current_player:
		set_mic(game.current_player.voice_chat)
	
	label_right.text = ""
	label_right.text += "FPS: %s\n" % [Performance.get_monitor(Performance.TIME_FPS)]
	label_right.text += "Ping: %sms\n" % [game.ping_ms]
	if game.current_player:
		label_right.text += "Pos: %s\n" % [game.current_player.global_position]
		label_right.text += "picked_up_object: %s\n" % [game.current_player.picked_up_object]
		
		var sync = game.current_player.get_node("MultiplayerCharacterBody3DSynchronizer")
		label_right.text += "CharacterBody Interpolation: %s\n" % [str(sync.interpolation_enabled)]
		
	
	label_right.text += "\n" % []


func set_mic(vc: VoiceChat3D):
	if vc.mic_enabled:
		mic_label.text = "[V] Mute   "
		mic_icon.texture = texture_mic_on
	else:
		mic_label.text = "[V] Unmute    "
		mic_icon.texture = texture_mic_off
	
	mic_volume.value = vc.current_volume
