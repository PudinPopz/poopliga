extends AudioStreamPlayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():

	pitch_scale = rand_range(0.6,1.4)
	print(CAMERA2D.LAST_CHAR_NAME)
	if CAMERA2D.LAST_CHAR_NAME.to_lower() == "jerry":
		stream = CAMERA2D.secret1
		pitch_scale = rand_range(.95,1.4)
		play(0)
		CAMERA2D.LAST_CHAR_NAME = "Jerry "
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
