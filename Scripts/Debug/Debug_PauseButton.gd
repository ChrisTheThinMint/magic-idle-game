extends CheckButton


func _on_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		Activities.pause_all_activities()
	else:
		Activities.unpause_all_activities()
	pass # Replace with function body.
