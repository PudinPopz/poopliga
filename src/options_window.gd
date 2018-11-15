extends Popup

onready var scroll_speed_slider = get_node("GridContainer/ScrollSpeedSlider")
onready var zoom_speed_slider = get_node("GridContainer/ZoomSpeedSlider")
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	scroll_speed_slider.connect("value_changed",self,"_on_scroll_speed_changed")
	zoom_speed_slider.connect("value_changed",self,"_on_zoom_speed_changed")
	$GridContainer/LowProcessorMode.connect("toggled", self, "_on_LowProcessorMode_toggled")
	$GridContainer/DisableAnimations.connect("toggled", self, "_on_DisableAnimations_toggled")

func _on_scroll_speed_changed(value):
	MainCamera.scroll_spd = value

func _on_zoom_speed_changed(value):
	MainCamera.zoom_spd = value

func _on_Options_toggled(button_pressed):
	visible = button_pressed


func _on_Options_pressed():
	popup_centered()

func _on_LowProcessorMode_toggled(button_pressed: bool) -> void:
	OS.low_processor_usage_mode = button_pressed


func _on_DisableAnimations_toggled(button_pressed: bool) -> void:
	if button_pressed:
		Editor.get_node("InspectorLayer/Inspector/AnimationPlayer").stop()
	else:
		Editor.get_node("InspectorLayer/Inspector/AnimationPlayer").play("MovingDots")
