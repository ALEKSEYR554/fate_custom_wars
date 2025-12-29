extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ChoosingBetweenTwo State")
	#{
		#"choose_between_two_question":"ENTER_MOUNT_QUESTION",
		#"first_option":"ENTER_MOUNT_QUESTION_AGREEMENT",
		#"second_option":"ENTER_MOUNT_QUESTION_DISAGREEMENT",
		#
		#"first_option_action":"mounting",
		#"second_option_action":null,
		#
		#"required_data":{
			#"glowing_kletka_number_selected":glowing_kletka_number_selected
		#}
	#}
	
	var choose_between_two_question = _data.get("choose_between_two_question",null)
	if choose_between_two_question == null:
		push_error("No choose_between_two_question in ChoosingBetweenTwo state data=",_data)
		return
	
	var first_option = _data.get("first_option",null)
	if first_option == null:
		push_error("No first_option in ChoosingBetweenTwo state data=",_data)
		return
	
	var second_option = _data.get("second_optioneement",null)
	if second_option == null:
		push_error("No second_option in ChoosingBetweenTwo state data=",_data)
		return
	
	var first_option_action = _data.get("first_option_action",null)
	var second_option_action = _data.get("second_option_action",null)
	if not (first_option_action or second_option_action):
		push_error("No first_option_action or second_option_action in ChoosingBetweenTwo state data=",_data)
		return
	
	var required_data = _data.get("required_data",{})
	
	var answer = await field.choose_between_two(
		choose_between_two_question,
		first_option,
		second_option
		)
	
	var net_data = {
		"pu_id":Globals.self_pu_id,
		"current_char_info_dic":current_char_info.to_dictionary()
	}
	net_data.merge(required_data)
	
	
	if answer == first_option:
		if first_option_action:
			rpc_id(1,"handle_network_message",first_option_action,net_data)
	else:
		if second_option_action:
			rpc_id(1,"handle_network_message",second_option_action,net_data)
	

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	
	#var char_info:CharInfo = CharInfo.from_dictionary(net_data.get("current_char_info_dic",{}))
	var pu_id = net_data.get("pu_id","")
	
	match message:
		"mounting":
			net_data["moving"]=true
			fsm.change_state_for_pu_ud(pu_id,"Moving",net_data)
		"choosed_physical_damage_type_for_counter_attack":
			net_data["damage_type"]=players_handler.DAMAGE_TYPE.PHYSICAL
			fsm.change_state_for_pu_ud(pu_id,"Attacking",net_data)
		"choosed_magical_damage_type_for_counter_attack":
			net_data["damage_type"]=players_handler.DAMAGE_TYPE.MAGICAL
			fsm.change_state_for_pu_ud(pu_id,"Attacking",net_data)
		"ChoosingBetweenTwo":
			fsm.change_state_for_pu_ud(pu_id,"StartTurn",net_data)
		"pass_pu_id_turn":
			players_handler.pass_next_turn(pu_id)
		
	

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
