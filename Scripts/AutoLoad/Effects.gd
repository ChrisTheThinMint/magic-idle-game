extends Node
## Autoload/Singleton

var EffectData: Dictionary = {
	"add_resource": {
		"context": "Resources",
		"method": "change_resource",
		"target_arg": "resource",
		"value_arg": "amount",
		"LOC_desc": "Gain {amount} x {resource}"
	},
	"subtract_resource": {
		"context": "Resources",
		"method": "reduce_resource",
		"target_arg": "resource",
		"value_arg": "amount",
		"LOC_desc": "Lose {amount} x {resource}"
	},
	"set_quality": {
		"context": "Qualities",
		"method": "override_quality",
		"target_arg": "quality",
		"value_arg": "value",
		"LOC_desc": "Set '{quality}' to {value}"
	},
	"remove_quality": {
		"context": "Qualities",
		"method": "override_quality",
		"target_arg": "quality",
		"value_arg": "value",
		"LOC_desc": "Remove '{quality}'",
		"default_arguments": {
			"value": 0
		}
	},
	"unlock_activity": {
		"context": "Activities",
		"method": "unlock_activity",
		"target_arg": "activity",
		"LOC_desc": "Unlock '{activity}'"
	},
	"lock_activity": {
		"context": "Activities",
		"method": "lock_activity",
		"target_arg": "activity",
		"LOC_desc": "Lock '{activity}'"
	},
	"start_storylet": {
		"context": "Storylets",
		"method": "start_storylet",
		"target_arg": "storylet",
		"LOC_desc": "Begin '{storylet}'"
	}
}

var TestEffects: Array[Dictionary] = [
	{
		"effect": "set_quality",
		"quality": "debug_quality_1",
		"value": 1
	}
]

func _ready() -> void:
	#Qualities.call("override_quality", "debug_quality_1", 1)
	#process_effect_list(TestEffects)
	pass

func is_valid(effect: String) -> bool:
	return EffectData.has(effect)

func get_context(context: String) -> Object:
	match(context):
		"Activities": return Activities
		"Resources": return Resources
		"Qualities": return Qualities
		"Storylets": return Storylets
		_: return null

func process_effect_list(input: Dictionary) -> bool:
	var all_clear = true
	
	for effect in input:
		var effect_data = input.get(effect)
		
		if(typeof(effect_data) != TYPE_DICTIONARY):
			effect_data = { "value": effect_data }
		
		var valid = process_effect(effect, effect_data)
		if(not valid):
			all_clear = false
		
	return all_clear

func process_effect(header: String, input: Dictionary) -> bool:
	var effect_ID = header.get_slice(".", 0)
	var target_ID = header.get_slice(".", 1)
	#var hidden = true if header.get_slice(".", 2) == "HIDDEN" else false
	
	# VALIDATE AND GET EFFECT
	if(not is_valid(effect_ID)):
		return false
	var effect = EffectData.get(effect_ID)
	
	# GET AND VALIDATE CONTEXT
	var singleton: Object = get_context(effect.get("context", ""))
	if(singleton == null):
		return false
	
	# GET AND VALIDATE METHOD
	var method = effect.get("method", "")
	if(not singleton.has_method(method)):
		return false
	
	var target_arg = effect.get("target_arg", "")
	var value_arg = effect.get("value_arg", "")
	
	var arguments: Array = effect.get("arguments", [])
	var default_arguments: Dictionary = effect.get("default_arguments", {})
	var target_arguments: Array = get_target_arguments(singleton, method)
	var final_arguments: Array = []
	
	for arg in target_arguments:
		var arg_name = arg.get("name")
		
		if arg_name == target_arg:
			final_arguments.append(target_ID)
		
		if arg_name == value_arg:
			final_arguments.append(input.get("value", 0))
		
		if(arguments.has(arg_name)):
			if(input.has(arg_name)):
				final_arguments.append(input.get(arg_name))
			elif(default_arguments.has(arg_name)):
				final_arguments.append(default_arguments.get(arg_name))
	
	if(final_arguments.size() != singleton.get_method_argument_count(method)):
		return false
	
	singleton.callv(method, final_arguments)
	return true

func get_target_arguments(singleton, method) -> Array:
	var method_list: Array[Dictionary] = singleton.get_method_list()
	var method_index = method_list.find_custom(is_method_data.bind(method))
	var method_data = method_list.get(method_index)
	return method_data.get("args")

func is_method_data(data: Dictionary, method: String) -> bool:
	return data.get("name") == method

func process_effect_descriptions(input: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	
	for effect in input:
		var effect_data = input.get(effect)
		
		if(typeof(effect_data) != TYPE_DICTIONARY):
			effect_data = { "value": effect_data }
		
		var line = process_effect_desc(effect, effect_data)
		if(line != "" && not effect_data.get("hide_from_tooltip")):
			lines.append(line)
	
	return lines

func process_effect_desc(header: String, input: Dictionary) -> String:
	var effect_ID = header.get_slice(".", 0)
	var target_ID = header.get_slice(".", 1)
	
	if header.get_slice(".", 2) == "HIDDEN":
		return ""
	
	# VALIDATE AND GET EFFECT
	if(not is_valid(effect_ID)):
		return ""
	var effect = EffectData.get(effect_ID)
	
	var desc: String = effect.get("LOC_desc", "")
	var final_arguments: Dictionary = {}
	
	var target_arg = effect.get("target_arg", "")
	match(target_arg):
		"activity":
			final_arguments.set("activity", Activities.get_loc(target_ID, "title"))
		"resource":
			final_arguments.set("resource", Resources.get_loc(target_ID, "title", input.get("value") > 1))
		"quality":
			final_arguments.set("quality", Qualities.get_loc(target_ID, "title"))
		"storylet":
			final_arguments.set("storylet", Storylets.get_loc(target_ID, "title"))
		_:
			final_arguments.set(target_arg, target_ID)
	
	var value_arg = effect.get("value_arg", "value")
	final_arguments.set(value_arg, input.get("value", 0))
	
	var arguments: Array = effect.get("arguments", [])
	var default_arguments: Dictionary = effect.get("default_arguments", {})
	for arg in arguments:
		if(input.has(arg)):
			final_arguments.set(arg, input.get(arg))
		elif(default_arguments.has(arg)):
			final_arguments.set(arg, default_arguments.get(arg))
		else:
			final_arguments.set(arg, null)
	
	return desc.format(final_arguments)
