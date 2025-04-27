class_name PigPen extends CipherTool

const section_margin_ratio = 0.1
@onready var line_color = (get_theme_stylebox("separator", "HSeparator") as StyleBoxLine).color
const line_width = 2
const text_color = Color(0.8, 0.9, 0.8)
const text_color_hover = Color(0.6, 1, 0.6)
@onready var dot_color = line_color
const x_directions = [Vector2.UP, Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN]

## The value currently hovered, 0 if not applicable
var current_value: String = '':
	set(value):
		if current_value != value:
			current_value = value
			queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(400, 400)


func get_section(x: int, y: int) -> Rect2:
	var half_size: float = min(size.x, size.y) / 2
	var square_offset = half_size * section_margin_ratio
	var square_side = half_size * (1 - section_margin_ratio * 2)
	var origin = size / 2 + Vector2.ONE * (square_offset - half_size)
	return Rect2(origin + Vector2(x, y) * half_size, Vector2(square_side, square_side))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_released() and current_value:
				letter_clicked.emit(current_value)
	if event is InputEventMouseMotion:
		var mouse_pos = event.global_position - global_position
		current_value = ''
		for dot in [0, 1]:
			var top_section = get_section(dot, 0)
			if top_section.has_point(mouse_pos):
				var scaled_pos = (mouse_pos - top_section.position) / top_section.size
				var x = int(min(floor(scaled_pos.x * 3), 2))
				var y = int(min(floor(scaled_pos.y * 3), 2))
				var code_point = 65 + dot * 9 + y * 3 + x
				current_value = char(code_point)
			
			var bottom_section = get_section(dot, 1)
			if bottom_section.has_point(mouse_pos):
				var distance = bottom_section.get_center().distance_to(mouse_pos)
				var angle = bottom_section.get_center().angle_to_point(mouse_pos)
				if 15 < distance and distance < 60:
					var index = 2
					if abs(angle) > PI * 3 / 4:
						index = 1
					elif angle < - PI / 4:
						index = 0
					elif angle > PI / 4:
						index = 3
					var code_point = 65 + 18 + dot * 4 + index
					current_value = char(code_point)
		set_default_cursor_shape(Control.CURSOR_POINTING_HAND if current_value else Control.CURSOR_ARROW)


func _draw() -> void:
	var font = get_theme_font("font", "Label")

	# Draw the # symbols
	for dot in [0, 1]:
		var rect = get_section(dot, 0)
		var origin: Vector2 = rect.position
		var side: float = rect.size.x
		
		draw_line(origin + Vector2(side / 3, 0), origin + Vector2(side / 3, side), line_color, line_width)
		draw_line(origin + Vector2(side * 2 / 3, 0), origin + Vector2(side * 2 / 3, side), line_color, line_width)
		draw_line(origin + Vector2(0, side / 3), origin + Vector2(side, side / 3), line_color, line_width)
		draw_line(origin + Vector2(0, side * 2 / 3), origin + Vector2(side, side * 2 / 3), line_color, line_width)
		
		for x in range(3):
			for y in range(3):
				var code_point = 65 + dot * 9 + y * 3 + x
				var letter = char(code_point)
				#var pos = origin + Vector2(x, y + 0.66) / 3 * side
				var pos = origin + Vector2(x + 0.5, y + 0.5) / 3 * side
				var color = text_color_hover if letter == current_value else text_color
				draw_string_centered(font, pos, letter, (int)(side / 5), color)

				if dot:
					var center_pos = origin + (Vector2(x, y) * 2 + Vector2.ONE) / 6 * side
					var dot_pos = center_pos + Vector2(1 - x, 1 - y) / 9 * side
					if x == 1 and y == 1:
						dot_pos += Vector2(0, side / 9)
					draw_circle(dot_pos, 3, dot_color, true, -1, true)

	# Draw the X symbols
	for dot in [0, 1]:
		var rect = get_section(dot, 1)
		var origin: Vector2 = rect.position
		var side: float = rect.size.x
		var center = rect.get_center()
		
		draw_line(origin, origin + Vector2(side, side), line_color, line_width)
		draw_line(origin + Vector2(side, 0), origin + Vector2(0, side), line_color, line_width)
		
		for i in range(len(x_directions)):
			var code_point = 65 + 18 + dot * 4 + i
			var letter = char(code_point)
			var pos = center + x_directions[i] / 4 * side
			var color = text_color_hover if letter == current_value else text_color
			draw_string_centered(font, pos, letter, (int)(side / 5), color)
			
			if dot:
				var dot_pos = center + x_directions[i] / 9 * side
				draw_circle(dot_pos, 3, dot_color, true, -1, true)


func draw_string_centered(font: Font, pos: Vector2, text: String, font_size: int, color: Color):
	const arbitrary_x_offset = 1
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var offset = Vector2(arbitrary_x_offset - text_size.x / 2, font.get_ascent(font_size) - text_size.y / 2)
	draw_string(font, pos + offset, text, HORIZONTAL_ALIGNMENT_CENTER, text_size.x, font_size, color)
	#draw_circle(pos, 2, Color.CYAN)
