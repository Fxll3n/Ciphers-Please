extends Control

var master_bus = AudioServer.get_bus_index("SFX")



func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value - 20)
	
	if value == 0:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
