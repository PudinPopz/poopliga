extends Control

const MetaBlock = preload("res://src/blocks/meta_block.tscn")
const DBScript = preload("res://src/blocks/dialogue_block.gd")
const DialogueBlock = preload("res://src/blocks/dialogue_block.tscn")
const TitleBlock = preload("res://src/blocks/title_block.tscn")
const CommentBlock = preload("res://src/blocks/comment_block.tscn")
const BranchBlock = preload("res://src/blocks/branch_block.tscn")

const fnt_noto_sans_16 = preload("res://fonts/NotoSans_16.tres")

const DEFAULT_LOWEST_POSITION = 400
const DEFAULT_HIGHEST_POSITION = -400

onready var blocks = get_node("Map/Blocks")
onready var cursor = get_node("Map/Cursor")
onready var control = get_node("Control")
onready var script_mode = get_node("ScriptModeLayer/ScriptMode")


var saveas_dialog

var lowest_position = DEFAULT_LOWEST_POSITION
var highest_position = DEFAULT_HIGHEST_POSITION

var current_folder
var current_file = ""

var is_ctrl_down := false
var is_alt_down := false
var is_shift_down := false

var current_meta_block = null

var focus = null
var last_focus = null

func _input(event):
	cursor.position = get_global_mouse_position()

	if event is InputEventWithModifiers and !event.is_echo():
		is_ctrl_down = event.control or event.command
		is_alt_down = event.alt
		is_shift_down = event.shift

	focus = control.get_focus_owner()

	# @TODO: Add system for remembering previous and jumping back to it
	if is_ctrl_down and Input.is_action_just_pressed("enter"):
		if focus is TextEdit and focus.name == "DialogueTextEdit":
			var block = focus.get_parent().get_parent()
			var tail_block
			if block.tail == "":
				tail_block = block.spawn_block_below()
			else:
				tail_block = blocks.get_node(block.tail)
				MainCamera.lerp_camera_pos(Vector2(MainCamera.position.x, tail_block.rect_position.y) + Vector2(0, 200), 0.5)
			tail_block.dialogue_line_edit.readonly = true
			tail_block.dialogue_line_edit.grab_focus()
			yield(get_tree().create_timer(0), "timeout")
			tail_block.dialogue_line_edit.readonly = false

	if is_ctrl_down and Input.is_action_just_pressed("t"):
		script_mode.visible = !script_mode.visible
		if script_mode.visible:
			last_focus = control.get_focus_owner()
			script_mode.get_node("TextEdit").grab_focus()
		else:
			if is_node_alive(last_focus):
				last_focus.grab_focus()


	if event is InputEventKey:
		handle_focus_shortcuts(event)

func handle_focus_shortcuts(event):
	if focus == null:
		return
	var block = focus.owner
	if block == null or !(block is DBScript):
		return
	if event.alt and event.scancode == KEY_C:
		block.character_line_edit.grab_focus()
	if event.alt and event.scancode == KEY_D:
		block.dialogue_line_edit.grab_focus()
	if event.alt and event.scancode == KEY_I:
		block.id_label.grab_focus()


# Called when the node enters the scene tree for the first time.
func _ready():
	theme = preload("res://themes/default_theme.tres")
	current_folder = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	randomize()
	set_process(true)
	reset()
	saveas_dialog = create_saveas_file_dialog()
	fix_popin_bug(10)

var double_click_timer_time = 0.35
var double_click_timer = 0
var already_refreshed = false
var last_unix_time = 0
func _process(delta):
	if delta == 0: return
	# Handle window title bar
	if int(OS.get_unix_time()) != int(last_unix_time):
		var title_str = ""
		if current_file != "":
			title_str += current_file + " | "
		title_str += "McFakeFake Poopliga Dialogue Editor Professional 2019 | FPS: " + str(int(1/delta))
		OS.set_window_title(title_str)
		last_unix_time = OS.get_unix_time()

	# Handle double click stuff
	double_click_timer -= delta
	double_click_timer = clamp(double_click_timer, 0, double_click_timer_time)

	# Handle rendering bug workaround
	if Input.is_action_just_pressed("refresh") or !already_refreshed:
		fix_rendering_bug()
		fix_popin_bug()
		already_refreshed = true

var _pending_render_bug_fix = false
var _pending_render_bug_fix_timer = 0

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT \
	or what == MainLoop.NOTIFICATION_WM_UNFOCUS_REQUEST:
		_pending_render_bug_fix = true

# Fix for weird rendering bug after tab out	(CAN BE SLOW)
func fix_rendering_bug():

	var start_time = OS.get_ticks_msec()
	blocks.visible = false
	blocks.visible = true
	print("Fixing rendering bug in ", OS.get_ticks_msec() - start_time, "ms")

	return

