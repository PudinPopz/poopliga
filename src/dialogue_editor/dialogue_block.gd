extends Node2D

onready var id_Label = get_node("NinePatchRect/TitleBar/Id_Label")
onready var DraggableSegment = get_node("NinePatchRect/TitleBar/DraggableSegment")
onready var CharacterLineEdit = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/CharacterLineEdit")
onready var DialogueRichTextLabel = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/DialogueRichTextLabel")
onready var DialogueLineEdit = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/DialogueRichTextLabel/LineEdit")
onready var AnimPlayer = get_node("AnimationPlayer")

var just_created = false
var dragging = false
var previous_pos = Vector2(0,0)
var mouse_delta = Vector2(0,0)
var mouse_pos = Vector2(0,0)
var mouse_previous_pos = Vector2(0,0)
var mouse_offset = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	if !just_created:
		set_process_input(false)

	DialogueLineEdit.connect("text_changed",self,"update_DialogueRichTextLabel")
	
	# Make clicking on things move to front
	#DialogueLineEdit.connect("focus_entered",self,"move_to_front")
	#id_Label.connect("focus_entered",self,"move_to_front")
	#CharacterLineEdit.connect("focus_entered",self,"move_to_front")
	#DialogueRichTextLabel.connect("focus_entered",self,"move_to_front")
	
	# Play spawn animation
	AnimPlayer.play("spawn")


func update_DialogueRichTextLabel(new_text):
	var new_text_formatted = new_text.replace("\\n","\n")
	DialogueRichTextLabel.set_bbcode(new_text_formatted)
	pass

func fill_with_garbage():
	CharacterLineEdit.text = str(randi())
	DialogueRichTextLabel.bbcode_text = str(randi()).sha256_text()
	DialogueLineEdit.text = str(randi()).sha256_text()

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

	if (DraggableSegment.pressed or just_created) and !dragging and !CAMERA2D.pan_mode:
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
	pass

func randomise_id():
	id_Label.text = str(float(OS.get_ticks_usec()) + randf()).sha256_text().substr(0,10)
	return id_Label.text
	pass
	
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
	AnimPlayer.play("kill")
	pass 


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"kill":
			self.queue_free() # actually kill
	

func _on_BoundingBox_mouse_entered():
	pass


func _on_BoundingBox_mouse_exited():
	pass

func _on_DraggableSegment_mouse_entered():
	set_process_input(true)
	pass

func _on_DraggableSegment_mouse_exited():
	if !just_created:
		set_process_input(false)
	pass