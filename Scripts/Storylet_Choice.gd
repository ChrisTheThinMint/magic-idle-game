class_name Storylet_Choice
extends MarginContainer

@onready var title_label: RichTextLabel = $MarginContainer/VBoxContainer/TitleLabel
@onready var initial_text_label: RichTextLabel = $MarginContainer/VBoxContainer/InitialTextLabel
@onready var result_text_label: RichTextLabel = $MarginContainer/VBoxContainer/ResultTextLabel

func update_body(title: String, initial_text: String, result_text: String, result_visible: bool = false):
	title_label.text = title
	initial_text_label.text = initial_text
	result_text_label.text = result_text
	
	result_text_label.visible = result_visible
	pass

func hide_result():
	result_text_label.visible = false
	pass

func reveal_result():
	result_text_label.visible = true
	pass
