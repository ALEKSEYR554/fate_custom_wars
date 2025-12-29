extends BattleState

signal answer_button_pressed_agreed(answer)

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ConfirmAction State")
	
	var action_after_confirming_action = _data.get("action_after_confirming_action",null)
	if action_after_confirming_action == null:
		push_error("No action_after_confirming_action in ",self.name, " state data=",_data)
		return
	
	var confirm_action_action_text = _data.get("confirm_action_action_text",null)
	if confirm_action_action_text == null:
		push_error("No confirm_action_action_text in ",self.name, " state data=",_data)
		return
	
	var parry_count_max = _data.get("parry_count_max")
	var current_parry_count = _data.get("current_parry_count",0)
	
	var data={
		"action_after_confirming_action":action_after_confirming_action,
		"parry_count_max":parry_count_max,
		"current_parry_count":current_parry_count
	}
	
	answer_button_pressed_agreed.connect(answer_button_pressed.bind(data))
	
	field.are_you_sure_label.text = tr("ARE_YOU_SURE_YOU_WANT_TO_QUESTION").format({"action":tr(confirm_action_action_text)})
	field.are_you_sure_label.visible = true

func answer_button_pressed(agreed:bool,data):
	var action_after_confirming_action = data.get("action_after_confirming_action")
	var pu_id = data.get("char_info_dic")["pu_id"]
	var new_data = {
		"pu_id":pu_id,
		"action_after_confirming_action":action_after_confirming_action,
		"agreed":agreed
	}
	new_data.merge(data)
	rpc_id(1,"handle_network_message",action_after_confirming_action)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var pu_id = net_data.get("pu_id")
	var char_info:CharInfo = field.get_current_char_info_for_pu_id(pu_id)
	var parry_count_max = net_data.get("parry_count_max")
	var current_parry_count = net_data.get("current_parry_count",0)
	
	var agreed = net_data.get("agreed")
	
	if agreed:
		match message:
			"parry":
				fsm.change_state_for_pu_ud(pu_id,"DiceRoll",net_data)
				#fsm.change_state_for_pu_ud(pu_id,"Parrying",net_data)
			"evade":
				fsm.change_state_for_pu_ud(pu_id,"DiceRoll",net_data)
			"choose_damage_type_before_counter_attack":
				fsm.change_state_for_pu_ud(pu_id,"ChooseBetweenTwo",net_data)
			"defence":
				fsm.change_state_for_pu_ud(pu_id,"DiceRoll",net_data)
			"release_from_Presence_Concealment_with_stun":
				fsm.change_state_for_pu_ud(pu_id,"MoveSelection",net_data)
	else:
		match message:
			"parry":
				fsm.change_state_for_pu_ud(pu_id,"Defending",net_data)
			"evade":
				fsm.change_state_for_pu_ud(pu_id,"Defending",net_data)
			"defence":
				fsm.change_state_for_pu_ud(pu_id,"Defending",net_data)
			"release_from_Presence_Concealment_with_stun":
				fsm.change_state_for_pu_ud(pu_id,"UnitTurnState",net_data)
	

func exit():
	answer_button_pressed_agreed.disconnect(answer_button_pressed)
	field.are_you_sure_label.visible=true
	field.you_were_attacked_container.visible=true
	
	
