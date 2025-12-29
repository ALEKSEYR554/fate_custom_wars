extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	field.blinking_glow_button=false
	field.blink_timer_node.timeout.emit()
	#current_action_points=3
	#current_action_points_label.text=str(current_action_points)
	field.disable_every_button(false)#if paralysis
	
	var net_data={
		"pu_id":Globals.self_pu_id,
		"current_char_info_dic":current_char_info.to_dictionary()
	}
	rpc_id(1,"handle_network_message","",net_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var pu_id = net_data.get("pu_id")

	var char_info=field.get_current_char_info_for_pu_id(pu_id)
	#print(players_handler.trigger_buffs_on)
	await players_handler.trigger_buffs_on(char_info,"End Turn")
	await players_handler.reduce_all_cooldowns(char_info, "End Turn")
	
	#field.unit_ids_already_played_this_turn.append(Globals.pu_id_player_info[char_info.pu_id]["current_unit_id"])
	
	Globals.pu_id_player_info[pu_id]["unit_ids_already_played_this_turn"].append(char_info.unit_id)
	#Globals.pu_id_player_info[pu_id]["maximum_playable_units"]=0
	var maximum_playable_units = Globals.pu_id_player_info[pu_id]["maximum_playable_units"]
	var unit_ids_already_played_this_turn = Globals.pu_id_player_info[pu_id]["unit_ids_already_played_this_turn"]

	field.calculate_maximum_playable_units_for_pu_id(pu_id)
	print("maximum_playable_units=",maximum_playable_units, "unit_ids_already_played_this_turn=",Globals.unit_ids_already_played_this_turn.size())

	if maximum_playable_units!=unit_ids_already_played_this_turn.size():
		fsm.change_state_for_pu_ud(pu_id,"ChoosingBetweenTwo",{
			"choose_between_two_question":"YOU_HAVE_UNPLAYED_UNITS_QUESTION",
			"first_option":"YOU_HAVE_UNPLAYED_UNITS_QUESTION_AGREEMENT",
			"second_option":"YOU_HAVE_UNPLAYED_UNITS_QUESTION_DISAGREEMENT",
			"first_option_action":"pu_id_choosing_unit_to_play",
			"second_option_action":"pass_pu_id_turn",
			"required_data":{
				"kletki_with_non_played_units":field.get_cells_with_unplayer_units_for_pu_id(pu_id)
			}
			})

		#var answer=await choose_between_two("YOU_HAVE_UNPLAYED_UNITS_QUESTION","YOU_HAVE_UNPLAYED_UNITS_QUESTION_AGREEMENT","YOU_HAVE_UNPLAYED_UNITS_QUESTION_DISAGREEMENT")
		#if answer=="YOU_HAVE_UNPLAYED_UNITS_QUESTION_DISAGREEMENT":
			#await choose_unit_to_play_for_pu_id()
		return

	#TODO
	#handle all buff on end turn effects here

	
	players_handler.pass_next_turn(pu_id)

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
