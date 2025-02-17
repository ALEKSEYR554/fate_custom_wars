extends Node2D

var players_nodes=[]

var teams_by_peer_id=[]
var texture_size=200

var turns_counter=1
var current_player_peer_id_turn

signal next_turn_pass

var turns_order_by_peer_id=[]

@onready var field = $".."

@onready var servant_info_main_container = $"../GUI/Servant_info_main_container"
@onready var servant_info_picture_and_stats_container = $"../GUI/Servant_info_main_container/servant_info_picture_and_stats_container"
@onready var servant_info_picture = $"../GUI/Servant_info_main_container/servant_info_picture_and_stats_container/servant_info_picture"
@onready var servant_info_stats_textedit = $"../GUI/Servant_info_main_container/servant_info_picture_and_stats_container/servant_info_stats_textedit"
@onready var servant_info_skills_textedit = $"../GUI/Servant_info_main_container/servant_info_skills_textedit"

@onready var current_hp_container = $"../GUI/current_hp_container"
@onready var current_hp_value_label = $"../GUI/current_hp_container/current_hp_value_label"



@onready var players_info_buttons_container = $"../GUI/players_info_buttons_container"

# peer_id={"servant_name":"bunyan","servant_node":NODE,
#"Buffs":[["buff_name",duration_int]],"debuffs:[["debuff_name",duration_int]]"}
var peer_id_player_info={}

#peer_id={"total_kletki_moved":INT,"total_success_hit":INT,"kletki_moved_this_turn":INT,"attacked_this_move":INT,
#"total_crit_hit":INT,"total_damage_dealt":INT,"total_damage_taken":INT}
var peer_id_player_game_stat_info={}

var peer_id_to_nickname={}

var peer_id_to_command_spells_int={}

var peer_id_to_items_owned={}

var peer_id_to_np_points={}

var peer_id_to_inventory_array={}
var player_info_button_current_peed_id=-1

var servant_name_to_peer_id={}
@onready var host_buttons = $"../GUI/host_buttons"
@onready var get_selected_character_button = $"../GUI/character_selection_container/get_selected_character"
@onready var char_select = $"../GUI/character_selection_container/Char_select"

@onready var skill_info_tab_container = $"../GUI/Skill_info_tab_container"
@onready var first_skill_text_edit = $"../GUI/Skill_info_tab_container/First Skill"
@onready var second_skill_text_edit = $"../GUI/Skill_info_tab_container/Second Skill"
@onready var third_skill_text_edit = $"../GUI/Skill_info_tab_container/Third Skill"
@onready var class_skills_text_edit = $"../GUI/Skill_info_tab_container/Class Skills"


@onready var custom_choices_tab_container = $"../GUI/custom_choices_tab_container"
@onready var use_custom_but_label_container = $"../GUI/use_custom_but_label_container"
@onready var use_custom_label = $"../GUI/use_custom_but_label_container/use_custom_label"
@onready var use_custom_button = $"../GUI/use_custom_but_label_container/use_custom_button"


signal chosen_allie()
var choosen_allie_return_value

#Current users ready 0/?
@onready var current_players_ready_label = $"../GUI/character_selection_container/Current_players_ready"
var current_users_ready=0
func fuck_you():
	print("fuck you")

func _ready():
	Globals.self_peer_id=multiplayer.get_unique_id()
	rpc("update_ready_users_count",current_users_ready,Globals.connected_players.size())
	#print(str(dir.get_directories()))
	return
	
	pass # Replace with function body.

@rpc("call_local","authority","reliable")
func load_servant(peer_id):
	var folderr
	if OS.has_feature("editor"):
		folderr="res"
	else:
		folderr="user"
	
	var servant_name=peer_id_player_info[peer_id]["servant_name"]
	servant_name_to_peer_id[servant_name]=peer_id
	var dir = DirAccess.open(folderr+"://servants/")
	#for i in dir.get_directories():#getting custom characters
	var player=Node2D.new()
	var player_textureRect = TextureRect.new()
	player.set_script(load(folderr+"://servants/"+str(servant_name)+"/"+str(servant_name)+".gd"))
	if ResourceLoader.exists(folderr+"://servants/"+str(servant_name)+"/sprite.png"):
		var img = Image.new()
		img.load(folderr+"://servants/"+str(servant_name)+"/sprite.png")
		player_textureRect.texture=ImageTexture.create_from_image(img)
	else:
		var img = Image.new()
		img.load(folderr+"://servants/"+str(servant_name)+"/sprite.webp")
		player_textureRect.texture=ImageTexture.create_from_image(img)
	var sizes=player_textureRect.texture.get_size()
	#texture.flat=true
	#texture.anchors_preset=
	#texture.button_down.connect(player_info_button_pressed.bind(peer_id))
	player_textureRect.position=Vector2(-(texture_size)/2,-texture_size)
	player_textureRect.scale=Vector2(texture_size/sizes.x,texture_size/sizes.y)
	print("sizes="+str(sizes))
	print("scale="+str(player.scale))
	#player.add_child(player,true)
	player.name=servant_name
	player.add_child(player_textureRect)
	
	if peer_id==Globals.self_peer_id:
		Globals.self_servant_node=player
	peer_id_player_info[peer_id]["servant_node"]=player
	
	self.add_child(player,true)
	#print(rand_kletka)
	#print(cell_positions[rand_kletka])
	#jopa.position = cord
	#set_random_teams()
	#return player
	
func get_selected_servant():
	var servant_name=char_select.get_current_servant()
	get_selected_character_button.disabled=true
	print(servant_name)
	#Globals.self_servant_node=load_servant_by_name()
	rpc("refresh_something_when_servant_selected",Globals.self_peer_id,Globals.nickname)
	rpc_id(1,"check_if_players_ready",multiplayer.get_unique_id(),servant_name)

@rpc("call_local","any_peer","reliable")
func refresh_something_when_servant_selected(peer_id,nickk):
	peer_id_to_nickname[peer_id]=nickk

@rpc("any_peer","call_local")
func check_if_players_ready(peer_id,servant_name):
	peer_id_player_info[peer_id]={"servant_name":servant_name,"servant_node":null}
	print("peer_id_player_info="+str(peer_id_player_info))
	current_users_ready+=1
	rpc("update_ready_users_count",current_users_ready,Globals.connected_players.size())
	print("Globals.connected_players="+str(Globals.connected_players)+"Globals.connected_players.size()="+str(Globals.connected_players.size()))
	print("=current_users_ready="+str(current_users_ready))
	if Globals.connected_players.size()==current_users_ready:
		if Globals.host_or_user=="host":
			host_buttons.visible=true
	
