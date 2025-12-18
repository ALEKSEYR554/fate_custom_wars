extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	var kletka_id_selected=_data.get("kletka_id_selected",null)
	if kletka_id_selected==null:
		push_error("No kletka_id_selected in ",self.name, " state data=",_data)
		return
		
	var damage_type=_data.get("damage_type",null)
	if damage_type==null:
		push_error("No damage_type in ",self.name, " state data=",_data)
		return
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	field.end_turn_button.disabled = true
	field.make_action_button.disabled = true
	field.skill_info_show_button.disabled = true
	
	field.end_turn_button.disabled=true
	var defender_char_info:CharInfo
	if _data.get("defender_char_info_dic"):
		defender_char_info = _data.get("defender_char_info_dic")
	else:
		defender_char_info=await field.choose_char_info_on_kletka_id(
			kletka_id_selected,
			_data.get("mounts_only",false),
			_data.get("playable_only",false)
		)
	
	var net_data={
			"pu_id":Globals.self_pu_id,
			"attacker_char_info_dic":current_char_info.to_dictionary(),
			"defender_char_info_dic":defender_char_info.to_dictionary(),
			"kletka_id_selected":kletka_id_selected,
			
			"damage_type":damage_type,
			"consume_action_point":_data.get("consume_action_point",true),
			"phantasm_config":_data.get("phantasm_config",{})
		}
		
	rpc_id(1,"handle_network_message","",net_data)
	

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	
	var pu_id = net_data.get("pu_id")
	var kletka_id_selected = net_data.get("kletka_id_selected")
	
	field.pu_id_attack_player_on_kletka_id(
		pu_id,
		kletka_id_selected,
		net_data
	)
	



func exit():
	
	field.blinking_glow_button=true
	field.glow_cletki_node.visible = true
	field.end_turn_button.disabled = false
	field.make_action_button.disabled = false
	field.skill_info_show_button.disabled = false
