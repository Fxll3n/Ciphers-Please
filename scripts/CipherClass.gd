class_name Cipher extends Node

const alphabet = "abcdefghijklmnopqrstuvwxyz"


## UTILITIES


static func _getLetter(c: String) -> int:
	return alphabet.find(c.to_lower())

static func _setLetter(c: String, new: int) -> String:
	if new < 0 or new >= alphabet.length():
		return c
	if c == c.to_lower():
		return alphabet[new]
	return alphabet[new].to_upper()

static func stripNonLetters(text: String, exceptions: String = "") -> String:
	var stripped = ""
	for letter in text:
		if alphabet.contains(letter.to_lower()) or exceptions.contains(letter):
			stripped += letter
	return stripped


## CIPHERS


static func encryptCaesar(plaintext: String, shifts: int) -> String:
	var ciphertext = ""
	for letter in plaintext:
		var position = _getLetter(letter)
		if position != -1:
			position = (position + shifts) % alphabet.length()
		ciphertext += _setLetter(letter, position)
	return ciphertext

static func encryptAtbash(plaintext: String) -> String:
	var ciphertext = ""
	for letter in plaintext:
		var position = _getLetter(letter)
		if position != -1:
			position = alphabet.length() - position - 1
		ciphertext += _setLetter(letter, position)
	return ciphertext

static func encryptVigenere(plaintext: String, key: String) -> String:
	var ciphertext = ""
	key = key.to_lower() # Convert key to lowercase
	var key_index = 0 # Initialize the key index

	for letter in plaintext:
		var position = _getLetter(letter)
		if position != -1:
			var key_char = key[key_index % key.length()]
			var key_pos = alphabet.find(key_char)
			position = (position + key_pos) % alphabet.length()
			key_index += 1
		ciphertext += _setLetter(letter, position)
	return ciphertext


static func encryptRail(plaintext: String, rails: int) -> String:
	plaintext = stripNonLetters(plaintext, '"')
	if rails <= 1:
		return plaintext
	var rail_lines := []
	for i in range(rails):
		rail_lines.append("")
	var current_rail = 0
	var direction_down = true
	for character in plaintext:
		rail_lines[current_rail] += character
		if current_rail == 0:
			direction_down = true
		elif current_rail == rails - 1:
			direction_down = false
		current_rail += 1 if direction_down else -1
	var result = "".join(rail_lines)
	# Insert spaces for readability
	for index in range(result.length() / 8, 0, -1):
		result = result.insert(index * 8, ' ')
	return result