func create_saveas_file_dialog():
	var thing = FileDialog.new()
	get_node("FrontWindows").add_child(thing)
	thing.access = FileDialog.ACCESS_FILESYSTEM
	thing.current_dir = current_folder
	thing.current_file = current_file
	thing.resizable = true
	thing.theme = theme
	thing.theme.default_font = fnt_noto_sans_16
	thing.add_filter("*.poopliga")
	thing.mode = FileDialog.MODE_SAVE_FILE
	thing.connect("file_selected",self,"save_as")
	thing.connect("popup_hide",self,"_on_popup_hide")
	return thing

# SavesbBlocks to dictionary - NOT file!
func save_blocks_to_dict():
	var dict = {}
	# Add data of all children of DialogueBlocks to dictionary
	for block in blocks.get_children():
		dict[block.id] = block.serialize()
	return dict

func _on_popup_hide():
	MainCamera.freeze = false

func _on_Save_pressed():
	# if not already open (@TODO)
	saveas_dialog.popup_centered(Vector2(1200,600))
	saveas_dialog.current_dir = current_folder
	saveas_dialog.current_file = current_file
	saveas_dialog.rect_position += Vector2(0,10)
	MainCamera.freeze = true

func save_as(path):
	var start_time = OS.get_ticks_msec()
	var dict = save_blocks_to_dict()

	var file = File.new()
	var json = to_json(dict)
	var pretty_json = convert_to_multiline_json(json)

	file.open(path, File.WRITE)
	file.store_string(pretty_json)
	file.close()

	var end_time_str = "Saved " + str(dict.size()) + "Blocks in " + str(OS.get_ticks_msec()-start_time) + "ms."
	print(end_time_str)
	current_file = get_filename_from_path(path)
	current_folder = get_folder_from_path(path)

# @TODO: Make actually pretty print
func convert_to_multiline_json(json : String):
	var output = json
	output = output.replace("{", "{\n")
	output = output.replace("}", "}\n")
	output = output.replace(",", ",\n")
	output = output.replace("[", "[\n")
	output = output.replace("]", "]\n")
	return output

func convert_from_multiline_json(json : String):
	var output = json
	output = output.replace("\n", "")
	return output

func fill_with_garbage_blocks(amount):
	for i in range(amount):
		var new_block = DialogueBlock.instance()
		blocks.add_child(new_block)
		new_block.randomise_id()
		new_block.rect_position = Vector2(0,rand_range(0,9990))
		new_block.fill_with_garbage()

func spawn_block(node_type := DB.dialogue_block, hand_placed = false, pos := Vector2(0,0), add_child := true):
	var block_pos = pos

	var node_to_spawn = DialogueBlock

	match node_type:
		DB.meta_block:
			node_to_spawn = MetaBlock
		DB.dialogue_block:
			node_to_spawn = DialogueBlock
		DB.title_block:
			node_to_spawn = TitleBlock
		DB.comment_block:
			node_to_spawn = CommentBlock
		DB.branch_block:
			node_to_spawn = BranchBlock

	var new_block = node_to_spawn.instance()
	#new_block.node_type = node_type
	new_block.just_created = true
	new_block.hand_placed = hand_placed
	if add_child:
		blocks.add_child(new_block)
	if hand_placed:
		block_pos = get_global_mouse_position()
		new_block.randomise_id()
	else:
		new_block.just_created = false

	new_block.rect_position = block_pos
	new_block.previous_pos = block_pos

	# Check if new highest or new lowest and apply if necessary
	if block_pos.y > lowest_position:
		lowest_position = block_pos.y
	if block_pos.y < highest_position:
		highest_position = block_pos.y


	return new_block

func _on_BackUIButton_pressed():

	if Input.is_action_pressed("title_block_button"):
		spawn_block(DB.title_block, true)
	elif Input.is_action_pressed("comment_block_button"):
		spawn_block(DB.comment_block, true)
	elif Input.is_action_pressed("branch_block_button"):
		spawn_block(DB.branch_block, true)
	# Spawn regular block if no modifiers
	elif double_click_timer > 0.001 or Input.is_action_pressed("ctrl") or is_ctrl_down:
		# Register double click

		spawn_block(DB.dialogue_block, true)
		# @TODO: ADD UNDO EQUIVALENT TO BUFFER


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

func _on_Find_pressed():

	$FrontWindows/FindWindow.popup_centered()

	$FrontWindows/FindWindow/HBoxContainer2/LineEdit.placeholder_text =$FrontWindows/FindWindow/HBoxContainer2/LineEdit.text
	$FrontWindows/FindWindow/HBoxContainer2/LineEdit.text = ""

	$FrontWindows/FindWindow/HBoxContainer2/LineEdit.grab_focus()

	pass # Replace with function body.


func _on_Open_pressed():

	var window = get_node("FrontWindows/OpenFileWindow")
	window.current_dir = current_folder
	window.current_file = current_file
	print(current_folder)

	window.popup_centered()
	window.rect_position.y += 10
	MainCamera.freeze = true

	pass # Replace with function body.



