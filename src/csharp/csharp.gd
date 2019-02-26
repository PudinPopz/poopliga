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
