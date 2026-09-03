extends Node

var StoryletData = {
  "debug_storylet": {
	"LOC_title": "The Illusion Of Choice",
	"LOC_desc": "Hey, buddy, im a storylet. That means I offer choices. Not choices like \"end the game\", because that would fall within the purview of your limited idea of fun. I offer practical choices, for instance: how are you going to stop some mean mother Hubbard from tearing you a structurally superfluous be-hind? The choices, use a gun, and if that ain't enough... Use more gun. Take for instance this heavy caliber tripod mounted lil' old number designed by me, built by me, and you best hope... That it's a choice. Because it might not be.",
	"choices": {
	  "debug_choice_1": {
		"LOC_title": "Use A Gun",
		"LOC_initial_text": "I've yet to meet one that can outsmart bullet.",
		"LOC_result_text": "You shoot once, and you miss. You shoot again, and you miss again. Shucks.",
		"effects": {}
	  },
	  "debug_choice_2": {
		"LOC_title": "Use More Gun",
		"LOC_initial_text": "I've yet to meet one that can outsmart... bullets? Eh, close enough.",
		"LOC_result_text": "Where did you get all these guns?",
		"effects": {}
	  },
	  "debug_choice_3": {
		"LOC_title": "Use the heavy caliber tripod designed by me",
		"LOC_initial_text": "Turns out it is a choice. Lucky you.",
		"LOC_result_text": "Who touched my gun!? I didn't say that you [i]could[/i] use it!",
		"effects": {}
	  }
	}
  }
}

var StoryletView: Storylet_View = null

signal request_open_storylet_view()
signal request_close_storylet_view()

signal storylet_view_opened()
signal storylet_view_closed()

var CurrentStorylet: String = ""

func _ready() -> void:
	pass

func is_valid(storylet: String) -> bool:
	return StoryletData.has(storylet)

func get_loc(storylet: String, key: String) -> String:
	if(not is_valid(storylet)): return ""
	return StoryletData.get(storylet).get("LOC_" + key, "")

func get_choices(storylet: String) -> Dictionary:
	if(not is_valid(storylet)): return {}
	return StoryletData.get(storylet).get("choices")

func get_choice(storylet: String, choice: String):
	return get_choices(storylet).get(choice, null)

func get_loc_for_choice(storylet: String, choice: String, key: String) -> String:
	var choice_data = get_choice(storylet, choice)
	if(choice_data == null): return ""
	return choice_data.get("LOC_" + key, "")

func start_storylet(storylet):
	if(not is_valid(storylet)): pass
	
	var title = "[u]" + get_loc(storylet, "title") + "[/u]"
	var desc = get_loc(storylet, "desc")
	StoryletView.update_body(title, desc)
	
	var choices = get_choices(storylet)
	StoryletView.clear_choices()
	for choice in choices:
		add_choice(storylet, choice)
	
	request_open_storylet_view.emit()
	pass

func add_choice(storylet: String, choice: String):
	var choice_data = get_choice(storylet, choice)
	
	var title = get_loc_for_choice(storylet, choice, "title")
	var initial_text = get_loc_for_choice(storylet, choice, "initial_text")
	var result_text = get_loc_for_choice(storylet, choice, "result_text")
	
	var choice_UI = StoryletView.create_choice()
	choice_UI.update_body(title, initial_text, result_text)
	pass
