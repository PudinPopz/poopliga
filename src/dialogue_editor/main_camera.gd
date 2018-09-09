extends Camera2D
signal scrolled
#signal moved

# IMPORTS
var DialogueBlock = preload("res://src/dialogue_editor/blocks/dialogue_block.gd")

onready var area_2d = get_node("Area2D")
onready var collision_shape = area_2d.get_node("CollisionShape2D")
var DIALOGUE_EDITOR

var LAST_MOUSE_POS = Vector2()
var LAST_CHAR_NAME = ""

var LAST_MODIFIED_BLOCK = null

var CURRENT_CONNECTION_HEAD_NODE
var CURRENT_CONNECTION_TAIL_NODE

const secret1 = preload("res://snd/secret1.ogg")

func _ready():
	Engine.target_fps = 200
	camera_previous_pos = position
	zoom = Vector2(zoom_level_max,zoom_level_max)
	get_tree().get_root().connect("size_changed", self, "_on_moved")
	update_rendered(true, -1)
	set_physics_process(true)


var scroll_spd = 160 #100
var zoom_spd = 1.5
var zoom_level_max = 3
var loop_mouse_cursor = true

var zoom_level = zoom_level_max
var mouse_pos = Vector2(0,0)
var mouse_previous_pos = Vector2(0,0)
var mouse_delta = Vector2(0,0)
var pan_mode = false
var scroll_mode : int = 0
var camera_previous_pos = Vector2(0,0)
var freeze = false
var target_pos = Vector2(0,0)
var in_lerp = false
var lerp_time = 0
var lerp_finish_time = 1.0

var blocks_on_screen = []
var last_blocks_on_screen = []




func _on_moved():
	update_rendered()

	pass
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		ignore_mouse = true
		update_rendered(true)
		pass
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		ignore_mouse = true
		pass



var ignore_mouse := true # Workaround for broken panning when out of focus
var is_ctrl_down := false
var is_alt_down := false
var is_alt_just_released := false
var is_shift_down := false

func _input(event):
	is_alt_just_released = false

	if event is InputEventWithModifiers and !event.is_echo():
		if is_alt_down and !event.alt:
			is_alt_just_released = true

		is_ctrl_down = event.control or event.command
		is_alt_down = event.alt
		is_shift_down = event.shift


	if freeze:
		return
	scroll_mode = 0

	# Mouse movement stuff
	if event is InputEventMouseMotion:
		mouse_pos = event.position

		if pan_mode and !ignore_mouse:
			mouse_delta = mouse_pos - mouse_previous_pos
			update_pan()

	#yep these are some long ass conditionals
	if Input.is_action_just_pressed("middle_click") or \
	(is_modifier_down(alt) and Input.is_action_pressed("click")) or \
	ignore_mouse and Input.is_action_pressed("middle_click"):
		if event is InputEventMouseMotion:
			ignore_mouse = false

		camera_previous_pos = position
		mouse_previous_pos = mouse_pos
		mouse_delta = Vector2(0,0)
		pan_mode = true

	elif Input.is_action_just_released("middle_click") or \
	((Input.is_action_just_released("alt") and !Input.is_action_pressed("middle_click")) or \
	(is_alt_just_released and !Input.is_action_pressed("middle_click")) or \
	(is_modifier_down(alt) and Input.is_action_just_released("click"))):
		mouse_delta = Vector2(0,0)
		pan_mode = false



	# Zoom
	# Mouse wheel with ctrl or alt to zoom
	if Input.is_action_pressed("middle_click") or is_modifier_down(alt) or is_modifier_down(ctrl):
		if Input.is_action_just_pressed("scroll_down"):
			zoom_level *= zoom_spd + 3*zoom_spd*int(Input.is_action_pressed("shift"))
			camera_previous_pos = position
			mouse_previous_pos = mouse_pos
			mouse_delta = Vector2(0,0)
			update_zoom()
		elif Input.is_action_just_pressed("scroll_up"):
			zoom_level /= zoom_spd + 3*zoom_spd*int(Input.is_action_pressed("shift"))
			camera_previous_pos = position
			mouse_previous_pos = mouse_pos
			mouse_delta = Vector2(0,0)
			update_zoom()

	# Scroll vertically
	elif (event is InputEventKey or event is InputEventMouseButton) and !pan_mode:
		if Input.is_action_pressed("scroll_down"):
			scroll_mode = 1
			position.y += scroll_spd + 3*scroll_spd*int(Input.is_action_pressed("shift"))
			#print(scroll_spd)
			emit_signal("scrolled")
			_on_moved()
		if Input.is_action_pressed("scroll_up"):
			scroll_mode = -1
			position.y -= scroll_spd + 3*scroll_spd*int(Input.is_action_pressed("shift"))
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
	if !pan_mode:
		return
	var prev_pos = position
	var new_position = camera_previous_pos - mouse_delta*zoom_level
	position = new_position
#	if new_position.y > 0:
#		position = new_position
#	else:
#		position.x = new_position.x
#		position.y = 0
	if position.floor() != prev_pos.floor():
		_on_moved()

	# Loop mouse cursor
	if loop_mouse_cursor:
		#OS.mouse
		var screen_mouse_pos = get_viewport().get_mouse_position() + OS.window_position
		if (screen_mouse_pos).y >= OS.get_screen_size(OS.current_screen).y:
			#mouse_pos.y = 0
			#get_viewport().warp_mouse(mouse_pos - OS.window_position)
			pass
		#print(screen_mouse_pos)

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
			if area2D is DialogueBlock:
				area2D.get_parent().set_visibility(false)
		for area2D in blocks_on_screen:
			if area2D is DialogueBlock:
				area2D.get_parent().set_visibility(true)

	last_blocks_on_screen = blocks_on_screen.duplicate()
	#print(OS.get_ticks_msec() - start_time)
	pass

func reset(pos = Vector2(640,360)):
	last_blocks_on_screen = []
	position = pos
	zoom_level = zoom_level_max
	zoom = Vector2(zoom_level,zoom_level)
	camera_previous_pos = position

var last_unix_time = 0
func _process(delta):
	if delta == 0: return
	if int(OS.get_unix_time()) != int(last_unix_time):
		OS.set_window_title("McFakeFake Poopliga Dialogue Editor Professional 2019 | FPS: " + str(int(1/delta)))
		last_unix_time = OS.get_unix_time()

	# Lerping
	if in_lerp:
		if !pan_mode:
			if lerp_time >= 1.0:
				position = position.linear_interpolate(target_pos, pow(lerp_time, 2))
			else:
				position = position.linear_interpolate(target_pos, lerp_time)
		lerp_time += 1*delta

	if lerp_time >= lerp_finish_time or (pan_mode and lerp_time >= 0.1):
		#print(lerp_time)
		position = target_pos
		in_lerp = false
		lerp_time = 0

	position.x = clamp(position.x, limit_left, limit_right)
	position.y = clamp(position.y, limit_top, limit_bottom)
		#emit_signal("scrolled")
		#_on_moved()

func lerp_camera_pos(target, seconds = 1.0, reset_time = false):
	in_lerp = true
	target_pos = target
	lerp_finish_time = seconds
	if reset_time:
		lerp_time = 0

func _physics_process(delta):

	pass


enum MODIFIER {
	ctrl,
	alt,
	shift
	}

func is_modifier_down(modifier):
	match modifier:
		ctrl:
			return is_ctrl_down or Input.is_action_pressed("ctrl")
		alt:
			return is_alt_down or Input.is_action_pressed("alt")
		shift:
			return is_shift_down or Input.is_action_pressed("shift")