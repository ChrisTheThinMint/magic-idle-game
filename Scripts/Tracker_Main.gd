extends VBoxContainer

const ACTIVITY_ENTRY = preload("uid://qch5alh1cfdh")
const QUALITY_ENTRY = preload("uid://dvxqd61xnjoug")
const RESOURCE_ENTRY = preload("uid://cyidwdg1ku1xq")

@onready var activity_toggle: Button = $ToggleBar/ActivityToggle
@onready var quality_toggle: Button = $ToggleBar/QualityToggle
@onready var resource_toggle: Button = $ToggleBar/ResourceToggle

@onready var activity_tracker = $MarginContainer/ScrollContainer_Left/Panel/ActivityTracker
@onready var activity_container = $MarginContainer/ScrollContainer_Left/Panel/ActivityTracker/ActivityContainer

@onready var quality_tracker = $MarginContainer/ScrollContainer_Left/Panel/QualityTracker
@onready var quality_container = $MarginContainer/ScrollContainer_Left/Panel/QualityTracker/QualityContainer

@onready var resource_tracker = $MarginContainer/ScrollContainer_Left/Panel/ResourceTracker
@onready var resource_container = $MarginContainer/ScrollContainer_Left/Panel/ResourceTracker/ResourceContainer

@onready var search_bar: HBoxContainer = $SearchBar
@onready var search_edit: LineEdit = $SearchBar/SearchEdit
@onready var reset_search_button: Button = $SearchBar/ResetSearchButton
@onready var filter_menu: OptionButton = $SearchBar/FilterMenu

var activity_entries = {}
var quality_entries = {}
var resource_entries = {}

func _ready() -> void:
	Activities.activity_started.connect(_on_activity_updated.bind(0))
	Activities.activity_progressed.connect(_on_activity_updated)
	Activities.activity_stopped.connect(_on_activity_stopped)
	Activities.activity_locked.connect(_on_activity_locked)
	Activities.activity_unlocked.connect(_on_activity_unlocked)
	Activities.activity_ended.connect(_on_activity_stopped)
	
	Activities.activity_paused.connect(_on_activity_updated_global)
	Activities.activity_unpaused.connect(_on_activity_updated_global)
	
	Qualities.quality_added.connect(_on_quality_updated)
	Qualities.quality_changed.connect(_on_quality_updated)
	Qualities.quality_removed.connect(_on_quality_removed)
	
	Resources.resource_added.connect(_on_resource_updated)
	Resources.resource_changed.connect(_on_resource_updated)
	Resources.resource_removed.connect(_on_resource_removed)
	pass

################################
#region ACTIVITY ENTRY FUNCTIONS
func _on_activity_updated(activity: String, _progress: int):
	if(activity_entries.has(activity)):
		var entry: Activity_Entry = activity_entries.get(activity)
		
		entry.update()
	else:
		var entry = ACTIVITY_ENTRY.instantiate()
		activity_container.add_child(entry)
		
		if(activity_toggle.button_pressed && not activity_tracker.visible):
			activity_tracker.visible = true
		
		activity_entries.set(activity, entry)
		entry.setup(activity, self)
		entry.visible = activity_toggle.button_pressed
	pass

func _on_activity_updated_global(activity: String):
	if(activity_entries.has(activity)):
		_on_activity_updated(activity, 0)
	pass

func _on_activity_stopped(activity: String, _last_completion: bool = false):
	if(activity_entries.has(activity)):
		var entry: Activity_Entry = activity_entries.get(activity)
		
		if(entry.pinned):
			entry.update()
		else:
			activity_entries.erase(activity)
			activity_container.remove_child(entry)
			
			entry.queue_free()
	pass

func _on_activity_locked(activity: String):
	if(activity_entries.has(activity)):
		var entry: Activity_Entry = activity_entries.get(activity)
		
		entry.lock()
	pass

func _on_activity_unlocked(activity: String):
	if(activity_entries.has(activity)):
		var entry: Activity_Entry = activity_entries.get(activity)
		
		entry.update()
	pass

