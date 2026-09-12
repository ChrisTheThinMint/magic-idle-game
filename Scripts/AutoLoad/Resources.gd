extends Node
## Autoload/Singleton

## Implementation of resource system
## Resources act as equipment, items, etc.
## They always have a minimum and maximum
## Most effects apply a delta (see change_resource)

var ResourceData = {
	"debug_resource": {
		"LOC_title": "Result",
		"LOC_title_pl": "Results",
		"max_amount": 500,
		"LOC_desc": "The fruit of having done something.",
		"supports": {
			"resource.debug_resource_2": {
				"required": 10,
				"increase": 1
			}
		}
	},
	"debug_resource_2": {
		"LOC_title": "Favour",
		"LOC_desc": "A result of your results.",
		"max_amount": 50,
		"milestones": {
			10: "unlock_activity.debug_activity_8",
			20: {
				"effect": "add_resource.debug_resource",
				"arguments": { "value": 100 },
				"LOC_message": "You receive a generous donation!"
			}
		}
	}
}

var ResourceCount = {}

signal resource_added(resource: String, amount: int)
signal resource_changed(resource: String, amount: int)
signal resource_max_changed(resource: String, max_amount: int)
signal resource_removed(resource: String)

func _ready() -> void:
	for resource in ResourceData:
		update_max_amount(resource)
	pass

func get_loc(resource: String, key: String, plural: bool = false) -> String:
	if(ResourceData.get(resource).has("LOC_" + key)):
		if(plural):
			if(ResourceData.get(resource).has("LOC_" + key + "_pl")):
				return ResourceData.get(resource).get("LOC_" + key + "_pl")
			else:
				return ResourceData.get(resource).get("LOC_" + key)
		else:
			return ResourceData.get(resource).get("LOC_" + key)
	else:
		return ""

func is_valid(resource: String) -> bool:
	return ResourceData.has(resource)

func is_active(resource: String) -> bool:
	return ResourceCount.has(resource)

func get_amount(resource: String) -> int:
	if(is_active(resource)):
		return ResourceCount.get(resource)
	else:
		return 0

func set_amount(resource: String, amount: int) -> int:
	if(is_valid(resource)):
		var new_amount = clampi(amount, 0, get_max_amount(resource))
		
		ResourceCount.set(resource, new_amount)
		
		if(not is_active(resource)):
			resource_added.emit(resource, new_amount)
		else: 
			resource_changed.emit(resource, new_amount)
		return new_amount
	else:
		push_error("Trying to add an invalid quality with resource %s" % resource)
		return 0

func add_amount(resource: String, amount: int) -> int:
	var old_amount = get_amount(resource)
	var new_amount = set_amount(resource, old_amount + amount)
	return new_amount - old_amount

#region HANDLING MAX AMOUNT
func get_max_amount(resource: String) -> int:
	if(ResourceData.get(resource).has("max_amount_current")):
		return ResourceData.get(resource).get("max_amount_current")
	else:
		return Maximum.MAX

func get_max_amount_base(resource: String) -> int:
	if(ResourceData.get(resource).has("max_amount")):
		return ResourceData.get(resource).get("max_amount")
	else:
		return Maximum.MAX

## Deprecated, always add/remove modifiers instead
func set_max_amount(resource: String, max_amount: int):
	ResourceData.get(resource).set("max_amount", max_amount)
	pass

func set_max_amount_modifier(resource: String, key: String, value: int):
	if(is_valid(resource)):
		if(ResourceData.get(resource).has("max_amount_modifiers")):
			
			if(value == 0):
				ResourceData.get(resource).get("max_amount_modifiers").erase(key)
			else:
				ResourceData.get(resource).get("max_amount_modifiers").set(key, value)
		elif(not value == 0):
			ResourceData.get(resource).set("max_amount_modifiers", {key: value})
		
		update_max_amount(resource)
	pass

func remove_max_amount_modifier(resource: String, key: String):
	set_max_amount_modifier(resource, key, 0)
	pass

func update_max_amount(resource):
	if(is_valid(resource)):
		var modifiers = ResourceData.get(resource).get("max_amount_modifiers", {})
		
		var new_max = Maximum.calculate_maximum(get_max_amount_base(resource), modifiers)
		ResourceData.get(resource).set("max_amount_current", new_max)
		
		resource_max_changed.emit(resource, new_max)
	pass
#endregion

func remove_resource(resource: String):
	if(is_valid(resource)):
		if(is_active(resource)):
			ResourceCount.erase(resource)
			resource_removed.emit(resource)
	else:
		push_error("Trying to remove an invalid resource with resource %s" % resource)
	pass

func change_resource(resource: String, amount: int):
	var title = get_loc(resource, "title")
	var old_amount = get_amount(resource)
	var change = add_amount(resource, amount)
	var new_amount = old_amount + change
	
	if(amount == 0):
		new_amount = 0
		
		GameLog.log_resource_remove(title)
		
		remove_resource(resource)
	else:
		if(abs(change) > 1):
			title = get_loc(resource, "title", true)
		
		if(old_amount != new_amount):
			if(is_active(resource)):
				if(amount > 0):
					GameLog.log_resource_gain(title, change, new_amount)
				else:
					GameLog.log_resource_lose(title, -change, new_amount)
			else:
				GameLog.log_resource_gain_new(title, change)
	
	var milestones: Dictionary = ResourceData.get(resource).get("milestones", {})
	var completed_milestones: Array = ResourceData.get(resource).get("completed_milestones", [])
	completed_milestones = Effects.process_milestone_list(milestones, completed_milestones, new_amount)
	ResourceData.get(resource).set("completed_milestones", completed_milestones)
	
	var supports: Dictionary = ResourceData.get(resource).get("supports", {})
	Maximum.process_supports(supports, new_amount, resource)
	pass

func reduce_resource(resource: String, amount: int):
	change_resource(resource, -amount)
	pass
