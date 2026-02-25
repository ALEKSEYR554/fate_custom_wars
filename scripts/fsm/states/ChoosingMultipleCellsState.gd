extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ChoosingMultipleCells State")
	
	var amount_cells_to_choose=_data.get("amount_cells_to_choose",null)
	if amount_cells_to_choose==null:
		push_error("No amount_cells_to_choose in ",self.name, "state data=",_data)
		return
	
	var type_of_cells_choose=_data.get("type_of_cells_choose",null)
	if type_of_cells_choose==null:
		push_error("No type_of_cells_choose in ",self.name, "state data=",_data)
		return
	
	var choose_starting_cell_id=_data.get("choose_starting_cell_id",null)
	if choose_starting_cell_id==null:
		push_error("No choose_starting_cell_id in ",self.name, "state data=",_data)
		return
	
	field.choose_multiple_cells(amount_cells_to_choose,type_of_cells_choose,choose_starting_cell_id)

	#if _data.get("damage_type",false):
	#	var net_data={
	#		"pu_id":Globals.self_pu_id,
	#		"current_char_info_dic":current_char_info.to_dictionary()
	#	}
	#	rpc_id(1,"handle_network_message","attacking",net_data)

func cells_choosen(cells_clicked:Array,type,_data:Dictionary):
	_data["multiple_cells_choosen"] = cells_clicked
	handle_network_message(type,_data)
	pass

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var pu_id = net_data.get("pu_id","")
	var char_info = CharInfo.from_dictionary(net_data.get("char_info_dic"))
	match message:
		"line_attack":
			net_data.merge(
				field.get_dice_roll_data_for_char_info_for_action_name(char_info,"Attack"),
				true
			)
			
			var char_info_dics_to_attack = field.get_enemies_char_info_dics_on_cells_id_for_char_info(net_data["multiple_cells_choosen"],char_info)
			var char_info_dic_to_attack = char_info_dics_to_attack.pop_front()
			net_data["defender_char_info_dic"] = char_info_dic_to_attack
			net_data["char_infos_to_attack_queue"] = char_info_dics_to_attack

			net_data["char_info_dics_attempted_to_attack_by_phantasm"] = {}
			net_data["char_info_dics_hitted_by_phantasm"] = {}


			if net_data.get("dash_phantasm",null):
				net_data["action_after_dice_roll"] = "dash_line_attack"
			else:
				net_data["action_after_dice_roll"] = "attack_line_attack"
			fsm.change_state_for_pu_ud(pu_id,"DiceRoll",net_data)
			pass

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
