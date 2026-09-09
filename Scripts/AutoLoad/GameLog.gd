extends Node
## Autoload/Singleton

var Display: Node = null

var Messages = []

var MessageRepeats = 0

signal log_updated(new_message: Dictionary)

func _ready() -> void:
	for i in 100:
		add_message("TEST")
	pass

func add_message(text: String):
	var new_message = { "text": text, "time": Time.get_time_string_from_system() }
	
	Messages.append(new_message)
	if(Display != null):
		Display.add_message(new_message)
	
	log_updated.emit(new_message)
	pass

func log_resource_gain(resource_name: String, amount: int, old_amount: int):
	var text = "You gain %s x '%s' (new total %s)" % [
		amount, resource_name, old_amount
	]
	
	add_message(text)
	pass
	
func log_resource_gain_new(resource_name: String, amount: int):
	var text = "You now have %s x '%s'" % [
		amount, resource_name
	]
	
	add_message(text)
	pass

func log_resource_lose(resource_name: String, amount: int, old_amount: int):
	var text = "You lose %s x '%s' (new total %s)" % [
		amount, resource_name, old_amount
	]
	
	add_message(text)
	pass

func log_resource_remove(resource_name: String):
	var text = "You no longer have any '%s'" % [
		resource_name
	]
	
	add_message(text)
	pass

func log_resource_too_low(resource_name: String, amount: int = 0, goal: int = 0):
	var text = "You need more '%s'" % [resource_name]
	if(amount > 0 && goal > 0):
		text += " (%s/%s)" % [amount, goal]
	
	add_message(text)
	pass

func log_resource_too_high(resource_name: String, amount: int = 0, goal: int = 0):
	var text = "You need less '%s'" % [resource_name]
	if(amount > 0 && goal < Resources.MAX):
		text += " (current: %s, maximum: %s)" % [amount, goal]
	
	add_message(text)
	pass

func log_resource_missing(resource_name: String, goal: int = 0):
	var text = "You need %s x '%s'" % [goal, resource_name]
	
	add_message(text)
	pass

func log_quality_create(quality_name: String):
	var text = "You now have '%s'" % [quality_name]
	
	add_message(text)
	pass

func log_quality_override(quality_name: String, amount: int):
	var text = "Your '%s' quality is now %s" % [
		quality_name, amount
	]
	
	add_message(text)
	pass

func log_quality_remove(quality_name: String):
	var text = "You no longer have '%s'" % [
		quality_name
	]
	
	add_message(text)
	pass

func log_quality_missing(resource_or_quality_name: String):
	var text = "You need '%s'" % [resource_or_quality_name]
	
	add_message(text)
	pass

func log_quality_specific_missing(quality_name: String, value: int):
	var text = "You need the quality '%s - %s'" % [quality_name, value]
	
	add_message(text)
	pass
	
func log_quality_range_missing(quality_name: String, value: int, value_max: int):
	var text = "You need the quality '%s' with a value between %s & %s" % [
		quality_name, value, value_max
	]
	
	add_message(text)
	pass