@rpc("authority","call_local","reliable")
func sync_peer_id_player_info(peer_id_player_info_temp):
	peer_id_player_info=peer_id_player_info_temp

@rpc("authority","call_local","reliable")
func set_teams_and_turns_order(shiffled_players_array,turn_order):
	var len=shiffled_players_array.size()/2
	teams_by_peer_id=[shiffled_players_array.slice(0,len),shiffled_players_array.slice(len)]
	print("teams="+str(teams_by_peer_id))
	
	turns_order_by_peer_id=turn_order
	for peer_id in turns_order_by_peer_id:
		var servant_button=Button.new()
		servant_button.text=peer_id_player_info[peer_id]["servant_name"]
		servant_button.button_down.connect(player_info_button_pressed.bind(peer_id))
		players_info_buttons_container.add_child(servant_button,true)
	

@rpc("authority","call_local","reliable")
func initialise_start_variables(peer_id_list):
	field.add_all_additional_nodes()
	for peer_id in peer_id_list:
		peer_id_to_items_owned[peer_id]=[]
		peer_id_to_items_owned[peer_id]=[]
		peer_id_to_inventory_array[peer_id]=[]
		peer_id_to_np_points[peer_id]=0
		peer_id_to_command_spells_int[peer_id]=3
		peer_id_player_game_stat_info[peer_id]={"total_kletki_moved":0,"total_success_hit":0,
	"kletki_moved_this_turn":0,"attacked_this_move":0,
	"total_crit_hit":0,"total_damage_dealt":0,"total_damage_taken":0}
	pass


func player_info_button_pressed(peer_id):
	field.hide_all_gui_windows("servant_info_main_container")
	print("player_info_button_pressed="+str(peer_id))
	servant_info_from_peer_id(peer_id)
	return
	if peer_id==player_info_button_current_peed_id and servant_info_main_container.visible:
		servant_info_main_container.visible= false
	else:
		player_info_button_current_peed_id=peer_id
		servant_info_from_peer_id(peer_id)

func servant_button_pressed(servant_name_info_to_get):
	print("servant_name_info_to_get:",servant_name_info_to_get)
	
	
func start():
	#выдаем каждому игроку свой NODE слуги
	rpc("sync_peer_id_player_info",peer_id_player_info)
	var temp_pl=peer_id_player_info.keys()
	temp_pl.shuffle()
	var sh1=temp_pl
	temp_pl.shuffle()
	var sh2=temp_pl
	print("temp_pl+"+str(temp_pl))
	
	rpc("set_teams_and_turns_order",sh1,sh2)
	for peer_id in peer_id_player_info.keys():
		#var node_to_add=load_servant_by_name(peer_id_player_info[peer_id]["servant_name"])
		rpc("load_servant",peer_id)
		#peer_id_player_info[peer_id]["servant_node"]=node_to_add
		#add_child(node_to_add,true)
		#print(node_to_add)
		#rpc_id(peer_id,"set_player_node",inst_to_dict(node_to_add))
		print("peer_id_player_info="+str(peer_id_player_info))
	#первоначальное выставление слуг на поле
	rpc("initialise_start_variables",turns_order_by_peer_id)
	for peer_id in turns_order_by_peer_id: 
		current_player_peer_id_turn=peer_id
		rpc_id(peer_id,"inital_spawn_of_player_forwarder")
		await next_turn_pass
		print(peer_id)
	turns_loop()
	

func turns_loop():
	print("turns_loop started")
	while true:
		turns_counter+=1
		for peer_id in turns_order_by_peer_id:
			current_player_peer_id_turn=peer_id
			field.rpc_id(peer_id,"start_turn")
			await next_turn_pass
		rpc("turn_update",turns_counter)

@rpc("any_peer","call_local","reliable")
func turn_update(turn):
	$"../GUI/turns_label".text=str("Turn: ",turn)

@rpc("any_peer","call_local","reliable")
func pass_next_turn(peer_id):
	field.my_turn=false
	if peer_id==current_player_peer_id_turn:
		next_turn_pass.emit()

@rpc("authority","call_local","reliable")
func inital_spawn_of_player_forwarder():
	print()
	field.inital_spawn_of_player()

@rpc("any_peer","call_local")
func update_ready_users_count(current_users_ready,all):
	current_players_ready_label.text="Current users ready"+str(current_users_ready)+"/"+str(all)


#func end_turn():
#	print("turn ended")
#	for peer_id in peer_id_player_info.keys():
#		print(peer_id_player_info[peer_id]["servant_node"].hp)
#		
#	print("teams array="+str(teams_by_peer_id))
#	trigger_buffs_on(Globals.self_peer_id,"turn_ended")
#	rpc_id(1,"pass_next_turn",Globals.self_peer_id)
#	pass




func choose_allie():
	var ketki_with_allies=[]
	for peer_id in get_allies():
		ketki_with_allies.append(field.peer_id_to_kletka_number[peer_id])
	field.choose_glowing_cletka_by_ids_array(ketki_with_allies)
	field.current_action="choose_allie"
	await chosen_allie
	return [servant_name_to_peer_id[choosen_allie_return_value.name]]
	pass

func show_skill_info_tab(peer_id=Globals.self_peer_id):
	print("=====================")
	var servant_nod=peer_id_player_info[peer_id]["servant_node"].skills
	var can_use_skill=true
	
	
	#print(servant_nod)
	first_skill_text_edit.text=servant_nod["First Skill"]["Description"]
	second_skill_text_edit.text=servant_nod["Second Skill"]["Description"]
	third_skill_text_edit.text=servant_nod["Third Skill"]["Description"]
	#print("third_skill_text_edit.text="+str(third_skill_text_edit.text))
	var cct=1
	for children in class_skills_text_edit.get_children():
		class_skills_text_edit.remove_child(children)
		children.queue_free() 
	#var class_skill_count=1
	for class_skill_count in range(1,10):
		var class_skill_name="Class Skill "+str(class_skill_count)
		if !servant_nod.has(class_skill_name):
			break
		var skill_info=servant_nod[class_skill_name]
		#for skill_info in servant_nod.slice(3):
		
		if skill_info["Type"]=="Weapon Change":
			#TODO create custom TabBar class for this shit
			#for description of weapon change
			var tab_cont=TabContainer.new()
			tab_cont.name="Weapon change"
			tab_cont.tab_alignment=TabBar.ALIGNMENT_CENTER
			
			
			for weapon in peer_id_player_info[peer_id]["servant_node"].skills[class_skill_name]["weapons"]:
				var t_edit_new=TextEdit.new()
				t_edit_new.editable=false
				t_edit_new.name=weapon
				t_edit_new.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
				t_edit_new.text=skill_info["weapons"][weapon]["Description"]
				tab_cont.add_child(t_edit_new)
			class_skills_text_edit.add_child(tab_cont)
		else:
			var t_edit=TextEdit.new()
			t_edit.editable=false
			t_edit.name="Class skill "+str(cct)
			t_edit.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
			t_edit.text=skill_info["Description"]
			class_skills_text_edit.add_child(t_edit)
		cct+=1
	pass

