extends Node
## Autoload/Singleton

## Implementation of activity system
## Activities are the main action in the game and progress on game tick
## They are tied to a Activity_UI scene for button & progress bar
## Starting one puts it on the stack, stopping the oldest if necessary

## The signals below are for future game logic or minor UI features
## We do not use them to update the main activity UI
## in order to avoid costly if checks with 100+ activities later on

signal activity_started(activity: String)
signal activity_progressed(activity: String, progress: float)
signal activity_stopped(activity: String)
signal activity_completed(activity: String, last_completion: bool)
signal activity_restarted(activity: String)
signal activity_locked(activity: String)
signal activity_unlocked(activity: String)

signal activity_paused(activity: String)
signal activity_unpaused(activity: String)

const MAX = float(1e10)

var ActivityData = {
	"debug_1": {
		"category": "debug",
		"locked": false,
		"LOC_title": "Do Something",
		"LOC_tooltip": "Doing something does typically result in results.",
		"LOC_start_message": "You start to do something...",
		"LOC_stop_message": "You stop doing something.",
		"LOC_complete_message": "You finish doing something!",
		"goal": 100,
		"speed": 50,
		"completions": 0,
		"effects": {
			"add_results": {
				"effect": "add_resource",
				"resource": "debug_resource",
				"amount": 5
			},
			"set_persistence": {
				"effect": "set_quality",
				"quality": "debug_quality_2",
				"value": 1,
				"hide_from_tooltip": true
			}
		}
	},
	"debug_2": {
		"category": "debug",
		"locked": false,
		"LOC_title": "Do Something Else",
		"LOC_tooltip": "Are you sure you want to do this?",
		"LOC_start_message": "You start to do something else...",
		"LOC_stop_message": "You stop doing something else.",
		"LOC_complete_message": "You finish doing something else!",
		"LOC_lock_message": "You no longer feel like doing something else.",
		"goal": 300,
		"speed": 60,
		"completions": 0,
		"effects": {
			"subtract_results": {
				"effect": "subtract_resource",
				"resource": "debug_resource",
				"amount": 2
			},
			"remove_persistence": {
				"effect": "remove_quality",
				"quality": "debug_quality_2",
				"hide_from_tooltip": true
			}
		}
	},
	"debug_3": {
		"category": "debug",
		"locked": false,
		"LOC_title": "Do Everything",
		"LOC_tooltip": "Its slow, but its something. Lots of somethings, in fact.",
		"LOC_start_message": "You try to do everything at once...",
		"LOC_stop_message": "You stop doing everything.",
		"LOC_complete_message": "You get something done, but not everything.",
		"LOC_complete_last_message": "You've done everything you can for now.",
		"goal": 100,
		"speed": 50,
		"completions": 0,
		"max_completions": 5,
		"effects": {
			"add_results": {
				"effect": "add_resource",
				"resource": "debug_resource",
				"amount": 12
			},
			"set_persistence": {
				"effect": "set_quality",
				"quality": "debug_quality_2",
				"value": 2,
				"hide_from_tooltip": true
			}
		}
	},
	"debug_4": {
		"category": "debug",
		"locked": false,
		"LOC_title": "Prove Something",
		"LOC_tooltip": "What do you have to prove? What did you accomplish?",
		"LOC_start_message": "You try to prove that you did something...",
		"LOC_stop_message": "You are no longer trying to prove something.",
		"LOC_complete_message": "Your results are invalid now, but they result in something else.",
		"goal": 100,
		"speed": 50,
		"completions": 0,
		"costs": {
			"resources": {
				"debug_resource": 20
			}
		},
		"effects": {
			"add_favours": {
				"effect": "add_resource",
				"resource": "debug_resource_2",
				"amount": 5
			}
		}
	},
	"debug_5": {
		"category": "debug",
		"locked": false,
		"LOC_title": "Unlock Something",
		"LOC_tooltip": "Not everything is obvious at first.",
		"LOC_start_message": "You try to unlock something...",
		"LOC_stop_message": "You stop trying to unlock something.",
		"LOC_restart_message": "You keep trying to unlock something...",
		"LOC_complete_message": "Whatever it is, you haven't unlocked it yet.",
		"LOC_complete_last_message": "You have unlocked something new!",
		"goal": 100,
		"speed": 50,
		"max_completions": 1,
		"effects": {
			"unlock_something_better": {
				"effect": "unlock_activity",
				"activity": "debug_6"
			}
		}
	},
	"debug_6": {
		"category": "debug",
		"locked": true,
		"LOC_title": "Do Something Better",
		"LOC_tooltip": "What is better, really? I daresay it's mostly vibes.",
		"LOC_unlock_message": "You feel like you can do something better.",
		"LOC_start_message": "You start to do something better...",
		"LOC_stop_message": "Against your best intentions, you stop doing something better.",
		"LOC_complete_message": "You finish doing something better, and feel a bit better too.",
		"goal": 100,
		"speed": 41.35,
		"completions": 0,
		"effects": {
			"add_results": {
				"effect": "add_resource",
				"resource": "debug_resource",
				"amount": 99
			},
			"set_persistence": {
				"effect": "set_quality",
				"quality": "debug_quality_2",
				"value": 4,
				"hide_from_tooltip": true
			},
			"lock_something_else": {
				"effect": "lock_activity",
				"activity": "debug_2"
			}
		}
	},
	"debug_7": {
		"category": "debug",
		"locked": true,
		"LOC_title": "Be Proud Of Something",
		"LOC_tooltip": "Yes, yes, you did it.",
		"LOC_start_message": "You start being proud of something...",
		"LOC_stop_message": "You stop being proud of something.",
		"LOC_complete_message": "You are done with being proud of something.",
		"goal": 750,
		"speed": 1,
		"completions": 0,
		"effects": {
			"add_lots_of_results": {
				"effect": "add_resource",
				"resource": "debug_resource",
				"amount": 250
			}
		},
		"DISPLAY_requirements": {
			"qualities": {
				"debug_quality": {
					"min": 4,
					"max": 5,
					"permanent": false
				}
			}
		}
	},
	"debug_8": {
		"category": "debug",
		"locked": true,
		"LOC_title": "Enjoy Something",
		"LOC_tooltip": "Atleast for a little bit.",
		"LOC_start_message": "You start enjoying something...",
		"LOC_stop_message": "You stop enjoying something.",
		"LOC_complete_message": "You are done with enjoying something.",
		"goal": 4000,
		"speed": 1,
		"completions": 0,
		"effects": {
			"remove_results": {
				"effect": "subtract_resource",
				"resource": "debug_resource",
				"amount": 25
			},
			"remove_favour": {
				"effect": "subtract_resource",
				"resource": "debug_resource_2",
				"amount": 1
			}
		},
		"DISPLAY_requirements": {
			"resources": {
				"debug_resource_2": {
					"min": 10,
					"permanent": false
				}
			}
		}
	}
}

