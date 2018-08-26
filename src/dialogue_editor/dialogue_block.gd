extends Node2D

# IMPORTS

const ThrowawaySound = preload("res://src/dialogue_editor/ThrowawaySound.tscn")

# RESOURCES
const spr_unfilled_circle = preload("res://sprites/icons/unfilled_circle_thick.png")
const spr_filled_circle = preload("res://sprites/icons/filled_circle.png")
const spr_unfilled_triangle = preload("res://sprites/icons/connector_small_unfilled.png")
const spr_filled_triangle = preload("res://sprites/icons/connector_small.png")

const snd_delet = preload("res://snd/delet_sound.ogg")
# FIELDS
var id := "" setget set_id, get_id
var dialogue_string := "" setget set_dialogue_string, get_dialogue_string
var character_name := "" setget set_character_name, get_character_name
var choices := [] setget set_choices, get_choices
var tail := "" setget set_tail, get_tail
var salsa_code := ""



# CHILD NODES

onready var nine_patch_rect = get_node("NinePatchRect")
onready var id_label = get_node("NinePatchRect/TitleBar/Id_Label")
onready var draggable_segment = get_node("NinePatchRect/TitleBar/DraggableSegment")
onready var character_line_edit = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/CharacterLineEdit")
onready var dialogue_rich_text_label = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/DialogueRichTextLabel")
onready var dialogue_line_edit = get_node("NinePatchRect/DialogueTextEdit")
onready var anim_player = get_node("AnimationPlayer")
onready var area_2d = get_node("Area2D")

onready var nine_patch_size = nine_patch_rect.rect_size


var hand_placed = false
var just_created : bool = false
var dragging : bool = false
var tail_valid : bool = false
var previous_pos := Vector2(0,0)
var mouse_delta := Vector2(0,0)
var mouse_pos := Vector2(0,0)
var mouse_previous_pos := Vector2(0,0)
var mouse_offset := Vector2(0,0)
var on_screen = false
var title_bar_hovered = false
var in_connecting_mode = false


onready var _head_connector_modulate_default = $NinePatchRect/TitleBar/HeadConnector.modulate
onready var _tail_connector_modulate_default = $NinePatchRect/TailConnector.modulate


# Called when the node enters the scene tree for the first time.
func _ready():
	#nine_patch_rect.visible = false # Disabled for now
	set_process(false)
	set_physics_process(false)
	if !just_created:
		set_process_input(false)
	
	dialogue_line_edit.connect("text_changed",self,"update_dialogue_rich_text_label")

	# Play spawn animation
	if hand_placed:
		anim_player.play("spawn")
		nine_patch_rect.visible = true

func set_visibility(boolean):
	#nine_patch_rect.visible = boolean
	# Disabled for now
	on_screen = boolean
	pass

	

func serialize(): # Converts dialogue block fields to a dictionary. Yes, we're using US spelling. Deal with it. 
	var dict = {
		key = id_label.text,
		dialogue = dialogue_rich_text_label.text,
		character = character_line_edit.text,
		choices = [],
		tail = "",
		salsa_code = "",
		pos_x = floor(position.x), # JSON does not support Vector2
		pos_y = floor(position.y)
	}

	return dict
	pass



	
func update_dialogue_rich_text_label():
	var new_text = dialogue_line_edit.text
	var new_text_formatted = new_text.replace("\\n","\n")
	dialogue_rich_text_label.set_bbcode(new_text_formatted)

func fill_with_garbage():
	character_line_edit.text = str(randi())
	dialogue_rich_text_label.bbcode_text = str(randi()).sha256_text()
	dialogue_line_edit.text = str(randi()).sha256_text()

func _input(event):
	if CAMERA2D.scroll_mode != 0:
		mouse_offset.y += CAMERA2D.scroll_mode*CAMERA2D.scroll_spd
	if CAMERA2D.pan_mode or !Input.is_action_pressed("click"):
		dragging = false
		mouse_offset = Vector2()
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		if dragging:
			mouse_delta = (mouse_pos - mouse_previous_pos)
			position = previous_pos + mouse_delta  * CAMERA2D.zoom_level  + mouse_offset
			if just_created:
				position = get_global_mouse_position()
			# Teleport block to cursor if too far away
			if abs(get_global_mouse_position().y - position.y) > 80 or \
			abs(get_global_mouse_position().x - position.x) > 400:
				just_created = true # Act like just created
			
	if (draggable_segment.pressed or just_created) and !dragging and !CAMERA2D.pan_mode:
		mouse_offset = Vector2()
		previous_pos = position
		mouse_previous_pos = mouse_pos
		dragging = true
	
	if Input.is_action_just_released("click"):
		just_created = false
		pass	
		
	
func move_to_front():
	# Move to front of DialogueBlocks
	var index = get_parent().get_child_count()
	get_parent().move_child(self, index)

func randomise_id():
	set_id(str(float(OS.get_ticks_usec()) + randf()).sha256_text().substr(0,10))
	return id

func _on_DraggableSegment_pressed():
	set_process_input(true)
	mouse_delta = Vector2(0,0)
	previous_pos = position
	mouse_previous_pos = mouse_pos
	dragging = true
	move_to_front()
	
func _on_DeleteButton_button_down():
	move_to_front()
	pass
