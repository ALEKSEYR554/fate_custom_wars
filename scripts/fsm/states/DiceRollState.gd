extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	var action_name=_data.get("action_name",null)
	if action_name==null:
		push_error("No action_name in ",self.name, "state data=",_data)
		return
	
	var can_reroll=_data.get("can_reroll",null)
	if can_reroll==null:
		push_error("No can_reroll in ",self.name, "state data=",_data)
		return
	
	var reroll_amount=_data.get("reroll_amount",null)
	if reroll_amount==null:
		push_error("No reroll_amount in ",self.name, "state data=",_data)
		return
	
	
	
	await field.await_dice_including_rerolls(action_name,can_reroll,reroll_amount)
	
	field.dices_main_VBoxContainer.visible=false
	field.you_were_attacked_container.visible=false
	field.are_you_sure_main_container.visible=false
	
func exit():
	
	pass
	
