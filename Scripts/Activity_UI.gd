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
	var tooltip_strings = Activities.construct_tooltip(my_activity)
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
