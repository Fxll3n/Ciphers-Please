class_name Validator extends SyntaxHighlighter

@export var expected: String:
	set(value):
		expected = value
		expected_stripped = strip(expected, expected_map)

@export var input: String:
	set(value):
		input = value
		input_stripped = strip(input, input_map)

# Same as the above strings, but only alphabetical characters and all lowercase
var expected_stripped: String
var input_stripped: String

# Maps character indices in the _stripped string to their index in the original string
var expected_map: Dictionary
var input_map: Dictionary

@export var show_highlight: bool = false

var similarity_index: float = 0 # 1 for virtually identical strings
var last_index: int = 0 # index of first expected character not in the input string
var incorrect_indices = [] # indices of characters in the input string which do not match the expected characters


func _get_line_start_index(text: String, line: int) -> int:
	if line == 0:
		return 0
	return 1 + text.find('\n', _get_line_start_index(text, line - 1))


func _get_line_syntax_highlighting(line: int) -> Dictionary:
	# Update internal state if needed
	if get_text_edit() != null and get_text_edit().text != input:
		input = get_text_edit().text
		update_similarity_index()
	if not show_highlight:
		return {}
	# Compute highlight
	var line_index = _get_line_start_index(input, line)
	var styles = {}
	var i = 0
	while i < incorrect_indices.size():
		var start = incorrect_indices[i]
		var end = start + 1
		i += 1
		while i < incorrect_indices.size() and incorrect_indices[i] == end:
			i += 1
			end += 1
		styles[start - line_index] = {"color": Color.RED}
		styles[end - line_index] = {}
	return styles


func strip(text: String, mapping_out: Dictionary) -> String:
	var index = 0
	var result = ""
	mapping_out.clear()
	for letter in text:
		if letter.to_lower() in Cipher.alphabet:
			mapping_out[result.length()] = index
			result += letter.to_lower()
		index += 1
	return result


func update_similarity_index():
	var a = expected_stripped
	var b = input_stripped
	var correct := 0
	incorrect_indices.clear()
	var i := 0
	var j := 0
	while i < a.length() and j < b.length():
		if a[i] == b[j]:
			correct += 1
		elif i + 2 < a.length() and j + 1 < b.length() and a.substr(i + 1, 2) == b.substr(j, 2):
			correct += 1
			i += 1
		elif i + 1 < a.length() and j + 2 < b.length() and a.substr(i, 2) == b.substr(j + 1, 2):
			incorrect_indices.append(input_map[j])
			correct += 1
			j += 1
		else:
			incorrect_indices.append(input_map[j])
		# Increment both indices
		i += 1
		j += 1
	last_index = 0 if i == 0 else expected_map[i - 1] + 1
	similarity_index = correct / float(a.length())
