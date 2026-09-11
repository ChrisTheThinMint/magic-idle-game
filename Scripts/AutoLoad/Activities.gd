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
signal activity_ended(activity: String) # Used only for activities with "does_not_restart"
signal activity_stopped(activity: String)
signal activity_completed(activity: String, last_completion: bool)
signal activity_restarted(activity: String)
signal activity_locked(activity: String)
signal activity_unlocked(activity: String)

signal activity_paused(activity: String)
signal activity_unpaused(activity: String)

const MAX = float(1e10)

var ActivityData = {
  "debug_activity_1": {
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
	  "add_resource.debug_resource": 5,
	  "set_quality.debug_quality_2.HIDDEN": 2
	}
  },
  "debug_activity_2": {
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
	  "subtract_resource.debug_resource": 5,
	  "remove_quality.debug_quality_2.HIDDEN": 0
	}
  },
  "debug_activity_3": {
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
	  "add_resource.debug_resource": 12,
	  "set_quality.debug_quality_2.HIDDEN": 2
	}
  },
  "debug_activity_4": {
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
	"effects": {
	  "add_resource.debug_resource_2": 5
	},
	"requirements": {
	  "resource_cost.debug_resource": 20
	}
  },
  "debug_activity_5": {
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
	  "unlock_activity.debug_activity_6": true
	}
  },
  "debug_activity_6": {
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
	  "add_resource.debug_resource": 99,
	  "set_quality.debug_quality_2.HIDDEN": 4,
	  "lock_activity.debug_activity_2": true
	}
  },
  "debug_activity_7": {
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
	  "add_resource.debug_resource": 250
	},
	"requirements": {
	  "check_quality.debug_quality_1": [
		4,
		5
	  ]
	}
  },
  "debug_activity_8": {
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
	  "subtract_resource.debug_resource": 25,
	  "subtract_resource.debug_resource_2": 1
	},
	"requirements": {
	  "resource_check.debug_resource_2": 10
	}
  },
  "debug_activity_9": {
	"category": "debug",
	"LOC_tooltip": "Or, atleast, think that you are.",
	"LOC_title": "Choose Something",
	"LOC_start_message": "You prepare to make a choice...",
	"LOC_stop_message": "You stop before you have to make a choice.",
	"goal": 100,
	"speed": 50,
	"does_not_restart": true,
	"effects": {
	  "start_storylet.debug_storylet": true
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

func _process(delta: float) -> void:
	for activity in CurrentActivities:
		if(not is_paused(activity)):
			process_activity(activity, delta)
	pass

func is_valid(activity: String) -> bool:
	return ActivityData.has(activity)

#region PROGRESS GET/SET
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
#endregion

#region GOAL GET/SET
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
#endregion

#region SPEED GET/SET
func get_speed(activity: String) -> float:
	if(ActivityData.get(activity).has("speed")):
		return ActivityData.get(activity).get("speed")
	else:
		printerr("Could not get speed for activity '%s'" % activity)
		return 1

func set_speed(activity: String, speed: float):
	ActivityData.get(activity).set("speed", speed)
	pass
#endregion

#region COMPLETIONS GET/SET
func get_completions(activity: String) -> int:
	if(ActivityData.get(activity).has("completions")):
		return ActivityData.get(activity).get("completions")
	else:
		return 0

func set_completions(activity: String, completions: int):
	ActivityData.get(activity).set("completions", completions)
	pass
#endregion

#region MAX COMPLETIONS GET/SET
func get_max_completions(activity: String) -> int:
	if(ActivityData.get(activity).has("max_completions")):
		return ActivityData.get(activity).get("max_completions")
	else:
		return int(MAX)

func set_max_completions(activity: String, max_completions: int):
	ActivityData.get(activity).set("max_completions", max_completions)
	pass
#endregion

#region PAID GET/SET
func is_paid(activity: String) -> bool:
	if(ActivityData.get(activity).has("costs_paid")):
		return ActivityData.get(activity).get("costs_paid")
	else:
		return false

func set_paid(activity: String, paid: bool = true):
	ActivityData.get(activity).set("costs_paid", paid)
	pass
#endregion

#region LOCALIZATION HANDLING
func get_loc(activity: String, key: String) -> String:
	if(ActivityData.get(activity).has("LOC_" + key)):
		return ActivityData.get(activity).get("LOC_" + key)
	else:
		return ""
#endregion

#region UI HANDLING
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
#endregion

#region ACTIVITY START AND STOP
# UI Signal
func _on_activity_toggled(activity: String):
	if(not is_active(activity)):
		start_activity(activity)
	else:
		stop_activity(activity)
	pass
	
func start_activity(activity: String):
	var paid = is_paid(activity)
	
	if(not paid):
		var requirements = ActivityData.get(activity).get("requirements", {})
		if(Requirements.process_requirements(requirements)):
			Requirements.process_costs(requirements)
			set_paid(activity)
			paid = true
		else:
			if(ActivityData.get(activity).has("LOC_missing_costs_message")):
				var text = ActivityData.get(activity).get("LOC_missing_costs_message")
				GameLog.add_message(text)
			else:
				GameLog.add_message("You can't do this yet!")
			Requirements.report_missing_requirements(requirements)
	
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
#endregion

#region ACTIVITY LOOP
func is_active(activity: String) -> bool:
	return CurrentActivities.has(activity)

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
		elif(ActivityData.get(activity).get("does_not_restart", false)):
			progress = 0
			set_progress(activity, 0)
			end_activity(activity)
		else:
			progress -= goal
			restart_activity(activity, progress)
	else:
		set_progress(activity, progress)
		activity_progressed.emit(activity, progress)
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
	
	var requirements: Dictionary = ActivityData.get(activity).get("requirements", {})
	Requirements.process_catalysts(requirements)
	
	var effects: Dictionary = ActivityData.get(activity).get("effects", {})
	Effects.process_effect_list(effects)
	
	var milestones: Dictionary = ActivityData.get(activity).get("milestones", {})
	var completed_milestones: Array = ActivityData.get(activity).get("completed_milestones", [])
	completed_milestones = Effects.process_milestone_list(milestones, completed_milestones, completions)
	ActivityData.get(activity).set("completed_milestones", completed_milestones)
	
	set_paid(activity, false)
	
	activity_completed.emit(activity, last_completion)
	
	return last_completion

func end_activity(activity: String):
	CurrentActivities.erase(activity)
	
	var activity_UI: Activity_UI = get_activity_ui(activity)
	if activity_UI:
		activity_UI.deactivate()
	
	activity_ended.emit(activity)
	pass

func restart_activity(activity: String, progress: float):
	set_progress(activity, progress)
	
	var requirements = ActivityData.get(activity).get("requirements", {})
	if(Requirements.process_requirements(requirements)):
		Requirements.process_costs(requirements)
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
		
		Requirements.report_missing_requirements(requirements)
	pass
#endregion

#region LOCKING ACTIVITIES
func is_locked(activity: String) -> bool:
	if(ActivityData.get(activity).has("locked")):
		return ActivityData.get(activity).get("locked")
	else:
		return false

func set_locked(activity: String, locked: bool = true):
	ActivityData.get(activity).set("locked", locked)
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
#endregion

#region PAUSING ACTIVITIES
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
		return
	
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
		return
	
	if(is_paused(activity, true)):
		var activity_UI: Activity_UI = get_activity_ui(activity)
		if activity_UI:
			activity_UI.unpause()
		
		set_paused(activity, false)
		activity_unpaused.emit(activity)
	
	## Remove the pause reason even if the activity is already unpaused
	remove_pause_reason(activity, reason)
	pass

func pause_all_activities(reason: String = "This activity is currently unavailable!"):
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

func unpause_all_activities(reason: String = ""):
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

#region BUILDING TOOLTIP
func construct_tooltip(activity: String) -> Array[String]:
	var title = "[b]" + Activities.get_loc(activity, "title") + "[/b]"
	var desc = Activities.get_loc(activity, "tooltip")
	
	return [title, desc, 
		construct_tooltip_stats(activity),
		construct_tooltip_costs(activity),
		construct_tooltip_effects(activity),
		"MMB to lock | Hold Shift to pin | RMB to clear"
	]

func construct_tooltip_stats(activity: String) -> String:
	var lines: PackedStringArray = []
	var line: String = ""
	
	var prog = get_progress(activity)
	var goal = get_goal(activity)
	var speed = get_speed(activity)
	var time: int = 0
	var h: int = 0
	var m: int = 0
	var s: int = 0
	
	var comp = get_completions(activity)
	var max_comp = get_max_completions(activity)
	
	if(comp == max_comp):
		line = "[color=Red]" + "Max completions reached!" + "[/color]"
		lines.append(line)
	elif(is_locked(activity)):
		line = "[color=Orange]" + "Activity is not unlocked yet!" + "[/color]"
		lines.append(line)
	
	if(is_paused(activity)):
		if(GlobalPause):
			line = "[color=Orange]" + Activities.GlobalPauseReason + "[/color]"
			lines.append(line)
		else:
			line = "[color=Orange]" + get_pause_reason(activity) + "[/color]"
			lines.append(line)
	
	if(ShowProgressAsPercentage): 
		line = "Progress: %5.2f%%" % (prog / goal * 100)
	else: 
		line = "Progress: %.2f/%.2f" % [prog, goal]
	lines.append(line)
	
	time= floor(((goal - prog) / speed))
	h = time / 3600
	m = (time % 3600) / 60
	s = ((time % 3600) % 60)
	
	if(h):
		line = "Time Left: %.0fh%.0fm%.0fs" % [h, m, s]
	elif(m):
		line = "Time Left: %.0fm%.0fs" % [m, s]
	else:
		line = "Time Left: %.0fs" % s
	lines.append(line)
	
	if(max_comp && max_comp < MAX):
		line = "Completions: %s/%s" % [comp, max_comp]
	else: 
		line = "Completions: %s" % comp
	lines.append(line)
	
	if(ShowTimeDetails): 
		if(ShowProgressAsPercentage): 
			line = "Speed: %.2f%%/s" % (speed / goal * 100)
		else: 
			line = "Speed: %.2f/s" % speed
		lines.append(line)
		
		time = int(floor((goal / speed)))
		h = time / 3600
		m = (time % 3600) / 60
		s = ((time % 3600) % 60)
		
		if(s > 3600):
			line = "Total Time: %.0fh%.0fm%.0fs" % [h, m, s]
		elif(s > 60):
			line = "Total Time: %.0fm%.0fs" % [m, s]
		else:
			line = "Total Time: %.0fs" % s
		lines.append(line)
	
	return "\n".join(lines)

func construct_tooltip_costs(activity: String) -> String:
	var lines: PackedStringArray = []
	var line: String = ""
	
	if(ActivityData.get(activity).has("requirements")):
		var requirements = ActivityData.get(activity).get("requirements")
		var new_lines: Array[String] = Requirements.process_requirement_descriptions(requirements)
		
		if(new_lines.size()):
			line = "[u]Requirements[/u]"
			lines.append(line)
			
			lines.append_array(new_lines)
	
	return "\n".join(lines)

func construct_tooltip_effects(activity: String) -> String:
	var lines: PackedStringArray = []
	var line: String = ""
	
	var effects = ActivityData.get(activity).get("effects", {})
	
	line = "[u]Effects[/u]"
	lines.append(line)
	
	lines.append_array(Effects.process_effect_descriptions(effects))
	
	return "\n".join(lines)
#endregion
