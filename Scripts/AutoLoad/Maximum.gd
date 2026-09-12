extends Node
## Autoload/Singleton

## Implements MAX constant as a single source of truth
## As well as the support system used for maximum increases
## Activities, resources and qualities can "support":
## a resource, increasing its max amount
## or an activity, increasing its max completions

## These types receive this support via modifier list, preserving base maximums
## This system is source -> target so that tooltips can be updated immediately
## As opposed to a future modifier system which would be target -> source

const MAX: int = 1e10

func calculate_maximum(base: int, modifiers: Dictionary) -> int:
	var new_max: int = clamp(base, 0, MAX)
	
	for modifier in modifiers:
		var value: int = modifiers.get(modifier)
		new_max += value
	
	return clampi(new_max, 0, MAX)

func process_supports(input: Dictionary, value: int, source: String):
	for header in input:
		var data = input.get(header)
		
		process_support(header, data, value, source)
	pass

func process_support(header: String, input: Variant, value: int, source: String):
	var context: String = header.get_slice(".", 0)
	var target: String = header.get_slice(".", 1)
	var hidden: String = header.get_slice(".", 2)
	
	var required = 1
	var increase = 1
	
	match(typeof(input)):
		TYPE_DICTIONARY:
			required = input.get("required", 1)
			increase = input.get("increase", 1)
		TYPE_ARRAY:
			required = 1 if input.get(0) == null else input.get(0)
			increase = 1 if input.get(1) == null else input.get(1)
		_:
			required = input
	
	var modifier = floor(increase * value / required)
	var key = target + "." + hidden if hidden else target
	
	match(context):
		"activity":
			Activities.set_max_completions_modifier(target, key, modifier)
			pass
		"resource":
			Resources.set_max_amount_modifier(target, key, modifier)
			pass
	pass

func process_support_descriptions(input: Dictionary) -> Array[String]:
	return []

func process_support_desc(header: String, input: Dictionary) -> String:
	return ""
