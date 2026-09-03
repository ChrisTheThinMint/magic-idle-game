class_name Activity_Entry
extends Node

@onready var rich_text_label: RichTextLabel = $HBoxContainer/RichTextLabel

@onready var state_label: Label = $HBoxContainer/Control2/StateLabel
@onready var progress_bar: ProgressBar = $HBoxContainer/Control2/ProgressBar

@onready var pin_button: Button = $HBoxContainer/Control/PinButton
@onready var play_button: Button = $HBoxContainer/Control3/PlayButton

var pinned = false
var my_activity = ""
var tracker_main = null

func setup(new_activity: String, tracker: Node):
	my_activity = new_activity
	tracker_main = tracker
	
	update()
	pass

func update():
	rich_text_label.text = Activities.get_loc(my_activity, "title")
	
	update_progress_bar()
	update_state_label()
	update_play_button()
	pass

func update_progress_bar():
	var progress = Activities.get_progress(my_activity)
	var goal = Activities.get_goal(my_activity)
	
	if(Activities.is_active(my_activity) && 
		not Activities.is_paused(my_activity)):
		progress_bar.visible = true
		progress_bar.value = progress
		progress_bar.max_value = goal
	else:
		progress_bar.visible = false
	pass

func update_state_label():
	if(Activities.is_paused(my_activity)):
		state_label.visible = true
		state_label.text = "PAUSED"
	else:
		if(Activities.is_active(my_activity)):
			state_label.visible = false
		else:
			state_label.visible = true
			state_label.text = "INACTIVE"
	pass

func update_play_button():
	if(Activities.is_paused(my_activity)):
		play_button.visible = false
	else:
		if(Activities.is_active(my_activity)):
			play_button.visible = true
			play_button.text = "||"
		else:
			play_button.visible = true
			play_button.text = ">"
	pass

func lock():
	progress_bar.visible = false
	
	state_label.visible = true
	state_label.text = "LOCKED"
	
	play_button.visible = false
	pass

func _on_mouse_entered() -> void:
	pin_button.visible = true
	pass

func _on_mouse_exited() -> void:
	if(!pinned):
		pin_button.visible = false
	pass

func _on_pin_button_toggled(toggled_on: bool) -> void:
	pinned = toggled_on
	
	if(!pinned):
		tracker_main._on_activity_unpin(self)
	pass

func _on_play_button_button_up() -> void:
	Activities._on_activity_toggled(my_activity)
	pass # Replace with function body.
