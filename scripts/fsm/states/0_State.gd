extends BattleState

func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	var var_name=_data.get("var_name",null)
	if var_name==null:
		push_error("No var_name in ",self.name, "state data=",_data)
		return
	
	
func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
