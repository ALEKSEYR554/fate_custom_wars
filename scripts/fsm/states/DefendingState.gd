extends BattleState

signal option_choosen_signal(option:String)

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
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
	
	var attacker_dices=_data.get("attacker_dices",null)
	if attacker_dices==null:
		push_error("No attacker_dices in ",self.name, " state data=",_data)
		return
	
	var defender_can_parry=_data.get("defender_can_parry",null)
	if defender_can_parry==null:
		push_error("No defender_can_parry in ",self.name, " state data=",_data)
		return
	
	var defender_can_defence=_data.get("defender_can_defence",null)
	if defender_can_defence==null:
		push_error("No defender_can_defence in ",self.name, " state data=",_data)
		return
	
	var defender_can_evade=_data.get("defender_can_evade",null)
	if defender_can_evade==null:
		push_error("No defender_can_evade in ",self.name, " state data=",_data)
		return
	
	
	#checking if allie attacking us
	#region betrayal check
	var self_unit_hit=false
	
	if attacker_char_info.pu_id == Globals.self_pu_id:
		self_unit_hit = true
	
	if attacker_char_info in field.players_handler.get_allies() and not self_unit_hit:
		field.disable_every_button()
		var type=await field.choose_between_two(
			tr("TEAMS_ALLY_ATTACKED_YOU_BETRAYLE_QUESTION").format(
				{
					"Ally_nick":Globals.pu_id_player_info[attacker_char_info.pu_id]["nickname"]
				}),
			"TEAMS_ALLY_ATTACKED_YOU_BETRAYLE_QUESTION_AGREEMENT",
			"TEAMS_ALLY_ATTACKED_YOU_BETRAYLE_QUESTION_DISAGREEMENT"
		)
		field.disable_every_button(false)
		if type=="TEAMS_ALLY_ATTACKED_YOU_BETRAYLE_QUESTION_AGREEMENT":
			pass
			#TODO
			#players_handler.additional_enemies+=attacker_char_info.pu_id
	#endregion
	
	
	field.you_were_attacked_parry_option_button.disabled  = not defender_can_parry
	field.you_were_attacked_evade_option_button.disabled  = not defender_can_evade
	field.you_were_attacked_def_option_button.disabled    = not defender_can_defence
	
	
	
	field.you_were_attacked_label.text=tr("YOU_WERE_ATTACKER_WHAT_TO_DO_QUESTION").format(
		{
			"Attacker_name":attacker_char_info.get_node().name,
			"Attacker_main_dice":attacker_dices["main_dice"],
			"Attacker_crit_dice":attacker_dices["crit_dice"]
		}
	)
	
	field.you_were_attacked_parry_option_button.pressed.connect(on_parry_pressed)
	field.you_were_attacked_evade_option_button.pressed.connect(on_evade_pressed)
	field.you_were_attacked_def_option_button.pressed.connect(on_defence_pressed)
	field.you_were_attacked_phantasm_option_button.pressed.connect(on_phantasm_pressed)
	
	field.you_were_attacked_container.visible = true
	var option_choosen = await option_choosen_signal
	
	var parry_count_max = _data.get("parry_count_max")
	var current_parry_count = _data.get("current_parry_count",0)
	
	var attack_answer_data={
		"pu_id":Globals.self_pu_id,
		"parry_count_max":parry_count_max,
		"attacker_dices":attacker_dices
	}
	rpc_id(1,"handle_network_message",attack_answer_data)

@rpc("any_peer","call_local","reliable")
func handle_network_message(message: String, net_data: Dictionary):
	var pu_id = net_data.get("pu_id")
	var char_info:CharInfo = field.get_current_char_info_for_pu_id(pu_id)
	var parry_count_max = net_data.get("parry_count_max")
	var current_parry_count = net_data.get("current_parry_count",0)
	match message:
		"parry":
			if current_parry_count>=1:
				var conf_action_data={
					"char_info_dic":char_info.to_dictionary(),
					"confirm_action_action_text":"ARE_YOU_SURE_YOU_WANT_TO_ACTION_PARRY",
					"action_after_confirming_action":"parry",
					"parry_count_max":parry_count_max,
					"current_parry_count":current_parry_count,
					"self_parry_position":"attacker"
				}
				conf_action_data.merge(net_data)
				fsm.change_state_for_pu_ud(pu_id,"ConfirmAction",conf_action_data)
				return
			
				#fill_are_you_sure_screen(tr("ARE_YOU_SURE_YOU_WANT_TO_ACTION_PARRY"))
				#var are_you_sure_result=await are_you_sure_signal
				#if are_you_sure_result==tr("ARE_YOU_SURE_DISAGREEMENT"):
					#you_were_attacked_container.visible=true
					#return
				#
			var conf_action_data = {
					"char_info_dic":char_info.to_dictionary(),
					"text":"ARE_YOU_SURE_YOU_WANT_TO_ACTION_PARRY",
					
					"action_after_confirming_action":"parry",
					"parry_count_max":parry_count_max,
					"current_parry_count":current_parry_count,
					
					"action_after_dice_roll":"parry_rolleds",
					
				}
			conf_action_data.merge(net_data)
			fsm.change_state_for_pu_ud(pu_id,"DiceRoll",conf_action_data)
		"evade":
			#you_were_attacked_container.visible=false
			var conf_action_data={
					"char_info_dic":char_info.to_dictionary(),
					"confirm_action_action_text":"ARE_YOU_SURE_YOU_WANT_TO_ACTION_EVADE",
					"action_after_confirming_action":"evade",
					
					"action_after_dice_roll":"evade_rolleds",
				}
			conf_action_data.merge(net_data)
			
			fsm.change_state_for_pu_ud(pu_id,"ConfirmAction",conf_action_data)
		"defence":
			var conf_action_data={
					"char_info_dic":char_info.to_dictionary(),
					"confirm_action_action_text":"ARE_YOU_SURE_YOU_WANT_TO_ACTION_DEFENCE",
					"action_after_confirming_action":"defence",
					
					"action_after_dice_roll":"defence_rolleds",
				}
			conf_action_data.merge(net_data)
			
			fsm.change_state_for_pu_ud(pu_id,"ConfirmAction",conf_action_data)

func on_parry_pressed():
	option_choosen_signal.emit("parry")

func on_defence_pressed():
	option_choosen_signal.emit("defence")

func on_evade_pressed():
	option_choosen_signal.emit("evade")

func on_phantasm_pressed():
	option_choosen_signal.emit("phantasm")

func exit():
	if field.you_were_attacked_parry_option_button.pressed.is_connected(on_parry_pressed):
		field.you_were_attacked_parry_option_button.pressed.disconnect(on_parry_pressed)
	
	if field.you_were_attacked_evade_option_button.pressed.is_connected(on_evade_pressed):
		field.you_were_attacked_evade_option_button.pressed.disconnect(on_evade_pressed)
	
	if field.you_were_attacked_def_option_button.pressed.is_connected(on_defence_pressed):
		field.you_were_attacked_def_option_button.pressed.disconnect(on_defence_pressed)
	
	if field.you_were_attacked_phantasm_option_button.pressed.is_connected(on_phantasm_pressed):
		field.you_were_attacked_phantasm_option_button.pressed.disconnect(on_phantasm_pressed)
	
	field.you_were_attacked_container.visible=false
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
