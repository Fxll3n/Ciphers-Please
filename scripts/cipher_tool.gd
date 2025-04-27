class_name CipherTool extends Control

## Whether this message is being encrypted or decrypted
@export var encrypting: bool
## The key associated to this message, if any
@export var key: String
## The input message
@export var message: String

## Emitted whenever a letter is clicked
signal letter_clicked(letter: String)