var ActivityUINodes = {}

var CurrentActivities = []

var MaximumActivities = 1

var ShowProgressAsPercentage = true
var ShowTimeDetails = false
var TooltipUpdateDelay = 4
var GlobalPause = false
var GlobalPauseReason = ""

func _ready() -> void:
	pass

func get_loc(activity: String, key: String) -> String:
	if(ActivityData.get(activity).has("LOC_" + key)):
		return ActivityData.get(activity).get("LOC_" + key)
	else:
		return ""

func get_progress(activity: String) -> float:
	if(ActivityData.get(activity).has("progress")):
		return ActivityData.get(activity).get("progress")
	else:
		return 0

func set_progress(activity: String, progress: float):
	ActivityData.get(activity).set("progress", progress)
	
	var activity_UI: Activity_UI = get_activity_ui(activity)
	if activity_UI:
		activity_UI.set_progress(progress)
	pass

func get_goal(activity: String) -> float:
	if(ActivityData.get(activity).has("goal")):
		return ActivityData.get(activity).get("goal")
	else:
		printerr("Could not get goal for activity '%s'" % activity)
		return 100

func set_goal(activity: String, goal: float):
	ActivityData.get(activity).set("goal", goal)
	
	var activity_UI: Activity_UI = get_activity_ui(activity)
	if activity_UI:
		activity_UI.set_goal(goal)
	pass

func get_speed(activity: String) -> float:
	if(ActivityData.get(activity).has("speed")):
		return ActivityData.get(activity).get("speed")
	else:
		printerr("Could not get speed for activity '%s'" % activity)
		return 1

