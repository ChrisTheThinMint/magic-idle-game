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
		"LOC_desc": "The fruit of having done something."
	},
	"debug_resource_2": {
		"LOC_title": "Favour",
		"LOC_desc": "A result of your results.",
		"maximum": 50,
		"unlocks": {
			"debug_8": {
				"min": 10,
				"permanent": false
			}
		}
	}
}

var ResourceCount = {}

signal resource_added(resource: String, amount: int)
signal resource_removed(resource: String)
signal resource_changed(resource: String, amount: int)

const MAX = int(1e10)

func _ready() -> void:
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

func get_max(resource: String) -> int:
	if(ResourceData.get(resource).has("maximum")):
		return ResourceData.get(resource).get("maximum")
	else:
		return MAX

func set_amount(resource: String, amount: int) -> int:
	if(is_valid(resource)):
		var new_amount = clampi(amount, 0, get_max(resource))
		
		if(not is_active(resource)):
			resource_added.emit(resource, new_amount)
		else: 
			resource_changed.emit(resource, new_amount)
			
		ResourceCount.set(resource, new_amount)
		return new_amount
	else:
		push_error("Trying to add an invalid quality with resource %s" % resource)
		return 0

func add_amount(resource: String, amount: int) -> int:
	var old_amount = get_amount(resource)
	var new_amount = set_amount(resource, old_amount + amount)
	return new_amount - old_amount

func remove_resource(resource: String):
	if(is_valid(resource)):
		if(is_active(resource)):
			resource_removed.emit(resource)
			ResourceCount.erase(resource)
	else:
		push_error("Trying to remove an invalid resource with resource %s" % resource)
	pass

func change_resource(resource: String, amount: int):
	var title = get_loc(resource, "title")
	
	if(amount == 0):
		GameLog.log_resource_remove(title)
		
		remove_resource(resource)
		process_unlocks(resource, 0)
	else:
		var old_amount = get_amount(resource)
		var change = add_amount(resource, amount)
		var new_amount = old_amount + change
		
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
		
		process_unlocks(resource, new_amount)
	pass

func reduce_resource(resource: String, amount: int):
	change_resource(resource, -amount)
	pass

func process_unlocks(resource: String, amount: int):
	if(ResourceData.get(resource).has("unlocks")):
		var unlocks = ResourceData.get(resource).get("unlocks")
		
		for unlock in unlocks: if(Activities.is_valid(unlock)):
			var data = unlocks.get(unlock)
			var minimum = 0
			var maximum = MAX
			var permanent = false
			
			if(data.has("min")):
				minimum = data.get("min")
				
			if(data.has("max")):
				maximum = data.get("max")
				
			if(data.has("permanent")):
				permanent = data.get("permanent")
			
			if(minimum <= amount && amount <= maximum):
				if(Activities.is_locked(unlock)):
					Activities.unlock_activity(unlock)
			elif(not permanent):
				Activities.lock_activity(unlock)
	pass
