extends Pickupable

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

func use():
	play_sfx.rpc()


@rpc("any_peer", "call_local")
func play_sfx():
	audio_stream_player_3d.play()
