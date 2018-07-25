extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var DraggableSegment = get_node("NinePatchRect/TitleBar/DraggableSegment")
#onready var SceneCamera = get_tree().get_node("Map/Camera2D")

var dragging = false
var previous_pos = Vector2(0,0)
var mouse_delta = Vector2(0,0)
var mouse_pos = Vector2(0,0)
var mouse_previous_pos = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
#	set_process(false)
#	set_process_input(false)
	
	#previous_pos = position
	print(previous_pos)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		if dragging:
			mouse_delta = mouse_pos - mouse_previous_pos
			position = previous_pos + mouse_delta * CAMERA2D.zoom_level
		
	if CAMERA2D.pan_mode or !Input.is_action_pressed("click"):
		dragging = false
		
	if DraggableSegment.pressed and !dragging and !CAMERA2D.pan_mode:
		previous_pos = position
		mouse_previous_pos = mouse_pos
		dragging = true
	
	
func _on_DraggableSegment_pressed():
	mouse_delta = Vector2(0,0)
	previous_pos = position
	mouse_previous_pos = mouse_pos
	dragging = true
	
func _on_DraggableSegment_toggled(button_pressed):
	print(button_pressed)
	pass # Replace with function body.




func _on_NinePatchRect_visibility_changed():
	print("HEY")
	pass # Replace with function body.
