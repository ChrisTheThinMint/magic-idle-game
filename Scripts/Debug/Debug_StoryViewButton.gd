extends CheckButton

func _on_ready() -> void:
	Storylets.storylet_view_opened.connect(_on_storylet_view_opened)
	Storylets.storylet_view_closed.connect(_on_storylet_view_closed)

func _on_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		Storylets.request_open_storylet_view.emit()
	else:
		Storylets.request_close_storylet_view.emit()
	pass # Replace with function body.

func _on_storylet_view_opened():
	set_pressed_no_signal(true)

func _on_storylet_view_closed():
	set_pressed_no_signal(false)
