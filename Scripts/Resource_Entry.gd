class_name Resource_Entry
extends Node

@onready var rich_text_label: RichTextLabel = $HBoxContainer/RichTextLabel
@onready var rich_text_label_2: RichTextLabel = $HBoxContainer/RichTextLabel2
@onready var control: Control = $HBoxContainer/Control
@onready var pin_button: Button = $HBoxContainer/Control/PinButton

var pinned = false
var my_resource = ""
var tracker_main = null

func setup(new_resource: String, tracker: Node):
	my_resource = new_resource
	tracker_main = tracker
	
	update()
	pass

func update():
	rich_text_label.text = Resources.get_loc(my_resource, "title", true)
	
	var amount = Resources.get_amount(my_resource)
	var max_amount = Resources.get_max_amount(my_resource)
	
	if(max_amount != Maximum.MAX):
		rich_text_label_2.text = "%s/%s" % [amount, max_amount]
	else:
		rich_text_label_2.text = "%s" % amount
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
		tracker_main._on_resource_unpin(self)
	pass # Replace with function body.
