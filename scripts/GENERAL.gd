extends Node

var scene_before = ".":
	set(new_scene):
		scene_before = new_scene
		if scene_before == "Menu":
			MenuAudio.play()
		else:
			MenuAudio.stop()
			
