extends CheckButton


func _on_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		Activities.global_pause()
	else:
		Activities.global_unpause()
	pass # Replace with function body.
