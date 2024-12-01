extends AudioStreamPlayer

@onready var audio = $"."

func play_audio():
	audio.play()
func stop_audio():
	audio.stop()
