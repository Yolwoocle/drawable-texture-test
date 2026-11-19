class_name VoiceChat3D
extends Node

# TODO:
# - cull sounds outside of hearing range
# - compress from stereo float32 to mono int16 to reduce data by 4
# - use a opus/VoIP lib like "twovoip" (it's good enough for now but it could reduce
#   data from to 96KB/s to ~3-6KB)
# - raytraced audio (see lib from bryson mcbee example)
# - skip silent mic chunks

signal mic_changed(enabled: bool)

@export var input: AudioStreamPlayer
@export var output: AudioStreamPlayer3D
@export var listener: AudioListener3D
@export var chunk_size = 512

const rpc_channel = 0
var mic_enabled = false: set = _set_mic_enabled
var current_volume: float = 0.0

var _buffer: PackedVector2Array

var _bus_name: String
var _bus_index: int

var _audio_capture: AudioEffectCapture
var _playback: AudioStreamGeneratorPlayback

func _ready() -> void:
	_bus_name = input.bus
	_bus_index = AudioServer.get_bus_index(_bus_name)
	_audio_capture = AudioServer.get_bus_effect(_bus_index, 0)
	
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		listener.make_current()
	else:
		input.stop()
		output.play()
		listener.queue_free()
		_playback = output.get_stream_playback()


func _process(delta: float) -> void:
	if is_multiplayer_authority():
		_read_mic_data()
	
	#current_volume = lerp(current_volume, 0.0, delta * 5.0)


func mute():
	mic_enabled = false


func unmute():
	mic_enabled = true


func _read_mic_data():
	var frame_count = _audio_capture.get_frames_available()
	
	if frame_count > 0:
		var voice_data: PackedVector2Array = _audio_capture.get_buffer(frame_count)
		_buffer.append_array(voice_data)
		#_audio_capture.clear_buffer()
	
	while _buffer.size() >= chunk_size:
		var chunk = _buffer.slice(0, chunk_size)
		_buffer = _buffer.slice(chunk_size)
		
		current_volume = _compute_rms(chunk)
		_receive_voice_frames.rpc(chunk, current_volume)


@rpc("any_peer", "call_remote", "unreliable", rpc_channel)
func _receive_voice_frames(data: PackedVector2Array, data_volume: float):
	if not data.is_empty() and _playback.get_frames_available() >= data.size():
		current_volume = data_volume
		_playback.push_buffer(data)


func _set_mic_enabled(value: bool):
	mic_enabled = value
	
	if not is_node_ready():
		await ready
	
	if value:
		mic_changed.emit(true)
		input.play()
	else:
		mic_changed.emit(false)
		input.stop()


func _compute_rms(frames: PackedVector2Array) -> float:
	if frames.is_empty():
		return 0.0
	var sum_sq := 0.0
	for f in frames:
		var mono := (f.x + f.y) * 0.5
		sum_sq += mono * mono
	return sqrt(sum_sq / frames.size())
