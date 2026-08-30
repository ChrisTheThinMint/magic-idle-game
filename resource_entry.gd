class_name Resource_Entry
extends Node

@onready var rich_text_label: RichTextLabel = $HBoxContainer/RichTextLabel
@onready var rich_text_label_2: RichTextLabel = $HBoxContainer/RichTextLabel2
@onready var control: Control = $HBoxContainer/Control
@onready var pin_button: Button = $HBoxContainer/Control/PinButton


var pinned = false
var my_resource = ""

func setup(new_resource: String, new_amount: int = 0):
	my_resource = new_resource
	
	#set_title(Resources.get_loc(my_resource, "title", true))
	#set_amount(amount, Resources.get_max(my_resource))
	
	set_title(Resources.get_loc(my_resource, "title", true))
	set_amount(new_amount)
	pass

func set_title(text: String, silent: bool = false):
	rich_text_label.text = text
	
	#if(not silent):
	#	update_tooltip()
	pass

func set_amount(amount: int):
	var max_amount = Resources.get_max(my_resource)
	
	if(max_amount != Resources.MAX):
		rich_text_label_2.text = "%s/%s" % [amount, max_amount]
	else:
		rich_text_label_2.text = "%s" % amount
	
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
