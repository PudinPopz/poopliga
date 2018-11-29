extends Popup

onready var scroll_speed_slider = get_node("GridContainer/ScrollSpeedSlider")
onready var zoom_speed_slider = get_node("GridContainer/ZoomSpeedSlider")
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	scroll_speed_slider.connect("value_changed",self,"_on_scroll_speed_changed")
	zoom_speed_slider.connect("value_changed",self,"_on_zoom_speed_changed")

	$GridContainer/EditorBackgroundSelect.connect("item_selected", self, "_on_BGSelect_selected")

	$GridContainer/LowProcessorMode.connect("toggled", self, "_on_LowProcessorMode_toggled")
	$GridContainer/DisableAnimations.connect("toggled", self, "_on_DisableAnimations_toggled")
	$GridContainer/EnableVSync.connect("toggled", self, "_on_VSync_toggled")
	$GridContainer/MuteSound.connect("toggled", self, "_on_MuteSound_toggled")
	$GridContainer/MoveBlocksAsChain.connect("toggled", self, "_on_MoveBlocksAsChain_toggled")

func _on_Options_pressed():
	popup_centered()

func _on_Options_toggled(button_pressed):
	visible = button_pressed


func _on_scroll_speed_changed(value):
	MainCamera.scroll_spd = value
	Editor.editor_settings["scroll_speed"] = value

func _on_zoom_speed_changed(value):
	MainCamera.zoom_spd = value
	Editor.editor_settings["zoom_speed"] = value

func _on_BGSelect_selected(ID):
	var selected_bg = $GridContainer/EditorBackgroundSelect.get_item_text(ID)
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
