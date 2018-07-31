extends TextEdit

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = !visible 
	visible = !visible
	set_process(true)
	set_process_input(true)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("alt"):
		
		visible = !visible 
		OS.request_attention()
#	pass
