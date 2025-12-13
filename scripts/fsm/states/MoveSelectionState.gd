extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	field.make_action_button.disabled = false
	field.end_turn_button.disabled = false
	field.move_button.disabled = true
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible=false
	
	field.current_action="move"
	
	var current_kletka=_data.get("Current Kletka",null)
	
	if current_kletka==null:
		push_error("no current kletka sent from server")
	
	var kletki_awailable=_data.get("Available Kletki",null)
	
	if kletki_awailable==null:
		push_error("no Available Kletki sent from server")
	
	
	field.choose_glowing_cletka_by_ids_array(kletki_awailable)
	
		
func exit():
	field.make_action_button.disabled = true
	field.end_turn_button.disabled = true
	field.move_button.disabled = false
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
	pass
