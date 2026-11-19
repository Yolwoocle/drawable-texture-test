extends Control

@onready var level: Level = $".."
@onready var mic_icon: TextureRect = %MicIcon
@onready var mic_volume: ProgressBar = %MicVolume
@onready var mic_label: Label = $MarginContainer/HBoxContainer/MicLabel

const texture_mic_off = preload("uid://dsxlqyjr4d4th")
const texture_mic_on = preload("uid://cy3gja4a4uxsd")

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if level.current_player:
		set_mic(level.current_player.voice_chat)


func set_mic(vc: VoiceChat3D):
	if vc.mic_enabled:
		mic_label.text = "[V] Mute   "
		mic_icon.texture = texture_mic_on
	else:
		mic_label.text = "[V] Unmute    "
		mic_icon.texture = texture_mic_off
	
	mic_volume.value = vc.current_volume
