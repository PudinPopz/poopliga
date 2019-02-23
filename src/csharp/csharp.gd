extends Node

var is_working : bool = false

# Avoid static typing here to prevent bugs in non-mono builds
var WinFileDialog = load("res://src/csharp/FileDialog.cs")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Test script here
	if WinFileDialog != null:
		is_working = true
		print("C# Active")


