extends BattleState

signal cell_pressed(id:int)

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ChoosingTarget State")
	field.type_of_damage_choose_buttons_box.visible=false
	
	var cells_to_choose=_data.get("cells_to_choose",null)
	if cells_to_choose==null:
		push_error("No cells_to_choose in ChoosingTargetState data=",_data)
		return
	
	field.make_action_button.disabled = false
	for child in field.make_action_button.get_children():
		#child.disabled=true
		child.set("disabled",true)#this in case I want to add Non button childs to it
		pass
	
	field.action_button_cancel.disabled=false
	
	field.end_turn_button.disabled = false
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible=false
	
	
	field.choose_glowing_cletka_by_ids_array(cells_to_choose)

	var cell_id = await cell_pressed

	var net_data={
		"pu_id":Globals.self_pu_id,
		"current_char_info_dic":current_char_info.to_dictionary(),
		"kletka_id":cell_id
	}

	_data.merge(net_data)
	rpc_id(1,"handle_network_message","",net_data)

func glow_cell_pressed(kletka_id):
	cell_pressed.emit(kletka_id)


@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	if not multiplayer.is_server():
		return
	var pu_id=net_data.get("pu_id",-1)
	var glowing_kletka_number_selected = net_data.get("kletka_id",-1)
	var char_info:CharInfo=CharInfo.from_dictionary(net_data.get("current_char_info_dic",{}))
	var action_after_choosing_kletka_id = net_data.get("action_after_choosing_kletka_id","")

	print("glow_cletka_pressed, current_action="+str(Globals.pu_id_to_action_points[pu_id]))

	
	match action_after_choosing_kletka_id:
		"field capture":
			#rpc("sync_owned_kletki",unit_uniq_id_to_kletki_ids_owned)
			Globals.pu_id_player_info[pu_id]["temp_kletka_capture_config"]["Color"]=Globals.self_field_color
			field.capture_single_kletka_sync_for_char_info(
				char_info,
				glowing_kletka_number_selected,
				Globals.pu_id_player_info[pu_id]["temp_kletka_capture_config"]
				)
			print("temp_kletka_capture_config  222="+str(Globals.pu_id_player_info[pu_id]["temp_kletka_capture_config"]))
			Globals.pu_id_to_current_action[char_info.pu_id]="wait"
		"choosing_unit_on_cell_to_attack":
			net_data.merge(
				{
					"kletka_id_to_choose_unit_on":glowing_kletka_number_selected,
					"action_after_choosing_unit_on_cell":"Attack"
				}
			)
			
			fsm.change_state_for_pu_ud(pu_id,"ChoosingUnitOnCell",net_data)
		"choosing_unit_on_cell_to_cast_buff_to":
			net_data.merge(
				{
					"kletka_id_to_choose_unit_on":glowing_kletka_number_selected,
					"action_after_choosing_unit_on_cell":"Skill use"
				}
			)
			
			fsm.change_state_for_pu_ud(pu_id,"ChoosingUnitOnCell",net_data)
			


		
func exit():
	field.make_action_button.disabled = false
	for child in field.make_action_button.get_children():
		#child.disabled=true
		child.set("disabled",false)
		pass
	
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
	pass
