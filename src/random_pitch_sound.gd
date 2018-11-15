extends AudioStreamPlayer

func _ready():
	pitch_scale = rand_range(0.6,1.4)

	if MainCamera.LAST_CHAR_NAME.to_lower() == "jerry" and get_parent().node_type == get_parent().NODE_TYPE.dialogue_block:
		stream = MainCamera.secret1
		pitch_scale = rand_range(.95,1.4)
		play(0)
		print("MEMES")

	if get_parent().hand_placed == false:
		stop()

