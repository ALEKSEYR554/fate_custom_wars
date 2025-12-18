extends BattleState



func enter(_data:Dictionary={}):
	super.enter(_data)
	print("Entering ",self.name," State")
	
	var parry_count_max=_data.get("parry_count_max",null)
	if parry_count_max==null:
		push_error("No parry_count_max in ",self.name, " state data=",_data)
		return
	
	var current_parry_count=_data.get("current_parry_count",null)
	if current_parry_count==null:
		push_error("No current_parry_count in ",self.name, " state data=",_data)
		return
	
	
	
func exit():
	
	field.blinking_glow_button=false
	field.glow_cletki_node.visible = false
	
