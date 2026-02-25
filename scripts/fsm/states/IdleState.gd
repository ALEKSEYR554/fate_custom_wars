extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering Wait State")
	
	#field.current_action="wait"
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
	field.type_of_damage_choose_buttons_box.visible=false
	
	if field.my_turn and not field.paralyzed:
		field.make_action_button.disabled = false
		field.end_turn_button.disabled = false
	else:
		field.make_action_button.disabled = true
		field.end_turn_button.disabled = true
		
func exit():
	field.make_action_button.disabled = true
	field.end_turn_button.disabled = true
	
	pass
