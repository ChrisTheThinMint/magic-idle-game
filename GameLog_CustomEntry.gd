extends LineEdit


func _on_text_submitted(new_text: String) -> void:
	GameLog.add_message(new_text)
	
	clear()
	pass # Replace with function body.
