extends HSlider

@export_enum("Master", "Music", "SFX") var bus: String = ''
@onready var bus_index = AudioServer.get_bus_index(bus)

func _ready() -> void:
	min_value = -30
	max_value = 0
	if bus_index < 0:
		editable = false
		print("Unknown audio bus: ", bus)
	else:
		value = AudioServer.get_bus_volume_db(bus_index)
		connect("value_changed", _on_value_changed)

func _on_value_changed(new_value):
	AudioServer.set_bus_volume_db(bus_index, new_value)
	AudioServer.set_bus_mute(bus_index, new_value == min_value)
