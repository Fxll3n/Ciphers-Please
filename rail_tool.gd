extends Control
class_name RailTool

# The message to display
var message: String
# List to hold references to letter labels
var letter_labels: Array = []

# Called when the node enters the scene tree for the first time.


# Function to create letter labels
func create_letter_row():
	var x_offset = 0  # X-position offset to arrange the letters in a row
	var y_offset = 0
	for i in range(message.length()):
		var letter = message[i]
		
		# Create a new Label for each character
		var letter_label = Label.new()
		letter_label.text = letter
		
		# Set the initial position of the letter in the row
		letter_label.position = Vector2(x_offset, y_offset)
		add_child(letter_label)  # Add label as child to this Control node
		
		# Store the label for later use
		letter_labels.append({
			"label": letter_label,
			"dragging": false  # Track if the label is being dragged
		})
		
		# Update the offset to position the next letter
		x_offset += 15  # Move the next letter to the right
		if x_offset > 300:
			x_offset = 0
			y_offset += 35

# Input event for dragging letters
func _input(event):
	if event is InputEventMouseButton:
		for letter_data in letter_labels:
			var label = letter_data["label"]
			if event.pressed and label.get_global_rect().has_point(event.position):
				letter_data["dragging"] = true
			elif not event.pressed:
				letter_data["dragging"] = false
	
	elif event is InputEventMouseMotion:
		for letter_data in letter_labels:
			if letter_data["dragging"]:
				var label = letter_data["label"]
				label.position += event.relative
