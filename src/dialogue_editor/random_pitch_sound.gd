extends AudioStreamPlayer

func _ready():

	pitch_scale = rand_range(0.6,1.4)

	if CAMERA2D.LAST_CHAR_NAME.to_lower() == "jerry":
		stream = CAMERA2D.secret1
		pitch_scale = rand_range(.95,1.4)
		play(0)

