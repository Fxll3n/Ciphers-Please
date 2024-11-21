class_name Task extends Resource

@export var msg: String = "" ## The actual real message! [b]DO NOT PUT AN ALREADY ENCRYPTED MESSAGE.[/b]
@export var msg_type: Data.MessageType = Data.MessageType.Outgoing ## The type of task (direction of message, kinda).
@export var from_to: String = "" ## Who the message is from/to (cosmetic).
@export_range(0, 5, 1) var difficulty: int = 0 ## The difficulty of this task (cosmetic).
@export_range(0, 100, 1) var pay: int = 0 ## The reward value for how much the player will receive for finishing.
@export var key: String = "" ## When using a cipher that deals with shifts, put an integer instead of text.
@export var cipher_type: Data.CipherType = Data.CipherType.Plaintext ## The type of Cipher that will be used, Ceasar's by default.

## If true, when the task is created for the terminal, it will give the player the encrypted version of the text instead of the actual plaintext.
var encrypted: bool:
	get():
		return msg_type != Data.MessageType.Outgoing

## The message shown in the terminal
var input_text: String:
	get():
		if encrypted:
			return get_ciphertext()
		else:
			return msg

## The message the player should end up with
var expected_text: String:
	get():
		if encrypted:
			return msg
		else:
			return get_ciphertext()

## Get the ciphertext corresponding to this task
func get_ciphertext() -> String:
	match cipher_type:
		Data.CipherType.Plaintext:
			return msg
		Data.CipherType.Caesar:
			return Cipher.encryptCaesar(msg, int(key))
		Data.CipherType.Atbash:
			return Cipher.encryptAtbash(msg)
		Data.CipherType.Vigenere:
			return Cipher.encryptVigenere(msg, key)
		Data.CipherType.Rail:
			return Cipher.encryptRail(msg, int(key))
		Data.CipherType.PigPen:
			return Cipher.encryptPigPen(msg)
		_:
			breakpoint
			return ""
