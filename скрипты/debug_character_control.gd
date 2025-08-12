extends Control
@onready var players_handler = $"../../players_handler"

const ranks = [
	"EX",
	"A+++", "A++", "A+", "A", "A-",
	"B+++", "B++", "B+", "B","B-",
	"C+++", "C++", "C+", "C","C-",
	"D+++", "D++", "D+", "D","D-",
	"E+++",  "E++", "E+", "E", "E-"
]
@onready var class_label_option_button = $PanelContainer/VBoxContainer/main_container/Stats_contaner/Class_hContaier6/Class_label_OptionButton

@onready var strength_label_option_button = $PanelContainer/VBoxContainer/main_container/Stats_contaner/Strenght_hContaier/Strength_label_OptionButton
@onready var endurance_label_option_button = $PanelContainer/VBoxContainer/main_container/Stats_contaner/Endurance_hContaier2/Endurance_label_OptionButton
@onready var agility_label_option_button = $PanelContainer/VBoxContainer/main_container/Stats_contaner/Agility_hContaier3/Agility_label_OptionButton
@onready var magic_attack_label_option_button = $PanelContainer/VBoxContainer/main_container/Stats_contaner/Mana_hContaier4/Magic_attack_label_OptionButton
@onready var luck_label_option_button = $PanelContainer/VBoxContainer/main_container/Stats_contaner/Luck_hContaier5/Luck_label_OptionButton

@onready var peer_id_to_name_label = $PanelContainer/VBoxContainer/main_container/Stats_contaner/peer_id_to_name_label
@onready var peer_id_option_button = $PanelContainer/VBoxContainer/main_container/Stats_contaner/HBoxContainer/Peer_id_OptionButton
@onready var magical_attack_check_box = $PanelContainer/VBoxContainer/main_container/Stats_contaner/Mana_hContaier4/Magical_attack_check_box


@onready var skills_raw_text_edit = $PanelContainer/VBoxContainer/main_container/Skills_raw_text_edit
@onready var erorr_label = $PanelContainer/VBoxContainer/erorr_label


@onready var hp_h_contaier_6 = $PanelContainer/VBoxContainer/main_container/Stats_contaner/HP_hContaier6
@onready var hp_label = $PanelContainer/VBoxContainer/main_container/Stats_contaner/HP_hContaier6/HP_label
@onready var hp_line_edit = $PanelContainer/VBoxContainer/main_container/Stats_contaner/HP_hContaier6/HP_LineEdit

@onready var use_skill_raw_edit = $PanelContainer/VBoxContainer/main_container/VBoxContainer/use_skill_raw_edit


@onready var dmg_label = $PanelContainer/VBoxContainer/main_container/VBoxContainer/Dmg_container/dmg_Label
@onready var dmg_refresh_button = $PanelContainer/VBoxContainer/main_container/VBoxContainer/Dmg_container/dmg_refresh_button



var old_text := ""

func get_stat_in_number(stat:String)->int:
	match stat.replace("+",""):
		"EX":
			return 6
		"A":
			return 5
		"B":
			return 4
		"C":
			return 3
		"D":
			return 2
		"E":
			return 1
		"F":
			return 1
		_:
			return 1

func get_magic(stat_rank:String,magical_powers:bool)->Dictionary:
	var out={"Rank":stat_rank,"Power":0,"Resistance":7}
	match stat_rank.replace("+",""):
		"EX":
			out["Power"]=15
			out["Resistance"]=7
		"A":
			out["Power"]=10
			out["Resistance"]=5
		"B":
			out["Power"]=8
			out["Resistance"]=4
		"C":
			out["Power"]=6
			out["Resistance"]=3
		"D":
			out["Power"]=4
			out["Resistance"]=2
		"E":
			out["Power"]=2
			out["Resistance"]=1
		"F":
			out["Power"]=1
			out["Resistance"]=1
		_:
			out["Power"]=1
			out["Resistance"]=1
	if not magical_powers:
		out["Power"]=0
	return out


func only_int_checker(text:String)->void:
	if text.is_empty() or text.is_valid_int():
		old_text = text
	else:
		hp_line_edit.text = old_text
