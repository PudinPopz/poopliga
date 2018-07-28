extends Camera2D
signal scrolled

var LAST_MOUSE_POS = Vector2()
var LAST_CHAR_NAME = ""
const secret1 = preload("res://snd/secret1.ogg")

func _ready():
	Engine.target_fps = 200
	camera_previous_pos = position
	zoom = Vector2(zoom_level_max,zoom_level_max)

var scroll_spd = 100
var zoom_spd = 1.2
var zoom_level_max = 3

var zoom_level = zoom_level_max
var mouse_pos = Vector2(0,0)
var mouse_previous_pos = Vector2(0,0)
var mouse_delta = Vector2(0,0)
var pan_mode = false
var scroll_mode : int = 0
var camera_previous_pos = Vector2(0,0)
var freeze = false




func _input(event):
	if freeze:
		return
	scroll_mode = 0

	# Mouse movement stuff
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		if pan_mode:
			mouse_delta = mouse_pos - mouse_previous_pos
			update_pan()
	#yep these are some long ass conditionals	
	if Input.is_action_just_pressed("middle_click") or \
	(Input.is_action_pressed("alt") and Input.is_action_pressed("click")):
		camera_previous_pos = position 
		mouse_previous_pos = mouse_pos
		mouse_delta = Vector2(0,0)
		pan_mode = true
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	elif Input.is_action_just_released("middle_click") or \
	(Input.is_action_just_released("alt") or (Input.is_action_pressed("alt") and Input.is_action_just_released("click"))):
		mouse_delta = Vector2(0,0)
		pan_mode = false
		Input.set_default_cursor_shape()
	
	

	# Zoom
	# Mouse wheel with ctrl or alt to zoom	
	if Input.is_action_pressed("alt") or Input.is_action_pressed("ctrl"):
		if Input.is_action_just_pressed("scroll_down"):
			zoom_level *= zoom_spd
			camera_previous_pos = position
			mouse_previous_pos = mouse_pos
			mouse_delta = Vector2(0,0)
			update_zoom()
		elif Input.is_action_just_pressed("scroll_up"):
			zoom_level *= 1/zoom_spd
			camera_previous_pos = position
			mouse_previous_pos = mouse_pos
			mouse_delta = Vector2(0,0)
			update_zoom()

	# Scroll vertically
	elif (event is InputEventKey or event is InputEventMouseButton) and !pan_mode:
		if Input.is_action_pressed("scroll_down"):
			scroll_mode = 1
			position.y += scroll_spd
			#print(scroll_spd)
			emit_signal("scrolled")
		if Input.is_action_pressed("scroll_up"):
			scroll_mode = -1
			position.y -= scroll_spd
			emit_signal("scrolled")
	
	


	
func update_zoom():
	zoom_level = clamp(zoom_level, 1,zoom_level_max)
	zoom.x = zoom_level
	zoom.y = zoom_level
	pass
	
func update_pan():
	if pan_mode:
		position = camera_previous_pos - mouse_delta*zoom_level
	pass

var last_unix_time = 0
func _process(delta):
	if int(OS.get_unix_time()) != int(last_unix_time):
		OS.set_window_title("McFakeFake Poopliga Dialogue Editor Professional 2019 | FPS: " + str(int(1/delta)))
		last_unix_time = OS.get_unix_time()
