extends Node
## Autoload/Singleton

# Dispatcher for requirements
# Intentionally not built around json implementation, unlike effects
# Since some requirements require several functions at different timings

# Supports three types: checks, costs and catalysts/capacity

# Checks set a condition that is evaluated without changing the target later
# This is the only type supported for qualities: quality_check
# A note on these: For performance reasons, they are inferior to unlocks
# As they are not checked until the player interacts with an activity
# An activity can appear locked when it shouldnt be or vice versa
# But they are good for two-factor validation and for tooltips
# Thus we dont even attempt to trace back unlocks and instead
# the designer sets those checks that are intended to be visible on the target
# Or you append .HIDDEN so they act as JSON comments (and two-factor still)

# Costs deduct the target in order for the source to work

# Catalysts deduct the target but can be restored at a later point
# They may need caching at a future point

# Capacity functions the same way as catalysts
# but has different localization for a future equipment/space system

# Called both for one-time checks and to confirm whether costs can be paid
func process_requirements(input: Dictionary) -> bool:
	var all_clear = true
	
	for requirement in input:
		var requirement_data = input.get(requirement)
		
		if(typeof(requirement_data) != TYPE_DICTIONARY):
			if(typeof(requirement_data) == TYPE_ARRAY 
				&& requirement_data.size() == 2):
				requirement_data = {
					"value": requirement_data.get(0),
					"value_max": requirement_data.get(1)
				}
			else:
				requirement_data = { "value": requirement_data }
		
		var valid = process_requirement(requirement, requirement_data)
		if(not valid):
			all_clear = false
	
	return all_clear

func process_requirement(header: String, input: Dictionary) -> bool:
	var type: String = header.get_slice(".", 0)
	var target: String = header.get_slice(".", 1)
	
	match(type):
		"resource_check", "resource_cost", "resource_catalyst", "resource_capacity":
			if(not Resources.is_valid(target)):
				return false
			
			var amount = Resources.get_amount(target)
			var value: int = input.get("value", 0)
			
			if(type == "resource_check"):
				var value_max: int = input.get("value_max", Maximum.MAX)
				value = min(value, value_max)
				
				if(amount < value || amount > value_max):
					return false
			else:
				# Costs/catalysts do not support min-max ranges
				if(amount < value): return false
		"quality_check":
			if(not Qualities.is_valid(target)):
				return false
			
			var current = Qualities.get_amount(target)
			
			var value: int = input.get("value", 0)
			var value_max: int = input.get("value_max", value)
			
			if(current < value || current > value_max):
				return false
	
	return true

# Typically called after process_requirements fails, to add log messages
func report_missing_requirements(input: Dictionary):
	for requirement in input:
		var requirement_data = input.get(requirement)
		
		if(typeof(requirement_data) != TYPE_DICTIONARY):
			requirement_data = { "value": requirement_data }
		
		report_on_requirement(requirement, requirement_data)
	pass

func report_on_requirement(header: String, input: Dictionary):
	var type: String = header.get_slice(".", 0)
	var target: String = header.get_slice(".", 1)
	
	match(type):
		"resource_check":
			if(not Resources.is_valid(target)):
				return false
				
			var amount = Resources.get_amount(target)
			var value: int = input.get("value", 0)
			var value_max: int = input.get("value_max", Maximum.MAX)
			
			var title = Resources.get_loc(target, "title", value > 1)
			
			value = min(value, value_max)
			
			title = Resources.get_loc(target, "title", value > 1 || value_max > 1)
			
			if(amount < value): 
				if(Resources.is_active(target)):
					GameLog.log_resource_too_low(title, amount, value)
				else:
					GameLog.log_resource_missing(title, value)
			elif(amount > value_max):
				GameLog.log_resource_too_high(title, amount, value)
		"resource_cost", "resource_catalyst", "resource_capacity":
			if(not Resources.is_valid(target)):
				return false
				
			var amount = Resources.get_amount(target)
			var value: int = input.get("value", 0)
			
			var title = Resources.get_loc(target, "title", value > 1)
			
			if(amount < value): 
				if(Resources.is_active(target)):
					GameLog.log_resource_too_low(title, amount, value)
				else:
					GameLog.log_resource_missing(title, value)
		"quality_check":
			if(not Qualities.is_valid(target)):
				return
			
			var title = Qualities.get_loc(target, "title")
			var current = Qualities.get_amount(target)
			
			var value: int = input.get("value", 0)
			var value_max: int = input.get("value_max", value)
			
			if(current < value || current > value_max):
				if(value == value_max):
					GameLog.log_quality_specific_missing(title, value)
				else:
					GameLog.log_quality_range_missing(title, value, value_max)
			pass
	pass

