extends Popup

onready var item_list = $ItemList

onready var scroll_speed_slider = get_node("General/ScrollSpeedSlider")
onready var zoom_speed_slider = get_node("General/ZoomSpeedSlider")

var default_general_settings : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	scroll_speed_slider.connect("value_changed",self,"_on_scroll_speed_changed")
	zoom_speed_slider.connect("value_changed",self,"_on_zoom_speed_changed")

	$General/EditorBackgroundSelect.connect("item_selected", self, "_on_BGSelect_selected")

	$General/LowProcessorMode.connect("toggled", self, "_on_LowProcessorMode_toggled")
	$General/DisableAnimations.connect("toggled", self, "_on_DisableAnimations_toggled")
	$General/EnableVSync.connect("toggled", self, "_on_VSync_toggled")
	$General/MuteSound.connect("toggled", self, "_on_MuteSound_toggled")
	$General/MoveBlocksAsChain.connect("toggled", self, "_on_MoveBlocksAsChain_toggled")
	
	$General/DefaultSettingsButtonHolder/DefaultSettingsButton.connect("pressed", self, "apply_default_general_settings")

	connect("visibility_changed", self, "on_visibility_changed")
	
	item_list.select(0)
	_on_ItemList_item_selected(0)
	
	for i in range(item_list.get_item_count()):
		item_list.set_item_tooltip_enabled(i, false)
	
	# Get default general editor settings
	default_general_settings = get_general_settings()
	
	# Wait for dialogue editor before loading settings just in case
	yield(get_tree().create_timer(0.0),"timeout")
	load_editor_settings()
	



func _on_Options_pressed():
	popup_centered()

func _on_Options_toggled(button_pressed):
	visible = button_pressed

func save_options_to_file():
	# Ensure things are updated
	update_spellcheck_settings()
	update_general_settings()
	var dict_string : String = JSON.print(Editor.editor_settings, "  ")
	var path : String = "user://editor_settings.json"
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(dict_string)
	file.close()

func load_editor_settings():
	if Editor.editor_settings.has("spellcheck_ignored_words"):
		$Spellcheck/IgnoredWords.text = Editor.editor_settings["spellcheck_ignored_words"]
	update_spellcheck_settings()
	load_general_settings()


func on_visibility_changed():
	if !visible:
		update_spellcheck_settings()
		update_general_settings()
		save_options_to_file()
		


# Move between different settings tabs
func _on_ItemList_item_selected(index: int) -> void:
	var item_name : String = item_list.get_item_text(index)

	for item in get_children():
		if item is GridContainer:
			item.visible = false

	get_node(item_name).visible = true

func update_general_settings():
	var general_dict : Dictionary = get_general_settings()
	Editor.editor_settings["general"] = general_dict

func get_general_settings() -> Dictionary:
	var general_dict : Dictionary = {}
	for item in $General.get_children():
		var value = null
		if item is Slider:
			value = item.value
		elif item is OptionButton:
			value = item.selected
		elif item is CheckBox:
			value = item.pressed
		elif item is TextEdit or item is LineEdit:
			value = item.text
		else:
			continue
		
		general_dict[item.name] = value
	return general_dict

func load_general_settings():
	if !Editor.editor_settings.has("general"):
		return
	
	for item_name in Editor.editor_settings["general"].keys():
		var item = $General.get_node(item_name)
		var value = Editor.editor_settings["general"][item_name]
		if item is Slider:
			item.value = value
		elif item is OptionButton:
			item.selected = value
		elif item is CheckBox:
			item.pressed = value
		elif item is TextEdit or item is LineEdit:
			item.text = value
		else:
			continue
	
	# TODO: Update the general settings system so that this spaghetti is removed.
	_on_scroll_speed_changed(Editor.editor_settings["general"]["ScrollSpeedSlider"])
	_on_zoom_speed_changed(Editor.editor_settings["general"]["ZoomSpeedSlider"])
	_on_BGSelect_selected(Editor.editor_settings["general"]["EditorBackgroundSelect"])
	_on_LowProcessorMode_toggled(Editor.editor_settings["general"]["LowProcessorMode"])
	_on_DisableAnimations_toggled(Editor.editor_settings["general"]["DisableAnimations"])
	_on_VSync_toggled(Editor.editor_settings["general"]["EnableVSync"])
	_on_MuteSound_toggled(Editor.editor_settings["general"]["MuteSound"])
	_on_MoveBlocksAsChain_toggled(Editor.editor_settings["general"]["MoveBlocksAsChain"])

func apply_default_general_settings():
	Editor.editor_settings["general"] = default_general_settings
	load_general_settings()

func update_spellcheck_settings():
	update_ignored_words()
	if CSharp.is_working:
		CSharp.SpellCheck.SetRealtimeEnabled($Spellcheck/RealtimeSpellcheckEnabled.pressed)

func update_ignored_words():
	var ignored_words_dict : Dictionary = CSharp.ignored_words_dict($Spellcheck/IgnoredWords.text)

	Editor.editor_settings["spellcheck_ignored_words"] = $Spellcheck/IgnoredWords.text

	if CSharp.is_working:
		CSharp.SpellCheck.SetIgnoredWordsEditor(ignored_words_dict)


func _on_scroll_speed_changed(value):
	MainCamera.scroll_spd = value
	Editor.editor_settings["scroll_speed"] = value

func _on_zoom_speed_changed(value):
	MainCamera.zoom_spd = value
	Editor.editor_settings["zoom_speed"] = value

func _on_BGSelect_selected(ID):
	var selected_bg = $General/EditorBackgroundSelect.get_item_text(ID)
	var bg_path = "res://sprites/backgrounds/" + selected_bg + ".jpg"
	Editor.get_node("BGLayer/Background").texture = load(bg_path)
	Editor.editor_settings["bg_select"] = ID

func _on_LowProcessorMode_toggled(button_pressed: bool) -> void:
	OS.low_processor_usage_mode = button_pressed
	Editor.editor_settings["low_processor_mode"] = button_pressed

func _on_DisableAnimations_toggled(button_pressed: bool) -> void:
	if button_pressed:
		Editor.get_node("InspectorLayer/Inspector/AnimationPlayer").stop()
	else:
		Editor.get_node("InspectorLayer/Inspector/AnimationPlayer").play("MovingDots")
	Editor.editor_settings["disable_animations"] = button_pressed

func _on_VSync_toggled(button_pressed: bool) -> void:
	OS.set_use_vsync(button_pressed)
	Editor.editor_settings["use_vsync"] = button_pressed

func _on_MuteSound_toggled(button_pressed: bool) -> void:
	AudioServer.set_bus_mute(0, button_pressed)
	Editor.editor_settings["mute_sound"] = button_pressed

func _on_MoveBlocksAsChain_toggled(button_pressed: bool) -> void:
	Editor.editor_settings["move_blocks_as_chain"] = button_pressed


