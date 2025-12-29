extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	var char_info_dic=_data.get("char_info_dic",null)
	if char_info_dic==null:
		push_error("No char_info_dic in ",self.name, "state data=",_data)
		return

	var skills_enabledd=_data.get("skills_enabledd",null)
	if skills_enabledd==null:
		push_error("No skills_enabledd in ",self.name, "state data=",_data)
		return
	
	var paralyzed=_data.get("paralyzed",null)
	if paralyzed==null:
		push_error("No paralyzed in ",self.name, "state data=",_data)
		return

	field.paralyzed = paralyzed
	
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)

	var action_points=Globals.pu_id_to_action_points[Globals.self_pu_id]
	
	var node_choosen=char_info.get_node()

	if paralyzed:
		field.disable_every_button()

		if players_handler.char_info_has_active_buff(current_char_info,"Charm"):
			field.info_table_show("YOU_ARE_CHARMED")
		else:
			field.info_table_show("YOU_ARE_PARALYZED")
		await field.info_ok_button.pressed
		
		field.end_turn_button.disabled=false
		field.command_spells_button.disabled=false

	var net_data={
		"pu_id":Globals.self_pu_id,
		"current_char_info_dic":current_char_info.to_dictionary()
	}

	field.skill_info_show_button.disabled=not skills_enabledd

	%np_points_number_label.text=str(node_choosen.phantasm_charge)
	%current_hp_value_label.text=str(node_choosen.hp)
	%peer_id_label.text=str(node_choosen.name)

	field.current_action_points_label.text=str(action_points)


	rpc_id(1,"handle_network_message","",net_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var char_info:CharInfo = field.get_current_char_info_for_pu_id(Globals.self_pu_id)
	field.finishing_unit_start_turn_for_char_info(char_info)

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
