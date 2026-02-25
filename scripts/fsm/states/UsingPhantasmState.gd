extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering UsingPhantasm State")
	
	var phantasm_data=_data.get("phantasm_data",null)
	if phantasm_data==null:
		push_error("No phantasm_data in ",self.name, "state data=",_data)
		return
	
	field.end_turn_button.disabled = true
	#var net_data={
	#	"pu_id":Globals.self_pu_id,
	#	"current_char_info_dic":current_char_info.to_dictionary(),
	#	"phantasm_data":phantasm_data
	#}
	
	rpc_id(1,"handle_network_message","",_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var pu_id=net_data.get("pu_id",-1)
	var char_info = CharInfo.from_dictionary(net_data.get("current_char_info_dic"))
	var phantasm_data=net_data.get("phantasm_data",{})

	var attack_type = phantasm_data.get("Attack Type","")
	return false
	#match attack_type:
	#	"Line":
	#		attacked_by_phantasm=await field.line_attack_phantasm(char_info,phantasm_data,false,net_data)
	#	"Dash":
	#		attacked_by_phantasm=await field.line_attack_phantasm(char_info,phantasm_data,true,net_data)
	#	"Single In Range":
	#		attacked_by_phantasm=await phantasm_in_range(phantasm_data,"Single")
	#	"All Enemies In Range":
	#		attacked_by_phantasm=await phantasm_in_range(phantasm_data,"All enemies")
	#	"Bomb":
	#		attacked_by_phantasm=await bomb_phantasm(phantasm_data)
	#	"All Field Enemies":
	#		pass

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
