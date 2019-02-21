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
onready var dimmer : ColorRect = $TopLayer/LoadingDimmer
onready var dimmer_label : Label = $TopLayer/LoadingDimmer/Label

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

var selected_block = null setget set_selected_block
var hovered_block = null

var rect_selected_blocks = []

var undo_buffer = []

var editor_settings = {}

func _input(event):
	cursor.position = get_global_mouse_position()

	if event is InputEventWithModifiers and !event.is_echo():
		is_ctrl_down = event.control or event.command
		is_alt_down = event.alt
		is_shift_down = event.shift

	focus = control.get_focus_owner()

	# CTRL + Enter: Go to next in chain
	# TODO: Add system for remembering previous and jumping back to it
	# TODO: Also maybe clean this because it's kinda a mess
	if is_ctrl_down and (Input.is_action_just_pressed("enter") or Input.is_action_just_pressed("space")):
		if is_instance_valid(focus) and focus is TextEdit and focus.name == "DialogueTextEdit" or \
		is_node_alive(selected_block):

			var block : DialogueBlock
			if is_node_alive(selected_block):
				block = selected_block
			else:
				block = focus.get_parent().get_parent()

			if block.node_type == block.NODE_TYPE.dialogue_block:
				var tail_block
				if block.tail == "":
					tail_block = block.spawn_block_below()
				else:
					tail_block = blocks.get_node(block.tail)

				if is_node_alive(tail_block):
					MainCamera.lerp_camera_pos(Vector2(MainCamera.position.x, tail_block.rect_position.y) + Vector2(0, 200), 0.5)
					tail_block.dialogue_line_edit.readonly = true
					tail_block.dialogue_line_edit.grab_focus()
					yield(get_tree().create_timer(0), "timeout")
					tail_block.dialogue_line_edit.readonly = false
					set_selected_block(tail_block)

	# CTRL + T: Script mode
	if is_ctrl_down and Input.is_action_just_pressed("t"):
		script_mode.visible = !script_mode.visible
		if script_mode.visible:
			last_focus = control.get_focus_owner()
			script_mode.get_node("TextEdit").grab_focus()
		else:
			if is_node_alive(last_focus):
				last_focus.grab_focus()

	# CTRL + Z: Undo previous command
	if is_ctrl_down and Input.is_action_just_pressed("z") and (focus == null or !(focus is LineEdit or focus is TextEdit)):
		undo_last()

	# Allow for script mode to actually be escaped
	if script_mode.visible and Input.is_key_pressed(KEY_ESCAPE):
		script_mode.visible = false

	# Escape inspector
	if $InspectorLayer/Inspector.visible and Input.is_key_pressed(KEY_ESCAPE):
		$InspectorLayer/Inspector.visible = false

	# Select block on mouse click
	if Input.is_action_just_pressed("click") and hovered_block != null and is_instance_valid(hovered_block):
		# Additional check for if underneath active inspector
		var overlaps_inspector : bool = true
		if !$InspectorLayer/Inspector.visible or !overlaps_inspector:
			set_selected_block(hovered_block)


	if event is InputEventKey:
		# Check if focus shortcut
		if is_alt_down:
			handle_focus_shortcuts(event)
		else:
			# I for Inspector
			if focus == null or !(focus is LineEdit or focus is TextEdit):
				if Input.is_key_pressed(KEY_I) or Input.is_key_pressed(KEY_E):
					update_inspector(true)
					$InspectorLayer/Inspector.visible = !$InspectorLayer/Inspector.visible

func handle_focus_shortcuts(event):
	if focus == null:
		focus == selected_block
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
	show_dimmer("Loading...")
	theme = preload("res://themes/default_theme.tres")
	current_folder = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	randomize()
	set_process(true)
	reset()
	saveas_dialog = create_saveas_file_dialog()
	fix_popin_bug(10)

	close_dimmer()

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
	var fd = FileDialog.new()
	get_node("FrontWindows").add_child(fd)
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.current_dir = current_folder
	fd.current_file = current_file
	fd.resizable = true
	fd.theme = theme
	fd.theme.default_font = fnt_noto_sans_16
	fd.add_filter("*.poopliga")
	fd.mode = FileDialog.MODE_SAVE_FILE
	fd.connect("file_selected",self,"save_as")
	fd.connect("popup_hide",self,"_on_popup_hide")
	return fd

# Saves blocks to dictionary - NOT file!
func save_blocks_to_dict():
	var dict = {}
	# Add data of all children of DialogueBlocks to dictionary
	for block in blocks.get_children():
		dict[block.id] = block.serialize()
	return dict

func _on_popup_hide():
	MainCamera.freeze = false

func _on_Save_pressed():
	if System.use_os_file_io:
		var path : String = CSharp.FileDialog.SaveFileDialog()
		if path == null:
			return
		show_dimmer("Saving File")

		save_as(path)
		close_dimmer()
		return
	saveas_dialog.popup_centered(Vector2(1200,600))
	saveas_dialog.current_dir = current_folder
	saveas_dialog.current_file = current_file
	saveas_dialog.rect_position += Vector2(0,10)
	MainCamera.freeze = true

