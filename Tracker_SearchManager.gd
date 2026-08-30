extends HBoxContainer

@onready var button: Button = $Button
@onready var option_button: OptionButton = $OptionButton
@onready var line_edit: LineEdit = $LineEdit

func _on_button_button_up() -> void:
	option_button.selected = -1
	line_edit.clear()
	pass # Replace with function body.