func _on_activity_unpin(entry: Activity_Entry):
	if(not Activities.is_active(entry.my_activity)):
		activity_entries.erase(entry.my_activity)
		activity_container.remove_child(entry)
		entry.call_deferred("free")
	elif(not activity_toggle.button_pressed):
		_on_activity_toggle_toggled(false)
	pass

func _on_activity_toggle_toggled(toggled_on: bool) -> void:
	var any_visible = toggled_on
	for activity in activity_entries:
		var entry: Activity_Entry = activity_entries.get(activity)
		if(entry.pinned):
			entry.visible = true
			any_visible = true
		else:
			entry.visible = toggled_on
	
	activity_tracker.visible = any_visible
	pass
#endregion
################################

###############################
#region QUALITY ENTRY FUNCTIONS
func _on_quality_updated(quality: String, _value: int):
	if(quality_entries.has(quality)):
		var entry: Quality_Entry = quality_entries.get(quality)
		
		entry.update()
	else:
		var entry = QUALITY_ENTRY.instantiate()
		quality_container.add_child(entry)
		
		if(quality_toggle.button_pressed && not quality_tracker.visible):
			quality_tracker.visible = true
		
		quality_entries.set(quality, entry)
		entry.setup(quality, self)
		entry.visible = quality_toggle.button_pressed
	pass

func _on_quality_removed(quality: String):
	if(quality_entries.has(quality)):
		var entry: Node = quality_entries.get(quality)
		
		if(entry.pinned):
			entry.update()
		else:
			quality_entries.erase(quality)
			quality_container.remove_child(entry)
			entry.queue_free()
	pass

func _on_quality_unpin(entry: Quality_Entry):
	if(not Qualities.is_active(entry.my_quality)):
		quality_entries.erase(entry.my_quality)
		quality_container.remove_child(entry)
		entry.call_deferred("free")
	elif(not quality_toggle.button_pressed):
		_on_quality_toggle_toggled(false)
	pass

func _on_quality_toggle_toggled(toggled_on: bool) -> void:
	var any_visible = toggled_on
	for quality in quality_entries:
		var entry: Quality_Entry = quality_entries.get(quality)
		if(entry.pinned):
			entry.visible = true
			any_visible = true
		else:
			entry.visible = toggled_on
	
	quality_tracker.visible = any_visible
	pass
#endregion
###############################

################################
#region RESOURCE ENTRY FUNCTIONS
func _on_resource_updated(resource: String, _amount: int):
	if(resource_entries.has(resource)):
		var entry: Resource_Entry = resource_entries.get(resource)
		
		entry.update()
	else:
		var entry = RESOURCE_ENTRY.instantiate()
		resource_container.add_child(entry)
		
		if(resource_toggle.button_pressed && not resource_tracker.visible):
			resource_tracker.visible = true
		
		resource_entries.set(resource, entry)
		entry.setup(resource, self)
		entry.visible = resource_toggle.button_pressed
	pass

func _on_resource_removed(resource: String):
	if(resource_entries.has(resource)):
		var entry: Node = resource_entries.get(resource)
		
		if(entry.pinned):
			entry.update()
		else:
			resource_entries.erase(resource)
			resource_container.remove_child(entry)
			entry.queue_free()
	pass

func _on_resource_unpin(entry: Resource_Entry):
	if(not Resources.is_active(entry.my_resource)):
		resource_entries.erase(entry.my_resource)
		resource_container.remove_child(entry)
		entry.call_deferred("free")
	elif(not resource_toggle.button_pressed):
		_on_resource_toggle_toggled(false)
	pass

func _on_resource_toggle_toggled(toggled_on: bool) -> void:
	var any_visible = toggled_on
	for resource in resource_entries:
		var entry: Resource_Entry = resource_entries.get(resource)
		if(entry.pinned):
			entry.visible = true
			any_visible = true
		else:
			entry.visible = toggled_on
	
	resource_tracker.visible = any_visible
	pass
#endregion
################################

func _on_reset_search_button_button_up() -> void:
	search_edit.clear()
	filter_menu.selected = -1
	pass
