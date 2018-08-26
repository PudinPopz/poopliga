extends Node2D

func _ready():
	update_grid()
	get_tree().get_root().connect("size_changed", self, "update_grid")
	set_process(true)
	set_process_input(true)

func redraw():
	update()
	
var window_ratio = Vector2(1,1)

var _last_camera_pos = Vector2(0,0)
func _process(delta):
	
	if CAMERA2D.pan_mode:
		update_grid()
	elif CAMERA2D.position != _last_camera_pos:
		_last_camera_pos = CAMERA2D.position
		update_grid()
		
func _input(event):
	if event is InputEventMouseButton:
		update_grid()
	pass


var special_offset = Vector2(0,0)
var enabled = true

func update_grid():
	if enabled:
		visible = true
	else:
		visible = false
		return
		
	window_ratio = OS.get_real_window_size().normalized()
	special_offset = Vector2(0,0)
	
	if window_ratio.x > 0.998 or window_ratio.y > 0.920:
		visible = false
		return
	if window_ratio.y > 0.6:
		if window_ratio.y > 0.90:
			special_offset = Vector2(0, floor(-10*CAMERA2D.zoom_level)*tile_size)
		elif window_ratio.y > 0.86:
			special_offset = Vector2(0, floor(-8*CAMERA2D.zoom_level)*tile_size)
		else:
			special_offset = Vector2(0, floor(-4*CAMERA2D.zoom_level)*tile_size)
	if window_ratio.x > .86:
		if window_ratio.x > 0.96:
			special_offset = Vector2(floor(-100*CAMERA2D.zoom_level)*tile_size, 0)
		elif window_ratio.x > 0.94:
			special_offset = Vector2(floor(-6*CAMERA2D.zoom_level)*tile_size, 0)
		else :
			special_offset = Vector2(floor(-4*CAMERA2D.zoom_level)*tile_size, 0)
		
	var camera_pos = CAMERA2D.position 
	position.x =  special_offset.x + (-0*1 + camera_pos.x) - normalise_value(camera_pos.x,-tile_size,tile_size)
	position.y =  special_offset.y + (0 + camera_pos.y) - normalise_value(camera_pos.y,-tile_size,tile_size)
	
	update()


var screen = Vector2()
var def_vp = Vector2(1280,720)
var line_color = Color("0fffffff")
var tile_size = 128
func _draw():
	#tile_size = 12
	var length = Vector2(0,0)
	#print(length)
	var zoom = CAMERA2D.zoom.x
	#zoom = 1
	var tile_amount = 25*zoom*(Vector2(1,1))

	var offset = Vector2(0,0)
	
	draw_set_transform(-(def_vp + Vector2(600,500) ), 0, Vector2(tile_size,tile_size))
	for y in range(0, tile_amount.y):
		draw_line(Vector2(0, y ) + offset, Vector2(tile_amount.y, y + length.y ) + offset, line_color)
	for x in range(0,tile_amount.x):
		draw_line(Vector2(x , 0) , Vector2(x +length.x, tile_amount.x) + offset, line_color)
	

func normalise_value(value, start, end):
	var width = end - start
	var offset_value = value - start
	return (offset_value - (floor(offset_value/width)*width)) + start