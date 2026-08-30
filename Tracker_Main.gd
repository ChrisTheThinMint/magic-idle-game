extends VBoxContainer

@onready var activity_tracker: RichTextLabel = $MarginContainer/ScrollContainer_Left/Panel/ActivityTracker
@onready var resource_tracker: RichTextLabel = $MarginContainer/ScrollContainer_Left/Panel/ResourceTracker
@onready var quality_tracker: RichTextLabel = $MarginContainer/ScrollContainer_Left/Panel/QualityTracker

func _on_activity_toggle_toggled(toggled_on: bool) -> void:
	activity_tracker.visible = toggled_on
	pass # Replace with function body.

func _on_quality_toggle_toggled(toggled_on: bool) -> void:
	quality_tracker.visible = toggled_on
	pass # Replace with function body.

func _on_resource_toggle_toggled(toggled_on: bool) -> void:
	resource_tracker.visible = toggled_on
	pass # Replace with function body.