func save_as(path : String, show_loading_screen : bool = true):
	show_dimmer("Saving File...")
	var start_time = OS.get_ticks_msec()
	var dict = save_blocks_to_dict()

	var file = File.new()
	var json = JSON.print(dict, "  ")
	var pretty_json = json

	file.open(path, File.WRITE)
	file.store_string(pretty_json)
	file.close()

	# NOTE: Dict size is decremented by 1 as the count should not include the meta block.
	var message = "Saved " + str(dict.size() - 1) + " blocks in " + str(OS.get_ticks_msec()-start_time) + "ms."
	push_message(message, 6.0)

	current_file = get_filename_from_path(path)
	current_folder = get_folder_from_path(path)
	close_dimmer()


func fill_with_garbage_blocks(amount):
	for i in range(amount):
		var new_block = DialogueBlock.instance()
		blocks.add_child(new_block)
		new_block.randomise_id()
		new_block.rect_position = Vector2(0,rand_range(0,9990))
		new_block.fill_with_garbage()

func spawn_block(node_type := DB.NODE_TYPE.dialogue_block, hand_placed = false, pos := Vector2(0,0), add_child := true):
	var block_pos = pos

	var node_to_spawn = DialogueBlock

	match node_type:
		DB.NODE_TYPE.meta_block:
			node_to_spawn = MetaBlock
		DB.NODE_TYPE.dialogue_block:
			node_to_spawn = DialogueBlock
		DB.NODE_TYPE.title_block:
			node_to_spawn = TitleBlock
		DB.NODE_TYPE.comment_block:
			node_to_spawn = CommentBlock
		DB.NODE_TYPE.branch_block:
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
		spawn_block(DB.NODE_TYPE.title_block, true)
	elif Input.is_action_pressed("comment_block_button"):
		spawn_block(DB.NODE_TYPE.comment_block, true)
	elif Input.is_action_pressed("branch_block_button"):
		spawn_block(DB.NODE_TYPE.branch_block, true)
	# Spawn regular block if no modifiers
	elif double_click_timer > 0.001 or Input.is_action_pressed("ctrl") or is_ctrl_down:
		# Register double click

		spawn_block(DB.NODE_TYPE.dialogue_block, true)
		# TODO: ADD UNDO EQUIVALENT TO BUFFER

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


func _on_Open_pressed():
	# Use Windows file I/O if on windows
	if System.use_os_file_io:
		show_dimmer("Loading File...")
		var path : String = CSharp.FileDialog.OpenFileDialog()
		if path == null:
			close_dimmer()
			return

		yield(get_tree().create_timer(0.0),"timeout")
		_on_OpenFileWindow_file_selected(path)
		return

	var window = get_node("FrontWindows/OpenFileWindow")
	window.current_dir = current_folder
	window.current_file = current_file
	print(current_folder)

	window.popup_centered()
	window.rect_position.y += 10
	MainCamera.freeze = true

func _on_Inspector_pressed() -> void:
	get_inspector().visible = !get_inspector().visible

func _on_OpenFileWindow_file_selected(path):
	show_dimmer("Loading file...")
	current_folder = get_folder_from_path(path)
	current_file = get_filename_from_path(path)
	var window = get_node("FrontWindows/OpenFileWindow")
	var file = File.new()
	file.open(path, File.READ)
	var json = file.get_as_text()

	# Kill all existing blocks to make room for new file
	reset(false) # DO NOT CREATE A NEW META BLOCK - Let it happen when loaded

	# Wait for next frame to ensure reset worked properly
	yield(get_tree().create_timer(0.000),"timeout")

	var start_time = OS.get_ticks_msec()
	# Load blocks from json whilst obtaining the amount of blocks as a return value
	var amount_of_blocks = load_blocks_from_json(json)
	var end_time = OS.get_ticks_msec()
	var message = "Loaded " + str(amount_of_blocks) +  " blocks in " + str(end_time - start_time) + "ms."
	yield(get_tree().create_timer(0.1),"timeout")
	push_message(message, 6.0)
	close_dimmer()

func _on_OpenFileWindow_popup_hide():
	MainCamera.freeze = false

var DB = DialogueBlock.instance()

func load_blocks_from_json(json) -> int: # Returns number of blocks
	var dict := {}
	if json is Dictionary:
		dict = json
	else:
		dict = parse_json((json))

	# Add meta block (must be first block to avoid bugs)
	var meta_key = "__META__*****"
	add_block_from_key(dict, meta_key)
	# Loop through individual blocks
	var number_of_blocks : int = 0
	for key in dict.keys():
		if key != meta_key: # Ignore if meta block (has already been added)
			add_block_from_key(dict, key)
			number_of_blocks += 1

	return number_of_blocks

