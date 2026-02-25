extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ChoosingUnitOnCell State")
	
	var kletka_id_to_choose_unit_on=_data.get("kletka_id_to_choose_unit_on",null)
	if kletka_id_to_choose_unit_on==null:
		push_error("No kletka_id_to_choose_unit_on in ",self.name, " state data=",_data)
		return
	
	var action_after_choosing_unit_on_cell=_data.get("action_after_choosing_unit_on_cell",null)
	if action_after_choosing_unit_on_cell==null:
		push_error("No action_after_choosing_unit_on_cell in ",self.name, " state data=",_data)
		return
	
	var char_info_choosen = await field.choose_char_info_on_kletka_id(kletka_id_to_choose_unit_on)
	
	_data.merge(
		{
			"char_info_dic_choosen":char_info_choosen.to_dictionary()
		}
	)
	rpc_id(1,"handle_network_message",action_after_choosing_unit_on_cell,_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var pu_id=net_data.get("pu_id","")
	var char_info:CharInfo = CharInfo.from_dictionary(net_data.get("current_char_info_dic"))
	match message:
		"Attack":
			fsm.change_state_for_pu_ud(pu_id,"Attacking",net_data)
		"choosing_unit_on_cell_to_cast_buff_to":
			var char_info_cast_skill_to = CharInfo.from_dictionary(
				net_data.get("char_info_dic_choosen",{})
			)
			if net_data.get("cast_condition",{}) != {}:
				var new_cast=field.get_char_infos_satisfying_condition(
					[char_info_cast_skill_to], net_data.get("cast_condition")
				)
				print_debug("New cast=",new_cast)
				if new_cast.is_empty():
					field.use_effect_for_char_info(
						net_data.get("effect_queque",[]),
						char_info,
						net_data
					)
				char_info_cast_skill_to=new_cast
			
			var current_effect_using = net_data.get("current_effect_using",{})
			players_handler.add_buffs_array_to_cast_array(current_effect_using,[char_info_cast_skill_to],net_data)

	
	players_handler.unit_uniq_id_player_game_stat_info[char_info.get_uniq_id()]["attacked_this_turn"]+=1

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
