extends BattleState

signal answer_button_pressed_agreed(answer)

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	var why=_data.get("why",null)
	if why==null:
		push_error("No why in ",self.name, "state data=",_data)
		return
	
	var text=_data.get("text",null)
	if text==null:
		push_error("No text in ",self.name, "state data=",_data)
		return
	
	field.are_you_sure_label.visible=true
	field.are_you_sure_label.text=tr("ARE_YOU_SURE_YOU_WANT_TO_QUESTION").format({"action":text})
	
	var agree = await answer_button_pressed_agreed
	
	if agree:
		match why:
			"":
				pass
	else:
		match why:
			"":
				pass

func exit():
	field.are_you_sure_label.visible=true
	
	
