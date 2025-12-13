extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	var kletka_id_selected=_data.get("kletka_id_selected",null)
	if kletka_id_selected==null:
		push_error("No kletka_id_selected in ",self.name, "state data=",_data)
		return
		
	var damage_type=_data.get("damage_type",null)
	if damage_type==null:
		push_error("No damage_type in ",self.name, "state data=",_data)
		return
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	field.end_turn_button.disabled = true
	field.make_action_button.disabled = true
	field.skill_info_show_button.disabled = true
	
	field.end_turn_button.disabled=true
	
	field.attack_player_on_kletka_id(
		current_char_info,
		kletka_id_selected,
		damage_type
	)


func exit():
	
	field.blinking_glow_button=true
	field.glow_cletki_node.visible = true
	field.end_turn_button.disabled = false
	field.make_action_button.disabled = false
	field.skill_info_show_button.disabled = false
