class_name Quality_Entry
extends Node

@onready var rich_text_label: RichTextLabel = $HBoxContainer/RichTextLabel
@onready var control: Control = $HBoxContainer/Control
@onready var pin_button: Button = $HBoxContainer/Control/PinButton

var pinned = false
var my_quality = ""
var tracker_main = null

func setup(new_quality: String, tracker: Node):
	my_quality = new_quality
	tracker_main = tracker
	
	update()
	pass

func update():
	var title = Qualities.get_loc(my_quality, "title")
	
	if(not Qualities.is_active(my_quality)):
		rich_text_label.text = "[color=Red]" + title + "[/color]"
	else:
		rich_text_label.text = title
	pass

func _on_mouse_entered() -> void:
	pin_button.visible = true
	pass # Replace with function body.

func _on_mouse_exited() -> void:
	if(!pinned):
		pin_button.visible = false
	pass # Replace with function body.

func _on_pin_button_toggled(toggled_on: bool) -> void:
	pinned = toggled_on
	
	if(!pinned):
		tracker_main._on_quality_unpin(self)
	pass # Replace with function body.
