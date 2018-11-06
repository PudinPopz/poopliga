extends DialogueBlock

enum {
	DBOX_CUSTOM,
	DBOX_BLACK_SERIF,
	DBOX_JANGNANMON
}

const DEFAULT_PROJECT_SETTINGS := {
	dialogue_box_style = DBOX_BLACK_SERIF
}

var project_settings := DEFAULT_PROJECT_SETTINGS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Do stuff on next frame
	yield(get_tree().create_timer(0), "timeout")


	# Load extra_data
	if !extra_data.empty():
		project_settings = extra_data.project_settings

func serialize():
	extra_data = {
		project_settings = project_settings
	}
	var dict = .serialize()
	return dict

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