func set_speed(activity: String, speed: float):
	ActivityData.get(activity).set("speed", speed)
	pass

func get_completions(activity: String) -> int:
	if(ActivityData.get(activity).has("completions")):
		return ActivityData.get(activity).get("completions")
	else:
		return 0

func set_completions(activity: String, completions: int):
	ActivityData.get(activity).set("completions", completions)
	pass

func get_max_completions(activity: String) -> int:
	if(ActivityData.get(activity).has("max_completions")):
		return ActivityData.get(activity).get("max_completions")
	else:
		return int(MAX)

func set_max_completions(activity: String, max_completions: int):
	ActivityData.get(activity).set("max_completions", max_completions)
	pass

func is_valid(activity: String) -> bool:
	return ActivityData.has(activity)

func is_locked(activity: String) -> bool:
	if(ActivityData.get(activity).has("locked")):
		return ActivityData.get(activity).get("locked")
	else:
		return false

func set_locked(activity: String, locked: bool = true):
	ActivityData.get(activity).set("locked", locked)
	pass

func is_paid(activity: String) -> bool:
	if(ActivityData.get(activity).has("costs_paid")):
		return ActivityData.get(activity).get("costs_paid")
	else:
		return false

func set_paid(activity: String, paid: bool = true):
	ActivityData.get(activity).set("costs_paid", paid)
	pass

func is_active(activity: String) -> bool:
	return CurrentActivities.has(activity)

func ui_get_activities_for_category(category: String) -> Array[String]:
	var activity_list: Array
	for activity in ActivityData:
		if ActivityData[activity].category == category:
			activity_list.append(activity)
	return activity_list

func ui_register_activity(activity: String, UI: Node):
	ActivityUINodes.set(activity, UI)
	pass

func get_activity_ui(activity: String) -> Node:
	if(ActivityUINodes.has(activity)):
		return ActivityUINodes.get(activity)
	else:
		return null

# UI Signal
func _on_activity_toggled(activity: String):
	if(not is_active(activity)):
		start_activity(activity)
	else:
		stop_activity(activity)
	pass

func _process(delta: float) -> void:
	for activity in CurrentActivities:
		if(not is_paused(activity)):
			process_activity(activity, delta)
	pass

func process_activity(activity: String, delta: float):
	var speed = get_speed(activity)
	var progress = get_progress(activity) + (speed * delta)
	var goal = get_goal(activity)
	
	if(progress >= goal):
		var lock = complete_activity(activity)
		
		if(lock):
			progress = 0
			set_progress(activity, 0)
			stop_activity(activity)
			lock_activity(activity)
		else:
			progress -= goal
			restart_activity(activity, progress)
	else:
		set_progress(activity, progress)
		activity_progressed.emit(activity, progress)
	pass

func check_costs(activity: String) -> bool:
	var can_pay = true
	
	if(ActivityData.get(activity).has("costs")):
		var costs = ActivityData.get(activity).get("costs")
		
		if(costs.has("resources")):
			var resources = costs.get("resources")
			
			for resource in resources:
				var cost = resources.get(resource)
				
				if(Resources.is_active(resource)):
					var amount = Resources.get_amount(resource)
					
					if(amount < cost):
						can_pay = false
				else:
					can_pay = false
		
		if(costs.has("qualities")):
			var qualities = costs.get("qualities")
			
			for quality in qualities:
				if(not Qualities.is_active(quality)):
					can_pay = false
	return can_pay

func report_missing_costs(activity: String):
	if(ActivityData.get(activity).has("costs")):
		var costs = ActivityData.get(activity).get("costs")
		
		if(costs.has("resources")):
			var resources = costs.get("resources")
			
			for resource in resources:
				var cost = resources.get(resource)
				var title = Resources.get_loc(resource, "title")
				if(abs(cost) > 1):
					title = Resources.get_loc(resource, "title", true)
				
				if(Resources.is_active(resource)):
					var amount = Resources.get_amount(resource)
					
					if(amount < cost):
						GameLog.log_resource_too_low(title, amount, cost)
				else:
					GameLog.log_resource_missing(title, cost)
		
		if(costs.has("qualities")):
			var qualities = costs.get("qualities")
			
			for quality in qualities:
				var title = Qualities.get_loc(quality, "title")
				
				if(not Qualities.is_active(quality)):
					GameLog.log_quality_missing(title)
	pass

