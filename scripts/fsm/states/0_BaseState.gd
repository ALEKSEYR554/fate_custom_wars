extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	var var_name=_data.get("var_name",null)
	if var_name==null:
		push_error("No var_name in ",self.name, " state data=",_data)
		return
	
	if _data.get("damage_type",false):
		var net_data={
			"pu_id":Globals.self_pu_id,
			"current_char_info_dic":current_char_info.to_dictionary()
		}
		rpc_id(1,"handle_network_message","attacking",net_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	pass

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
