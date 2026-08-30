extends Node
## Autoload/Singleton

## Implementation of quality system ala Fallen London
## Qualities are flags for capabilities, personality, contacts, story, etc
## They are always changed to a specific target value (see override_quality)
## (Specific use cases can still get their current value for arithmetic)
## They are considered inactive and removed from the count at zero

var QualityData = {
	"debug_quality_1": {
		"LOC_title": "An Uncertain Beginning",
		"LOC_desc": "The beginning is certain, but what lies beyond is not."
	},
	"debug_quality_2": {
		"LOC_title": "A Particular Persistence",
		"LOC_desc": "Practical proof of your proficiency in processes",
		"unlocks": {
			"debug_7": {
				"min": 4,
				"max": 5,
				"permanent": false
			}
		}
	},
	"debug_quality_3": {
		"LOC_title": "A Line of Horrendeously Excessive And Quite Unnecessary Length",
		"LOC_desc": "The beginning is certain, but what lies beyond is not."
	}
}

var QualityCount = {}

signal quality_added(quality: String, value: int)
signal quality_changed(quality: String, value: int)
signal quality_removed(quality: String)

const MAX = int(1e10)

func _ready() -> void:
	pass

func get_loc(quality: String, key: String) -> String:
	if(QualityData.get(quality).has("LOC_" + key)):
		return QualityData.get(quality).get("LOC_" + key)
	else:
		return ""

func is_valid(quality: String) -> bool:
	return QualityData.has(quality)

func is_active(quality: String) -> bool:
	return QualityCount.has(quality)

func get_amount(quality: String) -> int:
	if(is_active(quality)):
		return QualityCount.get(quality)
	else:
		return 0

func set_amount(quality: String, amount: int) -> int:
	if(is_valid(quality)):
		var final_amount = clampi(amount, 0, MAX)
		
		if(not is_active(quality)):
			quality_added.emit(quality, final_amount)
		else: 
			quality_changed.emit(quality, final_amount)
		
		QualityCount.set(quality, final_amount)
		return final_amount
	else:
		push_error("Trying to add an invalid quality %s with amount %s" % [quality, amount])
		return 0

#func add_amount(quality: String, amount: int):
	#set_amount(quality, get_amount(quality) + amount)
	#pass

func remove_quality(quality: String):
	if(is_valid(quality)):
		if(is_active(quality)):
			QualityCount.erase(quality)
		quality_removed.emit(quality)
	else:
		push_error("Trying to remove an invalid quality with quality %s" % quality)
	pass

# Qualities are always set to a new value, see above
func override_quality(quality: String, value: int):
	var title = get_loc(quality, "title")
	var old_value = get_amount(quality)
	
	if(value > 0 && old_value != value):
		if(is_active(quality) && old_value != value):
			GameLog.log_quality_override(title, value)
		else:
			GameLog.log_quality_create(title)
		var final_amount = set_amount(quality, value)
		
		process_unlocks(quality, final_amount)
	elif(value == 0):
		if(old_value > 0):
			GameLog.log_quality_remove(title)
		
		if(is_active(quality)):
			remove_quality(quality)
		
		## unlocks can still go through 
		## i.e. We treat a value of 0 as valid even if inactive
		process_unlocks(quality, 0)
	elif(value < 0):
		printerr("Trying to assign negative value to quality %s, removing instead" % quality)
		if(old_value > 0):
			GameLog.log_quality_remove(title)
		
		if(is_active(quality)):
			remove_quality(quality)
	pass

func process_unlocks(quality: String, value: int):
	if(QualityData.get(quality).has("unlocks")):
		var unlocks = QualityData.get(quality).get("unlocks")
		
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
			
			if(minimum <= value && value <= maximum):
				if(Activities.is_locked(unlock)):
					Activities.unlock_activity(unlock)
			elif(not permanent):
				Activities.lock_activity(unlock)
	pass