# Called to deduct both costs and catalysts
func process_costs(input: Dictionary):
	for requirement in input:
		var requirement_data = input.get(requirement)
		
		if(typeof(requirement_data) != TYPE_DICTIONARY):
			requirement_data = { "value": requirement_data }
		
		process_cost(requirement, requirement_data)
	pass

func process_cost(header: String, input: Dictionary):
	var type: String = header.get_slice(".", 0)
	var target: String = header.get_slice(".", 1)
	
	match(type):
		"resource_cost", "resource_catalyst", "resource_capacity":
			if(not Resources.is_valid(target)):
				return false
			
			var value: int = input.get("value", 0)
			
			Resources.reduce_resource(target, value)
	pass

# Called to restore catalysts after they were used
func process_catalysts(input: Dictionary):
	for requirement in input:
		var requirement_data = input.get(requirement)
		
		if(typeof(requirement_data) != TYPE_DICTIONARY):
			requirement_data = { "value": requirement_data }
		
		process_catalyst(requirement, requirement_data)
	pass

## Giving a catalyst back is relatively straightforward for resources
## This will require more involved handling for equipment or other systems
## i.e. anything where data is attached to the removed catalyst
func process_catalyst(header: String, input: Dictionary):
	var type: String = header.get_slice(".", 0)
	var target: String = header.get_slice(".", 1)
	
	match(type):
		"resource_catalyst", "resource_capacity":
			if(not Resources.is_valid(target)):
				return false
			
			var value: int = input.get("value", 0)
			
			Resources.add_resource(target, value)
	pass

func process_requirement_descriptions(input: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	
	for requirement in input:
		var requirement_data = input.get(requirement)
		
		if(typeof(requirement_data) != TYPE_DICTIONARY):
			requirement_data = { "value": requirement_data }
		
		var line = process_requirement_desc(requirement, requirement_data)
		if(line != "" && not requirement_data.get("hide_from_tooltip")):
			lines.append(line)
	
	return lines

func process_requirement_desc(header: String, input: Dictionary) -> String:
	var type: String = header.get_slice(".", 0)
	var target: String = header.get_slice(".", 1)
	
	if header.get_slice(".", 2) == "HIDDEN":
		return ""
	
	match(type):
		"resource_check":
			if(not Resources.is_valid(target)):
				return ""
			
			var value: int = input.get("value", 0)
			var value_max: int = input.get("value_max", value)
			var title = Resources.get_loc(target, "title", value > 1 || value_max > 1)
			
			if(value == value_max):
				return "%s x '%s'" % [value, title]
			else:
				return "%s-%s x '%s'" % [value, value_max, title]
		"resource_cost":
			var value: int = input.get("value", 0)
			var title = Resources.get_loc(target, "title", value > 1)
			
			return "%s x '%s' (consumed)" % [value, title]
		"resource_catalyst":
			var value: int = input.get("value", 0)
			var title = Resources.get_loc(target, "title", value > 1)
			
			return "%s x '%s' (Catalyst)" % [value, title]
		"resource_capacity":
			var value: int = input.get("value", 0)
			var title = Resources.get_loc(target, "title", value > 1)
			
			return "%s x '%s' (Capacity)" % [value, title]
		"quality_check":
			if(not Qualities.is_valid(target)):
				return ""
			
			var title = Qualities.get_loc(target, "title")
			
			var value: int = input.get("value", 0)
			var value_max: int = input.get("value_max", value)
			
			if(value == value_max):
				return "'%s - %s'" % [title, value]
			else:
				return "'%s - %s-%s'" % [title, value, value_max]
	return ""
