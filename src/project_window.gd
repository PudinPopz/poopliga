extends Control

onready var dbox_style_select = $Panel/GridContainer/DBoxStyleSelect

func _ready():
	dbox_style_select.connect("item_selected", self, "_on_dbox_style_select")
	pass # Replace with function body.

func _on_Project_pressed():
	reset_fields_to_current_values()
	get_node("Panel").popup_centered()


func _on_dbox_style_select(id : int):
	set_project_setting("dialogue_box_style", id)
	print(id)

func reset_fields_to_current_values():
	dbox_style_select.selected = get_project_setting("dialogue_box_style")



func get_project_setting(pref : String):
	return Editor.current_meta_block.project_settings[pref]

func set_project_setting(pref : String, value):
	Editor.current_meta_block.project_settings[pref] = value



