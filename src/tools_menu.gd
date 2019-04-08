extends Button

onready var menu : PopupMenu = $PopupMenu
onready var menu_pos : Vector2 = rect_position + Vector2(0, 40)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("pressed", self, "on_tools_pressed")
	menu.connect("id_pressed", self, "on_item_selected")

	# Disable certain options if no C#
	if !CSharp.is_working:
		var items_to_disable : Array = [0]
		for i in items_to_disable:
			menu.set_item_disabled(i, true)
			menu.set_item_text(i, menu.get_item_text(i) + " (requires C#)")


func on_tools_pressed() -> void:
	var menu_popup_rect : Rect2 = Rect2(menu_pos, Vector2())
	menu.popup(menu_popup_rect)
	menu.rect_position = menu_pos

func on_item_selected(ID : int) -> void:
	match ID:
		0:
			# Spellcheck
			owner.get_node("FrontWindows/SpellCheckWindow").popup_centered()
		1:
			# Import (merge)
			# Imports all new blocks from the specified file
			Editor.open_file(Editor.OPEN_FILE_BEHAVIOUR.append_new_ids)
		
		2:
			# Autosaves
			OS.shell_open(OS.get_user_data_dir())
		_:
			push_warning("Not yet implemented: " + str(ID))