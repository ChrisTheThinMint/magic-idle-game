extends VBoxContainer

const RESOURCE_ENTRY = preload("res://resource_entry.tscn")
const QUALITY_ENTRY = preload("res://quality_entry.tscn")

@onready var attribute_tracker = $MarginContainer/ScrollContainer_Left/Panel/AttributeTracker
@onready var attribute_container = $MarginContainer/ScrollContainer_Left/Panel/AttributeTracker/AttributeContainer

@onready var quality_tracker = $MarginContainer/ScrollContainer_Left/Panel/QualityTracker
@onready var quality_container = $MarginContainer/ScrollContainer_Left/Panel/QualityTracker/QualityContainer

@onready var resource_tracker = $MarginContainer/ScrollContainer_Left/Panel/ResourceTracker
@onready var resource_container = $MarginContainer/ScrollContainer_Left/Panel/ResourceTracker/ResourceContainer

@onready var search_bar: HBoxContainer = $SearchBar
@onready var search_edit: LineEdit = $SearchBar/SearchEdit
@onready var reset_search_button: Button = $SearchBar/ResetSearchButton
@onready var filter_menu: OptionButton = $SearchBar/FilterMenu

var quality_entries = {}
var resource_entries = {}

func _ready() -> void:
	Qualities.quality_added.connect(_on_quality_added)
	Qualities.quality_changed.connect(_on_quality_changed)
	Qualities.quality_removed.connect(_on_quality_removed)
	
	Resources.resource_added.connect(_on_resource_added)
	Resources.resource_changed.connect(_on_resource_changed)
	Resources.resource_removed.connect(_on_resource_removed)
	pass

func _on_attribute_added(attribute: String):
	pass

func _on_quality_added(quality: String, value: int):
	var entry = QUALITY_ENTRY.instantiate()
	quality_container.add_child(entry)
	
	quality_entries.set(quality, entry)
	entry.setup(quality)
	pass

func _on_quality_changed(quality: String, value: int):
	if(quality_entries.has(quality)):
		var entry: Quality_Entry = quality_entries.get(quality)
		
		entry.set_title()
	pass

func _on_quality_removed(quality: String):
	if(quality_entries.has(quality)):
		var entry: Node = quality_entries.get(quality)
		
		quality_entries.erase(quality)
		quality_container.remove_child(entry)
		entry.free()
	pass

func _on_resource_added(resource: String, amount: int):
	var entry = RESOURCE_ENTRY.instantiate()
	resource_container.add_child(entry)
	
	resource_entries.set(resource, entry)
	entry.setup(resource, amount)
	pass

func _on_resource_changed(resource: String, amount: int):
	if(resource_entries.has(resource)):
		var entry: Resource_Entry = resource_entries.get(resource)
		
		entry.set_amount(amount)
	pass

func _on_resource_removed(resource: String):
	if(resource_entries.has(resource)):
		var entry: Node = resource_entries.get(resource)
		
		resource_entries.erase(resource)
		resource_container.remove_child(entry)
		entry.free()
	pass

func _on_attribute_toggle_toggled(toggled_on: bool) -> void:
	attribute_tracker.visible = toggled_on
	pass # Replace with function body.
	
func _on_quality_toggle_toggled(toggled_on: bool) -> void:
	quality_tracker.visible = toggled_on
	pass # Replace with function body.

func _on_resource_toggle_toggled(toggled_on: bool) -> void:
	resource_tracker.visible = toggled_on
	pass # Replace with function body.

func _on_reset_search_button_button_up() -> void:
	search_edit.clear()
	filter_menu.selected = -1
	pass # Replace with function body.
