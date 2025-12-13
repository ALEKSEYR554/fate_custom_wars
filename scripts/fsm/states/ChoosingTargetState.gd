extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
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
	
		
func exit():
	field.make_action_button.disabled = false
	for child in field.make_action_button.get_children():
		#child.disabled=true
		child.set("disabled",false)
		pass
	
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
	pass
