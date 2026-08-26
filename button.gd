extends Button

@onready var activity: Activity_UI = $".."

func _get_tooltip(at_position: Vector2) -> String:
	return activity.get_dynamic_tooltip()
