extends Node

class_name Cipher

const alphabet = "abcdefghijklmnopqrstuvwxyz"

static func encryptCaesar(plaintext: String, shifts: int) -> String:
	var ciphertext = ""
	for letter in plaintext:
		letter = letter.to_lower()
		if alphabet.find(letter) != -1:
			var position = alphabet.find(letter)
			var new_position = (position + shifts) % alphabet.length()
			ciphertext += alphabet[new_position]
		else:
			ciphertext += letter
	return ciphertext

static func encryptAtbash(plaintext: String) -> String:
	var ciphertext = ""
	for letter in plaintext:
		letter = letter.to_lower()
		var letterPos = alphabet.find(letter)
		if letterPos != -1:
			var new_letter_pos = alphabet.length() - letterPos - 1
			letter = alphabet[new_letter_pos]
			ciphertext += letter
	return ciphertext

static func encryptVigenere(plaintext: String, key: String) -> String:
	var ciphertext = ""
	plaintext = plaintext.to_lower()  # Convert to lowercase
	key = key.to_lower()  # Convert key to lowercase
	var key_index = 0  # Initialize the key index

	for letterNumber in range(plaintext.length()):
		var current_char = plaintext[letterNumber]
		
		if alphabet.find(current_char) == -1:
			ciphertext += current_char
			continue
		
		var text_pos = alphabet.find(current_char)
		var key_char = key[key_index % key.length()]
		var key_pos = alphabet.find(key_char)
		var new_pos = (text_pos + key_pos) % alphabet.length()

		print("Plaintext Char:", current_char, "Key Char:", key_char, "Text Pos:", text_pos, "Key Pos:", key_pos, "New Pos:", new_pos)
		ciphertext += alphabet[new_pos]
		key_index += 1

	return ciphertext



static func encryptRail(plaintext: String, rails: int) -> String:
	if rails <= 1:
		return plaintext
	plaintext = plaintext.replace(" ", "").replace(".", "").replace(",", "")
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
	return "".join(rail_lines)
