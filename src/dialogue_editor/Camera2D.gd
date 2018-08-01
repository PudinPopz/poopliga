extends Camera2D
signal scrolled
#signal moved

onready var area_2d = get_node("Area2D")
onready var collision_shape = area_2d.get_node("CollisionShape2D")
var DIALOGUE_EDITOR

var LAST_MOUSE_POS = Vector2()
var LAST_CHAR_NAME = ""
const secret1 = preload("res://snd/secret1.ogg")

func _ready():
	Engine.target_fps = 200
	camera_previous_pos = position
	zoom = Vector2(zoom_level_max,zoom_level_max)
	get_tree().get_root().connect("size_changed", self, "_on_moved")
	update_rendered(true, -1)
	set_physics_process(true)
	

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

var blocks_on_screen = []
var last_blocks_on_screen = []
func _on_moved():
	update_rendered()

	pass
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		update_rendered(true)
		pass
		

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
			_on_moved()
		if Input.is_action_pressed("scroll_up"):
			scroll_mode = -1
			position.y -= scroll_spd
			emit_signal("scrolled")
			_on_moved()
	
	if Input.is_action_just_pressed("refresh"):
		update_rendered(true, -1)
	


	
func update_zoom():
	zoom_level = clamp(zoom_level, 1,zoom_level_max)
	zoom.x = zoom_level
	zoom.y = zoom_level
	update_rendered(true)
	pass

var _update_move_timer = 0
func update_pan():
	if pan_mode:
		var prev_pos = position
		position = camera_previous_pos - mouse_delta*zoom_level
		if position.floor() != prev_pos.floor():
			_on_moved()
	

func update_rendered(force=false, max_blocks=50):
	var start_time = OS.get_ticks_msec()
	# Update Area2D collision shape
	var mult = zoom_level_max* 0.0056# 0.01
	# To prevent weird bugs, this will not adapt to zoom.
	collision_shape.scale = mult*get_viewport_rect().size
	
	blocks_on_screen = area_2d.get_overlapping_areas()
	#print(blocks_on_screen.size(), "blocks")
	# Don't bother if there's over 50 blocks on screen
	if max_blocks != -1 and blocks_on_screen.size() >= max_blocks and last_blocks_on_screen != []:
		return
	
	if force\
	or blocks_on_screen.empty() or last_blocks_on_screen.empty()\
	or blocks_on_screen.front() != last_blocks_on_screen.front()\
	or blocks_on_screen.back() != last_blocks_on_screen.back():
	
		for area2D in last_blocks_on_screen:
			area2D.get_parent().set_visibility(false)
		for area2D in blocks_on_screen:
			area2D.get_parent().set_visibility(true)
		
	last_blocks_on_screen = blocks_on_screen.duplicate()
	#print(OS.get_ticks_msec() - start_time)
	pass	
	
func reset():
	last_blocks_on_screen = []
	position = Vector2(640,360)
	zoom_level = zoom_level_max
	zoom = Vector2(zoom_level,zoom_level)
	camera_previous_pos = position

var last_unix_time = 0
func _process(delta):
	if int(OS.get_unix_time()) != int(last_unix_time):
		OS.set_window_title("McFakeFake Poopliga Dialogue Editor Professional 2019 | FPS: " + str(int(1/delta)))
		last_unix_time = OS.get_unix_time()

func _physics_process(delta):
	
	pass