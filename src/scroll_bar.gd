extends VScrollBar

onready var label = get_node("Label")
# Called when the node enters the scene tree for the first time.
func _ready():
	MainCamera.connect("scrolled", self, "_on_MainCamera_scrolled")
	update_position_label()

func _on_MainCamera_scrolled():
	pass

var last_camera_pos = Vector2()
func _process(delta):
	# if camera position updates
	if last_camera_pos != MainCamera.position:
		update_position_label()
		pass
	last_camera_pos = MainCamera.position


func update_position_label():
	label.text = str(MainCamera.position.floor())
	label.visible = true 
