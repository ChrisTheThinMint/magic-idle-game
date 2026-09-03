class_name Activity_UI
extends MarginContainer

# Some implementations in this object depend on the "tooltips_pro" addon
# Which may not be included in the visible code files for brevity

@onready var button: TooltipTrigger = $Button
@onready var progress_bar = $Button/ProgressBar

var my_activity: String
var update_delay = 0
var raw_tooltip = ""

func _ready() -> void:
	button.toggled.connect(_on_button_toggled)
	pass

func setup(activity: String) -> void:
	my_activity = activity
	Activities.ui_register_activity(activity, self)
	
	set_progress(Activities.get_progress(activity), true)
	set_goal(Activities.get_goal(activity), true)
	set_button_text(Activities.get_loc(activity, "title"), true)
	update_tooltip()
	
	if(Activities.is_locked(activity)):
		lock()
	pass

func get_dynamic_tooltip() -> String:
	return "progress: %s" % progress_bar.value

@warning_ignore("unused_parameter")
func _on_button_toggled(toggled_on: bool):
	Activities._on_activity_toggled(my_activity)
	pass

func update_tooltip(ignore_delay: bool = false):
	var tooltip_strings = construct_tooltip()
	button.tooltip_strings = tooltip_strings
	
	if(button.active_tooltip != null):
		if(Activities.TooltipUpdateDelay == 0 
		|| update_delay >= Activities.TooltipUpdateDelay 
		|| ignore_delay):
			update_delay = 0
			button.active_tooltip.set_content(tooltip_strings)
		else:
			update_delay += 1
	else:
		update_delay = 0
	pass

func construct_tooltip() -> Array[String]:
	var separator = "[hr color=DimGray height=1]"
	
	var title = "[b]" + Activities.get_loc(my_activity, "title") + "[/b]"
	var desc = Activities.get_loc(my_activity, "tooltip")
	
	return [title, desc, 
		construct_tooltip_stats(),
		construct_tooltip_costs(),
		construct_tooltip_effects(),
		construct_tooltip_help()
	]

func construct_tooltip_stats() -> String:
	var lines: PackedStringArray = []
	var line: String = ""
	
	var prog = Activities.get_progress(my_activity)
	var goal = Activities.get_goal(my_activity)
	var speed = Activities.get_speed(my_activity)
	var time: int = 0
	var h: int = 0
	var m: int = 0
	var s: int = 0
	
	var comp = Activities.get_completions(my_activity)
	var max_comp = Activities.get_max_completions(my_activity)
	
	if(comp == max_comp):
		line = "[color=Red]" + "Max completions reached!" + "[/color]"
		lines.append(line)
	elif(Activities.is_locked(my_activity)):
		line = "[color=Orange]" + "Activity is not unlocked yet!" + "[/color]"
		lines.append(line)
	
	if(Activities.is_paused(my_activity)):
		if(Activities.GlobalPause):
			line = "[color=Orange]" + Activities.GlobalPauseReason + "[/color]"
			lines.append(line)
		else:
			line = "[color=Orange]" + Activities.get_pause_reason(my_activity) + "[/color]"
			lines.append(line)
	
	if(Activities.ShowProgressAsPercentage): 
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
	
	if(max_comp && max_comp < Activities.MAX):
		line = "Completions: %s/%s" % [comp, max_comp]
	else: 
		line = "Completions: %s" % comp
	lines.append(line)
	
	if(Activities.ShowTimeDetails): 
		if(Activities.ShowProgressAsPercentage): 
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

func construct_tooltip_costs() -> String:
	var lines: PackedStringArray = []
	var line: String = ""
	var data_name = ""
	var data = {}
	
	if(Activities.ActivityData.get(my_activity).has("costs")):
		var costs = Activities.ActivityData.get(my_activity).get("costs")
		
		line = "[u]Costs[/u]"
		lines.append(line)
		
		#if(not Activities.check_costs(my_activity)):
			#line = "[color=Red]" + "Can't pay for activity!" + "[/color]"
			#lines.append(line)
		
		if(costs.has("resources")): 
			for resource in costs.get("resources"): if(Resources.is_valid(resource)):
				data = costs.get("resources").get(resource)
				data_name = Resources.get_loc(resource, "title", abs(data) > 1)
				
				line = "%s x '%s'" % [data, data_name]
				lines.append(line)
		
		if(costs.has("qualities")):
			for quality in costs.get("qualities"): if(Qualities.is_valid(quality)):
				data = costs.get("qualities").get(quality)
				data_name = Qualities.get_loc(quality, "title")
				
				line = "'%s'" % [data_name, data]
				lines.append(line)
	
	return "\n".join(lines)