func _on_OpenFileWindow_file_selected(path):
	current_folder = get_folder_from_path(path)
	current_file = get_filename_from_path(path)
	var window = get_node("FrontWindows/OpenFileWindow")
	var file = File.new()
	file.open(path, File.READ)
	var json = file.get_as_text()
	json = convert_from_multiline_json(json)

	# Kill all existingbBlocks to make room for new file
	reset(false) # DO NOT CREATE A NEW META BLOCK - Let it happen when loaded

	yield(get_tree().create_timer(0.000),"timeout")
	load_blocks_from_json(json)

func _on_OpenFileWindow_popup_hide():
	MainCamera.freeze = false
	pass # Replace with function body.

var DB = DialogueBlock.instance()

func load_blocks_from_json(json):
	var dict := {}
	dict = parse_json((json))

	# Add meta block (must be first block to avoid bugs)
	var meta_key = "__META__*****"
	add_block_from_key(dict, meta_key)
	# Loop through individual blocks
	for key in dict.keys():
		if key != meta_key: # Ignore if meta block (has already been added)
			add_block_from_key(dict, key)

func add_block_from_key(dict, key):
	var values_dict = dict[key]
	var id = key
	var node_type = int(values_dict["type"])
	var pos = Vector2(values_dict["pos_x"], values_dict["pos_y"])

	var block = spawn_block(node_type)
	block.set_id(id)
	block.rect_position = pos
	block.node_type = node_type
	block.set_tail(values_dict["tail"])
	if block.tail != "":
		block.set_process(true)
	block.character_line_edit.text = values_dict["char"]
	block.dialogue_line_edit.text = values_dict["text"]
	block.set_character_name(values_dict["char"])
	block.set_dialogue_string(values_dict["text"])
	block.salsa_code = values_dict["code"]
	block.extra_data = values_dict["data"]
	block.update_dialogue_rich_text_label()

	if node_type == 0: # If meta block:
		current_meta_block = block # Get reference to it

func reset(create_new_meta_block := true):
	# Clear everything on board (Kill all children in dialogueblocks)

	for child in blocks.get_children():
		child.queue_free()

	MainCamera.reset()
	get_node("Map/GridBG").update_grid()

	lowest_position = DEFAULT_LOWEST_POSITION
	highest_position = DEFAULT_HIGHEST_POSITION

	current_meta_block = null

	# Create new meta block
	if create_new_meta_block:
		current_file = ""
		if is_instance_valid(current_meta_block):
			current_meta_block.name = "___INVALID_META_BLOCK_______@@@"
		current_meta_block = spawn_block(DB.meta_block)

	# Do rest of stuff 2 frames after
	yield(get_tree().create_timer(2), "timeout")
	$FrontUILayer/VScrollBar.update_scroll_bar()

func _on_Options2_focus_exited():
	pass # Replace with function body.



var prev_window_size = Vector2(100,100)

func _on_FindWindow_confirmed():
	var given_id = $FrontWindows/FindWindow/HBoxContainer2/LineEdit.text
	if given_id == "":
		given_id = $FrontWindows/FindWindow/HBoxContainer2/LineEdit.placeholder_text
		$FrontWindows/FindWindow/HBoxContainer2/LineEdit.text = given_id
	if blocks.has_node(given_id) and given_id != "" :
		var node =blocks.get_node(given_id)
		#MainCamera.pan_mode = true
		MainCamera.lerp_camera_pos(node.rect_position + Vector2(0, 200))

		MainCamera.update_rendered(true , -1)
		MainCamera.update()

		#OS.set_window_size(Vector2(100,100))
		fix_popin_bug()
	else:
		$FrontWindows/FindWindow.popup_centered()
		$FrontWindows/FindWindow/HBoxContainer2/LineEdit.grab_focus()

var _popin_fix_pending = false
var _popin_fix_pending_timer = -1





func _physics_process(delta):
	# Fix render bug
	pass
#	_popin_fix_pending_timer -=1
#	if _popin_fix_pending and _popin_fix_pending_timer <= 0:
#		OS.set_window_size(prev_window_size)
#		_popin_fix_pending = false


func fix_popin_bug(timer = 2): # TODO: Rename as to not confuse things
	prev_window_size = OS.get_window_safe_area().size
	OS.set_window_size(Vector2(prev_window_size.x+1,prev_window_size.y+1))
	_popin_fix_pending = true
	_popin_fix_pending_timer = timer


func force_redraw():
	pass


enum MODIFIER {
	ctrl,
	alt,
	shift
	}

func is_modifier_down(modifier):
	match modifier:
		ctrl:
			return is_ctrl_down or Input.is_action_pressed("ctrl")
		alt:
			return is_alt_down or Input.is_action_pressed("alt")
		shift:
			return is_shift_down or Input.is_action_pressed("shift")


static func is_node_alive(node : Node):
	if node == null:
		return false
	if !is_instance_valid(node):
		return false
	if node.is_queued_for_deletion():
		return false
	return true

static func get_folder_from_path(path: String):
	var end_index = path.rfind("/")
	return path.substr(0, end_index)

static func get_filename_from_path(path: String):
	var end_index = path.rfind("/")
	return path.substr(end_index + 1, path.length())