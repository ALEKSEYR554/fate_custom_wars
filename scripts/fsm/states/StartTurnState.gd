extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering StartTurn State")
	
	field.make_action_button.disabled = false
	field.end_turn_button.disabled = false


	var kletki_with_non_played_units = _data.get("kletki_with_non_played_units",null)
	if kletki_with_non_played_units == null:
		push_error("No kletki_with_non_played_units in ",self.name, "state data=",_data)
		return
	
	if kletki_with_non_played_units.size()<=0:
		field.info_table_show("NO_UNITS_AVAILABLE_TO_PLAY")

	#await field.choose_unit_to_play_for_pu_id(pu_id,maximum_playable_units,unit_ids_already_played_this_turn)
	var choosen_kletka_id:int

	if kletki_with_non_played_units.size()>1:
		#info_table_show(tr("CHOOSE_UNIT_TO_PLAY"))
		field.info_table_show("CHOOSE_UNIT_TO_PLAY")
		await field.info_ok_button.pressed
		field.choose_glowing_cletka_by_ids_array(kletki_with_non_played_units)
		choosen_kletka_id = await field.glow_kletka_pressed_signal

	else:
		choosen_kletka_id = kletki_with_non_played_units[0]

	var tmp = await field.get_char_info_on_kletka_id(choosen_kletka_id,false,true)

	var node_choosen = tmp.get_node()

	var unit_id_choosen=node_choosen.unit_id
	var net_data = {
		"pu_id":Globals.self_pu_id,
		"unit_id_choosen":unit_id_choosen
	}
	rpc_id(1,"handle_network_message","",net_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var pu_id:String = net_data.get("pu_id","")
	var unit_id_choosen:int = net_data.get("unit_id_choosen")
	var char_info:CharInfo = CharInfo.new(pu_id,unit_id_choosen)
	var node_choosen = char_info.get_node()
	
	Globals.pu_id_player_info[pu_id]["current_unit_id"] = unit_id_choosen
	
	var action_points = 0
	print("unit_id_choosen=",unit_id_choosen)
	if unit_id_choosen == 0:
		print("starting as main servant")
		action_points = 3
	else:
		print("starting as sub servant/summon")
		if node_choosen.servant:
			action_points = 3
		else:
			action_points = 0
		players_handler.reduce_additional_moves_for_char_info(
			char_info.to_dictionary(),
			-node_choosen.move_points
			)
		players_handler.reduce_additional_attacks_for_char_info(
			char_info.to_dictionary(),
			-node_choosen.can_attack
			)
	Globals.pu_id_to_action_points[pu_id] = action_points
	field.get_additional_actions_for_char_info_from_mount(char_info.to_dictionary())
	
	var turn_data = {
		"pu_id":pu_id,
		"char_info_dic":char_info.to_dictionary(),
		"action_points":action_points
	}

	field.handle_pre_unit_turn_things(turn_data)
	
	

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
