extends Node

var is_working : bool = false

# Avoid static typing here to prevent bugs in non-mono builds
var WinFileDialog = preload("res://src/csharp/FileDialog.cs")
var SpellCheck = preload("res://src/csharp/SpellCheck.cs")

func _ready() -> void:
	# Test script here
	if WinFileDialog != null:
		is_working = true
		print("C# Active")

	if !is_working:
		return

	# Warm up the spellchecker to prevent initial lag
	SpellCheck.WarmUp()

static func ignored_words_dict(input : String) -> Dictionary:
	var ignored_words_dict : Dictionary = {}
	var current_word : String = ""
	var text : String = input
	for i in range(len(text)):
		var character : String = text[i]
		var is_separator : bool = character in [' ', '\n', ',', ';']
		if is_separator or i >= len(text) - 1:
			if !is_separator:
				current_word += character
			if current_word != "":
				ignored_words_dict[(current_word.strip_edges().to_lower())] = ""
			current_word = ""
			continue
		current_word += character
	return ignored_words_dict