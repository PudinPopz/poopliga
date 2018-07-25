extends Node2D

var force_process = false
# NEXT THING TO DO: REPLACE BUTTONS WITH SPRITES AND AREA2DS
onready var sprite = get_node("Sprite") 
onready var area2D = get_node("Sprite/Area2D")
onready var collision_shape = get_node("Sprite/Area2D/CollisionShape2D")
func _ready():
	set_process(false)
	set_process_input(false)
	
	area2D.connect("mouse_entered", self, "_on_area2D_mouse_entered")
	area2D.connect("mouse_exited", self, "_on_area2D_mouse_exited")

var mouse_delta = Vector2(0,0)
var mouse_previous_pos = Vector2(0,0)
var node_previous_pos = Vector2(0,0)
var mouse_pos = Vector2(0,0)
var button_just_pressed = false
func _input(event):
	#if button.pressed and button_just_pressed = false:
	
	# Mouse movement stuff
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		if false:
			mouse_delta = mouse_pos - mouse_previous_pos
			update_drag()
		
	if false:
		node_previous_pos = position
		mouse_previous_pos = mouse_pos

	button_just_pressed = false	
	
	pass

func update_drag():
	position = node_previous_pos + mouse_delta
	if mouse_delta.length() > 2:
		print(str(mouse_delta) + "," + str(node_previous_pos))
	#mouse_delta = Vector2(0,0)
	pass

func _process(delta):
	pass


func _on_area2D_mouse_entered():
	#print("hi")
	set_process(true)
	set_process_input(true)
	pass 


func _on_area2D_mouse_exited():
	if !force_process:
		set_process(false)
		set_process_input(false)
	pass