func start_activity(activity: String):
	var paid = is_paid(activity)
	
	if(not paid):
		if(check_costs(activity)):
			process_costs(activity)
			set_paid(activity)
			paid = true
		else:
			if(ActivityData.get(activity).has("LOC_missing_costs_message")):
				var text = ActivityData.get(activity).get("LOC_missing_costs_message")
				GameLog.add_message(text)
			else:
				GameLog.add_message("You can't do this yet!")
			report_missing_costs(activity)
	
	if(paid):
		CurrentActivities.append(activity)
		if(CurrentActivities.size() > MaximumActivities):
			stop_activity(CurrentActivities.front())
		
		var activity_UI: Activity_UI = get_activity_ui(activity)
		if activity_UI:
			activity_UI.activate()
		
		activity_started.emit(activity)
		
		if(ActivityData.get(activity).has("LOC_start_message")):
			var text = ActivityData.get(activity).get("LOC_start_message")
			GameLog.add_message(text)
	else:
		var activity_UI: Activity_UI = get_activity_ui(activity)
		if activity_UI:
			activity_UI.deactivate()
	pass

func restart_activity(activity: String, progress: float):
	set_progress(activity, progress)
	
	if(check_costs(activity)):
		process_costs(activity)
		#Set it back to true since complete_activity has reset it
		set_paid(activity)
		
		activity_restarted.emit(activity, progress)
		if(ActivityData.get(activity).has("LOC_restart_message")):
			var text = ActivityData.get(activity).get("LOC_restart_message")
			GameLog.add_message(text)
	else:
		CurrentActivities.erase(activity)
		
		var activity_UI: Activity_UI = get_activity_ui(activity)
		if activity_UI:
			activity_UI.deactivate()
		
		activity_stopped.emit(activity, progress)
		## Use separate log statement to avoid weird grammar
		if(ActivityData.get(activity).has("LOC_missing_costs_restart_message")):
			var text = ActivityData.get(activity).get("LOC_missing_costs_restart_message")
			GameLog.add_message(text)
		else:
			GameLog.add_message("You can't do this anymore!")
		report_missing_costs(activity)
	pass

func stop_activity(activity: String):
	CurrentActivities.erase(activity)
	
	var activity_UI: Activity_UI = get_activity_ui(activity)
	if activity_UI:
		activity_UI.deactivate()
	
	activity_stopped.emit(activity)
	
	if(ActivityData.get(activity).has("LOC_stop_message")):
		var text = ActivityData.get(activity).get("LOC_stop_message")
		GameLog.add_message(text)
	pass

func lock_activity(activity: String):
	set_locked(activity, true)
	if(CurrentActivities.has(activity)):
		CurrentActivities.erase(activity)
	
	var activity_UI: Activity_UI = get_activity_ui(activity)
	if activity_UI:
		activity_UI.lock()
	
	activity_locked.emit(activity)
	
	if(ActivityData.get(activity).has("LOC_lock_message")):
		var text = ActivityData.get(activity).get("LOC_lock_message")
		GameLog.add_message(text)
	pass

func unlock_activity(activity: String):
	set_locked(activity, false)
	
	var activity_UI: Activity_UI = get_activity_ui(activity)
	if activity_UI:
		activity_UI.unlock()
	
	activity_unlocked.emit(activity)
	
	if(ActivityData.get(activity).has("LOC_unlock_message")):
		var text = ActivityData.get(activity).get("LOC_unlock_message")
		GameLog.add_message(text)
	pass

func complete_activity(activity: String) -> bool:
	var completions = get_completions(activity) + 1
	var max_completions = get_max_completions(activity)
	
	Activities.set_completions(activity, completions)
	
	var last_completion = false if completions < max_completions else true
	if(last_completion && ActivityData.get(activity).has("LOC_complete_last_message")):
		var text = ActivityData.get(activity).get("LOC_complete_last_message")
		GameLog.add_message(text)
	elif(ActivityData.get(activity).has("LOC_complete_message")):
		var text = ActivityData.get(activity).get("LOC_complete_message")
		GameLog.add_message(text)
	
	activity_completed.emit(activity, last_completion)
	
	process_effects(activity)
	set_paid(activity, false)
	
	return last_completion

