extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	"""
	{
		kletka_id_selected_for_attack:int,
		defender_char_info_dic:Dictionary,
		damage_type:String,

		mounts_only:bool,
		playable_only:bool,
		consume_action_point:bool,
		phantasm_config:dictionary
	}
	"""
	
	var kletka_id_selected_for_attack = _data.get("kletka_id_selected_for_attack",null)

	if kletka_id_selected_for_attack == null and _data.get("defender_char_info_dic") == null:
		push_error("No kletka_id_selected_for_attack or defender_char_info_dic in ",self.name, " state data=",_data)
		return
	
	var damage_type=_data.get("damage_type",null)
	if damage_type==null:
		if _data.get("phantasm_config",{}) == {}:
			push_error("No damage_type nor phantasm_config in ",self.name, " state data=",_data)
		else:
			damage_type = players_handler.DAMAGE_TYPE.PHANTASM
		return
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	field.end_turn_button.disabled = true
	field.make_action_button.disabled = true
	field.skill_info_show_button.disabled = true
	
	field.end_turn_button.disabled=true
	var defender_char_info_dic:Dictionary
	if _data.get("defender_char_info_dic"):
		defender_char_info_dic = _data.get("defender_char_info_dic")
	else:
		defender_char_info_dic=await field.choose_char_info_on_kletka_id(
			kletka_id_selected_for_attack,
			_data.get("mounts_only",false),
			_data.get("playable_only",false)
		).to_dictionary()

	
	#var net_data={
	#		"pu_id":Globals.self_pu_id,
	#		"attacker_char_info_dic":current_char_info.to_dictionary(),
	#		"defender_char_info_dic":defender_char_info_dic,
	#		"kletka_id_selected_for_attack":kletka_id_selected_for_attack,
	#		
	#		"damage_type":damage_type,
	#		"consume_action_point":_data.get("consume_action_point",true),
	#		"phantasm_config":_data.get("phantasm_config",{})
	#	}
	if kletka_id_selected_for_attack==null:
		kletka_id_selected_for_attack = field.get_current_kletka_id_for_char_info(CharInfo.from_dictionary(defender_char_info_dic))
		
	_data["kletka_id_selected_for_attack"] = kletka_id_selected_for_attack
	_data["attacker_char_info_dic"] = current_char_info.to_dictionary()


	rpc_id(1,"handle_network_message","",_data)
	

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	
	var attacker_char_info = CharInfo.from_dictionary(
		net_data.get("attacker_char_info_dic",{})
		)
	var defender_char_info = CharInfo.from_dictionary(
		net_data.get("defender_char_info_dic",{})
		)
	
	field.char_info_attack_char_info(
		attacker_char_info,
		defender_char_info,
		net_data
	)
	



func exit():
	
	field.blinking_glow_button=true
	field.glow_cletki_node.visible = true
	field.end_turn_button.disabled = false
	field.make_action_button.disabled = false
	field.skill_info_show_button.disabled = false
