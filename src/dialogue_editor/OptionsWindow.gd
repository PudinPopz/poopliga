extends Control

onready var scroll_speed_slider = get_node("GridContainer/ScrollSpeedSlider")
onready var zoom_speed_slider = get_node("GridContainer/ZoomSpeedSlider")
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	scroll_speed_slider.connect("value_changed",self,"_on_scroll_speed_changed")
	zoom_speed_slider.connect("value_changed",self,"_on_zoom_speed_changed")
	pass # Replace with function body.

func _on_scroll_speed_changed(value):
	CAMERA2D.scroll_spd = value
	pass

func _on_zoom_speed_changed(value):
	CAMERA2D.zoom_spd = value
	pass

func _on_Options_toggled(button_pressed):
	visible = button_pressed
	pass # Replace with function body.