func servant_info_from_peer_id(peer_id):
	var info=peer_id_player_info[peer_id]["servant_node"]
	#servant_info_main_container.visible= true#!servant_info_main_container.visible
	servant_info_stats_textedit.text='''Name:%s
HP:%s
Class:%s
Ideology:%s
Agility:%s
Endurance:%s
Luck:%s
Magic:%s
	'''%[info.name,info.hp,info.servant_class,info.ideology,info.agility,info.endurance,info.luck,info.magic]
	

func get_enemies_teams():
	var all_enemies_peer_id=[]
	for team in teams_by_peer_id:
		for member in team:
			if Globals.self_peer_id!=member:
				all_enemies_peer_id+=team
	return all_enemies_peer_id
	pass


var custom_id_to_skill={}

func fill_custom_thing(custom_items_dict,type=""):
	print("fill_custom_thing")
	custom_id_to_skill={}
	for children in custom_choices_tab_container.get_children():
		custom_choices_tab_container.remove_child(children)
		children.queue_free() 
	
	#for custom_description in custom_desctription_array:
	
	#print(str("custom_desctription_array=",custom_desctription_array))
	#print(str("custom_buffs_array=",custom_buffs_array))
	
	for custom_item_name in custom_items_dict:
		var custom_item=custom_items_dict[custom_item_name]
		var current_buff_effect
		
		var tt_edit=TextEdit.new()
		tt_edit.editable=false
		tt_edit.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
		tt_edit.name=custom_item_name
		tt_edit.text=custom_item["Description"]
		custom_choices_tab_container.add_child(tt_edit,true)
		var cost={"Type":"NP","value":6}
		
		
		print("custom_items_dict="+str(custom_items_dict))
		print("type="+str(type))
		match type:
			"phantasm":
				current_buff_effect=custom_item["Overcharges"]
				cost={"Type":"NP","value":custom_item["Overcharges"]["Default"]["Cost"]}
			"potion creating":
				cost={"Type":"Free","value":0}
			"potion using":
				cost={"Type":"Free","value":0}
				
		print("ff")
		custom_id_to_skill[custom_item_name]={"min_cost":cost,
		"Type":type,"Effect":current_buff_effect,"Description":custom_item["Description"]}
		print(str("custom_id_to_skill=",custom_id_to_skill))
	pass


func _on_custom_choices_tab_container_tab_changed(tab):
	#return
	#JUST IN CASE
	if custom_id_to_skill=={}: return
	use_custom_button.disabled=false
	
	var costt=custom_id_to_skill[custom_choices_tab_container.get_tab_control(tab).name]["min_cost"]
	match costt["Type"]:
		"NP":
			use_custom_label.text="Cost: "+str(costt["value"]," ",costt["Type"])
			if Globals.self_servant_node.phantasm_charge<costt["value"]:
				use_custom_button.disabled=true
	

func _on_use_custom_button_pressed():
	#print(custom_id_to_skill[custom_choices_tab_container.current_tab])
	var custom_id=custom_choices_tab_container.get_current_tab_control().name
	
	
	print("custom_id_to_skill[custom_id]="+str(custom_id_to_skill))
	match custom_id_to_skill[custom_id]["Type"]:
		"phantasm":
			use_phantasm(custom_id_to_skill[custom_id]["Effect"])
			field.reduce_one_action_point()
		"potion creating":
			var dict={custom_id:custom_id_to_skill[custom_id]}
			#dict.merge(custom_id_to_skill[custom_id])
			rpc("add_item_to_peer_id",Globals.self_peer_id,dict) #{"Name":custom_id,"Effect":custom_id_to_skill[custom_id]["Effect"],"range":custom_id_to_skill[custom_id]["range"]})
			field.reduce_one_action_point(0)
			#rpc("use_skill",custom_id_to_skill[custom_id]["Effect"])
		"potion using":
			print("\n\npotion using")
			#var kletki_ids=field.get_kletki_ids_with_enemies_you_can_reach_in_steps(custom_id_to_skill[custom_id]["range"])
			#{ "min_cost": { "Type": "Free", "value": 0 }, "Type": "potion creating", "Effect": [{ "Name": "Heal", "Power": 5 }], "range": 2 }
			var tmp=custom_id_to_skill[custom_id]["Effect"]
			var buf={"Buffs":tmp["Effect"],"Cast":["Single In Range",tmp["range"]]}
			use_skill(buf)
			print("custom_id_to_skill[custom_id][\"Effect\"]="+str(custom_id_to_skill[custom_id]["Effect"]))
	custom_choices_tab_container.visible=false
	use_custom_but_label_container.visible=false
	

@rpc("any_peer","call_local","reliable")
func add_item_to_peer_id(peer_id,item):
	peer_id_to_items_owned[peer_id].append(item)

func _on_phantasm_pressed():
	use_custom_button.disabled=false
	use_custom_label.visible=false
	if Globals.self_servant_node.phantasm_charge<6:
		use_custom_label.text="COST:6"
		
		use_custom_button.disabled=true
		pass
	
	fill_custom_thing(Globals.self_servant_node.phantasms,"phantasm")
	#for phantasm_name in Globals.self_servant_node.phantasms_info_array:
		#var tt_edit=TextEdit.new()
		#tt_edit.editable=false
		#tt_edit.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
		#tt_edit.name=phantasm_name["Name"]
		#tt_edit.text=phantasm_name["Text"]
		#custom_choices_tab_container.add_child(tt_edit,true)
	field.hide_all_gui_windows("use_custom")
	#field.are_you_sure_main_container.visible=true
	#await field.are_you_sure_signal
	#if field.are_you_sure_result=="no":
	#	return
	#Globals.self_servant_node.phantasm()
	pass # Replace with function body.

