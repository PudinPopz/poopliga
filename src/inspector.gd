extends Panel

func _ready() -> void:
	# Set up signal connections
	for child in $DialogueBoxContainer/PropertiesVBox.get_children():
		var label = child.get_node("Label")
		if label == null:
			continue

		# Line edits
		var line_edit : LineEdit = child.get_node("LineEdit")
		if line_edit != null:
			line_edit.connect("text_changed", self, "on_string_property_changed", [line_edit])

		# Toggle buttons
		var toggle : Button = child.get_node("ToggleContainer/Toggle")
		if toggle != null:
			toggle.connect("toggled", self, "on_bool_property_changed", [toggle])

	update_inspector()

func _on_Inspector_visibility_changed():
	update_inspector()

func update_inspector():
	# Check if block actually valid
	if Editor.selected_block == null or !is_instance_valid(Editor.selected_block):
		$Name/Label.text = "No block selected."
		set_all_containers_visibility(false)
		$EmptyContainer.visible = true
		return
	# Do nothing if reselecting the same thing
	if $Name/Label.text == str(Editor.selected_block.id):
		return
	$Name/Label.text = str(Editor.selected_block.id)

	set_all_containers_visibility(false)

	match Editor.selected_block.node_type:
		Editor.DB.NODE_TYPE.dialogue_block:
			$DialogueBoxContainer.visible = true
		_:
			$EmptyContainer.visible = true

	if $DialogueBoxContainer.visible:
		update_dialogue_box_container()


func update_dialogue_box_container():
	for child in $DialogueBoxContainer/PropertiesVBox.get_children():
		if !child.has_node("Label"):
			continue

		var label = child.get_node("Label")
		var property_name : String = label.text

		# Update line edits
		if child.has_node("LineEdit"):
			var line_edit : LineEdit = child.get_node("LineEdit")
			line_edit.text = ""
			if Editor.selected_block.extra_data.has(property_name):
				line_edit.text = Editor.selected_block.extra_data[property_name]

		# Update toggles
		if child.has_node("ToggleContainer/Toggle"):
			var toggle : Button = child.get_node("ToggleContainer/Toggle")
			toggle.pressed = false
			if Editor.selected_block.extra_data.has(property_name):
				toggle.pressed = Editor.selected_block.extra_data[property_name]

func on_string_property_changed(new_text, line_edit):
	var property_name : String = line_edit.get_parent().get_node("Label").text
	if new_text == "":
		# Remove property if blank to avoid cluttering file
		Editor.selected_block.extra_data.erase(property_name)
		return
	Editor.selected_block.extra_data[property_name] = new_text

func on_bool_property_changed(button_pressed, button):
	var property_name : String = button.get_parent().get_parent().get_node("Label").text
	if button_pressed == false:
		# Remove property if false to avoid cluttering file
		Editor.selected_block.extra_data.erase(property_name)
		return
	Editor.selected_block.extra_data[property_name] = button_pressed

func set_all_containers_visibility(visibility):
	for container in get_children():
		if container is ScrollContainer:
			container.visible = visibility