extends TextEdit

export var counter_camera_scroll := true
# Called when the node enters the scene tree for the first time.
func _ready():
	set_size(get_size()+Vector2(1,0))
	set_size(get_size()-Vector2(1,0))
	set_process(false)
	set_process_input(false)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
		
#	pass
