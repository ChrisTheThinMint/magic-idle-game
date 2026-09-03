class_name Storylet_View
extends VBoxContainer

@onready var title_label: RichTextLabel = $MarginContainer2/MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label: RichTextLabel = $MarginContainer2/MarginContainer/VBoxContainer/DescLabel

@onready var choice_container: VBoxContainer = $ScrollContainer/HBoxContainer/ChoiceContainer

const STORYLET_CHOICE = preload("res://UI/Storylet_Choice.tscn")

var Choices = []

func _ready() -> void:
	Storylets.StoryletView = self
	pass

func update_body(title: String, desc: String):
	title_label.text = title
	desc_label.text = desc
	pass

func clear_choices():
	for child in choice_container.get_children():
		child.queue_free()
	Choices.clear()

func create_choice() -> Storylet_Choice:
	var choice: Storylet_Choice = STORYLET_CHOICE.instantiate()
	
	choice_container.add_child(choice)
	Choices.append(choice)
	
	return choice
