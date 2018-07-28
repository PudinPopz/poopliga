extends Node2D

const DialogueDictionary = preload("res://src/dialogue_editor/dialogue_dictionary.gd")
const DialogueBlock = preload("res://src/dialogue_editor/dialogue_block.tscn")
const theme = preload("res://themes/default_theme.tres")
const fnt_noto_sans_16 = preload("res://fonts/NotoSans_16.tres")
#const Lato16 = preload("res://fonts/lato_16.tres")

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
	
	#fill_with_garbage_blocks(666)
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
	thing.access = FileDialog.ACCESS_FILESYSTEM
	thing.current_dir = "C:\\Users\\jamie\\Documents"
	thing.resizable = true
	thing.theme = theme
	thing.theme.default_font = fnt_noto_sans_16
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
			pos_x = visual_block.position.floor().x, # JSON does not support Vector2
			pos_y = visual_block.position.floor().y
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
	saveas_dialog.rect_position += Vector2(0,10)
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
		new_block.randomise_id()
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
		new_block.randomise_id()
		new_block.position = mouse_pos
		new_block.previous_pos = mouse_pos

		
		# @TODO: ADD UNDO EQUIVALENT TO BUFFER
		
		
		pass
	double_click_timer = double_click_timer_time

var confirm_create_new = null

func _on_New_pressed():
	# Create popup if doesn't exist
	if confirm_create_new == null:
		confirm_create_new = ConfirmationDialog.new()
		confirm_create_new.theme = theme
		confirm_create_new.theme.default_font = fnt_noto_sans_16 
		confirm_create_new.dialog_text = "Create a new empty file? \nAny unsaved progress will be lost :("	
		get_node("FrontWindows").add_child(confirm_create_new)
		confirm_create_new.connect("confirmed",self,"reset")
	confirm_create_new.popup_centered()


func reset():
	# Clear everything on board
	for child in DialogueBlocks.get_children():
		child.queue_free()
	
	CAMERA2D.position = Vector2(640,360)
	CAMERA2D.camera_previous_pos = CAMERA2D.position
	
	pass

func _on_Options2_focus_exited():
	pass # Replace with function body.
