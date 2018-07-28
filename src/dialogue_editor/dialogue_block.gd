extends Node2D

onready var NinePatch = get_node("NinePatchRect")
onready var id_Label = get_node("NinePatchRect/TitleBar/Id_Label")
onready var DraggableSegment = get_node("NinePatchRect/TitleBar/DraggableSegment")
onready var CharacterLineEdit = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/CharacterLineEdit")
onready var DialogueRichTextLabel = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/DialogueRichTextLabel")
onready var DialogueLineEdit = get_node("NinePatchRect/Dialogue/DialogueBoxSprite/DialogueRichTextLabel/LineEdit")
onready var AnimPlayer = get_node("AnimationPlayer")

const snd_delet = preload("res://snd/delet_sound.ogg")
const throwaway_sound = preload("res://src/dialogue_editor/ThrowawaySound.tscn")

var just_created : bool = false
var dragging : bool = false
var tail_valid : bool = false
var previous_pos := Vector2(0,0)
var mouse_delta := Vector2(0,0)
var mouse_pos := Vector2(0,0)
var mouse_previous_pos := Vector2(0,0)
var mouse_offset := Vector2(0,0)

onready var nine_patch_size = NinePatch.rect_size
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_physics_process(false)
	if !just_created:
		set_process_input(false)
	DialogueLineEdit.connect("text_changed",self,"update_DialogueRichTextLabel")

	# Play spawn animation
	AnimPlayer.play("spawn")


func update_DialogueRichTextLabel(new_text):
	var new_text_formatted = new_text.replace("\\n","\n")
	DialogueRichTextLabel.set_bbcode(new_text_formatted)
	pass

func fill_with_garbage():
	CharacterLineEdit.text = str(randi())
	DialogueRichTextLabel.bbcode_text = str(randi()).sha256_text()
	DialogueLineEdit.text = str(randi()).sha256_text()

func _input(event):
	if CAMERA2D.scroll_mode != 0:
		mouse_offset.y += CAMERA2D.scroll_mode*CAMERA2D.scroll_spd
	if CAMERA2D.pan_mode or !Input.is_action_pressed("click"):
		dragging = false
		mouse_offset = Vector2()
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		if dragging:
			mouse_delta = (mouse_pos - mouse_previous_pos)
			position = previous_pos + mouse_delta  * CAMERA2D.zoom_level  + mouse_offset
			if just_created:
				position = get_global_mouse_position()
			# Teleport block to cursor if too far away
			if abs(get_global_mouse_position().y - position.y) > 80 or \
			abs(get_global_mouse_position().x - position.x) > 400:
				just_created = true # Act like just created
				pass
			
	if (DraggableSegment.pressed or just_created) and !dragging and !CAMERA2D.pan_mode:
		mouse_offset = Vector2()
		previous_pos = position
		mouse_previous_pos = mouse_pos
		dragging = true
	
	if Input.is_action_just_released("click"):
		just_created = false
		pass	
		
	

func move_to_front():
	# Move to front of DialogueBlocks
	var index = get_parent().get_child_count()
	get_parent().move_child(self, index)
	pass

func randomise_id():
	id_Label.text = str(float(OS.get_ticks_usec()) + randf()).sha256_text().substr(0,10)
	return id_Label.text
	pass
	
func _on_DraggableSegment_pressed():
	set_process_input(true)
	mouse_delta = Vector2(0,0)
	previous_pos = position
	mouse_previous_pos = mouse_pos
	dragging = true
	move_to_front()
	
func _on_DeleteButton_button_down():
	move_to_front()
	pass
func _on_DeleteButton_pressed():
	AnimPlayer.play("kill")
	var death_sound = throwaway_sound.instance()
	death_sound.random_pitch = false
	death_sound.stream = snd_delet
	death_sound.volume_db = -6.118
	#get_node("AudioStreamPlayer2D").play(0)
	CAMERA2D.add_child(death_sound)
	pass 


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"kill":
			self.queue_free() # actually kill
	

func _on_BoundingBox_mouse_entered():
	pass


func _on_BoundingBox_mouse_exited():
	pass

func _on_DraggableSegment_mouse_entered():
	set_process_input(true)
	pass

func _on_DraggableSegment_mouse_exited():
	if !just_created:
		set_process_input(false)
	pass

onready var line_start_pos := Vector2(0,nine_patch_size.y-4)
onready var tail_location := Vector2(90,900)
onready var line_curve = Curve2D.new()
func _draw():
	#line_curve.clear_points()
	#line_curve.add_point(line_start_pos, Vector2(1,1),Vector2(1,1))
	#line_curve.add_point((line_start_pos + tail_location)/2)
	#line_curve.add_point(tail_location, Vector2(1,0),Vector2(1,1))
	if tail_valid:
		draw_line(line_start_pos,tail_location,Color("1e7da6"),4,true)
	
	#draw_polyline(line_curve.get_baked_points(),Color("1e7da6"),4,true)
	pass