extends Node

var EffectData: Dictionary = {
	"add_resource": {
		"context": "Resources",
		"method": "change_resource",
		"arguments": [ "resource", "amount" ],
		"LOC_desc": "Gain {amount} x {resource}",
		"LOC_alt_descriptions": {
			"negative": "Lose {amount} x {resource}"
		}
	},
	"subtract_resource": {
		"context": "Resources",
		"method": "reduce_resource",
		"arguments": [ "resource", "amount" ],
		"LOC_desc": "Lose {amount} x {resource}",
	},
	"set_quality": {
		"context": "Qualities",
		"method": "override_quality",
		"arguments": [ "quality", "value" ],
		"LOC_desc": "Set '{quality}' to {value}"
	},
	"remove_quality": {
		"context": "Qualities",
		"method": "override_quality",
		"arguments": [ "quality", "value" ],
		"LOC_desc": "Remove '{quality}'",
		"default_arguments": {
			"value": 0
		}
	},
	"unlock_activity": {
		"context": "Activities",
		"method": "unlock_activity",
		"arguments": [ "activity" ],
		"LOC_desc": "Unlock '{activity}'"
	},
	"lock_activity": {
		"context": "Activities",
		"method": "lock_activity",
		"arguments": [ "activity" ],
		"LOC_desc": "Lock '{activity}'"
	},
	"start_storylet": {
		"context": "Storylets",
		"method": "start_storylet",
		"arguments": [ "storylet" ],
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
		var valid = process_effect(effect_data)
		if(not valid):
			all_clear = false
		
	return all_clear

func process_effect(input: Dictionary) -> bool:
	# GET AND VALIDATE EFFECT
	if(input.has("effect") == false):
		return false
	if(not is_valid(input.get("effect"))):
		return false
	var effect = EffectData.get(input.get("effect"))
	
	# GET AND VALIDATE CONTEXT
	if(not effect.has("context")): 
		return false
	var singleton: Object = get_context(effect.get("context"))
	if(singleton == null):
		return false
	
	# GET AND VALIDATE METHOD
	if(not effect.has("method")): 
		return false
	var method = effect.get("method")
	if(not singleton.has_method(method)):
		return false
	
	var arguments = []
	var default_arguments = []
	if(effect.has("arguments")):
		arguments = effect.get("arguments")
	if(effect.has("default_arguments")):
		default_arguments = effect.get("default_arguments")
	var target_arguments = get_target_arguments(singleton, method)
	var final_arguments = []
	
	for arg in target_arguments:
		var arg_name = arg.get("name")
		
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
		var line = process_effect_desc(effect_data)
		if(line != "" && not effect_data.get("hide_from_tooltip")):
			lines.append(line)
	
	return lines

func process_effect_desc(input: Dictionary) -> String:
	# GET AND VALIDATE EFFECT
	if(input.has("effect") == false):
		return ""
	if(not is_valid(input.get("effect"))):
		return ""
	var effect = EffectData.get(input.get("effect"))
	
	var arguments: Array = []
	if(effect.has("arguments")):
		arguments = effect.get("arguments")
	var final_arguments: Dictionary = {}
	for arg in arguments:
		var data = input.get(arg)
		
		if(data):
			match(arg):
				"activity":
					data = Activities.get_loc(data, "title")
				"resource":
					data = Resources.get_loc(data, "title", input.get("amount") > 1)
				"quality":
					data = Qualities.get_loc(data, "title")
				"storylet":
					data = Storylets.get_loc(data, "title")
		
		final_arguments.set(arg, data)
	
	if(not effect.has("LOC_desc")):
		return ""
	var desc: String = effect.get("LOC_desc")
	
	return desc.format(final_arguments)