func use_phantasm(phantasm_info):
	#custom_choices_tab_container
	#[{ "Name": "Unreturning Formation", "Default": { "Cost": 6, "Attack Type": "Buff Granting", "Range": 0, "Damage": 0, "Effect": [{ "Buffs": [{ "Name": "Np-", "Duration": 3, "Power": 1 }, { "Name": "Def -x2", "Duration": 3, "Power": 1 }], "Cast": "All enemies" }, { "Buffs": [{ "Name": "Roll dice for effect", "Duration": 3, "Power": 1 }], "Cast": "All enemies" }] }, "Overcharge": { "Cost": 12, "Attack Type": "Buff Granting", "Range": 0, "Damage": 0, "Effect": [{ "Buffs": [{ "Name": "Np-", "Duration": 3, "Power": 1 }, { "Name": "Def -x2", "Duration": 3, "Power": 1 }], "Cast": "All enemies" }, { "Buffs": [{ "Name": "Roll dice for effect", "Duration": 3, "Power": 1 }], "Cast": "All enemies" }] } }]
	#print(str("phantasm_info=",phantasm_info))
	
	#"Rongominiad":{"Default":{"Cost":6,"Attack Type":"Line","Range":5,"Damage":5,"ignore":["Defence","defensive_buffs"],
	#"Effect Before Attack":1,"effect_on_success_attack":1,
	#"effect_after_attack":[{"Buffs":[{"Name":"Np-","Duration":3,"Power":1},{"Name":"Def -x2","Duration":3,"Power":1}],"Cast":"All enemies"},{"Buffs":[{"Name":"Roll dice for effect","Duration":3,"Power":1}],"Cast":"All enemies"}]},}
	var overcharge_can_be_used=""
	for overcharge in phantasm_info:#just bad info formation
		if overcharge=="Name":
			continue
		#checking maximum available overcharge that can be used right now
		if Globals.self_servant_node.phantasm_charge>=phantasm_info[overcharge]["Cost"]:
			overcharge_can_be_used=overcharge
			
			
	print(str("using overchage=",overcharge_can_be_used))
	var overcharge_use=phantasm_info[overcharge_can_be_used]
	
	"""
	for skill_info_hash in overcharge_use["effect_after_attack"]:
		var cast=skill_info_hash["Cast"]
		var range=0
		if typeof(cast)==TYPE_ARRAY:
			range=cast[1]
			cast=cast[0]
		var skill_info_array=skill_info_hash["Buffs"]
		
		if typeof(skill_info_array)==TYPE_DICTIONARY:
			skill_info_array=[skill_info_array]
		match cast.to_lower():
			"Phantasm Attacked"
	"""
	
	var attacked_by_phantasm
	
	if overcharge_use.has("Effect Before Attack"):
		await use_skill(overcharge_use["Effect Before Attack"])
	
	match overcharge_use["Attack Type"]:
		"Buff Granting":
			await use_skill(overcharge_use["Effect"])
		"Line":
			attacked_by_phantasm=await field.line_attack_phantasm(overcharge_use)
		"Single In Range":
			attacked_by_phantasm=await phantasm_in_range(overcharge_use,"Single")
		"All Enemies In Range":
			attacked_by_phantasm=await phantasm_in_range(overcharge_use,"All enemies")
		"All Field Enemies":
			pass
	
	if overcharge_use.has("effect_after_attack"):
		await use_skill(overcharge_use["effect_after_attack"],attacked_by_phantasm)
	
	#for effect in 
	
	pass

func phantasm_in_range(phantasm_config,type="Single"):
	var range=phantasm_config["range"]
	
	var kletki_to_attack_array=[]
	var enemies_array=get_enemies_teams()
	var tmp
	var attacked_enemies=[]
	match type:
		"Single":
			tmp=await choose_single_in_range(range)
		"All enemies":
			tmp=await get_all_enemies_in_range(range)
	for peer_id in tmp:
		kletki_to_attack_array+=field.peer_id_to_kletka_number[peer_id]
	await field.await_dice_roll()
	await field.hide_dice_rolls_with_timeout(1)
	for kletka in kletki_to_attack_array:
		var etmp=await field.attack_player_on_kletka_id(kletka,"Phantasm",phantasm_config)
		attacked_enemies.append(etmp)
		if field.attack_responce_string!="evaded" or field.attack_responce_string!="parried":
			use_skill(phantasm_config["effect_on_success_attack"])
	
	return attacked_enemies


func _on_free_phantasm_pressed():
	#peer_id_player_info[Globals.self_peer_id]["servant_node"].phantasm_charge+=6
	#field.disable_every_button()
	rpc("change_phantasm_charge_on_peer_id",Globals.self_peer_id,6)
	pass

@rpc("any_peer","call_local","reliable")
func change_phantasm_charge_on_peer_id(peer_id,amount):
	var cur_charge=peer_id_player_info[peer_id]["servant_node"].phantasm_charge
	if cur_charge+amount>=12:
		peer_id_player_info[peer_id]["servant_node"].phantasm_charge=12
	else:
		peer_id_player_info[peer_id]["servant_node"].phantasm_charge+=amount
	if peer_id==Globals.self_peer_id:
		$"../GUI/action/np_points_number_label".text=str(peer_id_player_info[peer_id]["servant_node"].phantasm_charge)

func get_allies():
	for team in teams_by_peer_id:
		for member in team:
			if Globals.self_peer_id==member:
				return team
	pass
	#cast self,allies, 
	

func get_all_peer_ids():
	var output=[]
	for team in teams_by_peer_id:
		for member in team:
			output.append(member)
	return output

func choose_single_in_range(range):
	var ketki_array=[]
	for peer_id in field.get_kletki_ids_with_enemies_you_can_reach_in_steps(range):
		ketki_array.append(field.peer_id_to_kletka_number[peer_id])
	ketki_array.append(field.current_kletka)
	field.choose_glowing_cletka_by_ids_array(ketki_array)
	field.current_action="choose_allie"
	await chosen_allie
	return [servant_name_to_peer_id[choosen_allie_return_value.name]]

func get_everyone_in_range(range):
	var ketki_array=[]
	for peer_id in field.get_kletki_ids_with_enemies_you_can_reach_in_steps(range):
		ketki_array.append(field.peer_id_to_kletka_number[peer_id])
	return [servant_name_to_peer_id[choosen_allie_return_value.name]]

func get_all_enemies_in_range(range):
	var enemies=get_enemies_teams()
	var out=[]
	for peer_id in get_everyone_in_range(range):
		if peer_id in enemies:
			out+=peer_id
	return out