func process_costs(activity: String):
	if(ActivityData.get(activity).has("costs")):
		var costs = ActivityData.get(activity).get("costs")
		
		if(costs.has("resources")):
			var resources = costs.get("resources")
			
			for resource in resources:
				var amount = resources.get(resource)
				# Since costs are entered as positive values, invert them here
				# At this point, we dont care if the change is valid anymore
				Resources.change_resource(resource, -amount)
		
		if(costs.has("qualities")):
			var qualities = costs.get("qualities")
			
			for quality in qualities:
				# A quality as "cost" means we remove it fully
				# This is not how qualities are intended to be used
				# But we support it for future experiments or mods
				Qualities.remove_quality(quality)
	pass

func process_effects(activity: String):
	if(ActivityData.get(activity).has("effects")):
		var effect_data = ActivityData.get(activity).get("effects")
		
		Effects.process_effect_list(effect_data)
	pass

####################
#region PAUSE SYSTEM
func is_paused(activity: String, ignore_global_pause: bool = false) -> bool:
	if(GlobalPause && not ignore_global_pause):
		return true
	if(ActivityData.get(activity).has("paused")):
		return ActivityData.get(activity).get("paused")
	else:
		return false

func set_paused(activity: String, paused: bool):
	ActivityData.get(activity).set("paused", paused)
	pass

func get_pause_reason(activity: String) -> String:
	if(ActivityData.get(activity).has("LOC_pause_reasons")):
		var reasons: Array = ActivityData.get(activity).get("LOC_pause_reasons")
		if(reasons.size()):
			return reasons.get(0)
		else:
			return ""
	else:
		return ""

func add_pause_reason(activity: String, reason: String):
	if(ActivityData.get(activity).has("LOC_pause_reasons")):
		var reasons = ActivityData.get(activity).get("LOC_pause_reasons")
		reasons.append(reason)
		ActivityData.get(activity).set("LOC_pause_reasons", reasons)
	else:
		ActivityData.get(activity).set("LOC_pause_reasons", [reason])

func remove_pause_reason(activity: String, reason: String):
	if(ActivityData.get(activity).has("LOC_pause_reasons")):
		var reasons: Array = ActivityData.get(activity).get("LOC_pause_reasons")
		reasons.erase(reason)
		ActivityData.get(activity).set("LOC_pause_reasons", reasons)
	pass

func pause_activity(activity: String, reason: String = "This activity is currently unavailable!"):
	if(not is_valid(activity)):
		pass
	
	if(not is_paused(activity, true)):
		var activity_UI: Activity_UI = get_activity_ui(activity)
		if activity_UI:
			activity_UI.pause()
		
		set_paused(activity, true)
		activity_paused.emit(activity)
	
	## Add the pause reason even if the activity is already paused
	add_pause_reason(activity, reason)
	pass

func unpause_activity(activity: String, reason: String = "This activity is currently unavailable!"):
	if(not is_valid(activity)):
		pass
	
	if(is_paused(activity, true)):
		var activity_UI: Activity_UI = get_activity_ui(activity)
		if activity_UI:
			activity_UI.unpause()
		
		set_paused(activity, false)
		activity_unpaused.emit(activity)
	
	## Remove the pause reason even if the activity is already unpaused
	remove_pause_reason(activity, reason)
	pass

func global_pause(reason: String = "This activity is currently unavailable!"):
	GlobalPause = true
	GlobalPauseReason = reason
	
	for activity in ActivityData:
		## Only continue if the activity wasnt already paused
		## Ignoring global pause because we just reset it
		if(not is_paused(activity, true)):
			var activity_UI: Activity_UI = get_activity_ui(activity)
			if activity_UI:
				activity_UI.pause()
			
			## So we dont emit inaccurate signals
			activity_paused.emit(activity)
	pass

func global_unpause(reason: String = ""):
	GlobalPause = false
	GlobalPauseReason = reason
	
	for activity in ActivityData:
		## Only continue for activities that were only paused by the global pause
		if(not is_paused(activity, true)):
			var activity_UI: Activity_UI = get_activity_ui(activity)
			if activity_UI:
				activity_UI.unpause()
			
			activity_unpaused.emit(activity)
	pass
#endregion
####################
