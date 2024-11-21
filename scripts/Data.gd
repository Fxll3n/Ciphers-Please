extends Node
class_name Data

const MoneyUnit: String = "¢";

enum CipherType {
	Plaintext, ## No cipher, used for test purposes
	Caesar, ## A monoalphabetic cipher that shifts the letters of the alphabet [member key] times.
	Atbash, ## A monoalphabetic cipher that reverses the alphabet. Eg: A=Z, B=Y, and etc...
	Vigenere, ## A polyalphabetic cipher that uses [member key]'s value, (if [member key] is a [String]).
	Rail, ## A cipher that orders the original text on a ZigZag Sequence that has [member key] rows/rails.
	PigPen ## A monoalphabetic cipher that replaces the letters of the alphabet with special symbols.
}

static func GetCipherName(type: CipherType) -> String:
	const _names = {
		CipherType.Plaintext: "Plain text",
		CipherType.Caesar: "Caesar",
		CipherType.Atbash: "Atbash",
		CipherType.Vigenere: "Vigenère",
		CipherType.Rail: "Rail fence",
		CipherType.PigPen: "Pig pen",
	}
	if type in _names:
		return _names[type]
	return "Unknown"

static func CipherHasKey(type: CipherType) -> bool:
	match(type):
		CipherType.Plaintext, CipherType.Atbash, CipherType.PigPen:
			return false
	return true

## The type of message (from a gameplay perspective)
enum MessageType {
	Outgoing, ## Outgoing message, must be encrypted
	Incoming, ## Incoming message, must be decrypted
	Intercept, ## Intercepted message, must be decrypted, unknown key-
}