func use_skill(skill_info_dictionary,custom_cast=null):
	#trait_name is used if "Damange 2х against trait"
	#String
	if typeof(skill_info_dictionary)==TYPE_DICTIONARY:
		skill_info_dictionary=[skill_info_dictionary]
	print(str("using skills=",skill_info_dictionary))
	for skill_info_hash in skill_info_dictionary:
		var cast=skill_info_hash["Cast"]
		var range=0
		if typeof(cast)==TYPE_ARRAY:
			range=cast[1]
			cast=cast[0]
		var skill_info_array=skill_info_hash["Buffs"]
		
		if typeof(skill_info_array)==TYPE_DICTIONARY:
			skill_info_array=[skill_info_array]
		match cast.to_lower():
			"all allies":
				cast=get_allies()
			"all allies except self":
				cast=get_allies().erase(Globals.self_peer_id)
			"self":
				cast=[Globals.self_peer_id]
			"all enemies":
				cast=get_enemies_teams()
			"single allie":
				cast=await choose_allie()
			"everyone":
				cast=get_all_peer_ids()
			"single in range":
				cast=await choose_single_in_range(range)
			"all enemies in range":
				cast=get_all_enemies_in_range(range)
			"Phantasm Attacked":
				if custom_cast!=null:
					cast=custom_cast
				else:
					cast=[Globals.self_peer_id]
		#casts always array even if one
		if cast==[]:
			continue
		for single_skill_info in skill_info_array:
			print("single_skill_info="+str(single_skill_info))
			match single_skill_info["Name"]:
				"Damage x2 against trait":
					rpc("add_buff_against_trait",cast,single_skill_info)
				"Potion creation":
					create_potion(single_skill_info["Potions"])
				"NP gauge":
					pass
				"Field Creation":
					field.capture_field_kletki(single_skill_info["Amount"],single_skill_info["Config"])
				"Roll dice for effect":
					roll_dice_for_result(single_skill_info,cast)
				_:#default/else
					rpc("add_buff",cast,single_skill_info)

func create_potion(potions_dict):
	"""[{"Name":"Heal Potion",
			 "Range":2,
			 "Buff":[
				{"Name":"Heal",
					"Duration":3,
					"Power":5}
				]
			},
			{"Name":"Posion potion",
			"Range":2,
			"Buff":[
				{"Name":"Posion",
					"Duration":3,
					"Power":1}
				]
			}]"""
			
	"""{
	"Posion":"(Яд: Накладывает на одного слугу в радиусе двух клеток состояние отравления и понижает здоровье на 1 очко каждый ход на протяжении трёх ходов.)",
	"Heal Potion":"(Зелье лечения: Восполняет 5 очков здоровья, а также снимает все дебаффы себе или другому слуге в радиусе двух клеток)"}
	}"""
	
	
	fill_custom_thing(potions_dict,"potion creating")
	
	field.hide_all_gui_windows("use_custom")
	
	pass

#@rpc("any_peer","reliable","call_local")
func reduce_all_cooldowns(peer_id,type="start turn"):
	match type:
		"start turn":
			rpc("reduce_buffs_cooldowns",peer_id,type)
			rpc("reduce_skills_cooldowns",peer_id,type)
		"end turn":
			rpc("reduce_buffs_cooldowns",peer_id,type)

@rpc("any_peer","reliable","call_local")
func reduce_buffs_cooldowns(peer_id,type="start turn"):
	print("reduce_buffs_cooldowns\n\n")
	var buffs=peer_id_player_info[peer_id]["servant_node"].buffs
	print("buffs="+str(buffs))
	var index_list_to_remove=[]
	for i in range(buffs.size()):
		print("i="+str(i)+" "+str(buffs[i]))
		if str(buffs[i]["Duration"]).is_valid_float():
			if buffs[i]["Duration"]-1<=0:
				index_list_to_remove.append(i)
			else:
				peer_id_player_info[peer_id]["servant_node"].buffs[i]["Duration"]-=1
			pass
	for i in index_list_to_remove:
		peer_id_player_info[peer_id]["servant_node"].buffs.pop_at(i)
	
@rpc("any_peer","reliable","call_local")
func reduce_skills_cooldowns(peer_id,type="start turn"):
	for i in range(peer_id_player_info[peer_id]["servant_node"].skill_cooldowns.size()):
		peer_id_player_info[peer_id]["servant_node"].skill_cooldowns[i]-=1
		if peer_id_player_info[peer_id]["servant_node"].skill_cooldowns[i]<=0:
			peer_id_player_info[peer_id]["servant_node"].skill_cooldowns[i]=0


@rpc("any_peer","reliable","call_local")
func reduce_custom_param(peer_id,buff_id,param):
	if peer_id_player_info[peer_id]["servant_node"].buffs[buff_id][param]-1<=0:
		peer_id_player_info[peer_id]["servant_node"].buffs.pop_at(buff_id)
	else:
		peer_id_player_info[peer_id]["servant_node"].buffs[buff_id][param]-=1





func trigger_buffs_on(peer_id,trigger):
	var buffs=peer_id_player_info[peer_id]["servant_node"].buffs
	var i=0
	for buff in buffs:
		if buff.has("Trigger"):
			if buff["Trigger"]==trigger:
				match buff["Effect On Trigger"]:
					"owner takes damage by power":
						rpc("take_damage_to_peer_id",peer_id,buff["Power"])
					"pull enemies on attack":
						field.pull_enemy(field.attacking_peer_id)
						
		match buff["Name"]:
			"Invincibility":
				if buff.has("hit times"):
					rpc("reduce_custom_param",peer_id,i,"hit times")
					return
		
		i+=1

	
	var calculata="""just in case to variable
	casted=3
	
	cur_turn=4
	
	every 2 turns
	
	4-3=1 %2!=0
	5-3=2%2==0
	
	casted=1
	
	cur_turn=4
	
	every 4 turns
	
	4-1=3 %3!=0
	5-1=4%3==0
	
	"""
	if trigger=="turn_ended":
		var cu_klet_config=field.kletka_preference[field.current_kletka]
		#{ "Owner": 1, "Np Up Every N Turn": 1,"turn_casted":1 , "Additional": <null> }
		#print("type="+str(typeof(cu_klet_config)))
		if typeof(cu_klet_config)==4:#if string
			return
		
		
		print("\n\ncu_klet_config="+str(cu_klet_config))
		if cu_klet_config["Owner"]==peer_id:
			print(str("cu_klet_config[owner]=",cu_klet_config["Owner"]))
			if cu_klet_config.has("Np Up Every N Turn"):
				print(str("cal=",turns_counter,"-",cu_klet_config["turn_casted"],"%",cu_klet_config["Np Up Every N Turn"],"=",(turns_counter-cu_klet_config["turn_casted"])%cu_klet_config["Np Up Every N Turn"]))
				if (turns_counter-cu_klet_config["turn_casted"])%cu_klet_config["Np Up Every N Turn"]==0:
					
					print("TRRRR")
					rpc("change_phantasm_charge_on_peer_id",peer_id,1)


