extends Node2D

# IMPORTS

const ThrowawaySound = preload("res://src/dialogue_editor/ThrowawaySound.tscn")

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
onready var dialogue_line_edit = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/DialogueRichTextLabel/LineEdit")
onready var anim_player = get_node("AnimationPlayer")
onready var area_2d = get_node("Area2D")

onready var nine_patch_size = nine_patch_rect.rect_size

# RESOURCES

const snd_delet = preload("res://snd/delet_sound.ogg")

var hand_placed = false
var just_created : bool = false
var dragging : bool = false
var tail_valid : bool = false
var previous_pos := Vector2(0,0)
var mouse_delta := Vector2(0,0)
var mouse_pos := Vector2(0,0)
var mouse_previous_pos := Vector2(0,0)
var mouse_offset := Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	nine_patch_rect.visible = false
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
	nine_patch_rect.visible = boolean
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



	
func update_dialogue_rich_text_label(new_text):
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
	id_label.text = str(float(OS.get_ticks_usec()) + randf()).sha256_text().substr(0,10)
	return id_label.text

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
	set_process_input(true)
	pass

func _on_DraggableSegment_mouse_exited():
	if !just_created:
		set_process_input(false)
	pass


# DRAWING CODE

onready var _line_start_pos := Vector2(0,nine_patch_size.y-4)
onready var _tail_location := Vector2(90,900)
onready var _line_curve = Curve2D.new()

func _draw():
	#line_curve.clear_points()
	#line_curve.add_point(line_start_pos, Vector2(1,1),Vector2(1,1))
	#line_curve.add_point((line_start_pos + tail_location)/2)
	#line_curve.add_point(tail_location, Vector2(1,0),Vector2(1,1))
	if tail_valid:
		draw_line(_line_start_pos,_tail_location,Color("1e7da6"),4,true)
	
	#draw_polyline(line_curve.get_baked_points(),Color("1e7da6"),4,true)
	pass

func _on_Id_Label_text_changed(new_text):

	
	pass # Replace with function body.


func _on_CharacterLineEdit_text_changed(new_text):
	CAMERA2D.LAST_CHAR_NAME = character_line_edit.text
	pass # Replace with function body.


# SETTERS AND GETTERS
func set_id(new_id):
	if new_id == "__META__*****":
		print("ID CHANGED DUE TO INVALID INPUT")
		new_id = ">:("
		return
	id = new_id
	id_label.text = id # Update textfield
	pass
func get_id():
	set_id(id_label.text) # Update id to be same as text input
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
	character_line_edit.text = character_name # Update textfield
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
	pass


