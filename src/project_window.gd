extends Control

onready var dbox_style_select = $Panel/GridContainer/DBoxStyleSelect
onready var author_field = $Panel/GridContainer/AuthorField
onready var description_field = $Panel/GridContainer/DescriptionField
onready var custom_block_attributes_text_edit = $Panel/CustomBlockAttributesTextEdit
onready var spellcheck_ignored_words_text_edit = $Panel/SpellcheckIgnoredWordsTextEdit

func _ready():
	dbox_style_select.connect("item_selected", self, "_on_dbox_style_select")
	author_field.connect("text_changed", self, "_on_author_changed")
	description_field.connect("text_changed", self, "_on_description_changed")
	custom_block_attributes_text_edit.connect("text_changed", self, "_on_custom_block_attributes_changed")
	spellcheck_ignored_words_text_edit.connect("text_changed", self, "_on_spellcheck_ignored_words_changed")
	
	Editor.connect("new_file", self, "reset_fields_to_current_values")
	Editor.connect("spellcheck_ignore_list_updated", self, "reset_fields_to_current_values")

	connect("visibility_changed", self, "on_visibility_changed")
	$Panel.connect("visibility_changed", self, "on_visibility_changed")

func _on_Project_pressed():
	reset_fields_to_current_values()
	get_node("Panel").popup_centered()


func _on_dbox_style_select(id : int):
	set_project_setting("dialogue_box_style", id)

func _on_author_changed(new_text):
	set_project_setting("author", new_text)

func _on_description_changed(new_text):
	set_project_setting("description", new_text)

func _on_custom_block_attributes_changed():
	set_project_setting("custom_block_attributes", custom_block_attributes_text_edit.text)
	if Editor.get_inspector().visible:
		Editor.update_inspector(true)
		
func _on_spellcheck_ignored_words_changed():
	set_project_setting("spellcheck_ignored_words", spellcheck_ignored_words_text_edit.text)

	var ignored_words_dict : Dictionary = CSharp.ignored_words_dict(spellcheck_ignored_words_text_edit.text)

	if CSharp.is_working:
		CSharp.SpellCheck.SetIgnoredWordsProject(ignored_words_dict)

func reset_fields_to_current_values():
	dbox_style_select.selected = int(get_project_setting("dialogue_box_style"))
	author_field.text = str(get_project_setting("author"))
	description_field.text = str(get_project_setting("description"))
	custom_block_attributes_text_edit.text = str(get_project_setting("custom_block_attributes"))
	spellcheck_ignored_words_text_edit.text = str(get_project_setting("spellcheck_ignored_words"))
	_on_spellcheck_ignored_words_changed()

func get_project_setting(pref : String):
	if Editor.current_meta_block.project_settings.has(pref):
		return Editor.current_meta_block.project_settings[pref]
	return ""

func set_project_setting(pref : String, value):
	Editor.current_meta_block.project_settings[pref] = value

func on_visibility_changed():
	if $Panel.visible:
		MainCamera.freeze = true
	else:
		MainCamera.freeze = false