@rpc("any_peer","reliable","call_local")
func roll_dice_for_result(skill_info,cast):
	await field.await_dice_roll()
	var dice_result=field.dice_roll_result_list
	var is_casted=null
	field.systemlog_message(str(Globals.nickname," thowing to decide bad status"))
	for peer_id in cast:
		is_casted=null
		while true:
			field.rpc_id(peer_id,"receice_dice_roll_results",dice_result)
			field.rpc_id(peer_id,"set_action_status",Globals.self_peer_id,"roll_dice_for_result")
			await field.attack_response
			match field.attack_responce_string:
				"Evaded bad status":
					is_casted=false
				"Even dice rolls, reroll for status":
					pass
				"Getting bad status":
					for single_skill in skill_info["Buff To Add"]:#shit
						rpc("add_buff",peer_id,single_skill)
					is_casted=true
			if is_casted!=null:
				break
		#field._on_dices_toggle_button_pressed()
	pass

@rpc("any_peer","reliable","call_local")
func add_buff_against_trait(cast_array,skill_info):
	#TODO
	var skill_name=skill_info["Name"]
	var duration=skill_info["trait"]
	var power=skill_info["Power"]
	var trait_name=skill_info["trait"]
	for who_to_cast_peer_id in cast_array:
		match skill_name:
			"Attack up":
				peer_id_player_info[who_to_cast_peer_id]["servant_node"].buffs+=["atk+",duration,power]

@rpc("any_peer","reliable","call_local")
func add_buff(cast_array,skill_info):
	if typeof(cast_array)!=TYPE_ARRAY:
		cast_array=[cast_array]
	for who_to_cast_peer_id in cast_array:
		match skill_info["Name"]:
			"Madness Enhancement":
				peer_id_player_info[who_to_cast_peer_id]["servant_node"].buffs=[]
				peer_id_player_info[who_to_cast_peer_id]["servant_node"].buffs=[
					{"Name":"Attack x2",
					"Duration":3,
					"Power":1},
					{"Name":"skill seal",
					"Duration":3}
					]
			"NP Gauge":
				charge_np_to_peer_id_by_number(who_to_cast_peer_id,skill_info["Power"])
			"Heal":
				heal_peer_id(who_to_cast_peer_id,skill_info["Power"])
			"Invincibility":#if power==0 then all turns else for N hits
				peer_id_player_info[who_to_cast_peer_id]["servant_node"].buffs.append(skill_info)
			_:#else
				peer_id_player_info[who_to_cast_peer_id]["servant_node"].buffs.append(skill_info)
	pass

@rpc("any_peer","reliable","call_local")
func remove_buff(cast_array,skill_name,remove_passive=false):
	for who_to_remove_buff_peer_id in cast_array:
		var i=0
		for buff in peer_id_player_info[who_to_remove_buff_peer_id]["servant_node"].buffs:
			if buff["Name"]==skill_name:
				if buff["Duration"]=="Passive":
					if remove_passive:
						peer_id_player_info[who_to_remove_buff_peer_id]["servant_node"].buffs.pop_at(i)
				else:
					peer_id_player_info[who_to_remove_buff_peer_id]["servant_node"].buffs.pop_at(i)
			i+=1

func heal_peer_id(peer_id,amount,type="normal"):
	print(str("\nheal_peer_id=",peer_id," by ",amount))
	
	
	var servant_node_to_heal=peer_id_player_info[peer_id]["servant_node"]
	var current_hp=servant_node_to_heal.hp
	var amount_to_heal
	var max_hp=servant_node_to_heal.default_stats["hp"]
	if type=="command_spell":
		amount_to_heal=max_hp*0.7
	else:#command spell is static 70%
		amount_to_heal=amount
		for buff in servant_node_to_heal.buffs:
			if buff["Name"]=="heal x2":
				amount_to_heal*=2
	
	if current_hp+amount_to_heal>max_hp:
		servant_node_to_heal.hp=max_hp
	else:
		servant_node_to_heal.hp+=amount_to_heal
	rpc("update_hp_on_peer_id",peer_id,servant_node_to_heal.hp)
	print(str("hp now is ",servant_node_to_heal.hp,"\n"))
	
func _process(delta):
	pass

@rpc("any_peer","call_local","reliable")
func charge_np_to_peer_id_by_number(peer_id,number,source="damage"):
	print("\n===charge_np_to_peer_id_by_number===")
	print("peer_id_to_np_points[peer_id]="+str(peer_id_to_np_points[peer_id])+"+"+str(number))
	var number_to_add=number
	if peer_id_to_np_points[peer_id]>=12:
		pass
	else:
		for skill in peer_id_player_info[peer_id]["servant_node"].buffs:
			match skill["Name"]:
				"NP Gain Up":
					number_to_add+=skill["Power"]
				"NP Gain Up X":
					number_to_add*=skill["Power"]
		peer_id_to_np_points[peer_id]+=number_to_add
	
	if peer_id==Globals.self_peer_id:
		$"../GUI/action/np_points_number_label".text=str(peer_id_to_np_points[peer_id])

func get_endurance_in_numbers(Endurance):
	match Endurance.replace("+",""):
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

