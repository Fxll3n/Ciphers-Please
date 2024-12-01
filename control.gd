extends Control
class_name VigenereTable

const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var key: String = ALPHABET
var encrypt: bool = true
var hover_row = -1
var hover_col = -1

func _draw():
	var rect_size = size
	var rows = ALPHABET.length()
	var cols = key.length()
	var cell_width = rect_size.x / (cols + 1) # Automatically resizes the width and height to fit neatly in parent node.
	var cell_height = rect_size.y / (rows + 1)
	var font = get_theme_font("font", "Label")
	var font_size = int(min(cell_width, cell_height) * 0.8)

	# Draw table + headers
	# Simple ass nested for loop
	for row in rows:
		for col in cols:
			var cell_rect = Rect2(
				Vector2((col+1) * cell_width, (row+1) * cell_height), 
				Vector2(cell_width, cell_height)
			)
			
			# Highlight bulshit
			var cell_color = Color.WHITE
			if row == hover_row or col == hover_col:
				cell_color = Color(0.6, 0.8, 0.6, 1)
			
			# Draw cell
			draw_rect(cell_rect, cell_color, true)
			draw_rect(cell_rect, Color.DARK_GRAY, false)
			
			# Draw letters
			var letter_color = Color.BLACK
			
			if row == 1:
				# Top header
				draw_string(font, 
					Vector2((col+1) * cell_width + cell_width/3, cell_height*3/4), 
					key[col], 
					HORIZONTAL_ALIGNMENT_LEFT, 
					-1, 
					font_size, 
					Color.DARK_GRAY if col != hover_col else Color.GREEN
				)
			
			if col == 1:
				# Side header
				draw_string(font, 
					Vector2(cell_width/3, (row+1) * cell_height + cell_height*3/4), 
					ALPHABET[row], 
					HORIZONTAL_ALIGNMENT_LEFT, 
					-1, 
					font_size, 
					Color.DARK_GRAY if row != hover_row else Color.GREEN
				)
			
			# Cipher letter
			var shifted_index = (row + ALPHABET.find(key[col])) % 26
			if not encrypt:
				shifted_index = (row + 26 - ALPHABET.find(key[col])) % 26
				
			draw_string(font, 
				cell_rect.position + Vector2(cell_width/3, cell_height*3/4), 
				ALPHABET[shifted_index], 
				HORIZONTAL_ALIGNMENT_LEFT, 
				-1, 
				font_size,
				letter_color
			)

func _input(event):
	if event is InputEventMouseMotion:
		var rect_size = size
		var rows = ALPHABET.length()
		var cols = key.length()
		var cell_width = rect_size.x / (cols + 1)
		var cell_height = rect_size.y / (rows + 1)
		
		var local_pos = get_local_mouse_position()
		
		# Calculate hover row and column
		hover_row = int(local_pos.y / cell_height) - 1
		hover_col = int(local_pos.x / cell_width) - 1
		
		if hover_row < 0 or hover_row >= rows:
			hover_row = -1
		if hover_col < 0 or hover_col >= cols:
			hover_col = -1
		
		queue_redraw()
