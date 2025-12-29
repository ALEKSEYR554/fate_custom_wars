extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ReleasePresenceConcealment State")
	
	var maximum_turns=_data.get("maximum_turns",null)
	if maximum_turns==null:
		push_error("No maximum_turns in ",self.name, "state data=",_data)
		return
	
	var minimum_turns=_data.get("minimum_turns",null)
	if minimum_turns==null:
		push_error("No minimum_turns in ",self.name, "state data=",_data)
		return
	
	var turns_passed=_data.get("turns_passed",null)
	if turns_passed==null:
		push_error("No turns_passed in ",self.name, "state data=",_data)
		return
	
	var stun = null
	if turns_passed>=maximum_turns:
		#release_from_Presence_Concealment(false)
		field.info_table_show(tr("PRESENCE_CONSEALMENT_END"))
		field.make_action_button.disabled = true
		field.end_turn_button.disabled = true
		field.disable_every_button()
		stun = false
	elif turns_passed>minimum_turns:
		#release_from_Presence_Concealment(true)
		field.make_action_button.disabled = true
		field.end_turn_button.disabled = true
		field.info_table_show(tr("EXIT_PRECENCE_CONCEALMENT_EARLIER"))
		await field.info_ok_button.pressed
		
		stun = true
	else:#waiting for minumum turns
		field.disable_every_button()
		field.info_table_show(
			tr("YOU_IN_PRESENCE_CONCEALMENT_FOR_TURNS").format(
			{
				"amount":abs(turns_passed-minimum_turns)
			}
		))
		
		await field.info_ok_button.pressed

	
	var net_data={
		"pu_id":Globals.self_pu_id,
		"current_char_info_dic":current_char_info.to_dictionary(),
		"stun":stun,
		"turns_passed":turns_passed,
		"maximum_turns":maximum_turns,
		"minimum_turns":minimum_turns
	}
	rpc_id(1,"handle_network_message","",net_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var pu_id:String = net_data.get("pu_id","")
	var char_info:CharInfo = CharInfo.from_dictionary(net_data.get("current_char_info_dic",{}))
	var stun:bool = net_data.get("stun",false)
	
	if stun == true:
		net_data["confirm_action_action_text"]="ARE_YOU_SURE_YOU_WANT_TO_ACTION_RELEASE_PRESENCE_CONCEALMENT"
		net_data["action_after_confirming_action"] = "release_from_Presence_Concealment_with_stun"
		fsm.change_state_for_pu_ud(pu_id,"ConfirmActionState",net_data)
	elif stun == false:
		var kletki_awailable=field.get_unoccupied_kletki()
		net_data["Available Kletki"]=kletki_awailable
		fsm.change_state_for_pu_ud(pu_id,"MoveSelection",net_data)
		#choose_glowing_cletka_by_ids_array(kletka_to_initial_spawn)
		#net_data["confirm_action_action_text"]="PRESENCE_CONSEALMENT_END"
		#net_data["action_after_confirming_action"] = "release_from_Presence_Concealment_no_stun"
		#fsm.change_state_for_pu_ud(pu_id,"ConfirmActionState",net_data)
	
	

func exit():
	field.make_action_button.disabled = false
	field.end_turn_button.disabled = false
	