func calculate_damage_to_take(attacker_peer_id,enemies_dice_results,damage_type="normal",special="regular"):
	#damage_type="normal"/"Magical"
	#special is to half the damage bc evade or defence
	print("calculating damage to take\n\n")
	
	var zero_damage=false
	
	#Магический урон у сейберов сначала делится на 2 потом вычитается магическая защита
	var damage_to_take
	var attacker_damage
	var self_defence=0
	var buffs_to_ignore=[]
	var is_field_ignore_magic_defence=false
	

	
	if damage_type=="Magical":
		damage_to_take=peer_id_player_info[attacker_peer_id]["servant_node"].magic["Power"]
		
		var cur_kletka_conf=field.kletka_preference[field.current_kletka]
		if typeof(cur_kletka_conf)==4:
			is_field_ignore_magic_defence=false
		else:
			if cur_kletka_conf["Owner"]==attacker_peer_id and cur_kletka_conf["Ignore Magical Defence"]:
				is_field_ignore_magic_defence=true
		
	else:
		damage_to_take=peer_id_player_info[attacker_peer_id]["servant_node"].attack_power
	
	if !field.recieved_phantasm_config.is_empty():#for phantasm damage
		damage_to_take=field.recieved_phantasm_config["Damage"]
		if field.recieved_phantasm_config.has("Ignore"):
			buffs_to_ignore=field.recieved_phantasm_config["Ignore"]
		
	print("damage_type="+str(damage_type)+" damage_to_take="+str(damage_to_take))
	
	#calculating attacker damage
	print("calculating attacker damage")
	for skill in peer_id_player_info[attacker_peer_id]["servant_node"].buffs:
		match skill["Name"]:
			"ATK Up":
				damage_to_take+=skill["Power"]
			"ATK UP X":
				damage_to_take*=skill["Power"]
			"ATK Down":
				damage_to_take-=skill["Power"]
			"ATK Down X":
				damage_to_take=floor(damage_to_take/skill["Power"])
			"NP Strength Up" when damage_type=="Phantasm":
				damage_to_take+=skill["Power"]
			"NP Strength Up X" when damage_type=="Phantasm":
				damage_to_take*=skill["Power"]
			"NP Strength Down" when damage_type=="Phantasm":
				damage_to_take-=skill["Power"]
			"NP Strength Down X" when damage_type=="Phantasm":
				damage_to_take*=floor(damage_to_take/skill["Power"])
			"Madness Enhancement":
				damage_to_take*=skill["Power"]
		print(str("Buff= ",skill["Name"]," power=",skill["Power"]," damage_to_take=",damage_to_take))
	
	if enemies_dice_results["crit_dice"]==enemies_dice_results["main_dice"]:
		damage_to_take*=2
		print("CRITTTT"+ str(" damage_to_take=",damage_to_take))
	
	#calculating self defence
	print("calculating self defence")
	for skill in peer_id_player_info[Globals.self_peer_id]["servant_node"].buffs:
		var skill_type_array=Globals.buffs_types[skill["Name"]]
		var ignore=false
		for skill_type in skill_type_array:
			for skill_to_ignore in buffs_to_ignore:
				if skill_type==skill_to_ignore:
					ignore=true
		if ignore:
			continue
		match skill["Name"]:
			"Def Down X":
				damage_to_take*=skill["Power"]
			"Def Down":
				damage_to_take+=skill["Power"]
			"Def Up":
				damage_to_take-=skill["Power"]
			"Def Up X":
				damage_to_take=floor(damage_to_take/skill["Power"])
			"Evade":
				return "evaded"
			"Invincibility":#if power==0 then all turns else for N hits
				zero_damage=true
				damage_to_take*=0
				break
		print(str("Buff= ",skill["Name"]," power=",skill["Power"]," damage_to_take=",damage_to_take))
	
	
	if special=="Halfed Damage":
		damage_to_take=floor(damage_to_take/2)
		print("Halfed Damage   damage_to_take="+str(damage_to_take))
	
	if damage_type=="Magical":
		if not is_field_ignore_magic_defence:
			damage_to_take-=Globals.self_servant_node.magic["resistance"]
			print(str("magical resistange=",Globals.self_servant_node.magic["resistance"]," damage_to_take=",damage_to_take))
		else:
			print("field is ignoring magical defence")
		if peer_id_player_info[attacker_peer_id]["servant_node"].servant_class=="Saber":
			damage_to_take=floor(damage_to_take/2)
			print(str("Saber resistance", "damage_to_take=",damage_to_take))

	elif special=="Defence":
		var ignore=false
		for skill_to_ignore in buffs_to_ignore:
			if skill_to_ignore=="Defence":
				ignore=true
		if ignore:
			pass
		else:
			damage_to_take-=field.dice_roll_result_list["defence_dice"]
			print(str("defending=",field.dice_roll_result_list["defence_dice"]," damage_to_take=",damage_to_take))
	if damage_to_take<=1:
		damage_to_take=1
		
	if zero_damage:
		damage_to_take=0
	#Globals.self_servant_node.hp-=damage_to_take
	
	print(str("damage_to_take=",damage_to_take," type=",damage_type,"\n\n"))
	
	return damage_to_take

@rpc("any_peer","reliable","call_local")
func take_damage_to_peer_id(peer_id,damage_amount):
	var start_hp=peer_id_player_info[peer_id]["servant_node"].hp
	var new_hp=start_hp-damage_amount
	
	rpc("update_hp_on_peer_id",peer_id,new_hp)
	if peer_id==Globals.self_peer_id:
		field.rpc("systemlog_message",str(Globals.nickname," took ",damage_amount," damage, now HP=", new_hp))
	print(str(peer_id_to_nickname[peer_id]," HP is ",new_hp," now"))
	
	if new_hp<=0:
		trigger_death_to_peer_id(peer_id)


func trigger_death_to_peer_id(peer_id):
	for skill in peer_id_player_info[peer_id]["servant_node"].buffs:
		match skill["Name"]:
			"Guts":
				update_hp_on_peer_id(peer_id,skill["Power"])
				return
	
	if peer_id_to_command_spells_int[peer_id]>=3:
		var max_hp=peer_id_player_info[peer_id]["servant_node"].default_stats["hp"]
		update_hp_on_peer_id(peer_id,max_hp)
		reduce_command_spell_on_peer_id(peer_id)
		reduce_command_spell_on_peer_id(peer_id)
		reduce_command_spell_on_peer_id(peer_id)
	else:
		for i in range(9):
			peer_id_player_info[peer_id]["servant_node"].rotation_degrees+=10
			await get_tree().create_timer(0.1).timeout
			turns_order_by_peer_id.erase(peer_id)
	


@rpc("any_peer","reliable","call_local")
func update_hp_on_peer_id(peer_id,hp_to_set):
	if peer_id==Globals.self_peer_id:
		current_hp_value_label.text=str(hp_to_set)
	peer_id_player_info[peer_id]["servant_node"].hp=hp_to_set

func get_peer_id_attack_range(peer_id):
	var range=peer_id_player_info[peer_id]["servant_node"].attack_range
	for buff in peer_id_player_info[peer_id]["servant_node"].buffs:
			if buff["Name"]=="Attack Range Set":
				range=buff["Power"]
			if buff["Name"]=="Attack Range Add":
				range+=buff["Power"]
	return range
	

