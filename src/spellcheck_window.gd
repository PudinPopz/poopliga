extends WindowDialog

onready var item_list : ItemList = $ItemList
onready var error_count_label : Label = $ErrorCountLabel

onready var ignore_word_button : Button = $HBoxContainer/IgnoreWord 
onready var ignore_block_button : Button = $HBoxContainer/IgnoreBlock 

var error_arr : Array = []
var item_index : int = -99

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !CSharp.is_working:
		queue_free()
		return
	connect("visibility_changed", self, "on_visibility_changed")
	$CheckButton.connect("pressed", self, "on_check_pressed")
	$ItemList.connect("item_selected", self, "on_item_selected")
	error_count_label.text = ""
	
	ignore_word_button.connect("pressed", self, "on_word_ignored")
	ignore_block_button.connect("pressed", self, "on_block_ignored")
	
	CSharp.SpellCheck.GetInstance().connect("SuggestionComplete", self, "on_suggestion_complete")
	
func on_visibility_changed():
	if visible:
		on_check_pressed()

func on_check_pressed():
	var blocks : Array = Editor.blocks.get_children()
	error_arr = CSharp.SpellCheck.CheckBlocks(blocks)

	# Sort error_arr by block y pos
	error_arr.sort_custom(Sorter, "spellcheck_y_pos")

	item_list.clear()
	for error in error_arr:
		var error_string : String
		error_string = '"' + error.Word +'" at '
		error_string += error.Block.id + " : " + str(error.Index)
		item_list.add_item(error_string)
		item_list.set_item_tooltip_enabled(item_list.get_item_count() - 1, false)
	

	# Update error count label
	var error_count : int = len(error_arr)
	match error_count:
		0:
			error_count_label.text = "No errors found."
		1:
			error_count_label.text = "1 error found."
		_:
			error_count_label.text = str(error_count) + " errors found."

	$SuggestionLabel.text = ""

func on_item_selected(index : int):
	item_index = index
	
	var word : String = error_arr[index].Word
	
	var block : DialogueBlock = error_arr[index].Block
	MainCamera.lerp_time = 0
	MainCamera.lerp_camera_pos(block.rect_position)
	Editor.set_selected_block(block)
	
	$SuggestionLabel.text = "Calculating suggestions..."
	CSharp.SpellCheck.RunSuggestionThread(word)

func on_suggestion_complete():
	var suggestions = CSharp.SpellCheck.GetCurrentSuggestions()
	var output_text : String = ""
	output_text += "Suggestions: "
	for i in range(suggestions.size()):
		output_text += suggestions[i]
		if i < suggestions.size() - 1:
			output_text += ", "
	$SuggestionLabel.text = output_text

func get_suggestions_arr(word : String):
	return CSharp.SpellCheck.GetSuggestions(word)

func on_word_ignored():
	if item_index < 0:
		return
		
	var word : String = error_arr[item_index].Word
	var new_list : String = Editor.current_meta_block.project_settings["spellcheck_ignored_words"] + "\n" + word
	new_list = new_list.strip_edges()
	Editor.current_meta_block.project_settings["spellcheck_ignored_words"] = new_list
	Editor.emit_signal("spellcheck_ignore_list_updated")
	on_check_pressed()
	
func on_block_ignored():
	if item_index < 0:
		return
	
	var block_id : String = error_arr[item_index].Block.id
	var new_list : String = Editor.current_meta_block.project_settings["spellcheck_ignored_words"] + "\n" + '"' + block_id + '"'
	new_list = new_list.strip_edges()
	Editor.current_meta_block.project_settings["spellcheck_ignored_words"] = new_list
	Editor.emit_signal("spellcheck_ignore_list_updated")
	on_check_pressed()

class Sorter:
	static func spellcheck_y_pos(a, b):
		if a.Block.rect_position.y < b.Block.rect_position.y:
			return true
		return false