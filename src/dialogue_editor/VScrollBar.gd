extends VScrollBar

onready var label = get_node("Label")
# Called when the node enters the scene tree for the first time.
func _ready():
	CAMERA2D.connect("scrolled", self, "_on_CAMERA2D_scrolled")
	update_position_label()
	pass # Replace with function body.

func _on_CAMERA2D_scrolled():
	pass
	#update_position_label()

var last_camera_pos = Vector2()
func _process(delta):
	# if camera position updates
	if last_camera_pos != CAMERA2D.position:
		update_position_label()
		pass
	last_camera_pos = CAMERA2D.position
	pass
func update_position_label():
	label.text = str(CAMERA2D.position.floor())
	label.visible = true 
	
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
