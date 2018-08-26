extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
	update()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

onready var _line_start_pos := Vector2(0,0)
onready var _tail_location := Vector2(0,0)
#onready var _line_curve = Curve2D.new()
#onready var _line_points : PoolVector2Array
#onready var _curve_points = 48

func _draw():
	#line_curve.clear_points()
	#line_curve.add_point(line_start_pos, Vector2(1,1),Vector2(1,1))
	#line_curve.add_point((line_start_pos + tail_location)/2)
	#line_curve.add_point(tail_location, Vector2(1,0),Vector2(1,1))
	
	position.x = 0
	position.y = -8 + get_parent().get_node("NinePatchRect").margin_bottom
	
	
	# Set draw transform to global coordinates
	var inv = get_global_transform().inverse()
	draw_set_transform(inv.get_origin(), inv.get_rotation(), inv.get_scale())
	
	_line_start_pos = get_global_transform().origin
	_tail_location =  get_global_mouse_position()
	
	

#	_line_curve.clear_points()
#	_line_curve.add_point(_line_start_pos)
#	_line_curve.add_point((_line_start_pos + _tail_location)/2, Vector2(800,800))
#	_line_curve.add_point(_tail_location)
#
#	var line_points : PoolVector2Array
#	for i in range(_curve_points+1):
#		line_points.push_back(_line_start_pos + Vector2(i, cos(i)))
#
	

	
	# If in process of connecting to another potential node
	if CAMERA2D.CURRENT_CONNECTION_HEAD_NODE == get_parent():
		draw_circle(_line_start_pos, 2, Color.white)
		draw_line(_line_start_pos, _tail_location, Color.white, 4, true)
		
		#draw_polyline(line_points, Color("ffffff"),4,true)
		pass
	
	
	print(CAMERA2D.CURRENT_CONNECTION_HEAD_NODE," to ",CAMERA2D.CURRENT_CONNECTION_TAIL_NODE)
	
	
	pass