# Called when the node enters the scene tree for the first time.
func _ready():
	hp_line_edit.text_changed.connect(only_int_checker)
	for rank in ranks:
		strength_label_option_button.add_item(rank)
		endurance_label_option_button.add_item(rank)
		agility_label_option_button.add_item(rank)
		magic_attack_label_option_button.add_item(rank)
		luck_label_option_button.add_item(rank)
	for servant_class in Globals.CLASS_NAMES:
		class_label_option_button.add_item(servant_class)
	
	for pu_id in Globals.pu_id_to_nickname.keys():
		peer_id_to_name_label.text+=str("Id=",pu_id," nick=",Globals.pu_id_to_nickname[pu_id],"\n")
	
	
	class_label_option_button.select(randi_range(0,Globals.CLASS_NAMES.size()-1))
	
	strength_label_option_button.select(randi_range(0,ranks.size()-1))
	endurance_label_option_button.select(randi_range(0,ranks.size()-1))
	agility_label_option_button.select(randi_range(0,ranks.size()-1))
	magic_attack_label_option_button.select(randi_range(0,ranks.size()-1))
	luck_label_option_button.select(randi_range(0,ranks.size()-1))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_buffs_array()->Array:
	var json = JSON.new()
	
	var skills_string=str('{"a":[',skills_raw_text_edit.text,']}')
	var skills_array:Array=[]
	var error = json.parse(skills_string)

	if error == OK:
		erorr_label.text=""
		skills_array = json.data["a"]
		if typeof(skills_array) == TYPE_ARRAY:
			print(skills_array) # Prints the array.
		else:
			print("Unexpected data")
	else:
		erorr_label.text=str("JSON Parse Error: ", json.get_error_message(), " in ", skills_raw_text_edit.text, " at line ", json.get_error_line())
		print("FUCK")
	return skills_array

func _on_refresh_button_pressed(choose:bool=false):
	if not choose:
		peer_id_to_name_label.text=""
		peer_id_option_button.clear()
		for pu_id in Globals.pu_id_to_nickname.keys():
			peer_id_to_name_label.text+=str("Id=",pu_id," nick=",Globals.pu_id_to_nickname[pu_id],"\n")
			peer_id_option_button.add_item(str(pu_id))
	if peer_id_option_button.get_selected()==-1:
		print('peer_id_option_button.get_selected()==-1')
		return
	var peer_id_text=peer_id_option_button.get_item_text(peer_id_option_button.get_selected())
	if not peer_id_text.is_empty():
		print("pu_id=",peer_id_text)
		if not peer_id_text in Globals.pu_id_to_nickname.keys():
			print('not pu_id_text.to_int() in Globals.pu_id_to_nickname.keys()')
			return
		var servant_node=Globals.pu_id_player_info[peer_id_text]["servant_node"]
		var stats:Dictionary={}

		var buffs_str=str(servant_node.buffs)
		skills_raw_text_edit.text=buffs_str.substr(1,buffs_str.length()-2)

		#stats.strength=ranks[strength_label_option_button.get_selected_id()]
		#stats.agility=ranks[agility_label_option_button.get_selected_id()]
		#stats.endurance=ranks[endurance_label_option_button.get_selected_id()]
		#stats.magic=ranks[magic_attack_label_option_button.get_selected_id()]
		#stats.luck=ranks[luck_label_option_button.get_selected_id()]
		#stats.servant_class=Globals.CLASS_NAMES[class_label_option_button.get_selected_id()]
		
		stats.strength=servant_node.strength
		stats.agility=servant_node.agility
		stats.endurance=servant_node.endurance
		stats.magic=servant_node.magic["Rank"]#=get_magic(stats.magic,magical_attack_check_box.toggle_mode)
		stats.luck=servant_node.luck
		stats.servant_class=servant_node.servant_class
		hp_line_edit.text=str(servant_node.hp)
		stats.hp=servant_node.hp

		#servant_node.buffs=get_buffs_array()
		magical_attack_check_box.button_pressed=servant_node.magic["Power"]>0

		print(stats)
		class_label_option_button.select(Globals.CLASS_NAMES.find(stats.servant_class))
	
		strength_label_option_button.select(ranks.find(stats.strength))
		endurance_label_option_button.select(ranks.find(stats.endurance))
		agility_label_option_button.select(ranks.find(stats.agility))
		magic_attack_label_option_button.select(ranks.find(stats.magic))
		luck_label_option_button.select(ranks.find(stats.luck))

		#servant_node.attack_power=get_stat_in_number(servant_node.strength)
	
		
	pass # Replace with function body.


