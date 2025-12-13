extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	var attacker_char_info_dic=_data.get("attacker_char_info_dic",null)
	if attacker_char_info_dic==null:
		push_error("No attacker_char_info_dic in ",self.name, "state data=",_data)
		return
	var attacker_char_info=CharInfo.from_dictionary(attacker_char_info_dic)
	
	var defender_char_info_dic=_data.get("defender_char_info_dic",null)
	if defender_char_info_dic==null:
		push_error("No defender_char_info_dic in ",self.name, "state data=",_data)
		return
	var defender_char_info=CharInfo.from_dictionary(defender_char_info_dic)
	
	var attacker_dices=_data.get("attacker_dices",null)
	if attacker_dices==null:
		push_error("No attacker_dices in ",self.name, "state data=",_data)
		return
	
	var defender_can_parry=_data.get("defender_can_parry",null)
	if defender_can_parry==null:
		push_error("No defender_can_parry in ",self.name, "state data=",_data)
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
	
	field.you_were_attacked_label.text=tr("YOU_WERE_ATTACKER_WHAT_TO_DO_QUESTION").format(
		{
			"Attacker_name":attacker_char_info.get_node().name,
			"Attacker_main_dice":attacker_dices["main_dice"],
			"Attacker_crit_dice":attacker_dices["crit_dice"]
		}
	)
	
	
	
	
func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
