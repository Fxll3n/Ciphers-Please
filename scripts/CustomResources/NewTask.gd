extends Resource
class_name NewTask

enum cypher {
	Ceasar, ## A monoalphabetic cipher that shifts the letters of the alphabet [member key] times.
	Atbash, ## A monoalphabetic cipher that reverses the alphabet. Eg: A=Z, B=Y, and etc...
	Vigenere, ## A polyalphabetic cipher that uses [member key]'s value, (if [member key] is a [String]).
	Rail, ## A cipher that orders the original text on a ZigZag Sequence that has [member key] rows/rails.
	PigPen ## A monoalphabetic cipher that replaces the letters of the alphabet with special symbols.
}

@export var msg: String ## The actual real message! [b]DO NOT PUT AN ALREADY ENCRYPTED MESSAGE.[/b]
@export var key: String ## When using a cipher that deals with shifts, put an integer instead of text.
@export var pay: int ## The reward value for how much the player will recieve for finishing.
@export var cipher_type: cypher ## The type of Cipher that will be used, Ceasar's by default.
@export var encrypted: bool = false ## If check, when the task is created for the terminal, it will give the player the encrypted version of the text instead of the actual plaintext.

var ciphertask

func setup():
	match cipher_type:
		cypher.Ceasar:
			ciphertask = CeasarTask.new()
			ciphertask.text = msg if !encrypted else Cipher.encryptCeasar(msg, int(key))
		cypher.Atbash:
			ciphertask = AtbashTask.new()
			ciphertask.text = msg if !encrypted else Cipher.encryptAtbash(msg)
		cypher.Vigenere:
			ciphertask = VigenereTask.new()
			ciphertask.text = msg if !encrypted else Cipher.encryptVigenere(msg, str(key))
		cypher.Rail:
			ciphertask = RailTask.new()
			ciphertask.text = msg if !encrypted else Cipher.encryptRail(msg, int(key))
		cypher.PigPen:
			ciphertask = PigPenTask.new()
			ciphertask.text = msg if !encrypted else Cipher.encryptPigPen(msg)
	print(ciphertask.text)
	var save_path = "res://CurrentTask/CurrentTask.tres"
	ResourceSaver.save(ciphertask, save_path)
	
