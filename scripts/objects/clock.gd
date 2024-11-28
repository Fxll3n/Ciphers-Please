extends Node3D

enum ClockMode {
	Hours12,
	Hours24,
	Minutes,
}

@export_category("Clock properties")
## Start time of the clock (minutes for Hours mode, seconds otherwise)
@export var start_time: int = 1*60+23;
@onready var time = start_time:
	set(new_time):
		time = new_time
		if not alarm_beeping:
			set_time(new_time)
## Mode of the clock (12H, 24H, or minutes:seconds)
@export var mode: ClockMode = ClockMode.Hours24
## Whether the colon should blink
@export var blink_colon: bool = true

@export_category("Timer")
@export var autostart: bool = true
@export var interval: float = 1.0
@export var increment: int = 1

## Exact at which the alarm beeps
var alarm_time: int = -1
var alarm_beeping: bool = false
const alarm_blink_time: float = 10

## Emitted when the alarm starts beeping
signal alarm_triggered(time: int)

## Maps character to bits, with MSB=a, LSB=h (look up 7-segment diagrams)
const CHAR_TO_BITS = {
	' ': 0b00000000,
	'0': 0b11111100,
	'1': 0b01100000,
	'2': 0b11011010,
	'3': 0b11110010,
	'4': 0b01100110,
	'5': 0b10110110,
	'6': 0b10111110,
	'7': 0b11100000,
	'8': 0b11111110,
	'9': 0b11110110,
	'a': 0b11101110,
	'b': 0b00111110,
	'c': 0b10011100,
	'd': 0b01111010,
	'e': 0b10011110,
	'f': 0b10001110,
};

## Max time in minutes/seconds per clock mode
const WRAP_TIME = {
	ClockMode.Hours12: 13*60, # Special case to show up to 12:59
	ClockMode.Hours24: 24*60,
	ClockMode.Minutes: 60*60,
}

func _ready() -> void:
	# Setup viewport
	$Viewport.size = $Viewport/ClockFace/Background.size
	
	# Setup timer
	$Timer.wait_time = interval
	$ColonTimer.wait_time = interval / 2
	if autostart:
		$Timer.start()
		if blink_colon:
			$ColonTimer.start()

	# Setup clock
	set_time(start_time)

## Advance time and update clock
func _on_timer_timeout() -> void:
	time += increment
	if time >= WRAP_TIME[mode]:
		time -= WRAP_TIME[mode]
		if mode == ClockMode.Hours12: # Special case to show up to 12:59
			time += 60
	if not alarm_beeping:
		set_time(time)
		if time == alarm_time:
			_start_alarm()

## Blink the colon
func _on_colon_timer_timeout() -> void:
	if not alarm_beeping:
		$Viewport/ClockFace/Colons.visible =  !$Viewport/ClockFace/Colons.visible

## Blink entire clock face when alarm is beeping
func _on_alarm_blink_timer_timeout() -> void:
	assert(alarm_beeping)
	if $Viewport/ClockFace/Colons.visible:
		## Hide digits
		for i in range(0, 4):
			set_char(i, ' ')
		$Viewport/ClockFace/Colons.visible = false
	else:
		## Show digits
		set_time(alarm_time)
		$Viewport/ClockFace/Colons.visible = true

## Set the time to display on the clock
func set_time(minutes: int) -> void:
	assert(minutes <= (99 * 60 + 99))
	@warning_ignore("integer_division")
	var text: String = '%2d%02d' % [minutes / 60, minutes % 60];
	for i in range(0, 4):
		set_char(i, text[i])

## Set the character to display on one clock digit
func set_char(index: int, character: String) -> void:
	assert(index < 4);
	var sprite = $Viewport/ClockFace/Digits.get_child(index) as Node2D;
	if sprite and sprite.material:
		sprite.material.set_shader_parameter('bits', CHAR_TO_BITS[character])

## Start beeping the alarm
func _start_alarm() -> void:
	get_tree().create_timer(alarm_blink_time).connect("timeout", _stop_alarm)
	alarm_beeping = true
	$Viewport/ClockFace/Colons.visible = true # required for correct animation
	$AlarmBlinkTimer.start()
	$Beep.play()
	alarm_triggered.emit(alarm_time)

## Stop beeping the alarm
func _stop_alarm() -> void:
	$AlarmBlinkTimer.stop()
	$Viewport/ClockFace.visible = true
	$Viewport/ClockFace/Colons.visible = true
	alarm_beeping = false
	set_time(time)
