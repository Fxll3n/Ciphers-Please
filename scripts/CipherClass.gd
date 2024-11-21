extends Node
class_name Cipher
const alphabet = "abcdefghjklmnopqrstuvwxyz"

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
			var new_letter_pos = abs(letterPos - alphabet.length()+1)
			letter = alphabet[new_letter_pos]
			
			ciphertext += letter
	
	return ciphertext

static func encryptVigenere(plaintext: String, key: String) -> String:
	var ciphertext = ""
	plaintext = plaintext.to_lower()
	key = key.to_lower()
	for letterNumber in plaintext.length():
		var text_pos = alphabet.find(plaintext[letterNumber])
		var key_pos = alphabet.find(key[letterNumber % key.length()])
		var new_pos = (text_pos + key_pos) % alphabet.length()
		ciphertext += alphabet[new_pos]
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

static func encryptPigPen(plaintext: String) -> String:
	var symbols = {
		"a": "⊓", "b": "⊐", "c": "⊏", "d": "⊒",
		"e": "∠", "f": "∟", "g": "⊥", "h": "⊢",
		"i": "⊣", "j": "◊", "k": "□", "l": "△",
		"m": "▽", "n": "○", "o": "⬡", "p": "⬢",
		"q": "★", "r": "☆", "s": "∴", "t": "∵",
		"u": "⋮", "v": "⋯", "w": "⋰", "x": "⋱",
		"y": "∷", "z": "⊙" 
	}
	
	var ciphertext = ""
	for c in plaintext.to_lower():
		if symbols.has(c):
			ciphertext += symbols[c]
		else:
			ciphertext += c
	return ciphertext
