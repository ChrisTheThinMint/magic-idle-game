extends RichTextLabel

func _ready() -> void:
	GameLog.Display = self
	
	rebuild_text()
	pass

func add_message(message: Dictionary):
	var timestamp = message.get("time")
	var message_text = message.get("text")
	
	append_text(
		"[color=DimGray][font_size=10]%s:  [/font_size][/color]" % timestamp
		+ "%s" % message_text
		+ "\n"
	)
	pass

func rebuild_text():
	clear()
	text = ""
	
	for message in GameLog.Messages:
		add_message(message)
	pass
