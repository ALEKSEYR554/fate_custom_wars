extends BattleState

signal use_pressed(tab_choosen)

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	var var_name=_data.get("var_name",null)
	if var_name==null:
		push_error("No var_name in ",self.name, "state data=",_data)
		return
	
	_data.merge(
		{
			"pu_id":Globals.self_pu_id,
			"current_char_info_dic":current_char_info.to_dictionary()
		},true
	)

	use_pressed.connect(handle_use_custom_pressed.bind(_data))
	

func pressed_use_custom_button(tab_choosen):
	use_pressed.emit(tab_choosen)
	players_handler.custom_choices_tab_container.visible=false
	players_handler.use_custom_but_label_container.visible=false
	field.hide_all_gui_windows("use_custom")

func handle_use_custom_pressed(tab_choosen,net_data):
	var custom_id_to_skill = tab_choosen.get_meta("skill_info")

	var custom_id=tab_choosen.name
	var skill_to_use = custom_id_to_skill[custom_id]
	
	net_data.merge(
		{
			"custom_skill_to_use_info":skill_to_use,
			"custom_id":custom_id
		},true
	)
	
	rpc_id(1,"handle_network_message","",net_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var char_info = CharInfo.from_dictionary(net_data.get("current_char_info_dic"))
	var custom_skill_to_use = net_data.get("custom_skill_to_use_info")
	var custom_id = net_data.get("custom_id")

	print_debug("custom_skill_to_use="+str(custom_skill_to_use))
	match custom_skill_to_use["Type"]:
		Globals.CUSTOM_TYPES.PHANTASM:
			await players_handler.use_phantasm(custom_skill_to_use["Effect"])
			field.reduce_one_action_point(-1,'CUSTOM_TYPES.PHANTASM used')
		Globals.CUSTOM_TYPES.POTION_CREATING:
			var dict={custom_id:custom_skill_to_use}
			#dict.merge(skill_to_use)
			players_handler.add_item_to_char_info(char_info,dict,custom_id) #{"Name":custom_id,"Effect":skill_to_use["Effect"],"range":skill_to_use["range"]})
			field.reduce_one_action_point(0)
			#rpc("use_skill",skill_to_use["Effect"])
		Globals.CUSTOM_TYPES.BUFF_CHOOSING:
			var result = await players_handler.use_skill(custom_skill_to_use["Effect"])
			await field.sleep(0.1)
			#custom_choice_used.emit(result)
		Globals.CUSTOM_TYPES.POTION_USING:
			print("\n\npotion using")
			#var kletki_ids=field.get_kletki_ids_with_players_you_can_reach_in_steps(skill_to_use["range"])
			#{ "min_cost": { "Type": "Free", "value": 0 }, "Type": "potion creating", "Effect": [{ "Name": "Heal", "Power": 5 }], "range": 2 }
			var tmp = custom_skill_to_use["Effect"]
			for effect in tmp:
				var buf={"Buffs":effect,"Cast":"Single In Range","Cast Range":effect["Range"]}
				#var result = await use_skill(buf)
				print_debug("skill_to_use[\"Effect\"]="+str(custom_skill_to_use["Effect"]))
				await field.sleep(0.1)
				#custom_choice_used.emit(result)

func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
