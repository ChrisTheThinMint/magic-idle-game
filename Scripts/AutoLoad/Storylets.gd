extends Node
## Autoload/Singleton

var StoryletData = {
	"debug_storylet_1": {
		"LOC_title": "The Illusion Of Choice",
		"LOC_desc": "Hey, buddy, im a storylet. That means I offer choices. Now, choose one of these three things or go away.",
		"choices": {
			"debug_choice_1": {
				"LOC_title": "A Simple Choice",
				"LOC_initial_text": "You want some results? I've got them on the down-low.",
				"LOC_result_text": "Here you go, buddy. Don't spend them all in one place!",
				"effects": {
					"add_resource.debug_resource": 5
				}
			},
			"debug_choice_2": {
				"LOC_title": "A Harder Choice",
				"LOC_initial_text": "Choicelet has results if you have favours.",
				"LOC_result_text": "Player satisfied, yes-yes? Return again!",
				"requirements": {
					"resource_check.debug_resource_2": 10
				},
				"effects": {
					"add_resource.debug_resource": 25
				}
			},
			"debug_choice_3": {
				"LOC_title": "A Complex Choice",
				"LOC_initial_text": "I'm not as straightforward as the other choices. If you choose me, I'll introduce you to other choices.",
				"LOC_result_text": "You shouldn't be able to see this text!",
				"effects": {
					"start_storylet.debug_storylet_1": true
				}
			}
		}
	},
	"debug_storylet_2": {
		"parent": "debug_storylet_1",
		"LOC_title": "The Delusion Of Choice",
		"LOC_desc": "So, you've come to make another choice. Go ahead, here are four options. There is no wrong answer... but if you're scared, you can always go back.",
		"choices": {
			"debug_choice_1": {
				"LOC_title": "Option A",
				"LOC_initial_text": "Choose me!",
				"LOC_result_text": "Thank you for choosing me. Here, have an apple.",
				"requirements": {
					"quality_check.debug_quality_2": 0
				}
			},
			"debug_choice_2": {
				"LOC_title": "Option B",
				"LOC_initial_text": "No, choose me!",
				"LOC_result_text": "Thank you for choosing me. Here, have some bread.",
				"requirements": {
					"quality_check.debug_quality_2": 1
				}
			},
			"debug_choice_3": {
				"LOC_title": "Option C",
				"LOC_initial_text": "Choose me! Please!",
				"LOC_result_text": "Thank you for choosing me. Here, have a cookie.",
				"requirements": {
					"quality_check.debug_quality_2": 2
				}
			},
			"debug_choice_4": {
				"LOC_title": "Option D",
				"LOC_initial_text": "Don't choose me!",
				"LOC_result_text": "Why did you choose me? I don't have anything to give you...",
				"requirements": {
					"quality_check.debug_quality_2": 3
				}
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
	var requirement_text = construct_choice_requirements(storylet, choice)
	var result_text = get_loc_for_choice(storylet, choice, "result_text")
	
	var choice_UI = StoryletView.create_choice()
	choice_UI.update_body(title, initial_text, requirement_text, result_text)
	pass

func construct_choice_requirements(storylet: String, choice: String) -> String:
	var lines: PackedStringArray = []
	var line: String = ""
	var choice_data = get_choice(storylet, choice)
	
	if(choice_data.has("requirements")):
		var requirements = choice_data.get("requirements")
		var new_lines: Array[String] = Requirements.process_requirement_descriptions(requirements)
		
		if(new_lines.size()):
			line = "[u]Requirements[/u]"
			lines.append(line)
			
			lines.append_array(new_lines)
	
	return "\n".join(lines)
