extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering DiceRoll State")
	
	var action_name = _data.get("action_name",null)
	if action_name == null:
		push_error("No action_name in ",self.name, " state data=",_data)
		return
	
	var can_reroll = _data.get("can_reroll",null)
	if can_reroll == null:
		push_error("No can_reroll in ",self.name, " state data=",_data)
		return
	
	var reroll_amount = _data.get("reroll_amount",null)
	if reroll_amount == null:
		push_error("No reroll_amount in ",self.name, " state data=",_data)
		return
	
	var action_after_dice_roll = _data.get("action_after_dice_roll",null)
	if action_after_dice_roll == null:
		push_error("No action_after_dice_roll in ",self.name, " state data=",_data)
		return
	

	var dice_result_list = await field.await_dice_including_rerolls(action_name,can_reroll,reroll_amount)
	
	field.dices_main_VBoxContainer.visible = false
	field.you_were_attacked_container.visible = false
	field.are_you_sure_main_container.visible = false
	
	_data["dice_roll_result"]=dice_result_list
	
	rpc_id(1,"handle_network_message",action_after_dice_roll,_data)


@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	#TODO
	#var set_dices=players_handler.char_info_has_active_buff(get_current_self_char_info(),"Faceless Moon")
	var pu_id = net_data.get("pu_id","")
	var char_info = CharInfo.from_dictionary(net_data.get("char_info_dic"))
	match message:
		"attack_after_attacker_dice_roll":
			field.attack_after_attacker_dice_roll(net_data)
		"parry_rolleds":
			field.parry_rolled(net_data)
		"evade_rolleds":
			field.evade_rolled(net_data)
		"defence_rolleds":
			field.defence_rolled(net_data)
		"dash_line_attack":
			field.add_line_attack_cells(net_data)
			field.dash_char_info_for_phantasm(char_info,net_data)
			fsm.change_state_for_pu_ud(pu_id,"Attacking",net_data)
		"attack_line_attack":
			field.add_line_attack_cells(net_data)
			fsm.change_state_for_pu_ud(pu_id,"Attacking",net_data)

func exit():
	
	field.dices_main_VBoxContainer.visible=false
	field.you_were_attacked_container.visible=false
	field.are_you_sure_main_container.visible=false
	pass
	
