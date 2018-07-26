extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var DraggableSegment = get_node("NinePatchRect/TitleBar/DraggableSegment")
onready var DialogueRichTextLabel = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/DialogueRichTextLabel")
onready var DialogueLineEdit = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/DialogueRichTextLabel/LineEdit")
#onready var SceneCamera = get_tree().get_node("Map/Camera2D")

var dragging = false
var previous_pos = Vector2(0,0)
var mouse_delta = Vector2(0,0)
var mouse_pos = Vector2(0,0)
var mouse_previous_pos = Vector2(0,0)
var mouse_offset = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
#	set_process(false)
#	set_process_input(false)
	
	#previous_pos = position
	DialogueLineEdit.connect("text_changed",self,"update_DialogueRichTextLabel")
	
	pass # Replace with function body.

func update_DialogueRichTextLabel(new_text):
	var new_text_formatted = new_text.replace("\\n","\n")
	DialogueRichTextLabel.set_bbcode(new_text_formatted)
	pass

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
		

		
	if DraggableSegment.pressed and !dragging and !CAMERA2D.pan_mode:
		mouse_offset = Vector2()
		previous_pos = position
		mouse_previous_pos = mouse_pos
		dragging = true

	
func _on_DraggableSegment_pressed():
	mouse_delta = Vector2(0,0)
	previous_pos = position
	mouse_previous_pos = mouse_pos
	dragging = true
	
func _on_DraggableSegment_toggled(button_pressed):
	#print(button_pressed)
	pass # Replace with function body.




func _on_NinePatchRect_visibility_changed():
	#print("HEY")
	pass # Replace with function body.


func _on_DialogueRichTextLabel_meta_clicked(meta):
	
	pass # Replace with function body.
