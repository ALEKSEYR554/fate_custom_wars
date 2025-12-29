extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	field.make_action_button.disabled = false
	field.end_turn_button.disabled = false
	field.move_button.disabled = true
	
	field.blinking_glow_button = false
	field.glow_cletki_node.visible = false
	
	#field.current_action="move"
	
	var current_kletka = _data.get("Current Kletka",null)
	if current_kletka == null:
		push_error("no current kletka sent from server")
		return
	
	var kletki_awailable = _data.get("Available Kletki",null)
	
	if kletki_awailable == null:
		push_error("no Available Kletki sent from server")
		return
	
	field.choose_glowing_cletka_by_ids_array(kletki_awailable)
	var glowing_kletka_number_selected = await field.glow_kletka_pressed_signal
	
	var net_data={
		"initial_spawn":_data.get("Initial Spawn",false),
		"glowing_kletka_number_selected":glowing_kletka_number_selected,
		"pu_id":Globals.self_pu_id,
		"current_char_info_dic":current_char_info.to_dictionary()
	}
	var message=""
	if _data.get("Initial Spawn",false):
		message="initial_spawn"
	else:
		message="move"
	rpc_id(1,"handle_network_message",message,net_data)
	
	
@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var pu_id=net_data.get("pu_id","")
	var glowing_kletka_number_selected = net_data.get("glowing_kletka_number_selected",-1)
	var char_info:CharInfo = field.get_current_char_info_for_pu_id(pu_id)
	
	match message:
		"initial_spawn":
			fsm.change_state_for_pu_ud(pu_id,"Idle")
			
			players_handler.rpc_id(
				Globals.pu_id_player_info[char_info.pu_id]["current_peer_id"],
				"set_random_command_spell_set"
				)


			field.move_player_from_kletka_id1_to_id2(char_info,-1,glowing_kletka_number_selected)
			
			await field.sleep(0.1)
			rpc_id(
				Globals.pu_id_player_info[char_info.pu_id]["current_peer_id"],
				"show_gui_depends_on_situation",
				"initianl_spawn")
			players_handler.rpc("pass_next_turn",char_info.pu_id)
			
			#is_game_started=true
			Globals.is_game_started=true
		"move":
			fsm.change_state_for_pu_ud(pu_id,"Idle")
			
			var mounted=false
			if field.check_if_kletka_has_mount(glowing_kletka_number_selected):
				print("kletka has mount")
				if field.check_if_char_info_can_ride_mount_on_kletka_id(char_info,glowing_kletka_number_selected):
					
					var choose_data=field.get_base_fsm_data_for_pu_id(pu_id)
					
					choose_data.merge(
						{
							"choose_between_two_question":"ENTER_MOUNT_QUESTION",
							"first_option":"ENTER_MOUNT_QUESTION_AGREEMENT",
							"second_option":"ENTER_MOUNT_QUESTION_DISAGREEMENT",
							
							"first_option_action":"mounting",
							"disagreement_case_name":null,
							
							"required_data":{
								"glowing_kletka_number_selected":glowing_kletka_number_selected
							}
						}
					)
					
					fsm.change_state_for_pu_ud(pu_id,"ChoosingBetweenTwo",choose_data)
					return
				else:
					print("player cant ride this mount")
			
			var presence_cons_stun=net_data.get("stun",null)
			if presence_cons_stun != null:
				if presence_cons_stun == true:
					players_handler.add_buff([char_info.to_dictionary()],
					{"Name":"Paralysis",
						"Duration":1,
						"Power":1
						}
					)
				field.show_char_info_servant_node(char_info.to_dictionary(),true)
				players_handler.remove_buff([char_info.to_dictionary()],"Presence Concealment",true)

			fsm.change_state_for_pu_ud(pu_id,"Moving",net_data)
			
func exit():
	field.make_action_button.disabled = true
	field.end_turn_button.disabled = true
	field.move_button.disabled = false
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
	pass
