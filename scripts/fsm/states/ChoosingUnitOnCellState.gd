extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ChoosingUnitOnCell State")
	
	var kletka_id_to_choose_unit_on=_data.get("kletka_id_to_choose_unit_on",null)
	if kletka_id_to_choose_unit_on==null:
		push_error("No kletka_id_to_choose_unit_on in ",self.name, " state data=",_data)
		return
	
	await field.choose_char_info_on_kletka_id(kletka_id_to_choose_unit_on)
	
	if _data.get("damage_type",false):
		var net_data={
			"pu_id":Globals.self_pu_id,
			"current_char_info_dic":current_char_info.to_dictionary()
		}
		rpc_id(1,"handle_network_message","attacking",net_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var pu_id=net_data.get("pu_id","")
	var char_info:CharInfo = CharInfo.from_dictionary(net_data.get("current_char_info_dic"))
	var attack_data=field.get_base_fsm_data_for_pu_id(pu_id)
	attack_data.merge(
		{
			"damage_type":Globals.unit_uniq_id_to_damage_type[char_info.get_uniq_id()]
		}
	)
	fsm.change_state_for_pu_ud(pu_id,"Attacking",attack_data)
	
	players_handler.unit_uniq_id_player_game_stat_info[char_info.get_uniq_id()]["attacked_this_turn"]+=1

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
