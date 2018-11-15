extends Panel

onready var properties_vbox : VBoxContainer = $ScrollContainer/PropertiesVBox

func _ready() -> void:
	update_inspector()

func _on_Inspector_visibility_changed():
	update_inspector()

func update_inspector():
	if Editor.selected_block == null:
		return
	$Name/Label.text = str(Editor.selected_block.id)