func _on_apply_button_pressed():
	if peer_id_option_button.get_selected()==-1:
		print('pu_id_option_button.get_selected()==-1')
		return
	var peer_id_text=peer_id_option_button.get_item_text(peer_id_option_button.get_selected())
	if peer_id_text:
		print("peer_id=",peer_id_text)
		if not peer_id_text.to_int() in Globals.pu_id_to_nickname.keys():
			print('not peer_id_text.to_int() in Globals.pu_id_to_nickname.keys()')
			return
		var servant_node=Globals.pu_id_player_info[peer_id_text]["servant_node"]
		var stats:Dictionary={}

		#var buffs_str=str(skills_raw_text_edit.text)
		#skills_raw_text_edit.text=buffs_str.substr(1,buffs_str.length()-2)


		stats.strength=ranks[strength_label_option_button.get_selected_id()]
		stats.agility=ranks[agility_label_option_button.get_selected_id()]
		stats.endurance=ranks[endurance_label_option_button.get_selected_id()]
		stats.magic=ranks[magic_attack_label_option_button.get_selected_id()]
		stats.luck=ranks[luck_label_option_button.get_selected_id()]
		stats.servant_class=Globals.CLASS_NAMES[class_label_option_button.get_selected_id()]
		stats.hp=hp_line_edit.text.to_int()



		#servant_node.strength=stats.strength
		#servant_node.agility=stats.agility
		#servant_node.endurance=stats.endurance
		#servant_node.magic=get_magic(stats.magic,magical_attack_check_box.toggle_mode)
		#servant_node.luck=stats.luck
		#servant_node.servant_class=stats.servant_class
		#servant_node.buffs=get_buffs_array()
		rpc("set_pu_id_stats_and_buffs",peer_id_text,stats,get_buffs_array(),get_magic(stats.magic,magical_attack_check_box.toggle_mode))


	pass # Replace with function body.

@rpc("authority","call_local","reliable")
func set_pu_id_stats_and_buffs(pu_id:String,stats:Dictionary,buffs:Array,magic:Dictionary):
	var servant_node=Globals.pu_id_player_info[pu_id]["servant_node"]
	servant_node.strength=stats.strength
	servant_node.agility=stats.agility
	servant_node.endurance=stats.endurance
	servant_node.magic=magic
	servant_node.luck=stats.luck
	servant_node.servant_class=stats.servant_class
	servant_node.buffs=buffs
	servant_node.hp=stats.hp

func _on_magical_attack_check_box_toggled(toggled_on):
	print("e")
	pass # Replace with function body.


func _on_peer_id_option_button_item_selected(index):
	_on_refresh_button_pressed(true)
	pass # Replace with function body.


func _on_use_skill_button_pressed():
	var json = JSON.new()
	
	var skills_string=str('{"a":[',use_skill_raw_edit.text,']}')
	var skills_array:Array=[]
	var error = json.parse(skills_string)

	if error == OK:
		erorr_label.text=""
		skills_array = json.data["a"]
		if typeof(skills_array) == TYPE_ARRAY:
			#print(skills_array) # Prints the array.
			players_handler.use_skill(skills_array)
		else:
			print("Unexpected data")
	else:
		erorr_label.text=str("JSON Parse Error: ", json.get_error_message(), " in ", use_skill_raw_edit.text, " at line ", json.get_error_line())
		print("FUCK")
	pass # Replace with function body.


func _on_dmg_refresh_button_pressed():
	dmg_label.text=str("Ph:",players_handler.calculate_pu_id_attack_against_pu_id(Globals.self_pu_id,-1,"Physical"),
	" Mg:",players_handler.calculate_pu_id_attack_against_pu_id(Globals.self_pu_id,-1,"Magical"))
	pass # Replace with function body.
