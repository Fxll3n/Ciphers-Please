extends AudioStreamPlayer

@onready var audio = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func play_audio():
	audio.play()
func stop_audio():
	audio.stop()
