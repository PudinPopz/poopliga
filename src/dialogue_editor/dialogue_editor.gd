extends Node2D

const DialogueDictionary = preload("res://src/dialogue_editor/dialogue_dictionary.gd")
const DialogueBlock = preload("res://src/dialogue_editor/dialogue_block.tscn")
#var theme0 = load("res://themes/0.tres")
const Lato16 = preload("res://fonts/lato_16.tres")

onready var DialogueBlocks = get_node("Map/DialogueBlocks")
var saveas_dialog

var dialogue_dictionary
var lowest_position = -99999999

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_process(true)
	dialogue_dictionary = DialogueDictionary.new()
	dialogue_dictionary.test()
	update_lowest_position()
	saveas_dialog = create_saveas_file_dialog()
	
	fill_with_garbage_blocks(900)
	pass 

var double_click_timer_time = 0.35
var double_click_timer = 0
func _process(delta):
	double_click_timer -= delta
	double_click_timer = clamp(double_click_timer, 0, double_click_timer_time)
	pass

func create_saveas_file_dialog():
	var thing = FileDialog.new()
	get_node("FrontWindows").add_child(thing)
	#thing.popup(Rect2(0,100,1200,600))
	#thing.popup_exclusive = true
	thing.access = FileDialog.ACCESS_FILESYSTEM
	thing.current_dir = "C:\\Users\\jamie\\Documents"
	thing.resizable = true
	thing.theme = Theme.new()
	thing.theme.default_font = Lato16 
	thing.add_filter("*.poopliga")
	thing.mode = FileDialog.MODE_SAVE_FILE
	thing.connect("file_selected",self,"save_as")
	thing.connect("popup_hide",self,"_on_popup_hide")
	return thing

# Calculates and updates lowest position of a dialogue block. SOMEWHAT RESOURCE INTENSIVE.
func update_lowest_position():
	#var start_time = OS.get_ticks_msec()
	var lowest = -99999999
	for block in DialogueBlocks.get_children():
		if block.position.y > lowest:
			lowest = block.position.y
	lowest_position = lowest # Update lowest_position - wouldn't want to waste this precious call
	#print("Calculated lowest position in " + str(OS.get_ticks_msec()-start_time) + "ms.")
	return lowest

# Saves blocks to dictionary - NOT file!
func save_blocks_to_dictionary():
	# Clear dictionary
	dialogue_dictionary.clear_all()
	# Add data of all children of DialogueBlocks to dictionary
	for visual_block in DialogueBlocks.get_children():
		# Create actual block
		var actual_block = {
			key = visual_block.id_Label.text,
			dialogue = visual_block.DialogueRichTextLabel.text,
			character = visual_block.CharacterLineEdit.text,
			choices = [],
			tail = "",
			code = "",
			position = visual_block.position,

		}
		# Store actual block in dictionary
		dialogue_dictionary.add(actual_block.key, actual_block)
		pass
	pass

func _on_popup_hide():
	CAMERA2D.freeze = false
	pass
func _on_Save_pressed():
	# if not already open (@TODO)
	saveas_dialog.popup_centered(Vector2(1200,600))
	CAMERA2D.freeze = true
	pass # Replace with function body.

func save_as(path):
	var start_time = OS.get_ticks_msec()
	save_blocks_to_dictionary()

	var file = File.new()
	var json = to_json(dialogue_dictionary.dictionary)
	file.open(path, File.WRITE)
	file.store_string(json)
	file.close()
	
	var end_time_str = "Saved " + str(dialogue_dictionary.dictionary.size()) + " blocks in " + str(OS.get_ticks_msec()-start_time) + "ms."
	print(end_time_str)
	pass

func fill_with_garbage_blocks(amount):
	for i in range(amount):
		var new_block = DialogueBlock.instance()
		DialogueBlocks.add_child(new_block)
		new_block.id_Label.text = str(OS.get_ticks_usec()).sha256_text().substr(0,10)
		new_block.position = Vector2(0,rand_range(0,9990))
		new_block.fill_with_garbage()
		
		#new_block.visible = false
	
	pass


func _on_BackUIButton_pressed():
	if double_click_timer > 0.001 or Input.is_action_pressed("ctrl"):
		# Register double click
		var mouse_pos = get_global_mouse_position()
		var new_block = DialogueBlock.instance()
		new_block.just_created = true
		DialogueBlocks.add_child(new_block)
		new_block.id_Label.text = str(OS.get_ticks_usec()).sha256_text().substr(0,10)
		new_block.position = mouse_pos
		new_block.previous_pos = mouse_pos

		
		# @TODO: ADD UNDO EQUIVALENT TO BUFFER
		
		
		pass
	double_click_timer = double_click_timer_time
	
	
	


	pass # Replace with function body.
