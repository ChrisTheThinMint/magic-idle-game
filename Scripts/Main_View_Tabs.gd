extends TabContainer

func _ready() -> void:
	Storylets.request_open_storylet_view.connect(_open_storylet_view)
	Storylets.request_close_storylet_view.connect(_close_storylet_view)
	pass

func _open_storylet_view():
	current_tab = get_tab_idx_from_control($StoryletView)
	Storylets.storylet_view_opened.emit()
	pass

# Should default to the previous tab
# Replace this with better logic if we add a third tab
func _close_storylet_view():
	current_tab = get_tab_idx_from_control($Activities)
	Storylets.storylet_view_closed.emit()
	pass
