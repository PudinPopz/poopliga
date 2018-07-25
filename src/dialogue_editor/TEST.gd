extends Node

const DialogueDictionary = preload("res://src/dialogue_editor/dialogue_dictionary.gd")

var dialogue_dictionary
# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_dictionary = DialogueDictionary.new()
	dialogue_dictionary.test()
	pass 

func open_file_dialog():
	var thing = FileDialog.new()
	add_child(thing)
	thing.popup(Rect2(0,0,1200,600))
	thing.access = thing.ACCESS_FILESYSTEM
	thing.current_dir = "C:\\Users\\jamie\\Documents"
	print(thing.current_dir)


