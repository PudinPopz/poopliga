extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var id_Label = get_node("NinePatchRect/TitleBar/Id_Label")
onready var DraggableSegment = get_node("NinePatchRect/TitleBar/DraggableSegment")
onready var CharacterLineEdit = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/CharacterLineEdit")
onready var DialogueRichTextLabel = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/DialogueRichTextLabel")
onready var DialogueLineEdit = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/DialogueRichTextLabel/LineEdit")
#onready var SceneCamera = get_tree().get_node("Map/Camera2D")

var just_created = false
var dragging = false
var previous_pos = Vector2(0,0)
var mouse_delta = Vector2(0,0)
var mouse_pos = Vector2(0,0)
var mouse_previous_pos = Vector2(0,0)
var mouse_offset = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	DialogueLineEdit.connect("text_changed",self,"update_DialogueRichTextLabel")
	#previous_pos = position
	#mouse_previous_pos = get_local_mouse_position()
	#mouse_pos = get_local_mouse_position()
	
	
	pass # Replace with function body.

func update_DialogueRichTextLabel(new_text):
	var new_text_formatted = new_text.replace("\\n","\n")
	DialogueRichTextLabel.set_bbcode(new_text_formatted)
	pass

func fill_with_garbage():
	id_Label.text = str(randi())
	CharacterLineEdit.text = str(randi())
	DialogueRichTextLabel.bbcode_text = str(randi())
	DialogueLineEdit.text = str(randi())
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



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

	
func _on_DraggableSegment_pressed():
	mouse_delta = Vector2(0,0)
	previous_pos = position
	mouse_previous_pos = mouse_pos
	dragging = true
	

func _on_DeleteButton_pressed():
	self.queue_free()
	pass # Replace with function body.
