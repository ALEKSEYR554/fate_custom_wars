extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering Moving State")
	
	var glowing_kletka_number_selected=_data.get("glowing_kletka_number_selected",null)
	if glowing_kletka_number_selected==null:
		push_error("No glowing_kletka_number_selected in Moving state data=",_data)
		return
	
	
	
	
	
	var net_data={
		"pu_id":Globals.self_pu_id,
		"current_char_info_dic":current_char_info.to_dictionary()
	}
	rpc_id(1,"handle_network_message","",net_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var pu_id=net_data.get("pu_id","")
	var glowing_kletka_number_selected = net_data.get("glowing_kletka_number_selected",-1)
	var char_info:CharInfo = field.get_current_char_info_for_pu_id(pu_id)
	
	var mounted = net_data.get("mounted",null)
	
	if char_info.get_node().additional_moves>=1 or field.get_current_kletka_id_for_char_info(char_info)==-1:
		players_handler.reduce_additional_moves_for_char_info(char_info)
	else:
		field.reduce_one_action_point_for_pu_id(char_info.pu_id,-1,"movement")
	#move_player_from_kletka_id1_to_id2(Globals.self_peer_id,get_current_kletka_id(),glowing_kletka_number_selected)
	field.move_player_from_kletka_id1_to_id2(
		char_info,
		field.get_current_kletka_id_for_char_info(char_info),
		glowing_kletka_number_selected
	)
	if mounted:
		field.sit_char_info_on_mount_on_kletka_id(
			char_info.to_dictionary(),
			glowing_kletka_number_selected
		)

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