func add_block_from_key(dict, key):
	var values_dict = dict[key]
	var id = key
	var node_type = int(values_dict["type"])
	var pos = Vector2(values_dict["posx"], values_dict["posy"])

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
	block.extra_data = values_dict["data"]
	block.update_dialogue_rich_text_label()

	if node_type == 0: # If meta block:
		current_meta_block = block # Get reference to it

	return block

func reset(create_new_meta_block := true):
	# Clear everything on board (Kill all children in dialogueblocks)

	for child in blocks.get_children():
		child.queue_free()

	MainCamera.reset()
	get_node("Map/GridBG").update_grid()

	# Clear undo buffer
	undo_buffer = []

	lowest_position = DEFAULT_LOWEST_POSITION
	highest_position = DEFAULT_HIGHEST_POSITION

	current_meta_block = null
	set_selected_block(null)
	hovered_block = null

	# Create new meta block
	if create_new_meta_block:
		current_file = ""
		if is_instance_valid(current_meta_block):
			current_meta_block.name = "___INVALID_META_BLOCK_______@@@"
		current_meta_block = spawn_block(DB.NODE_TYPE.meta_block)

	update_inspector(true)
	get_inspector().visible = false

	# Do rest of stuff 0.1 s after
	yield(get_tree().create_timer(0.1), "timeout")
	$FrontUILayer/VScrollBar.update_scroll_bar()
	set_selected_block(null)
	update_inspector(true)
	push_message(" ")

func undo_last():
	if undo_buffer.size() <= 0:
		push_message("There is nothing left to undo.")
		return
	var last_command = undo_buffer.pop_back()
	var event : String = last_command[0]
	var value = last_command[1]

	match event:
		"deleted":
			# Undelete block (spawn back)
			var dict : Dictionary = value
			var undeleted_block
			for key in dict.keys():
				if blocks.has_node(key):
					var block_to_delete = blocks.get_node(key)
					block_to_delete.name = key + "_PD"
					block_to_delete.queue_free()
				undeleted_block = Editor.add_block_from_key(dict, key)
				update_inspector(true)
			if dict.size() == 1:
				push_message("UNDO: Deleted block " + undeleted_block.id + ".")
			else:
				push_message("UNDO: Deleted " + str(dict.size()) + " blocks.")

var prev_window_size = Vector2(100,100)


func _on_CursorArea_area_entered(area):
	if area.get_parent() is DBScript:
		hovered_block = area.get_parent()

func _on_CursorArea_area_exited(area: Area2D) -> void:
	if area.get_parent() is DBScript:
		hovered_block = null

var _popin_fix_pending = false
var _popin_fix_pending_timer = -1

func fix_popin_bug(timer = 2): # TODO: Rename as to not confuse things
	prev_window_size = OS.get_window_safe_area().size
	OS.set_window_size(Vector2(prev_window_size.x+1,prev_window_size.y+1))
	_popin_fix_pending = true
	_popin_fix_pending_timer = timer

func set_selected_block(value):
	var previous_block = selected_block
	selected_block = value

	if !is_node_alive(selected_block) or !(selected_block is DBScript):
		selected_block = null
		update_inspector()
		return

	# Highlight selected block
	selected_block.nine_patch_rect.modulate =  Color("ffffff") * 1.4
	if is_node_alive(previous_block) and previous_block != selected_block:
		previous_block.nine_patch_rect.modulate = Color(1,1,1)

	update_inspector()


func get_inspector():
	return $InspectorLayer/Inspector

func update_inspector(force := false):
	get_inspector().update_inspector(force)

var _clear_message_pending = false
var _message_timer : SceneTreeTimer = null
func push_message(text : String, duration := 4.0):
	$FrontUILayer/Message.text = text
	if duration != -1:
		if _message_timer == null or !is_instance_valid(_message_timer):
			_message_timer = get_tree().create_timer(duration)
		else:
			_message_timer.time_left = duration
		yield(_message_timer, "timeout")
		$FrontUILayer/Message.text = ""
		_message_timer = null

func popup_message(text : String, title : String = "", use_richtextlabel := false):
	var popup : AcceptDialog = $FrontWindows/GenericPopupMessage
	popup.dialog_text = text
	popup.window_title = title

	# Use rich text label to display text instead of normal message text if desired
	if use_richtextlabel:
		var richtextlabel = $FrontWindows/GenericPopupMessage/Control/RichTextLabel
		richtextlabel.bbcode_enabled = true
		richtextlabel.bbcode_text = text
		popup.dialog_text = ""

	popup.popup_centered()

func show_dimmer(text : String):
	dimmer_label.text = text
	dimmer.visible = true

func close_dimmer():
	dimmer.visible = false


enum {
	ctrl,
	alt,
	shift
	}

func is_modifier_down(modifier):
	# Allow for string values to also be entered
	if typeof(modifier) == TYPE_STRING:
		match modifier:
			"ctrl":
				modifier = ctrl
			"alt":
				modifier = alt
			"shift":
				modifier = shift

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
