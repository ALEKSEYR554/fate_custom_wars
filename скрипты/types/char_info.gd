extends Resource
class_name CharInfo

var pu_id:String
#var node:Node2D 
var unit_id:int
var servant_name:String

func _init(_pu_id:String, _unit_id:int):
	pu_id = _pu_id
	unit_id = _unit_id
	#servant_name = _servant_name


func is_valid()->bool:
	return pu_id!="" and unit_id>=0# and node!=null

#func get_init_id()->int:
#	return node.get_meta("unit_id")

func get_node()->Node2D:
	return Globals.pu_id_player_info[pu_id]["units"][unit_id]

func get_uniq_id()->String:

	return get_node().get_meta("unit_unique_id")

func get_phantasm_charge_points()->int:
	return get_node().phantasm_charge

func get_servant_name()->String:

	
	return get_node().get_script().get_file().get_basename()