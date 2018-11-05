extends "res://src/blocks/dialogue_block.gd"

var tail_count := 2
var tails := ["","","","","",""]
var choices := ["","","","","",""]

func _ready():
	# Call _ready() of dialogue_block
	._ready()
	node_type = NODE_TYPE.branch_block

	# Do rest of stuff on frame after ready
	yield(get_tree().create_timer(0), "timeout")
	# Load extra_data
	if !extra_data.empty():
		tail_count = tail_count
		tails = extra_data.tails
		choices = extra_data.choices
	# Load data into fields
	$NinePatchRect/TailCountHSlider.value = tail_count
	# Update choice field text
	for i in range(choices.size()):
		get_choice_field(i).text = choices[i]

	# Run tailcount update code
	_on_TailCountHSlider_value_changed(tail_count)


func get_choice_field(index : int):
	if index < 0 or index > 5:
		return null
	var path = "NinePatchRect/Choices/" + str(index) + "/LineEdit"
	return get_node(path)

func get_tail_connector(index : int):
	if index < 0 or index > 5:
		return null
	var path = "NinePatchRect/Tails/" + str(index) + "/TailConnector"
	return get_node(path)

func serialize():
	for i in range(choices.size()):
		choices[i] = get_choice_field(i).text

	extra_data = {
		tail_count = tail_count,
		tails = tails,
		choices = choices
	}
	var dict = .serialize()
	return dict

func _on_TailCountHSlider_value_changed(value: float) -> void:
	tail_count = value

	# Resize NinePatchRect
	if value >= 5:
		$NinePatchRect.rect_size.y = 300
	elif value >= 3:
		$NinePatchRect.rect_size.y = 220
	else:
		$NinePatchRect.rect_size.y = 150

	# Hide and reveal choice fields
	for i in range(choices.size()):
		var field = get_choice_field(i)
		var connector = get_tail_connector(i)
		if i >= tail_count:
			field.get_parent().visible = false
			connector.get_parent().visible = false
		else:
			field.get_parent().visible = true
			connector.get_parent().visible = true