func construct_tooltip_effects() -> String:
	var lines: PackedStringArray = []
	var line: String = ""
	
	if(Activities.ActivityData.get(my_activity).has("effects")):
		var effects = Activities.ActivityData.get(my_activity).get("effects")
		
		line = "[u]Effects[/u]"
		lines.append(line)
		
		lines.append_array(Effects.process_effect_descriptions(effects))
	
	return "\n".join(lines)

func construct_tooltip_help() -> String:
	var lines: PackedStringArray = []
	var line: String = ""
	
	line = "MMB to lock"
	lines.append(line)
	
	line = "Hold Shift to pin"
	lines.append(line)
	
	line = "RMB to clear"
	lines.append(line)
	
	#"[hr height=1 width=100%]\n" + 
	return " | ".join(lines)

func set_progress(progress: float, silent: bool = false):
	progress_bar.set_value_no_signal(progress)
	
	if(not silent):
		update_tooltip()
	#if(Activities.ShowProgressAsPercentage):
		#var goal = Activities.get_goal(my_activity)
		#var perc = progress / goal * 100
		#var text = "Progress: %5.2f%%" % perc
		#
		#button.tooltip_strings[0] = text
	#else:
		#var goal = Activities.get_goal(my_activity)
		#var text = "Progress: %0.1f/%0.1f" % [progress, goal]
		#
		#button.tooltip_strings[0] = text
	#
	#if(button.active_tooltip != null):
		#if(update_delay >= Activities.TooltipUpdateDelay):
			#update_delay = 0
			#button.active_tooltip.set_content(button.tooltip_strings)
		#else:
			#update_delay += 1
	#else:
		#update_delay = 0
	pass

func set_goal(goal: float, silent: bool = false):
	progress_bar.max_value = goal
	
	if(not silent):
		update_tooltip()
	pass

func set_button_text(text: String, silent: bool = false):
	button.text = text
	
	if(not silent):
		update_tooltip()
	pass

func activate():
	button.set_pressed_no_signal(true)
	
	update_style()
	update_tooltip(true)
	pass

func deactivate():
	button.set_pressed_no_signal(false)
	
	update_style()
	update_tooltip(true)
	pass

func pause():
	update_style()
	update_tooltip(true)
	pass

func unpause():
	update_style()
	update_tooltip(true)
	pass

func lock():
	button.set_pressed_no_signal(false)
	button.disabled = true
	
	update_style()
	update_tooltip(true)
	pass

func unlock():
	button.set_pressed_no_signal(false)
	button.disabled = false
	
	update_style()
	update_tooltip(true)
	pass

func update_style():
	progress_bar.remove_theme_stylebox_override("fill")
	
	if(Activities.is_locked(my_activity)):
		set_style_locked()
	else:
		if(Activities.is_active(my_activity)):
			if(Activities.is_paused(my_activity)):
				set_style_active_paused()
			else:
				set_style_active()
		else:
			if(Activities.is_paused(my_activity)):
				set_style_inactive_paused()
			else:
				set_style_inactive()
	pass

func set_style_active():
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.0, 0.5, 1.0, 1.0)
	progress_bar.add_theme_stylebox_override("fill", stylebox)
	pass

func set_style_active_paused():
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.0, 0.3, 0.6, 1.0)
	progress_bar.add_theme_stylebox_override("fill", stylebox)
	pass

func set_style_inactive():
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.5, 0.5, 0.5, 1.0)
	progress_bar.add_theme_stylebox_override("fill", stylebox)
	pass

func set_style_inactive_paused():
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.35, 0.35, 0.35, 1.0)
	progress_bar.add_theme_stylebox_override("fill", stylebox)

func set_style_locked():
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.25, 0.15, 0.15, 1.0)
	progress_bar.add_theme_stylebox_override("fill", stylebox)
