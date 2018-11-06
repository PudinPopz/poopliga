extends Control

onready var dbox_style_select = $Panel/GridContainer/DBoxStyleSelect
onready var author_field = $Panel/GridContainer/AuthorField
onready var description_field = $Panel/GridContainer/DescriptionField

func _ready():
	dbox_style_select.connect("item_selected", self, "_on_dbox_style_select")
	author_field.connect("text_changed", self, "_on_author_changed")
	description_field.connect("text_changed", self, "_on_description_changed")

func _on_Project_pressed():
	reset_fields_to_current_values()
	get_node("Panel").popup_centered()


func _on_dbox_style_select(id : int):
	set_project_setting("dialogue_box_style", id)

func _on_author_changed(new_text):
	set_project_setting("author", new_text)

func _on_description_changed(new_text):
	set_project_setting("description", new_text)

func reset_fields_to_current_values():
	dbox_style_select.selected = int(get_project_setting("dialogue_box_style"))
	author_field.text = str(get_project_setting("author"))
	description_field.text = str(get_project_setting("description"))

func get_project_setting(pref : String):
	if Editor.current_meta_block.project_settings.has(pref):
		return Editor.current_meta_block.project_settings[pref]

func set_project_setting(pref : String, value):
	Editor.current_meta_block.project_settings[pref] = value



