extends BattleState

#means that it is not your turn

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering Spectator State")
	
	field.current_action="wait"
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
	field.make_action_button.disabled = true
	field.end_turn_button.disabled = true
	
		
func exit():
	field.make_action_button.disabled = true
	field.end_turn_button.disabled = true

	pass
