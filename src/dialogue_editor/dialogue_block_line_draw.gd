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

func _draw():	
	position.x = 0
	position.y = -8 + get_parent().get_node("NinePatchRect").margin_bottom
	
	
	# Set draw transform to global coordinates
	var inv = get_global_transform().inverse()
	draw_set_transform(inv.get_origin(), inv.get_rotation(), inv.get_scale())
	
	_line_start_pos = get_global_transform().origin
	_tail_location =  get_global_mouse_position()

	
	# If in process of connecting to another potential node
	if MainCamera.CURRENT_CONNECTION_HEAD_NODE == get_parent():
		draw_circle(_line_start_pos, 2, Color.white)
		draw_line(_line_start_pos, _tail_location, Color.white, 4, true)

	# If node has a defined tail node
	if get_parent().tail != "":
		var tail_node = MainCamera.DIALOGUE_EDITOR.blocks.get_node(get_parent().tail)
		if tail_node == null:
			get_parent().tail = ""
			return
		_tail_location = tail_node.position
		_tail_location.y += 14
		draw_circle(_line_start_pos, 2, Color.white)
		draw_line(_line_start_pos, _tail_location, Color("eaeaea"), 4, true)
		draw_circle(_tail_location, 6, Color.white)

	#print(MainCamera.CURRENT_CONNECTION_HEAD_NODE," to ", MainCamera.CURRENT_CONNECTION_TAIL_NODE)