extends VBoxContainer

@export var category: String

func _ready() -> void:
	var activities_to_create = Activities.ui_get_activities_for_category(category)
	
	for activity in activities_to_create:
		var activity_ui = load("res://activity.tscn").instantiate()
		add_child(activity_ui)
		activity_ui.setup(activity)
	pass
