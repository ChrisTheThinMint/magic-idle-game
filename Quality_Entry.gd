class_name Quality_Entry
extends Node

@onready var rich_text_label: RichTextLabel = $HBoxContainer/RichTextLabel
@onready var control: Control = $HBoxContainer/Control
@onready var pin_button: Button = $HBoxContainer/Control/PinButton

var pinned = false
var my_quality = ""

func setup(new_quality: String):
	my_quality = new_quality
	
	set_title(true)
	pass

func set_title(silent: bool = false):
	var new_text = Qualities.get_loc(my_quality, "title")
	rich_text_label.text = Qualities.get_loc(my_quality, "title")
	
	#if(not silent):
	#	update_tooltip()
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
	pass # Replace with function body.