func _on_DeleteButton_pressed():
	anim_player.play("kill")
	var death_sound = ThrowawaySound.instance()
	death_sound.pitch_scale = rand_range(0.7,1.3)
	death_sound.stream = snd_delet
	death_sound.volume_db = -6.118
	CAMERA2D.add_child(death_sound)
	pass 


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"kill":
			# Tell Camera2D to reset array of last rendered stuff
			# (workaround for null pointer)
			CAMERA2D.last_blocks_on_screen = []
			self.queue_free() # actually kill
	

func _on_DraggableSegment_mouse_entered():
	
	
	_on_HeadArea2D_mouse_entered()
	
	set_process_input(true)
	update()
	pass

func _on_DraggableSegment_mouse_exited():
	_on_HeadArea2D_mouse_exited()
	if !just_created:
		set_process_input(false)
	update()
	pass


func _on_HeadArea2D_mouse_entered():
	print("hii")
	CAMERA2D.CURRENT_CONNECTION_TAIL_NODE = self
	#print(CAMERA2D.CURRENT_CONNECTION_TAIL_NODE)
	title_bar_hovered = true
	update()
	pass # Replace with function body.


func _on_HeadArea2D_mouse_exited():
	if CAMERA2D.CURRENT_CONNECTION_TAIL_NODE == self:
		CAMERA2D.CURRENT_CONNECTION_TAIL_NODE = null
	title_bar_hovered = false
	update()
	pass # Replace with function body.



func _on_Id_Label_text_changed(new_text):
	#set_id(new_text)
	
	pass # Replace with function body.


func _on_CharacterLineEdit_text_changed(new_text):
	set_character_name(new_text)
	CAMERA2D.LAST_CHAR_NAME = character_line_edit.text
	
	pass # Replace with function body.


# SETTERS AND GETTERS
func set_id(new_id):
	var old_id = id
	if !is_id_valid(new_id):
		if is_id_valid(old_id):
			new_id = old_id
		else:
			new_id = randomise_id()
		print("INVALID INPUT - ID CHANGED TO: ", new_id)

	id = new_id
	id_label.text = id # Update textfield
	name = id # Update name in tree
	pass
	
func is_id_valid(test_id):
	if test_id == "__META__*****" or test_id == "":
		return false
	if name != test_id and CAMERA2D.DIALOGUE_EDITOR.DialogueBlocks.has_node(test_id):
		return false
	if test_id.length() > 10:
		return false
	return true
	
	pass	
	
func get_id():
	return id
	pass

func set_dialogue_string(new_dialogue_string):
	dialogue_string = new_dialogue_string
	dialogue_line_edit.text = dialogue_string # Update textfield
	pass
	
func get_dialogue_string():
	set_dialogue_string(dialogue_line_edit.text)
	return dialogue_string
	pass
	
func set_character_name(new_character_name):
	character_name = new_character_name
	#character_line_edit.text = character_name # Update textfield
	pass
	
func get_character_name():
	set_character_name(character_line_edit.text)
	return character_name
	pass
	
func set_choices(new_choices):
	choices = new_choices 
	pass
	
func get_choices():
	return choices
	pass
	
func set_tail(new_tail):
	tail = new_tail
	pass
	
func get_tail():
	return tail

func _on_Id_Label_text_entered(new_text):
	set_id(new_text)
	#anim_player.play("spawn")
	id_label.release_focus()
	print(get_id())

func _on_Id_Label_focus_exited():
	if id == id_label.text:
		return
	set_id(id_label.text)
	anim_player.play("spawn")
	print(get_id())
	
func _on_TailConnector_button_down():
	
	in_connecting_mode = true
	CAMERA2D.CURRENT_CONNECTION_HEAD_NODE = self
	update()
	set_process(true)
	$NinePatchRect/TailConnector.pressed = false
	$NinePatchRect.grab_focus()
	pass # Replace with function body.
	
func _on_TailConnector_button_up():
#	in_connecting_mode = false
#	CAMERA2D.CURRENT_CONNECTION_HEAD_NODE = null
#	update()
#	set_process(false)
	pass # Replace with function body.

func release_connection():
	in_connecting_mode = false
	CAMERA2D.CURRENT_CONNECTION_HEAD_NODE = null
	update()
	set_process(false)

# DRAWING CODE



func _draw():
	
	if CAMERA2D.CURRENT_CONNECTION_HEAD_NODE == self:
		$NinePatchRect/TailConnector.modulate = Color(1,1,1)
		$NinePatchRect/TailConnector.texture_normal = spr_filled_triangle
	else:
		$NinePatchRect/TailConnector.modulate = _tail_connector_modulate_default
		$NinePatchRect/TailConnector.texture_normal = spr_unfilled_triangle
	
	if CAMERA2D.CURRENT_CONNECTION_HEAD_NODE != null and title_bar_hovered:
		#$NinePatchRect.modulate = Color(1.3,1.3,1.3)
		$NinePatchRect/TitleBar/HeadConnector.modulate = Color(1,1,1)
	else:
		#$NinePatchRect.modulate = Color(1,1,1)
		$NinePatchRect/TitleBar/HeadConnector.modulate = _head_connector_modulate_default
		
	$LineDrawNode.update()
	pass

func _process(delta):
	if Input.is_action_just_released("click"):
		release_connection()
	update()