func _on_texture_rect_gui_input(event):
	if event.is_action_pressed:
		print(event)
	pass # Replace with function body.

@rpc("any_peer","reliable","call_local")
func reduce_additional_moves_for_peer_id(peer_id):
	peer_id_player_info[peer_id]["servant_node"].additional_moves-=1

@rpc("any_peer","reliable","call_local")
func set_peer_id_cooldown_for_skill_id(peer_id,skill_number,cooldown):
	peer_id_player_info[peer_id]["servant_node"].skill_cooldowns[skill_number]=cooldown
	

func _on_use_skill_button_pressed():
	print("[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]")
	print(skill_info_tab_container.current_tab)
	field.hide_all_gui_windows("skill_info_tab_container")
	match skill_info_tab_container.current_tab+1:
		1:
			#Globals.self_servant_node.first_skill()
			use_skill(Globals.self_servant_node.skills["First Skill"]["Effect"])
			
			rpc("set_peer_id_cooldown_for_skill_id",Globals.self_peer_id,0,
			Globals.self_servant_node.skills["First Skill"]["Cooldown"])
		2:
			#Globals.self_servant_node.second_skill()
			use_skill(Globals.self_servant_node.skills["Second Skill"]["Effect"])
			
			rpc("set_peer_id_cooldown_for_skill_id",Globals.self_peer_id,1,
			Globals.self_servant_node.skills["Second Skill"]["Cooldown"])
		3:
			#Globals.self_servant_node.third_skill()
			use_skill(Globals.self_servant_node.skills["Third Skill"]["Effect"])
			
			rpc("set_peer_id_cooldown_for_skill_id",Globals.self_peer_id,2,
			Globals.self_servant_node.skills["Third Skill"]["Cooldown"])
		4:
			var class_skill_number= skill_info_tab_container.get_current_tab_control().current_tab+1
			if Globals.self_servant_node.skills["Class Skill "+str(class_skill_number)]["Type"]=="Weapon Change":
				#print(skill_info_tab_container.get_current_tab_control().get_current_tab_control())
				var weapon_name_to_change_to=skill_info_tab_container.get_current_tab_control().get_current_tab_control().get_current_tab_control().name
				var tt=skill_info_tab_container.get_current_tab_control()
				var tt2=tt.get_current_tab_control()
				print(tt2.name)
				var tt3=tt2.get_current_tab_control()
				print("eee")
				
				rpc("set_peer_id_cooldown_for_skill_id",Globals.self_peer_id,2+class_skill_number,
				Globals.self_servant_node.skills["Class Skill "+str(class_skill_number)]["Cooldown"])
				
				change_weapon(weapon_name_to_change_to,class_skill_number)
			else:
				#Globals.self_servant_node.call("Class Skill "+str(class_skill_number))
				use_skill(Globals.self_servant_node.skills["Class Skill "+str(class_skill_number)]["Effect"])
					
				rpc("set_peer_id_cooldown_for_skill_id",Globals.self_peer_id,2+class_skill_number,
				Globals.self_servant_node.skills["Class Skill "+str(class_skill_number)]["Cooldown"])
	
	field.reduce_one_action_point()
	pass # Replace with function body.

@rpc("any_peer","call_local","reliable")
func change_peer_id_servant_stat(peer_id,stat,value):
	match stat:
		"attack_range":
			peer_id_player_info[peer_id]["servant_node"].attack_range=value
		"attack_power":
			peer_id_player_info[peer_id]["servant_node"].attack_power=value

@rpc("any_peer","call_local","reliable")
func change_peer_id_sprite(peer_id,image):
	peer_id_player_info[peer_id]["servant_node"].get_child(0).texture=image

func change_weapon(weapon_name_to_change_to,class_skill_number):
	var weapons_array=Globals.self_servant_node.skills["Class Skill "+str(class_skill_number)]["weapons"]
	rpc("remove_buff",[Globals.self_peer_id],weapons_array[Globals.self_servant_node.current_weapon]["buff"]["Name"],true)
	print("weapon_name_to_change_to="+str(weapon_name_to_change_to))
	
	rpc("change_peer_id_sprite",Globals.self_peer_id,
	load("res://servants/"+peer_id_player_info[Globals.self_peer_id]["servant_name"]+
	"/sprite_"+str(weapon_name_to_change_to)+".png"))
	
	rpc("change_peer_id_servant_stat",Globals.self_peer_id,"attack_range",weapons_array[weapon_name_to_change_to]["range"])
	rpc("change_peer_id_servant_stat",Globals.self_peer_id,"attack_power",weapons_array[weapon_name_to_change_to]["Damage"])
	
	if weapons_array[weapon_name_to_change_to]["is_one_hit_per_turn"]:
		rpc("add_buff",[Globals.self_peer_id],{"Buffs":[{"Name":"Charge NP","Duration":"Passive"}]})
	else:
		rpc("remove_buff",[Globals.self_peer_id],"one attack per turn",true)
	
	
	if weapons_array[weapon_name_to_change_to].has("buff"):
		rpc("add_buff",[Globals.self_peer_id],weapons_array[weapon_name_to_change_to]["buff"])
	pass



func _on_items_pressed():
	#{ "Heal Potion": { "min_cost": { "Type": "Free", "value": 0 }, "Type": "potion creating", "Effect": [{ "Name": "Heal", "Power": 5 }], "range": 2, "description": "(Зелье лечения: Восполняет 5 очков здоровья, а также снимает все дебаффы себе или другому слуге в радиусе двух клеток)" } }
	
	
	var items_array=peer_id_to_items_owned[Globals.self_peer_id].duplicate(true)
	
	print("\n\nitems_array="+str(items_array))
	var items_descriptions={}
	var items_effects={}
	print(items_array)
	for item in items_array:
		print(item)
		var item_name=item.keys()[0]
		items_descriptions[item_name]={"Text":item[item_name]["Description"]}
		items_effects[item_name]=item[item_name]
		items_effects[item_name].erase("Description")
		#items_descriptions[item]=items_array[item][]
	print("items_descriptions="+str(items_descriptions)+" items_effects="+str(items_effects))
	print('\n\n')
	fill_custom_thing(items_effects,"potion using")
	field.hide_all_gui_windows("use_custom")
		
	pass # Replace with function body.

@rpc("any_peer","call_local","reliable")
func reduce_command_spell_on_peer_id(peer_id):
	peer_id_to_command_spells_int[peer_id]-=1
