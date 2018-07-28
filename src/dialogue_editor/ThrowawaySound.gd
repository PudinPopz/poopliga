extends AudioStreamPlayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var random_pitch : bool = false
func _ready():
	if random_pitch:
		pitch_scale = rand_range(0.6,1.4)
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ThrowawaySound_finished():
	print("bye")
	self.queue_free()
	pass # Replace with function body.
