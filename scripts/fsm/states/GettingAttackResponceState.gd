extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	var attack_responce=_data.get("attack_responce",null)
	if attack_responce==null:
		push_error("No attack_responce in ",self.name, "state data=",_data)
		return
	
	var attacker_char_info_dic=_data.get("attacker_char_info_dic",null)
	if attacker_char_info_dic==null:
		push_error("No attacker_char_info_dic in ",self.name, " state data=",_data)
		return
	var attacker_char_info=CharInfo.from_dictionary(attacker_char_info_dic)
	
	var defender_char_info_dic=_data.get("defender_char_info_dic",null)
	if defender_char_info_dic==null:
		push_error("No defender_char_info_dic in ",self.name, " state data=",_data)
		return
	var defender_char_info=CharInfo.from_dictionary(defender_char_info_dic)
	
	

	var net_data={
		"pu_id":Globals.self_pu_id,
		"current_char_info_dic":current_char_info.to_dictionary()
	}
	rpc_id(1,"handle_network_message","attacking",net_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	
	field.attack_responce_handle_for_char_info_from_char_info(net_data)

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
