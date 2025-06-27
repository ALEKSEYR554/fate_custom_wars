extends Node2D

#region Onready
@onready var field = self.get_parent()

@onready var host_buttons:VBoxContainer = $"../GUI/host_buttons"

@onready var servant_info_main_container:VBoxContainer = $"../GUI/Servant_info_main_container"
@onready var servant_info_picture_and_stats_container:HBoxContainer = $"../GUI/Servant_info_main_container/servant_info_picture_and_stats_container"
@onready var servant_info_picture:TextureRect = $"../GUI/Servant_info_main_container/servant_info_picture_and_stats_container/servant_info_picture"
@onready var servant_info_stats_textedit:TextEdit = $"../GUI/Servant_info_main_container/servant_info_picture_and_stats_container/servant_info_stats_textedit"
@onready var servant_info_skills_textedit:TextEdit = $"../GUI/Servant_info_main_container/servant_info_skills_textedit"
@onready var show_buffs_advanced_way_button = $"../GUI/Servant_info_main_container/show_buffs_advanced_way_button"


@onready var current_hp_container:HBoxContainer = $"../GUI/current_hp_container"
@onready var current_hp_value_label:Label = $"../GUI/current_hp_container/current_hp_value_label"


@onready var players_info_buttons_container:VBoxContainer = $"../GUI/players_info_buttons_container"

@onready var get_selected_character_button:Button = $"../GUI/character_selection_container/get_selected_character"
@onready var char_select:Control = $"../GUI/character_selection_container/Char_select"

@onready var skill_info_tab_container:TabContainer = $"../GUI/Skill_info_tab_container"
@onready var first_skill_text_edit:TextEdit = $"../GUI/Skill_info_tab_container/First Skill"
@onready var second_skill_text_edit:TextEdit = $"../GUI/Skill_info_tab_container/Second Skill"
@onready var third_skill_text_edit:TextEdit = $"../GUI/Skill_info_tab_container/Third Skill"
@onready var class_skills_text_edit:TabContainer = $"../GUI/Skill_info_tab_container/Class Skills"


@onready var custom_choices_tab_container:TabContainer = $"../GUI/custom_choices_tab_container"
@onready var use_custom_but_label_container:VBoxContainer = $"../GUI/use_custom_but_label_container"
@onready var use_custom_label:Label = $"../GUI/use_custom_but_label_container/use_custom_label"
@onready var use_custom_button:Button = $"../GUI/use_custom_but_label_container/use_custom_button"
@onready var current_players_ready_label:Label = $"../GUI/character_selection_container/Current_players_ready"
#endregion

#region Usable Variables
var custom_id_to_skill:Dictionary={}
var turns_order_by_pu_id:Array=[]

var teams_by_pu_id:Array=[]

var turns_counter:int=1
var current_player_pu_id_turn:String



var start_camera_position:Vector2
var start_camera_zoom:Vector2
var last_camera_positon:Vector2
var last_camera_zoom:Vector2

# peer_id={"servant_name":"bunyan","servant_node":NODE,
#"Buffs":[["buff_name",duration_int]],"debuffs:[["debuff_name",duration_int]]"}
#var peer_id_player_info:Dictionary={}

#peer_id={"total_kletki_moved":INT,"total_success_hit":INT,"kletki_moved_this_turn":INT,"attacked_this_turn":INT,
#"total_crit_hit":INT,"total_damage_dealt":INT,"total_damage_taken":INT,"skill_used_this_turn":INT,
#"total_skill_used":INT}
var pu_id_player_game_stat_info={}

var pu_id_to_command_spells_int:Dictionary={}

var pu_id_to_items_owned:Dictionary={}

var pu_id_to_np_points:Dictionary={}

var pu_id_to_inventory_array:Dictionary={}
var player_info_button_current_pu_id:String=""

var self_command_spell_type:String=""
var servant_name_to_pu_id:Dictionary={}

#Current users ready 0/?
var current_users_ready:int=0
var choosen_allie_return_value:Node2D
#endregion


signal next_turn_pass
signal chosen_allie()
signal buff_removed
signal buffs_cooldown_reduced
signal skills_cooldown_reduced
#region CONSTANTS
const CUSTOM_TYPES = {PHANTASM = "phantasm", POTION_CREATING = "potion creating", POTION_USING = "potion using", BUFF_CHOOSING="buff choosing"}
const TEXTURE_SIZE:int=200
const DEFAULT_GAME_STAT={"total_kletki_moved":0,"total_success_hit":0,
		"kletki_moved_this_turn":0,"attacked_this_turn":0,
		"total_crit_hit":0,"total_damage_dealt":0,"total_damage_taken":0,
		"skill_used_this_turn":0,"total_skill_used":0}

const DAMAGE_TYPE= {PHYSICAL="Physical", MAGICAL="Magical", PHANTASM="Phantasm"}
const buff_ignoring=["Ignore Defence","Ignore DEF Buffs","Ignore Invincible","Sure Hit","Ignore Evade"]
#endregion

func fuck_you():
	print("fuck you")


#region Starting and Loading
func _ready():
	self.z_index=50
	#Globals.self_peer_id=multiplayer.get_unique_id()
	$"../GUI/peer_id_label".text=str(Globals.self_pu_id)
	rpc("update_ready_users_count",current_users_ready,Globals.pu_id_player_info.size())
	#print(str(dir.get_directories()))
	return


@rpc("call_local","authority","reliable")
func load_servant(pu_id:String):
	print("loading servant for pu_id=",pu_id)
	var folderr
	if OS.has_feature("editor"):
		folderr="res://"
	else:
		folderr="user://"
	
	if OS.has_feature("mobile"):
		folderr=Globals.user_folder
	
	var servant_name:String=Globals.pu_id_player_info[pu_id].get("servant_name",null)
	if servant_name==null:
		push_error("servant is not found while loading")
		print("\n\nservant is not found while loading=",pu_id," Globals.pu_id_player_info=",Globals.pu_id_player_info)
		return
	
	var img=null

	for servant in Globals.characters:
		if servant["Name"]==servant_name:
			img=servant["image"]

	if img==null:
		push_error("No sprite Found while loading servant")
		return

	#var dir = DirAccess.open(folderr+"://servants/")
	#for i in dir.get_directories():#getting custom characters
	var player:Node2D=Node2D.new()
	var player_textureRect:TextureRect = TextureRect.new()
	var effect_layer:TextureRect = TextureRect.new()
	var buff_name_label:Label= Label.new()
	#var servant_folder_name:String=folderr+"servants/"+str(servant_name)
	
	player.set_script(load(Globals.user_folder+"servants/"+str(servant_name)+"/"+str(servant_name)+".gd"))
	#print("servant_folder_name=",servant_folder_name)
	#print("folder content=",DirAccess.open(servant_folder_name).get_files())
	#print('ResourceLoader.exists(servant_folder_name+"/sprite.png")=',ResourceLoader.exists(servant_folder_name+"/sprite.png"))
	#print('img.load(servant_folder_name+"/sprite.png")=',load(servant_folder_name+"/sprite.png"))
	
	#var img = Image.new()
	#var er=img.load(Globals.user_folder+"servants/"+str(servant_name)+"/sprite.png")
	
	#if er!=OK:
	#	er=img.load(Globals.user_folder+"servants/"+str(servant_name)+"/sprite.png")
		
	#if er!=OK:
	#	push_error("No sprite Found while loading servant")
	#	return
		
	player_textureRect.texture=ImageTexture.create_from_image(img)
	effect_layer.texture=load("res://white.png")
	
	var sizes:Vector2=player_textureRect.texture.get_size()
	#texture.flat=true
	#texture.anchors_preset=
	#texture.button_down.connect(player_info_button_pressed.bind(peer_id))
	player_textureRect.position=Vector2(-(TEXTURE_SIZE*1.0)/2,-TEXTURE_SIZE)
	player_textureRect.scale=Vector2(TEXTURE_SIZE/sizes.x,TEXTURE_SIZE/sizes.y)
	
	
	effect_layer.size=Vector2(TEXTURE_SIZE*1.1,TEXTURE_SIZE*1.1)
	effect_layer.position=Vector2(-(TEXTURE_SIZE*1.1)/2,-TEXTURE_SIZE*1.1)
	
	buff_name_label.position=Vector2(-(TEXTURE_SIZE*1.1)/2,-TEXTURE_SIZE*1.2)
	buff_name_label.text="FUCK"
	
	
	buff_name_label.add_theme_font_size_override("font_size",40)
	buff_name_label.add_theme_color_override("font_outline_color",Color.WHITE)
	buff_name_label.add_theme_constant_override("outline_size",5)
	buff_name_label.add_theme_color_override("font_color",Color.BLACK)
	buff_name_label.z_index=1
	print("sizes="+str(sizes))
	print("scale="+str(player.scale))
	#player.add_child(player,true)
	player.name=servant_name
	effect_layer.z_index=-1
	effect_layer.modulate=Color(1, 1, 1, 0)
	buff_name_label.modulate=Color(1, 1, 1, 0)
	player.add_child(player_textureRect)
	player.add_child(effect_layer)
	player.add_child(buff_name_label)
	
	
	
	print("pu_id==Globals.self_pu_id=",pu_id," ",Globals.self_pu_id)
	if pu_id==Globals.self_pu_id:
		print("pu==Globals self, adding")
		Globals.self_servant_node=player
		print("Globals.self_servant_node=",Globals.self_servant_node)
	Globals.pu_id_player_info[pu_id]["servant_node"]=player
	
	self.add_child(player,true)
	
	servant_name_to_pu_id[player.name]=pu_id
	#Globals.pu_id_player_info[pu_id]["servant_name"]=player.name
	
	print("servant_name_to_pu_id=",servant_name_to_pu_id)
	#print(rand_kletka)
	#print(cell_positions[rand_kletka])
	#jopa.position = cord
	#set_random_teams()
	#return player
	
func get_selected_servant()->void:
	var servant_name:String=char_select.get_current_servant()
	get_selected_character_button.disabled=true
	print(servant_name)
	rpc("set_nickname_for_pu_id",Globals.self_pu_id,Globals.nickname)
	rpc_id(1,"check_if_players_ready",Globals.self_pu_id,servant_name)

@rpc("call_local","any_peer","reliable")
func set_nickname_for_pu_id(pu_id:String,nickk:String):
	Globals.pu_id_to_nickname[pu_id]=nickk

@rpc("any_peer","call_local","reliable")
func check_if_players_ready(pu_id:String,servant_name:String):
	print("\n\n check_if_players_ready id=",pu_id," sevanntName=",servant_name)
	Globals.pu_id_player_info[pu_id]["servant_name"]=servant_name#,"servant_node":null}

	print("pu_id=",pu_id, "  "+str(Globals.pu_id_player_info)+" is ready")
	current_users_ready+=1
	rpc("update_ready_users_count",current_users_ready,Globals.pu_id_player_info.size())

	rpc("sync_pu_id_player_info",Globals.pu_id_player_info.duplicate(true))
	sync_pu_id_player_info(Globals.pu_id_player_info.duplicate(true))

	#print("Globals.connected_players="+str(Globals.connected_players)+"Globals.connected_players.size()="+str(Globals.connected_players.size()))
	print("=current_users_ready="+str(current_users_ready))
	if Globals.pu_id_player_info.size()==current_users_ready:
		if Globals.host_or_user=="host":
			host_buttons.visible=true
	

@rpc("authority","call_local","reliable")
func inital_spawn_of_player_forwarder():
	print()
	field.inital_spawn_of_player()

@rpc("any_peer","call_local","reliable")
func update_ready_users_count(current_users_ready_local:int,max_players:int):
	current_players_ready_label.text="Current users ready"+str(current_users_ready_local)+"/"+str(max_players)


@rpc("authority","call_local","reliable")
func sync_pu_id_player_info(pu_id_player_info_temp:Dictionary):
	print_debug("sync_pu_id_player_info=",pu_id_player_info_temp)
	Globals.pu_id_player_info=pu_id_player_info_temp

@rpc("authority","call_local","reliable")
func set_teams_and_turns_order(shiffled_players_array,turn_order):
	var len_=shiffled_players_array.size()/2
	teams_by_pu_id=[shiffled_players_array.slice(0,len_),shiffled_players_array.slice(len_)]
	print("teams="+str(teams_by_pu_id))
	
	turns_order_by_pu_id=turn_order
	for pu_id in turns_order_by_pu_id:
		var servant_button=Button.new()
		servant_button.text=Globals.pu_id_player_info[pu_id]["servant_node"].name
		servant_button.button_down.connect(player_info_button_pressed.bind(pu_id))
		players_info_buttons_container.add_child(servant_button,true)
	

@rpc("authority","call_local","reliable")
func initialise_start_variables(pu_id_list:Array):
	field.add_all_additional_nodes()
	for pu_id in pu_id_list:
		pu_id_to_items_owned[pu_id]={}
		pu_id_to_inventory_array[pu_id]=[]
		pu_id_to_np_points[pu_id]=0
		pu_id_to_command_spells_int[pu_id]=3
		pu_id_player_game_stat_info[pu_id]=DEFAULT_GAME_STAT.duplicate(true)
		Globals.self_field_color = Color(randf(), randf(), randf())
		
	start_camera_position=$"../Camera2D".position
	start_camera_zoom=$"../Camera2D".zoom

	pass

func start():
	#выдаем каждому игроку свой NODE слуги
	rpc("sync_pu_id_player_info",Globals.pu_id_player_info.duplicate(true))
	sync_pu_id_player_info(Globals.pu_id_player_info.duplicate(true))
	var temp_pl=Globals.pu_id_player_info.keys()
	temp_pl.shuffle()
	var sh1=temp_pl
	temp_pl.shuffle()
	var sh2=temp_pl
	print("temp_pl+"+str(temp_pl))
	
	

	print("\n\ninfo before loading=",Globals.pu_id_player_info)

	print("\n START SELF PEER_ID=",Globals.get_self_peer_id(), " =", multiplayer.get_unique_id())

	for pu_id in Globals.pu_id_player_info.keys():
		print("just before load servant for id=",pu_id)
		#var node_to_add=load_servant_by_name(peer_id_player_info[peer_id]["servant_name"])
		rpc("load_servant",pu_id)
		#peer_id_player_info[peer_id]["servant_node"]=node_to_add
		#add_child(node_to_add,true)
		#print(node_to_add)
		#rpc_id(peer_id,"set_player_node",inst_to_dict(node_to_add))
		print("\njust after loading servant pu_id_player_info="+str(Globals.pu_id_player_info))
	
	print_debug("set_teams_and_turns_order=",sh1,sh2)
	rpc("set_teams_and_turns_order",sh1,sh2)
	#первоначальное выставление слуг на поле
	rpc("initialise_start_variables",turns_order_by_pu_id)
	for pu_id in turns_order_by_pu_id: 
		current_player_pu_id_turn=pu_id
		var pu_peer_id=Globals.pu_id_player_info[pu_id]["current_peer_id"]
		rpc_id(pu_peer_id,"inital_spawn_of_player_forwarder")
		await next_turn_pass
		print(pu_id)
	turns_loop()

#endregion

#region Turns Handler
@rpc("any_peer","call_local","reliable")
func pass_next_turn(pu_id:String)->void:
	if pu_id==current_player_pu_id_turn:
		field.my_turn=false
		next_turn_pass.emit()
		


func is_only_one_team_stand()->bool:
	var pu_id_alive=turns_order_by_pu_id.duplicate(true)
	if get_all_pu_ids().size()==1:#for debug only
		return false
	var teams_alive=[]
	for team in pu_id_alive:
		for member in team:
			if team in teams_alive:
				break
			if member in pu_id_alive:
				teams_alive.append(team)
	print("teams_alive="+str(teams_alive))
	print(teams_alive.size()==1)
	return teams_alive.size()==1

func turns_loop() -> void:
	print("turns_loop started")
	while !is_only_one_team_stand():
		turn_update(turns_counter)
		rpc("turn_update",turns_counter)
		
		for pu_id in turns_order_by_pu_id:
			print("\n\nNow "+str(pu_id)+" turn\n\n")
			var peer_id=Globals.pu_id_player_info[pu_id]["current_peer_id"]

			if Globals.pu_id_player_info[pu_id]["disconnected_more_than_timeout"]:
				continue


			current_player_pu_id_turn=pu_id
			rpc("update_current_player_turn",current_player_pu_id_turn)

			
			field.rpc_id(peer_id,"start_turn")
			await next_turn_pass
		turns_counter+=1
		turn_update(turns_counter)
		rpc("turn_update",turns_counter)
		
	$"../GUI/host_buttons/finish_button".visible=true

@rpc("any_peer","call_local","reliable")
func update_current_player_turn(cur_player_turn_pu_id:String):
	current_player_pu_id_turn=cur_player_turn_pu_id

@rpc("any_peer","reliable","call_remote")
func turn_update(turn) -> void:
	$"../GUI/turns_label".text=str("Turn: ",turn)
	turns_counter=turn

#endregion


func player_info_button_pressed(pu_id:String):
	print("player_info_button_pressed="+str(pu_id))
	servant_info_from_pu_id(pu_id)
	if pu_id!=player_info_button_current_pu_id and servant_info_main_container.visible:
		#servant_info_main_container.visible= false
		#servant_info_from_pu_id(peer_id)
		player_info_button_current_pu_id=pu_id
		pass
	else:
		player_info_button_current_pu_id=pu_id
		field.hide_all_gui_windows("servant_info_main_container")
		#servant_info_from_pu_id(peer_id)


func choose_allie()->Array:
	var ketki_with_allies=[]
	for pu_id in get_allies():
		ketki_with_allies.append(field.pu_id_to_kletka_number[pu_id])
	field.choose_glowing_cletka_by_ids_array(ketki_with_allies)
	field.current_action="choose_allie"
	await chosen_allie
	return [servant_name_to_pu_id[choosen_allie_return_value.name]]

func show_skill_info_tab(pu_id:String=Globals.self_pu_id)->void:
	print("=====================")
	var servant_skills:Dictionary=Globals.pu_id_player_info[pu_id]["servant_node"].skills
	
	
	
	#print(servant_nod)
	first_skill_text_edit.text=servant_skills.get("First Skill").get("Description")
	second_skill_text_edit.text=servant_skills.get("Second Skill").get("Description")
	third_skill_text_edit.text=servant_skills.get("Third Skill").get("Description")
	#print("third_skill_text_edit.text="+str(third_skill_text_edit.text))
	var cct=1
	for children in class_skills_text_edit.get_children():
		class_skills_text_edit.remove_child(children)
		children.queue_free() 
	#var class_skill_count=1
	for class_skill_count in range(1,10):
		var class_skill_name="Class Skill "+str(class_skill_count)
		if !servant_skills.has(class_skill_name):
			break
		var skill_info=servant_skills[class_skill_name]
		#for skill_info in servant_nod.slice(3):
		
		if skill_info["Type"]=="Weapon Change":
			#TODO create custom TabBar class for this shit
			#for description of weapon change
			var tab_cont=TabContainer.new()
			tab_cont.name="Weapon change"
			tab_cont.tab_alignment=TabBar.ALIGNMENT_CENTER
			
			for weapon in Globals.pu_id_player_info[pu_id]["servant_node"].skills[class_skill_name]["weapons"]:
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

func servant_info_from_pu_id(pu_id:String,advanced:bool=show_buffs_advanced_way_button.button_pressed)->void:
	
	
	var info=Globals.pu_id_player_info[pu_id]["servant_node"]
	#servant_info_main_container.visible= true#!servant_info_main_container.visible
	servant_info_stats_textedit.text="Name:%s\nHP:%s\nClass:%s\nIdeology:%s\nAgility:%s
	Endurance:%s\nLuck:%s\nMagic:%s\n"%[info.name,info.hp,info.servant_class,info.ideology,info.agility,info.endurance,info.luck,info.magic]
	var buffs:Array=info.buffs
	var display_buffs=""
	if advanced:
		for buff in buffs:
			display_buffs+=str(buff)+"\n"
	else:
		for buff in buffs:
			display_buffs+=str("\t",buff["Name"])
			if buff.has("Power"):
				display_buffs+=str(" lvl ",buff["Power"])
			if buff.has("Duration"):
				display_buffs+=str(" for ",buff["Duration"],"turns")
				
			display_buffs+="\n"
	var peer_skills:Dictionary=info.skills
	servant_info_picture.texture=Globals.pu_id_player_info[pu_id]["servant_node"].get_child(0).texture
	var skill_text_to_display=""
	for skill in peer_skills.keys():
		skill_text_to_display+=str("\t",peer_skills[skill]["Description"],"\n")
	servant_info_skills_textedit.text="Buffs:\n\t%sSkills:\n\t%s"%[display_buffs,skill_text_to_display]

func get_enemies_teams()->Array:
	var all_enemies_pu_id=[]
	for team in teams_by_pu_id:
		for member in team:
			if Globals.self_pu_id!=member:
				all_enemies_pu_id+=team
	return all_enemies_pu_id




func fill_custom_thing(custom_items_dict:Dictionary,type="")->void:
	print("fill_custom_thing")
	print("custom_items="+str(custom_items_dict))
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
		var tt_edit:TextEdit=TextEdit.new()

		tt_edit.editable=false
		tt_edit.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
		tt_edit.name=custom_item_name
		tt_edit.text=custom_item["Description"]
		custom_choices_tab_container.add_child(tt_edit,true)
		var cost={"Type":"NP","value":6}
		
		
		print_debug("custom_items_dict="+str(custom_items_dict))
		print_debug("type="+str(type))
		match type:
			CUSTOM_TYPES.PHANTASM:
				current_buff_effect=custom_item["Overcharges"]
				cost={"Type":"NP","value":custom_item["Overcharges"]["Default"]["Cost"]}
			CUSTOM_TYPES.POTION_CREATING:
				current_buff_effect=custom_item["Buff"]
				cost={"Type":"Free","value":0}
			CUSTOM_TYPES.POTION_USING:
				current_buff_effect=custom_item["Effect"]
				cost={"Type":"Free","value":0}
			CUSTOM_TYPES.BUFF_CHOOSING:
				current_buff_effect=custom_item
				cost={"Type":"Free","value":0}
			_:
				push_error("Unhandled Custom type:"+str(type))
				
		#print("ff\n\n")
		print_debug("custom_item="+str(custom_item))
		custom_id_to_skill[custom_item_name]={"min_cost":cost,
		"Type":type,"Effect":current_buff_effect,"Description":custom_item["Description"]}
		print_debug(str("custom_id_to_skill=",custom_id_to_skill))
	


func _on_custom_choices_tab_container_tab_changed(tab)->void:
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
	

func _on_use_custom_button_pressed()->void:
	#print(custom_id_to_skill[custom_choices_tab_container.current_tab])
	var custom_id=custom_choices_tab_container.get_current_tab_control().name
	custom_choices_tab_container.visible=false
	use_custom_but_label_container.visible=false
	
	print_debug("custom_id_to_skill[custom_id]="+str(custom_id_to_skill))
	match custom_id_to_skill[custom_id]["Type"]:
		CUSTOM_TYPES.PHANTASM:
			await use_phantasm(custom_id_to_skill[custom_id]["Effect"])
			field.reduce_one_action_point()
		CUSTOM_TYPES.POTION_CREATING:
			var dict={custom_id:custom_id_to_skill[custom_id]}
			#dict.merge(custom_id_to_skill[custom_id])
			rpc("add_item_to_pu_id",Globals.self_pu_id,dict,custom_id) #{"Name":custom_id,"Effect":custom_id_to_skill[custom_id]["Effect"],"range":custom_id_to_skill[custom_id]["range"]})
			field.reduce_one_action_point(0)
			#rpc("use_skill",custom_id_to_skill[custom_id]["Effect"])
		CUSTOM_TYPES.BUFF_CHOOSING:
			await use_skill(custom_id_to_skill[custom_id]["Effect"])
		CUSTOM_TYPES.POTION_USING:
			print("\n\npotion using")
			#var kletki_ids=field.get_kletki_ids_with_enemies_you_can_reach_in_steps(custom_id_to_skill[custom_id]["range"])
			#{ "min_cost": { "Type": "Free", "value": 0 }, "Type": "potion creating", "Effect": [{ "Name": "Heal", "Power": 5 }], "range": 2 }
			var tmp=custom_id_to_skill[custom_id]["Effect"]
			for effect in tmp:
				var buf={"Buffs":effect,"Cast":"Single In Range","Cast Range":effect["Range"]}
				await use_skill(buf)
				print_debug("custom_id_to_skill[custom_id][\"Effect\"]="+str(custom_id_to_skill[custom_id]["Effect"]))
				
	
	

@rpc("any_peer","call_local","reliable")
func add_item_to_pu_id(pu_id:String,item:Dictionary,item_name:String)->void:
	print("item for pu_id="+str(pu_id)+" = "+str(item))
	var valid:bool=false
	var count:int=1
	var new_item_name=item_name+""
	while !valid:
		if pu_id_to_items_owned[pu_id].has(new_item_name):
			new_item_name=item_name+str(count)
			count+=1
		else:
			valid=true
	#var new_dict_to_append={new_item_name:item[item_name]}
	pu_id_to_items_owned[pu_id][new_item_name]=item[item_name]

@rpc("any_peer","call_local","reliable")
func change_game_stat_for_pu_id(pu_id:String,stat:String,value_to_add:int,reset:bool=false)->void:
	if reset:
		pu_id_player_game_stat_info[pu_id][stat]=value_to_add
	else:
		pu_id_player_game_stat_info[pu_id][stat]+=value_to_add
	pass


func check_field_buffs_under_pu_id(pu_id)->Array:
	var kletk_id=get_pu_id_kletka_number(pu_id)
	var kletka_config:Dictionary=field.kletka_preference[kletk_id]
	var out_buffs=[]
	if not kletka_config.is_empty():
		if kletka_config.get("Ignore Magical Defence",false):
			if kletka_config.get("Owner",0):
				out_buffs.append({"Name":"Disable Magic Resistance","Type":"Status","Pu Id":kletka_config["Owner"]})
	return out_buffs


#region Stat get

func get_pu_id_buffs(pu_id:String)->Array:
	var default_buffs:Array=Globals.pu_id_player_info[pu_id]["servant_node"].buffs.duplicate(true)

	var new_buffs=default_buffs

	new_buffs.append_array(check_field_buffs_under_pu_id(pu_id))

	return new_buffs


func check_if_pu_id_got_crit(pu_id:String,dice_results:Dictionary)->bool:
	var crit_removed=false
	var is_crit=false
	for skill in get_pu_id_buffs(pu_id):
		match skill["Name"]:
			"Critical Remove":
				crit_removed=true
			"Critical Hit Rate Up":
				if dice_results["crit_dice"] in skill["Crit Chances"]:
					is_crit=true
	if crit_removed:
		is_crit=false
	return is_crit

func calculate_crit_damage(pu_id:String,damage:int)->int:
	var new_damage:int=damage+0
	for skill in get_pu_id_buffs(pu_id):
		match skill["Name"]:
			"Critical Strength Up":
				new_damage+=skill.get("Power",0)
			"Critical Strength Up X":
				new_damage*=skill.get("Power",1)
	return new_damage

func get_pu_id_attack_power(pu_id:String)->int:
	var base_attack:int=Globals.pu_id_player_info[pu_id]["servant_node"].attack_power

	return base_attack+0

func get_current_time()->String:
	#day is 6 turns, night is 4
	if turns_counter%10>5:
		return "Night"
	else:
		return "Day"
	#return ""

func check_condition_wrapper(condition:Dictionary):
	var who_to_check=condition.get("Who To Check","")
	var what_to_check=condition.get("What To Check","")
	var bigger=condition.get("Bigger Than",null)
	var smaller=condition.get("Smaller Than",null)
	var exact=condition.get("Exact",null)

	if not (who_to_check and what_to_check):
		return false
	
	var pu_id_to_check:Array
	match who_to_check:
		"Enemie":
			pu_id_to_check=get_enemies_teams()
		"Self":
			pu_id_to_check=[Globals.self_pu_id]

	var condition_check=false
	for pu_id in pu_id_to_check:
		var pu_id_node=Globals.pu_id_player_info[pu_id]["servant_node"]
		var stat_to_check
		match what_to_check:
			"Magic Power":
				#stat_to_check=peer_node.magic["Power"]
				stat_to_check=get_pu_id_magical_attack(pu_id)
			"Magic Resistance":
				#stat_to_check=peer_node.magic["resistance"]
				stat_to_check=get_pu_id_magical_defence(pu_id)
			"Magic Rank":
				stat_to_check=pu_id_node.magic["Rank"]
			"Attack Power":
				stat_to_check=get_pu_id_attack_power(pu_id)
			"Trait":
				var traits=get_pu_id_traits(pu_id)
				return intersect(traits,exact)
			"Attack Range":
				stat_to_check=get_pu_id_attack_range(pu_id)
			"Attribute":
				stat_to_check=pu_id_node.attribute
			"Ideology":
				var ideology=pu_id_node.ideology
				if typeof(exact)!=TYPE_ARRAY:
					continue
				return intersect(ideology,exact)
				
			"Class":
				var ser_class=get_pu_id_class(pu_id)
				if typeof(exact)!=TYPE_STRING:
					continue
				return exact==ser_class
			"HP":
				stat_to_check=pu_id_node.hp
			"Gender":
				stat_to_check=get_pu_id_gender(pu_id)
			"Strength":
				stat_to_check=get_pu_id_strength(pu_id)
			"Agility":
				stat_to_check=get_pu_id_agility(pu_id)
			"Endurance":
				stat_to_check=get_pu_id_endurance(pu_id)
			"Luck":
				stat_to_check=get_pu_id_luck(pu_id)
			"Buff Name":
				if pu_id_has_buff(pu_id,exact):
					return true
				else:
					return false
			"Field":
				var current_field=get_current_fields()
				if typeof(exact)!=TYPE_ARRAY:
					continue
				return intersect(current_field,exact)
			"Time":
				var current_time=[get_current_time()]
				if typeof(exact)!=TYPE_ARRAY:
					continue
				return intersect(current_time,exact)
		if bigger!=null:
			print_debug("Bigger=",stat_to_check,">",bigger,"?")
			print("typeof(bigger)=",typeof(bigger))
			if typeof(bigger)==TYPE_FLOAT:
				if stat_to_check>bigger:
					return true
			if typeof(bigger)==TYPE_STRING:
				return stat_one_bigger_than_second(stat_to_check,bigger)
		if smaller!=null:
			if typeof(smaller)==TYPE_FLOAT:
				if stat_to_check<smaller:
					return true
			if typeof(smaller)==TYPE_STRING:
				return stat_one_bigger_than_second(smaller,stat_to_check)
		if exact!=null:
			if stat_to_check==exact:
				return true
	return condition_check


func stat_one_bigger_than_second(stat1:String,stat2:String)->bool:
	print_debug("stat_one_bigger_than_second, stat1=",stat1," stat2=",stat2)
	var first_pos=Globals.ranks.find(stat1)
	var second_pos=Globals.ranks.find(stat2)
	#print_debug("stat_one_bigger_than_second, stat1=",first_pos," stat2=",second_pos)
	return first_pos<second_pos

func calculate_pu_id_attack_against_pu_id(attacker_pu_id:String,taker_pu_id:String,damage_type:String,phantasm_config:Dictionary={})->int:
	var attack_total


	match damage_type:
		DAMAGE_TYPE.PHANTASM:
			attack_total=phantasm_config.get("Damage",1)
		DAMAGE_TYPE.MAGICAL:
			attack_total=get_pu_id_magical_attack(attacker_pu_id)
		DAMAGE_TYPE.PHYSICAL:
			attack_total=get_pu_id_attack_power(attacker_pu_id)
		_:
			push_error("Wrong damage type while calculate_pu_id_attack_against_pu_id, damage_type=",damage_type)
			attack_total=1
	
	var taker_servant
	var taker_traits
	var taker_gender

	if taker_pu_id!="":
		taker_servant=Globals.pu_id_player_info[taker_pu_id]["servant_node"]
		taker_traits=taker_servant.traits
		taker_gender=get_pu_id_gender(taker_pu_id)



	var attacker_servant=Globals.pu_id_player_info[attacker_pu_id]["servant_node"]
	var attacker_buffs=get_pu_id_buffs(attacker_pu_id)


	var phantasm_additional_buffs=phantasm_config.get("Phantasm Buffs",[])
	

	attacker_buffs.append_array(phantasm_additional_buffs)


	for buff in attacker_buffs:
		if buff.has("Condition"):
			var check_buff=check_condition_wrapper(buff["Condition"])
			print_debug("check_buff=",check_buff)
			if not check_buff:
				continue
		match buff["Name"]:
			"ATK Up":
				attack_total+=buff["Power"]
			"ATK Down":
				attack_total-=buff["Power"]
			"NP Strength Up" when damage_type==DAMAGE_TYPE.PHANTASM:
				attack_total+=buff["Power"]
			"NP Strength Down" when damage_type==DAMAGE_TYPE.PHANTASM:
				attack_total-=buff["Power"]
			"Magic ATK Up" when damage_type==DAMAGE_TYPE.MAGICAL:
				attack_total+=buff["Power"]
			"ATK Up Against Attribute":
				if buff.get("Attribute","")==taker_servant.attribute:
					attack_total+=buff["Power"]
			"Madness Enhancement":
				attack_total*=buff["Power"]
			"ATK Up Against Gender" when taker_pu_id!="":
				if buff.get("Gender","")==taker_gender:
					attack_total+=buff["Power"]
			"ATK Up Against Trait" when taker_pu_id!="":
				if buff.get("Trait","") in taker_traits:
					attack_total+=buff["Power"]
			"ATK Down Against Trait" when taker_pu_id!="":
				if buff.get("Trait","") in taker_traits:
					attack_total-=buff["Power"]
			"ATK Up X Against Class" when taker_pu_id!="":
				if buff.get("Class","")==taker_servant.class:
					attack_total+=buff["Power"]
			"ATK Up Against Alignment" when taker_pu_id!="":
				if buff.get("Alignment","") in taker_servant.ideology:
					attack_total+=buff["Power"]
		var poww=""
		if buff.has("Power"):
			poww=str(" power=",buff["Power"])
		print(str("Buff= ",buff["Name"],poww," damage_to_take=",attack_total))
	
	for buff in attacker_buffs:
		match buff["Name"]:
			"ATK UP X":
				attack_total*=buff["Power"]
			"ATK Down X":
				attack_total=floor(attack_total/buff["Power"])
			"NP Strength Up X" when damage_type==DAMAGE_TYPE.PHANTASM:
				attack_total*=buff["Power"]
			"NP Strength Down X" when damage_type==DAMAGE_TYPE.PHANTASM:
				attack_total*=floor(attack_total/buff["Power"])
			"Magic ATK Up X" when damage_type==DAMAGE_TYPE.MAGICAL:
				attack_total*=buff["Power"]
			"ATK Up X Against Gender" when taker_pu_id!="":
				if buff.get("Gender","")==taker_gender:
					attack_total*=buff["Power"]
			"ATK Up X Against Attribute":
				if buff.get("Attribute","")==taker_servant.attribute:
					attack_total*=buff["Power"]
			"ATK Up X Against Trait" when taker_pu_id!="":
				if buff.get("Trait","") in taker_traits:
					attack_total*=buff["Power"]
			"ATK Down X Against Trait" when taker_pu_id!="":
				if buff.get("Trait","") in taker_traits:
					attack_total=floor(attack_total/buff["Power"])
			"ATK Up X Against Class" when taker_pu_id!="":
				if buff.get("Class","")==taker_servant.class:
					attack_total*=buff["Power"]
			"ATK Up X Against Alignment" when taker_pu_id!="":
				if buff.get("Alignment","") in taker_servant.ideology:
					attack_total*=buff["Power"]
		
		var poww=""
		if buff.has("Power"):
			poww=str(" power=",buff["Power"])
		print(str("Buff= ",buff["Name"],poww," damage_to_take=",attack_total))
		
	attack_total=ceil(attack_total)
	return attack_total

func get_pu_id_agility(pu_id:String)->String:
	var base_agility:String=Globals.pu_id_player_info[pu_id]["servant_node"].agility
	#TODO fix this later AKA after Andersen
	var _new_agility:String=""
	for skill in get_pu_id_buffs(pu_id):
		match skill["Name"]:
			"Agility Add":
				_new_agility+=""#skill.get("Power",0)*1.0/base_agility
			"Agility Set":
				_new_agility=""#get_agility_in_numbers(skill.get("Power","C"))
	return base_agility#int(base_agility+new_agility)

func get_pu_id_endurance(pu_id:String)->String:
	var base_stat:String=Globals.pu_id_player_info[pu_id]["servant_node"].endurance
	var _new_stat:String=base_stat+""
	#TODO fix this later AKA after Andersen
	for skill in get_pu_id_buffs(pu_id):
		match skill["Name"]:
			"Endurance Add":
				_new_stat+=skill.get("Power",0)
			"Endurance Set":
				_new_stat=skill.get("Power",1)
	return base_stat	

func get_agility_in_numbers(Endurance)->int:
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
		_:
			return 1

func get_pu_id_attack_range(pu_id:String)->int:
	var base_range:int=Globals.pu_id_player_info[pu_id]["servant_node"].attack_range
	var new_range:int=base_range+0
	for skill in get_pu_id_buffs(pu_id):
		match skill["Name"]:
			"Attack Range Add":
				new_range+=skill.get("Power",0)
			"Attack Range Set":
				new_range=skill.get("Power",1)
	return new_range

func get_pu_id_magical_attack(pu_id:String)->int:
	var base_stat:int=Globals.pu_id_player_info[pu_id]["servant_node"].magic.get("Power",0)
	var new_stat:int=base_stat+0
	for skill in get_pu_id_buffs(pu_id):
		match skill["Name"]:
			"Magical Attack Add":
				new_stat+=skill.get("Power",0)
			"Magical Attack Set":
				new_stat=skill.get("Power",1)
	return new_stat

func get_pu_id_magical_defence(pu_id:String)->int:
	var base_stat:int=Globals.pu_id_player_info[pu_id]["servant_node"].magic.get("Defence",0)
	var new_stat:int=base_stat+0
	for skill in get_pu_id_buffs(pu_id):
		match skill["Name"]:
			"Magical Defence Add":
				new_stat+=skill.get("Power",0)
			"Magical Defence Set":
				new_stat=skill.get("Power",1)
	return new_stat

func get_pu_id_luck(pu_id:String)->String:
	var base_stat:String=Globals.pu_id_player_info[pu_id]["servant_node"].luck
	var _new_stat:String=base_stat+""
	#TODO fix this later AKA after Andersen
	for skill in get_pu_id_buffs(pu_id):
		match skill["Name"]:
			"Luck Add":
				_new_stat+=skill.get("Power",0)
			"Luck Set":
				_new_stat=skill.get("Power",1)
	return base_stat	

#endregion





func _on_phantasm_pressed()->void:
	use_custom_button.disabled=false
	use_custom_label.visible=false
	if Globals.self_servant_node.phantasm_charge<6:
		use_custom_label.text="COST:6"
		
		use_custom_button.disabled=true
		pass
	
	if pu_id_has_buff(Globals.self_pu_id,"NP Seal"):
		custom_choices_tab_container.visible=false
		use_custom_but_label_container.visible=false
		field.info_table_show("Your NP is sealed by debuff")
		await field.info_ok_button.pressed
		return
	
	
	fill_custom_thing(Globals.self_servant_node.phantasms,CUSTOM_TYPES.PHANTASM)
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

func get_maximum_overcharge_name_available(phantasms_config: Dictionary) -> String:

	var overcharge_up_buff=pu_id_has_buff(Globals.self_pu_id,"Overcharge Up")

	var sorted_by_cost = []
	for phantasm_name in phantasms_config:
		if phantasms_config[phantasm_name].has("Cost"):
			sorted_by_cost.append({"Name": phantasm_name, "Cost": phantasms_config[phantasm_name]["Cost"]})
	sorted_by_cost.sort_custom(func(a, b): return a.Cost < b.Cost)

	var maximum_item = -1

	for i in range(sorted_by_cost.size()):
		var item = sorted_by_cost[i]
		if item.Cost <= Globals.self_servant_node.phantasm_charge:
			
			if maximum_item == -1 or item.Cost > sorted_by_cost[maximum_item].Cost:
				maximum_item = i

	if overcharge_up_buff and maximum_item != -1:
		if maximum_item + 1 < sorted_by_cost.size():
			maximum_item += 1

	if maximum_item != -1:
		return sorted_by_cost[maximum_item]["Name"]
	else:
		return "" 







func use_phantasm(phantasm_info):
	var overcharge_can_be_used=""
	#for overcharge in phantasm_info:#just bad info formation
	#	if overcharge=="Name":
	#		continue
		#checking maximum available overcharge that can be used right now

	#	if Globals.self_servant_node.phantasm_charge>=phantasm_info[overcharge]["Cost"]:
	overcharge_can_be_used=get_maximum_overcharge_name_available(phantasm_info)
			
			
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
		"Bomb":
			attacked_by_phantasm=await bomb_phantasm(overcharge_use)
		"Dash":
			attacked_by_phantasm=await field.line_attack_phantasm(overcharge_use,true)
		"All Field Enemies":
			pass
	
	if overcharge_use.has("effect_after_attack"):
		print("effect_after_attack=true")
		await use_skill(overcharge_use["effect_after_attack"],attacked_by_phantasm)
	
	
	rpc("charge_np_to_pu_id_by_number",Globals.self_pu_id,-overcharge_use["Cost"])
	#for effect in 
	
	pass

func get_pu_id_kletka_number(pu_id:String)->int:
	var servant_name=Globals.pu_id_player_info[pu_id]["servant_node"].name
	print("servant_name=",servant_name," pu_id=",pu_id)
	for kletka_id in field.occupied_kletki:
		if field.occupied_kletki[kletka_id].name==servant_name:
			return kletka_id
	push_error("couldn't get pu_id's kletka number=",pu_id, " name=",servant_name," field.occupied_kletki=",field.occupied_kletki)
	return 0


func bomb_phantasm(phantasm_config):
	var range_to_choose_enemie=phantasm_config["Range"]
	var aoe_range=phantasm_config["AOE_Range"]
	var kletki_to_attack_array=[]
	var attacked_enemies=[]
	var first_pu_id=await choose_single_in_range(range_to_choose_enemie)
	kletki_to_attack_array.append(get_pu_id_kletka_number(first_pu_id[0]))

	var pu_ids_around=get_all_enemies_in_range(aoe_range,first_pu_id[0])

	kletki_to_attack_array.append_array(pu_ids_around)
	
	await field.await_dice_roll()
	await field.hide_dice_rolls_with_timeout(1)
	for kletka in kletki_to_attack_array:
		var etmp=await field.attack_player_on_kletka_id(kletka,"Phantasm",false,phantasm_config)
		if etmp=="ERROR":
			continue
		attacked_enemies.append(etmp)
		if field.attack_responce_string!="evaded" or field.attack_responce_string!="parried":
			if phantasm_config.has("effect_on_success_attack"):
				await use_skill(phantasm_config["effect_on_success_attack"])
	
	return attacked_enemies


func phantasm_in_range(phantasm_config,type="Single"):
	var range=phantasm_config["Range"]
	var attacked_enemies=[]
	var kletki_to_attack_array=[]
	var enemies_array=get_enemies_teams()
	var tmp
	
	match type:
		"Single":
			tmp=await choose_single_in_range(range)
		"All enemies":
			tmp=await get_all_enemies_in_range(range)
	for pu_id in tmp:
		kletki_to_attack_array.append(field.pu_id_to_kletka_number[pu_id])
	await field.await_dice_roll()
	await field.hide_dice_rolls_with_timeout(1)
	for kletka in kletki_to_attack_array:
		var etmp=await field.attack_player_on_kletka_id(kletka,"Phantasm",false,phantasm_config)
		if etmp=="ERROR":
			continue
		attacked_enemies.append(etmp)
		if field.attack_responce_string!="evaded" or field.attack_responce_string!="parried":
			if phantasm_config.has("effect_on_success_attack"):
				await use_skill(phantasm_config["effect_on_success_attack"])
	
	return attacked_enemies


func _on_free_phantasm_pressed():
	#pu_id_player_info[Globals.self_pu_id]["servant_node"].phantasm_charge+=6
	#field.disable_every_button()
	rpc("charge_np_to_pu_id_by_number",Globals.self_pu_id,6)
	pass

@rpc("any_peer","call_local","reliable")
func change_phantasm_charge_on_pu_id(pu_id,amount):
	print("change_phantasm_charge_on_pu_id("+str(pu_id)+","+str(amount))
	var cur_charge=Globals.pu_id_player_info[pu_id]["servant_node"].phantasm_charge
	if cur_charge+amount>=12:
		Globals.pu_id_player_info[pu_id]["servant_node"].phantasm_charge=12
	else:
		Globals.pu_id_player_info[pu_id]["servant_node"].phantasm_charge+=amount
	if pu_id==Globals.self_pu_id:
		$"../GUI/action/np_points_number_label".text=str(Globals.pu_id_player_info[pu_id]["servant_node"].phantasm_charge)

func get_allies(pu_id_to_search:String=Globals.self_pu_id):
	for team in teams_by_pu_id:
		for member in team:
			if pu_id_to_search==member:
				return team
	pass
	#cast self,allies, 
	

func get_all_pu_ids():


	return Globals.get_connected_persistent_ids()

	var output=[]
	for team in teams_by_pu_id:
		for member in team:
			output.append(member)
	return output

func choose_single_in_range(_range,pu_id_to_search:String=Globals.self_pu_id):
	var ketki_array=[]
	var pur_id_kletka=get_pu_id_kletka_number(pu_id_to_search)
	print("choose_single_in_range pur_id_kletka=",pur_id_kletka)
	for kletka_id in field.get_kletki_ids_with_enemies_you_can_reach_in_steps(_range,pur_id_kletka):
		ketki_array.append(kletka_id)
	ketki_array.append(field.current_kletka)
	field.choose_glowing_cletka_by_ids_array(ketki_array)
	print("choose_single_in_range=",ketki_array)
	field.current_action="choose_allie"
	await chosen_allie
	return [servant_name_to_pu_id[choosen_allie_return_value.name]]

@rpc("any_peer","call_local",'reliable')
func check_if_hp_is_bigger_than_max_hp_for_pu_id(pu_id)->void:
	var max_hp=get_pu_id_maximun_hp(pu_id)
	var servant_node=Globals.pu_id_player_info[pu_id]["servant_node"]
	if servant_node.hp>max_hp:
		servant_node.hp=servant_node.default_stats["hp"]
	update_hp_on_pu_id(pu_id,servant_node.hp)
	return



#func get_everyone_in_range(range):
#	var out=[]
#	var kletka_id=0
#	for peer_id in field.get_kletki_ids_with_enemies_you_can_reach_in_steps(range):
#		kletka_id=field.peer_id_to_kletka_number[peer_id]
#		if field.occupied_kletki.get(kletka_id,0):
#			out.append(field.occupied_kletki.get(kletka_id))
#	return out

func get_all_enemies_in_range(_range,pu_id_to_search:String=Globals.self_pu_id)->Array:
	var enemies=get_enemies_teams()
	var out=[]
	for pu_id in get_everyone_in_range(_range,pu_id_to_search):
		if pu_id in enemies:
			out+=pu_id
	return out

func get_everyone_in_range(range_local:int,pu_id_to_search:String=Globals.self_pu_id)->Array:
	var out=[]
	#var kletka_id=0
	var pu_id_kletk_id=field.pu_id_to_kletka_number[pu_id_to_search]
	for kletka_id in field.get_kletki_ids_with_enemies_you_can_reach_in_steps(range_local,pu_id_kletk_id):
		if field.occupied_kletki.get(kletka_id,0):
			var servant_node=field.occupied_kletki.get(kletka_id)
			out.append(servant_name_to_pu_id[servant_node.name])
	return out


func check_if_pu_id_has_skill_currency(pu_id:String,currency:String,amount:int)->bool:
	match currency:
		"NP":
			if Globals.pu_id_player_info[pu_id]["servant_node"].phantasm_charge>=amount:
				return true
		"HP":
			if Globals.pu_id_player_info[pu_id]["servant_node"].hp>=amount:
				return true
		_:
			push_warning("UNKNOWN CURRENCY:"+str(currency))
	return false

func reduce_pu_id_currency(pu_id:String,currency:String,amount:int)->void:
	match currency:
		"NP":
			rpc("charge_np_to_pu_id_by_number",pu_id,-amount)
		"HP":
			rpc("take_damage_to_pu_id",pu_id,amount,false)
		_:
			push_warning("UNKNOWN CURRENCY:"+str(currency))


func get_buff_types(buff:Dictionary)->Array:
	var buff_specific_types = buff.get("Types",[])
	if buff_specific_types.is_empty():
		var buff_name = buff.get("Name","")
		if buff_name!="":
			if Globals.buffs_types.has(buff_name):
				buff_specific_types = Globals.buffs_types[buff_name]
	
	#print_debug("buff types=",buff_specific_types)
	return buff_specific_types

func get_all_allies_in_range(_range:int,pu_id_to_search:String=Globals.self_pu_id)->Array:
	var allies=get_allies(pu_id_to_search)
	var out=[]
	for pu_id in get_everyone_in_range(_range,pu_id_to_search):
		if pu_id in allies:
			out+=pu_id
	return out

func can_use_mandness_enhancement() -> bool:
	var self_bufs=get_pu_id_buffs(Globals.self_pu_id)
	
	for buff in self_bufs:
		if buff.get("Type",""):
			continue
		if "Buff Positive Effect" in get_buff_types(buff):
			return false
	return true

func use_skill(skill_info_dictionary,custom_cast:Array=[])->bool:
	#trait_name is used if "Damange 2х Against Trait"
	#String
	var was_skill_used=false
	print("\n\nuse_skill="+str(skill_info_dictionary)+"\n")
	rpc("zoom_out_in_camera_before_buff",true)

	if typeof(skill_info_dictionary)==TYPE_DICTIONARY:
		skill_info_dictionary=[skill_info_dictionary]
	
	print(str("using skills=",skill_info_dictionary))
	for skill_info_hash:Dictionary in skill_info_dictionary:
		if skill_info_hash.has("Cost"):
			print("checking cost")
			var curr=skill_info_hash["Cost"].get("Currency","")
			var amount=skill_info_hash["Cost"].get("Amount",0)
			if check_if_pu_id_has_skill_currency(Globals.self_pu_id,curr,amount):
				print_debug("you have currency"+str(curr)+" value:"+str(amount))
				reduce_pu_id_currency(Globals.self_pu_id,curr,amount)
			else:
				field.info_table_show("Not enought "+str(curr)+" value:"+str(amount))
				await field.info_ok_button.pressed
				continue
		if skill_info_hash.has("Choose Buff"):
			fill_custom_thing(skill_info_hash["Choose Buff"],CUSTOM_TYPES.BUFF_CHOOSING)
			field.hide_all_gui_windows("use_custom")
			continue
		
		if '"Madness Enhancement"' in str(skill_info_hash):
			print_debug('"Madness Enhancement" in str(skill_info_hash)')
			if can_use_mandness_enhancement():
				pass
			else:
				field.info_table_show("can not apply madness enchencement, you have buffs")
				await field.info_ok_button.pressed
				continue
		
		var cast=skill_info_hash.get("Cast","self")
		var cast_range=skill_info_hash.get("Cast Range",0)
		var cast_condition:Dictionary=skill_info_hash.get("Cast Condition",{})
		#if typeof(cast)==TYPE_ARRAY:
		#	range=cast[1]
		#	cast=cast[0]
		var skill_info_array=skill_info_hash["Buffs"]
		
		if typeof(skill_info_array)==TYPE_DICTIONARY:
			skill_info_array=[skill_info_array]
		match cast.to_lower():
			"all allies":
				cast=get_allies()
			"all allies except self":
				cast=get_allies()
				cast.erase(Globals.self_pu_id)
			"all allies in range":
				cast=get_all_allies_in_range(cast_range)
			"all allies in range except self":
				cast=get_all_allies_in_range(cast_range)
				cast.erase(Globals.self_pu_id)
			"self":
				cast=[Globals.self_pu_id]
			"all enemies":
				cast=get_enemies_teams()
			"single allie":
				cast=await choose_allie()
			"everyone":
				cast=get_all_pu_ids()
			"single in range":
				cast=await choose_single_in_range(cast_range)
			"all enemies in range":
				cast=get_all_enemies_in_range(cast_range)
			"phantasm attacked":
				if not custom_cast.is_empty():
					cast=custom_cast
				else:
					#cast=[Globals.self_peer_id]
					continue
			"trigger initiator":
				if not custom_cast.is_empty():
					cast=custom_cast
				else:
					#cast=[Globals.self_peer_id]
					continue
		#casts always array even if one
		if cast==[]:
			continue
		print("cast_condition=",cast_condition)
		if not cast_condition.is_empty():
			var new_cast=get_pu_ids_satisfying_condition(cast,cast_condition)
			print_debug("New cast=",new_cast)
			if new_cast.is_empty():
				continue
			cast=new_cast
		for single_skill_info in skill_info_array:
			print("single_skill_info="+str(single_skill_info))
			match single_skill_info["Name"]:
				"Potion creation":
					await create_potion(single_skill_info["Potions"])
				"Field Change":
					change_field(single_skill_info,Globals.self_pu_id)
				"Field Creation":
					await field.capture_field_kletki(single_skill_info["Amount"],single_skill_info["Config"])
				"Field Manipulation":
					await field.field_manipulation(single_skill_info)
				"Roll dice for effect":
					await roll_dice_for_result(single_skill_info,cast)
				_:#default/else
					rpc("add_buff",cast,single_skill_info)
		was_skill_used=true
	await get_tree().create_timer(2).timeout
	rpc("zoom_out_in_camera_before_buff",false)
	return was_skill_used


func change_field(skill:Dictionary,pu_id:String)->void:
	#field.field_status={"Default":"City","Field Buffs":[]}
	var new_skill=skill.duplicate(true)
	new_skill["Owner"]=pu_id
	field.field_status["Field Buffs"].append(new_skill)

	return

@rpc("any_peer","reliable","call_remote")
func reduce_field_skills_cooldowns(pu_id:String):
	var field_buffs=field.field_status.get("Field Buffs",[])
	if field_buffs.is_empty():
		return
	var buffs_to_remove:Array=[]

	for i in range(field_buffs.size()):
		print("i="+str(i)+" "+str(field_buffs[i]))
		var buff_owner=field_buffs[i].get("Owner",-1)
		if buff_owner!=pu_id:
			continue
		if field_buffs[i].has("Duration"):
			var buff_duration=field_buffs[i]["Duration"]
			print("field buff_name=",field_buffs[i]["Name"])
			if str(buff_duration).is_valid_float():
				if buff_duration-1<=0:
					field_buffs.append(field_buffs[i])
				else:
					#field_buffs[pu_id]["servant_node"].field_buffs[i]["Duration"]-=1
					field.field_status["Field Buffs"]["Duration"]-=1

	for i in buffs_to_remove:
		field.field_status["Field Buffs"].erase(i)
	return

func get_current_fields()->Array:
	var default_field=field.field_status.get("Default",["City"])
	var field_buffs=field.field_status.get("Field Buffs",[])
	var output_field=[]
	if field_buffs.is_empty():
		return default_field
	
	output_field.append_array(field_buffs)
	for buff in field_buffs:
		var field_name=buff.get("Field Name","")
		if field_name:
			output_field.append(field_name)

	return output_field

func get_pu_ids_satisfying_condition(cast:Array,cast_condition:Dictionary)->Array:
	print("get_pu_ids_satisfying_condition=",cast," condition=",cast_condition)
	var condition=cast_condition.get("Condition","")
	var output:Array=[]
	for pu_id in cast:
		match condition:
			"Trait":
				var condition_trait=cast_condition.get("Trait","")
				var peer_traits=get_pu_id_traits(pu_id)
				if condition_trait in peer_traits:
					output.append(pu_id)
			"Class":
				var serv_class=cast_condition.get("Class","")
				var peer_class=get_pu_id_class(pu_id)
				if serv_class == peer_class:
					output.append(pu_id)
			"Gender":
				var serv_gender=cast_condition.get("Gender","")
				var peer_gender=get_pu_id_gender(pu_id)
				if peer_gender == serv_gender:
					output.append(pu_id)
			"Buff":
				var buff_name=cast_condition.get("Buff","")
				if pu_id_has_buff(pu_id,buff_name):
					output.append(pu_id)
	return output




func create_potion(potions_dict):
	print("\ncreate_potion")
	print("potions_dict="+str(potions_dict))
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
	
	
	fill_custom_thing(potions_dict,CUSTOM_TYPES.POTION_CREATING)
	
	field.hide_all_gui_windows("use_custom")
	
	pass

#@rpc("any_peer","reliable","call_local")
func reduce_all_cooldowns(pu_id,type="Turn Started"):
	match type:
		"Turn Started":
			await reduce_buffs_cooldowns(pu_id,type)
			rpc("reduce_buffs_cooldowns",pu_id,type)
			#await buffs_cooldown_reduced
			
			await reduce_skills_cooldowns(pu_id,type)
			rpc("reduce_skills_cooldowns",pu_id,type)

			await reduce_field_skills_cooldowns(pu_id)
			rpc("reduce_field_skills_cooldowns",pu_id)

			#await skills_cooldown_reduced
			print("skills_cooldown_reduced")
		"End Turn":
			await reduce_buffs_cooldowns(pu_id,type)
			rpc("reduce_buffs_cooldowns",pu_id,type)
			#await buffs_cooldown_reduced
	
	field.update_field_icon()




@rpc("any_peer","reliable","call_remote")
func reduce_buffs_cooldowns(pu_id:String,type="Turn Started"):
	
	print("reduce_buffs_cooldowns\n\n")
	var buffs=Globals.pu_id_player_info[pu_id]["servant_node"].buffs
	print("\nbuffs="+str(buffs))
	var buffs_list_to_remove=[]
	
	for i in range(buffs.size()):
		print("i="+str(i)+" "+str(buffs[i]))
		if buffs[i].has("Duration"):
			var buff_duration=buffs[i]["Duration"]
			print("buff_name=",buffs[i]["Name"])
			if str(buff_duration).is_valid_float():
				match type:
					"End Turn":
						if buff_duration - int(buff_duration)!=0:#if duration 0.5 then it is reduced and the end of the turn
							if buff_duration-1<=0:
								buffs_list_to_remove.append(buffs[i])
							else:
								Globals.pu_id_player_info[pu_id]["servant_node"].buffs[i]["Duration"]-=1
							continue
					"Turn Started":
						if buff_duration-1<=0:
							print_debug("removing buff")
							buffs_list_to_remove.append(buffs[i])
						else:
							Globals.pu_id_player_info[pu_id]["servant_node"].buffs[i]["Duration"]-=1
					_:
						push_error("attemt reducing buffs cooldown with unhandled type=",type)
			
	print("\nbuffs_list_to_remove="+str(buffs_list_to_remove))
	
	#it is removing buff by erasing full inclusion so it it valid
	#it is removing not by ids
	for i in buffs_list_to_remove:
		Globals.pu_id_player_info[pu_id]["servant_node"].buffs.erase(i)
	
	#remove_buffs_for_peer_id_at_index_array(peer_id,buffs_list_to_remove)
	
	
	buffs_cooldown_reduced.emit()
	
@rpc("any_peer","reliable","call_remote")
func reduce_skills_cooldowns(pu_id:String,_type="Turn Started",amount:int=1):
	for i in range(Globals.pu_id_player_info[pu_id]["servant_node"].skill_cooldowns.size()):
		Globals.pu_id_player_info[pu_id]["servant_node"].skill_cooldowns[i]-=amount
		if Globals.pu_id_player_info[pu_id]["servant_node"].skill_cooldowns[i]<=0:
			Globals.pu_id_player_info[pu_id]["servant_node"].skill_cooldowns[i]=0
	
	skills_cooldown_reduced.emit()


@rpc("any_peer","reliable","call_local")
func reduce_custom_param(pu_id:String,buff_id_array:Array,param:String):
	print_debug("reduce_custom_param, pu_id=",pu_id," param=",param," buff_id_array=",buff_id_array)
	buff_id_array.sort()
	print_debug("buff_id_array.size()=",buff_id_array.size())
	print_debug(range(buff_id_array.size() - 1, -1, -1))
	#for i in range(0,buff_id_array.size(),-1):
	for i in range(buff_id_array.size() - 1, -1, -1):
		var buff_id=buff_id_array[i]
		print("buff_id=",buff_id)
		if Globals.pu_id_player_info[pu_id]["servant_node"].buffs[buff_id][param]-1<=0:
			Globals.pu_id_player_info[pu_id]["servant_node"].buffs.pop_at(buff_id)
			print_debug("buff popped at",buff_id)
		else:
			Globals.pu_id_player_info[pu_id]["servant_node"].buffs[buff_id][param]-=1
			print_debug("param=",param," reduces")

@rpc("any_peer","reliable","call_local")
func remove_buffs_for_pu_id_at_index_array(pu_id:String,ids:Array)->void:
	ids.sort()
	for i in range(ids.size() - 1, -1, -1):
		var buff_id=ids[i]
		print_debug("buff_id=",buff_id)
		Globals.pu_id_player_info[pu_id]["servant_node"].buffs.pop_at(buff_id)
		print_debug("buff popped at",buff_id)

func trigger_buffs_on(pu_id:String,trigger:String,triggered_by_pu_id=null):
	var buffs=Globals.pu_id_player_info[pu_id]["servant_node"].buffs
	var i=0
	var buffs_ids_to_reduce_trigger_uses:Array=[]
	var buffs_to_reduce_custom_param:Array=[]
	var count=0
	print("trigger_buffs_on="+str(trigger)+" triggered_by_pu_id="+str(triggered_by_pu_id))
	for buff in buffs:
		var buff_trigger=buff.get("Trigger","")
		if buff_trigger:
			if buff_trigger==trigger or (buff_trigger=="Turns Dividable By Power" and trigger=="Turn Started") \
			or (buff_trigger=="Delayed Effect" and trigger=="Turn Started"):
				if buff_trigger=="Turns Dividable By Power":
					if buff.get("Power"):
						if buff["Power"]==0:
							continue
						#print_debug("turns_counter=",turns_counter-1," buff[Power]=",buff["Power"])
						if not ((turns_counter) % buff["Power"]==0):
							continue
				
				if buff_trigger=="Delayed Effect":
					var after_turns=buff.get("Effect After Turns",0)
					#var turn_casted=buff.get("Turn Casted",0)
					buffs_to_reduce_custom_param.append({"Id":count,"Param":"Effect After Turns"})
					if after_turns-1>0:
						continue
					

				if not buff.has("Effect On Trigger"):
					if buff.has("Total Trigger Uses"):
						buffs_ids_to_reduce_trigger_uses.append(count)
					continue
				print("trigger="+str(trigger)+" effect"+str(buff["Effect On Trigger"]))
				if typeof(buff["Effect On Trigger"])==TYPE_STRING:#if set action string
					match buff["Effect On Trigger"]:
						"Take Damage By Power":
							rpc("take_damage_to_pu_id",pu_id,buff["Power"])
						"pull enemies on attack":
							field.pull_enemy(field.attacking_pu_id)
						_:
							push_error("Wrong set trigger effect="+str(buff["Effect On Trigger"]))
				else:
					print("using trigger buff")
					var buffs_to_add=buff["Effect On Trigger"].duplicate(true)
					if typeof(buffs_to_add)==TYPE_DICTIONARY:
						buffs_to_add=[buffs_to_add]

					for effect in buffs_to_add:
						await use_skill(effect,[triggered_by_pu_id])
					#buffs_ids_to_reduce_trigger_uses.append(buff)
					if buff.has("Total Trigger Uses"):
						buffs_ids_to_reduce_trigger_uses.append(count)
						
						#rpc("reduce_custom_param",pu_id,i,"Total Trigger Uses")

		count+=1
		
	for buff in buffs:#defencive buffs
		if trigger=="Damage Taken":
			match buff["Name"]:
				"Invincibility":
					if buff.has("Hit Times"):
						rpc("reduce_custom_param",pu_id,[i],"Hit Times")
						break
		i+=1
	if !buffs_ids_to_reduce_trigger_uses.is_empty():
		rpc("reduce_custom_param",pu_id,buffs_ids_to_reduce_trigger_uses,"Total Trigger Uses")
	
	for buff in buffs_to_reduce_custom_param:
		print_debug("buffs_to_reduce_custom_param=",buff)
		rpc("reduce_custom_param",pu_id,[buff["Id"]],buff["Param"])
	
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
	if trigger=="End Turn":
		if field.current_kletka!=-1:
			var cu_klet_config=field.kletka_preference[field.current_kletka]
			#{ "Owner": 1, "Np Up Every N Turn": 1,"turn_casted":1 , "Additional": <null> }
			#print("type="+str(typeof(cu_klet_config)))
			if not cu_klet_config.is_empty():
				print("\n\ncu_klet_config="+str(cu_klet_config))
				if cu_klet_config["Owner"]==pu_id:
					print(str("cu_klet_config[owner]=",cu_klet_config["Owner"]))
					if cu_klet_config.has("Np Up Every N Turn"):
						print(str("cal=",turns_counter,"-",cu_klet_config["turn_casted"],"%",cu_klet_config["Np Up Every N Turn"],"=",(turns_counter-cu_klet_config["turn_casted"])%cu_klet_config["Np Up Every N Turn"]))
						if (turns_counter-cu_klet_config["turn_casted"])%cu_klet_config["Np Up Every N Turn"]==0:
							
							print("TRRRR")
							rpc("charge_np_to_pu_id_by_number",pu_id,1)
		
	
	if trigger=="Turn Started":
		remove_all_expired_captured_kletki()
			

func remove_all_expired_captured_kletki():
	print("remove_all_expired_captured_kletki")
	var kletki_id_array=field.kletka_preference.keys()
	#{ "Owner": 1, "Np Up Every N Turn": 1,"turn_casted":1 , "Additional": <null> }
	#print("type="+str(typeof(cu_klet_config)))
	for kletka_id in kletki_id_array:
		if field.kletka_preference[kletka_id].is_empty():
			continue
		var cu_klet_config=field.kletka_preference[kletka_id]
		print("Found kletka captured")
		print(cu_klet_config)
		if cu_klet_config.has("Duration"):
			if cu_klet_config["Owner"]==current_player_pu_id_turn:
				print("Is owner turn=true")
				var kletka_duration=cu_klet_config["Duration"]
				var turn_casted=cu_klet_config.get("Turn Casted",1)
				#cur turn 6
				#casted 3
				#6-3=3
				print("\n duration= ",turns_counter,"-",turn_casted,">",kletka_duration)
				if turns_counter-turn_casted>kletka_duration:
					print("duration expired")
					field.kletka_preference[field.current_kletka]={}
					for captured in field.get_all_children(field.captured_kletki_node):
						if captured.name=="field "+str(kletka_id):
							captured.queue_free()

@rpc("any_peer","reliable","call_local")
func roll_dice_for_result(skill_info:Dictionary,cast:Array):
	await field.await_dice_roll()
	var dice_result=field.dice_roll_result_list
	var is_casted=null
	field.systemlog_message(str(Globals.nickname," thowing to decide bad status"))
	for pu_id in cast:
		is_casted=null
		var pu_peer_id=Globals.pu_id_player_info[pu_id]["current_peer_id"]
		while true:
			field.rpc_id(pu_peer_id,"receice_dice_roll_results",dice_result)
			field.rpc_id(pu_peer_id,"set_action_status",Globals.self_pu_id,"roll_dice_for_result")

			var status= await field.attack_response
			match status:
				"OK":
					pass
				"Disconnect":
					field.attack_responce_string="Getting bad status"
					field.rpc("systemlog_message",str(Globals.nickname," disconnected, applying effect"))
			
			match field.attack_responce_string:
				"Evaded bad status":
					is_casted=false
				"Even dice rolls, reroll for status":
					pass
				"Getting bad status":
					for single_skill in skill_info["Buff To Add"]:#shit
						rpc("add_buff",pu_id,single_skill)
					is_casted=true
			if is_casted!=null:
				break
		#field._on_dices_toggle_button_pressed()
	pass

func apply_madness_enhancement(pu_id:String,buff_info:Dictionary)->void:
	#already in rpc invoke
	var user_buffs=Globals.pu_id_player_info[pu_id]["servant_node"].buffs.duplicate(true)
	print_debug("apply_madness_enhancement, pu_id=",pu_id)
	var main_buff_duration=buff_info.get("Duration",1)
	var main_buff_power=buff_info.get("Power",2)
	for buff in user_buffs:
		print("buff=",buff)
		var buff_type= buff.get("Type","")
		if buff_type:
			print("buff not removed")
			continue
		print_debug("removing buff")
		await remove_buff([pu_id],buff.get("Name"))
	
	add_buff([pu_id],{"Name":"ATK Up X","Display Name":"Madness Enhancement","Type":"Status","Duration":main_buff_duration,"Power":main_buff_power})

	var smart=buff_info.get("Can Use 1 Skill",false)
	if smart:
		add_buff([pu_id],{"Name":"Maximum Skills Per Turn","Type":"Status","Power":1,"Duration":main_buff_duration})
	else:
		add_buff([pu_id],{"Name":"Skill Seal","Type":"Status","Duration":main_buff_duration})
	return

func reduce_custom_param_for_buff_name(pu_id:String,buff_name:String,param:String,first_only:bool=true):
	var buffs_ids=[]
	var pu_id_buffs_arr=Globals.pu_id_player_info[pu_id]["servant_node"].buffs
	for i in range(pu_id_buffs_arr.size()):
		if pu_id_buffs_arr[i]["Name"]==buff_name:
			if pu_id_buffs_arr[i].has(param):
				buffs_ids.append(i)
				if first_only:
					break
	reduce_custom_param(pu_id,buffs_ids,param)

func get_pu_id_class(pu_id:String)->String:
	var peer_node=Globals.pu_id_player_info[pu_id]["servant_node"]
	var default_peer_class=peer_node.servant_class
	
	var class_buff=pu_id_has_buff(pu_id,"Class Change")
	var buffs_class:String
	if class_buff:
		buffs_class = class_buff.get("Class","")
		if buffs_class in Globals.CLASS_NAMES:
			return buffs_class
		else:
			push_warning("Wrong class name=",class_buff)
	return default_peer_class

func intersect(array1, array2):
	for item in array1:
		if array2.has(item):
			return true
	return false


func pu_id_can_get_buff(pu_id:String,buff_info:Dictionary)->bool:
	var buff_block=pu_id_has_buff(pu_id,"Nullify Buff")
	var buff_block_types=[]
	if buff_block:
		buff_block_types.append_array(buff_block.get("Types To Block",["Buff Positive Effect"]))
	

	var debuff_immunity=pu_id_has_buff(pu_id,"Nullify Debuff")
	if debuff_immunity:
		buff_block_types.append_array(debuff_immunity.get("Types To Block",["Buff Negative Effect"]))

	var buff_types=buff_info.get("Types",[])
	if buff_types.is_empty():
		buff_types=Globals.buffs_types.get(buff_info.get("Name"),"")
		if not buff_types:
			push_error("No buff types found for buff=",buff_info)
	
	if buff_block and intersect(buff_block_types,buff_types):
		if buff_block.has("Uses"):
			reduce_custom_param_for_buff_name(pu_id,buff_info["Name"],"Uses")
		return false
	
	if debuff_immunity and "Buff Negative Effect" in buff_types:
		if debuff_immunity.has("Uses"):
			reduce_custom_param_for_buff_name(pu_id,buff_info["Name"],"Uses")
		return false
	return true

func buffs_removal(pu_id: String, buff_info: Dictionary) -> void:
	var buff_types_to_remove: Array = buff_info.get("Types To Remove", [])
	var is_buff_removal_resist=pu_id_has_buff(pu_id,"Buff Removal Resist")
	if is_buff_removal_resist:
		if "Buff Positive Effect" in buff_types_to_remove:
			buff_types_to_remove.erase("Buff Positive Effect")
	
	
	if buff_types_to_remove.is_empty():
		if is_buff_removal_resist:
			print("Buff removal resist, skipping")
		else:
			push_error("No buff types to remove. buff_info=", buff_info, "is_buff_removal_resist=",is_buff_removal_resist)
		return

	var amount_to_remove: int = buff_info.get("Amount", -1)
	var order: String = buff_info.get("Order", "Newest")
	
	var target_buffs_array: Array = Globals.pu_id_player_info[pu_id]["servant_node"].buffs
	if target_buffs_array.is_empty():
		return

	var indices_to_remove: Array = []

	for i in range(target_buffs_array.size()):
		var current_buff: Dictionary = target_buffs_array[i]
		print_debug("checking removing buff",current_buff)
		if current_buff.get("Type",""):
			print_debug("it has Type field, skipping")
			continue

		var buff_specific_types = current_buff.get("Types",[])
		
		
	
		#var actual_buff_types: Array = [] 
		if buff_specific_types.is_empty():
			var buff_name = current_buff.get("Name","")
			if buff_name!="":
				if Globals.buffs_types.has(buff_name):
					buff_specific_types = Globals.buffs_types[buff_name]
		
		print_debug("buff types=",buff_specific_types)
		if buff_specific_types.is_empty():
			push_warning("No Types found for buff",current_buff, " removing any way")
			indices_to_remove.append(i)
		elif intersect(buff_specific_types, buff_types_to_remove): 
			indices_to_remove.append(i)
			
	
	if indices_to_remove.is_empty():
		return
	
	
	print("indices_to_remove=",indices_to_remove)
	if amount_to_remove <= 0:
		pass
	else:
		match order:
			"Newest":
				print("newest=",indices_to_remove.size() - amount_to_remove,"   ",indices_to_remove.size() - 1)
				if indices_to_remove.size() > amount_to_remove:
					indices_to_remove = indices_to_remove.slice(indices_to_remove.size() - amount_to_remove, indices_to_remove.size())
			"Oldest":
				print("Oldest=",0,"   ", amount_to_remove)
				if indices_to_remove.size() > amount_to_remove:
					indices_to_remove = indices_to_remove.slice(0, amount_to_remove)
			_:
				push_error("Wrong order specified: ", order, ". buff_info=", buff_info)
				indices_to_remove.clear()
	
	if indices_to_remove.is_empty():
		return
	
	
	print_debug("removing buffs ids=",indices_to_remove)
	
	rpc("remove_buffs_for_pu_id_at_index_array",pu_id,indices_to_remove)
	
	
	#for index_val in indices_to_remove:
	#	if index_val >= 0 and index_val < target_buffs_array.size():
	#		target_buffs_array.remove_at(index_val)
	#	else:
	#		push_warning("Attempted to remove buff at out-of-bounds index: ", index_val)
	pass

func get_absorbs_buffs()->Array:
	var output=[]
	for pu_id in Globals.pu_id_player_info.keys():
		var ubsb=pu_id_has_buff(pu_id,"Absorb Buffs")
		if ubsb:
			output.append({"Buffs Names":ubsb.get("Buffs Names",[]),"Peer":pu_id})
	return output

@rpc("any_peer","reliable","call_local")
func add_buff(cast_array,skill_info:Dictionary):
	if typeof(cast_array)!=TYPE_ARRAY:
		cast_array=[cast_array]
	
	if skill_info.get("Type","")!="":
		var ubsorb=get_absorbs_buffs()
		print_debug("ubsorb=",ubsorb)
		for single_absorb in ubsorb:
			if skill_info["Name"] in single_absorb["Buffs Names"]:
				cast_array=[single_absorb["Peer"]]
	

	for who_to_cast_pu_id in cast_array:
		effect_on_buff(who_to_cast_pu_id,skill_info["Name"])
		if skill_info.get("Type",""):
			pass
		else:
			if not pu_id_can_get_buff(who_to_cast_pu_id,skill_info):
				continue
		match skill_info["Name"]:
			"Madness Enhancement":
				await apply_madness_enhancement(who_to_cast_pu_id,skill_info)
				#peer_id_player_info[who_to_cast_pu_id]["servant_node"].buffs=[]
				#peer_id_player_info[who_to_cast_pu_id]["servant_node"].buffs=[
				#	{"Name":"ATK Up X",
				#		"Type":"Status",
				#		"Duration":3,
				#		"Power":2},
				#	{"Name":"Skill Seal",
				#		"Type":"Status",
				#		"Duration":3}
				#	]
			"NP Charge":
				charge_np_to_pu_id_by_number(who_to_cast_pu_id,skill_info.get("Power",1),"Skill")
			"Reduce Skills Cooldown":
				reduce_skills_cooldowns(who_to_cast_pu_id,"skill",skill_info.get("Power",1))
			"Buff Removal":
				buffs_removal(who_to_cast_pu_id,skill_info)
			"Debuff Removal":
				buffs_removal(who_to_cast_pu_id,skill_info)
			"NP Discharge":
				charge_np_to_pu_id_by_number(who_to_cast_pu_id,-skill_info.get("Power",1),"Skill")
			"Multiply NP":
				var current_peer_id_np:int=pu_id_to_np_points[who_to_cast_pu_id]
				var multyply_power=skill_info.get("Power",1)-1
				var end_np_points:int=ceil(current_peer_id_np*multyply_power)
				end_np_points=min(end_np_points,12)
				charge_np_to_pu_id_by_number(who_to_cast_pu_id,end_np_points,"Skill")
			"Heal":
				heal_pu_id(who_to_cast_pu_id,skill_info.get("Power",5))
			"HP Drain":
				heal_pu_id(who_to_cast_pu_id,-skill_info.get("Power",5),"Drain")
			"Additional Move":
				reduce_additional_moves_for_pu_id(who_to_cast_pu_id,-1)
			"Delayed Effect":
				skill_info["Turn Casted"]=turns_counter
				Globals.pu_id_player_info[who_to_cast_pu_id]["servant_node"].buffs.append(skill_info)
			"Faceless Moon":
				skill_info["Dices"]=field.dice_roll_result_list.duplicate(true)
				Globals.pu_id_player_info[who_to_cast_pu_id]["servant_node"].buffs.append(skill_info)
			"Presence Concealment":
				start_presence_concealment_for_pu_id(who_to_cast_pu_id)
				var copy_info=skill_info.duplicate(true)
				copy_info["Turn Casted"]=turns_counter
				Globals.pu_id_player_info[who_to_cast_pu_id]["servant_node"].buffs.append(copy_info)
			"Invincibility":#if power==0 then all turns else for N hits
				Globals.pu_id_player_info[who_to_cast_pu_id]["servant_node"].buffs.append(skill_info)
			_:#else
				Globals.pu_id_player_info[who_to_cast_pu_id]["servant_node"].buffs.append(skill_info)
	pass

@rpc("any_peer","reliable","call_local")
func start_presence_concealment_for_pu_id(pu_id:String):
	Globals.pu_id_player_info[pu_id]["servant_node"].visible=false
	var cur_kletka_before=field.current_kletka
	if pu_id==Globals.self_pu_id:
		field.current_kletka=-1
	field.occupied_kletki.erase(cur_kletka_before)
	field.pu_id_to_kletka_number[pu_id]=-1
	pass

@rpc("any_peer","reliable","call_local")
func zoom_out_in_camera_before_buff(zoom_out=true):

	return#TODO implement later
	print("\nzoom_out_in_camera_before_buff")
	if zoom_out:
		print("zoom out")
		last_camera_positon=$"../Camera2D".position
		last_camera_zoom=$"../Camera2D".zoom
		await get_tree().create_timer(0.1).timeout
		$"../Camera2D".position=start_camera_position
		$"../Camera2D".zoom=start_camera_zoom
	else:
		print("zoom in")
		await get_tree().create_timer(0.1).timeout
		$"../Camera2D".position=last_camera_positon
		$"../Camera2D".zoom=last_camera_zoom

@rpc("any_peer","reliable","call_local")
func effect_on_buff(pu_id_buff_given_to:String,buff_name)->void:
	for i in range (10):
		Globals.pu_id_player_info[pu_id_buff_given_to]["servant_node"].get_child(1).modulate=Color(1,1,1,i*0.1)
		await get_tree().create_timer(0.05).timeout
	Globals.pu_id_player_info[pu_id_buff_given_to]["servant_node"].get_child(2).text=buff_name
	
	for i in range (5):
		Globals.pu_id_player_info[pu_id_buff_given_to]["servant_node"].get_child(2).modulate=Color(1,1,1,i*0.2)
		await get_tree().create_timer(0.006).timeout
	
	
	await get_tree().create_timer(0.1).timeout
	for i in range (10,-1,-1):
		Globals.pu_id_player_info[pu_id_buff_given_to]["servant_node"].get_child(1).modulate=Color(1,1,1,i*0.1)
		Globals.pu_id_player_info[pu_id_buff_given_to]["servant_node"].get_child(2).modulate=Color(1,1,1,i*0.1)
		await get_tree().create_timer(0.05).timeout
	
	pass

@rpc("any_peer","reliable","call_local")
func remove_buff(cast_array:Array,skill_name:String,remove_passive=false,remove_only_passive_one=false):
	#remove SINGLE BUFF
	#if need to remove bath then await buff_removed to sync
	for who_to_remove_buff_pu_id in cast_array:
		var i=0
		for buff in Globals.pu_id_player_info[who_to_remove_buff_pu_id]["servant_node"].buffs:
			if buff["Name"]==skill_name:
				var buf_type=buff.get("Type","")
				if buf_type=="Status":
					continue
				if buf_type=="Passive":
					if remove_passive: 
						Globals.pu_id_player_info[who_to_remove_buff_pu_id]["servant_node"].buffs.pop_at(i)
						buff_removed.emit()
						return
				else:
					Globals.pu_id_player_info[who_to_remove_buff_pu_id]["servant_node"].buffs.pop_at(i)
					buff_removed.emit()
					return
			i+=1
	buff_removed.emit()
	

func get_pu_id_maximun_hp(pu_id:String)->int:
	var servant_node:Node2D=Globals.pu_id_player_info[pu_id]["servant_node"]
	var default_max_hp:int=servant_node.default_stats["hp"]
	var additional_hp:int=0
	for buff:Dictionary in get_pu_id_buffs(pu_id):
		if buff.get("Name","")=="Max HP Plus":
			additional_hp+=buff.get("Power",1)

	return default_max_hp+additional_hp

func heal_pu_id(pu_id:String,amount:int,type:String="normal"):
	print(str("\nheal_pu_id=",pu_id," by ",amount))
	
	
	var servant_node_to_heal:Node2D=Globals.pu_id_player_info[pu_id]["servant_node"]
	var current_hp:int=servant_node_to_heal.hp
	var amount_to_heal:int
	var max_hp:int=get_pu_id_maximun_hp(pu_id)
	if type=="command_spell":
		amount_to_heal=ceil(max_hp*0.7)
	else:#command spell is static 70%
		amount_to_heal=amount
		for buff in get_pu_id_buffs(pu_id):
			match buff["Name"]:
				"HP Recovery Up":
					amount_to_heal+=buff["Power"]
				"HP Recovery Up X":
					amount_to_heal*=buff["Power"]
	
	#amount_to_heal=max(amount_to_heal,1)
	print_debug("current_hp+amount_to_heal=",current_hp+amount_to_heal)
	var set_one_hp=false
	if current_hp+amount_to_heal<=0:
		set_one_hp=true
	if current_hp+amount_to_heal>max_hp:
		if set_one_hp:
			servant_node_to_heal.hp=1
		else:
			servant_node_to_heal.hp=max_hp
	else:
		if set_one_hp:
			servant_node_to_heal.hp=1
		else:
			servant_node_to_heal.hp+=amount_to_heal
	
	

	rpc("update_hp_on_pu_id",pu_id,servant_node_to_heal.hp)
	print(str("hp now is ",servant_node_to_heal.hp,"\n"))
	
func _process(_delta):
	pass

@rpc("any_peer","call_local","reliable")
func charge_np_to_pu_id_by_number(pu_id:String,number:int,source="damage"):
	print("\n===charge_np_to_pu_id_by_number===")
	print("pu_id_to_np_points[pu_id]="+str(pu_id_to_np_points[pu_id])+"+"+str(number))
	var number_to_add=number
	for skill in Globals.pu_id_player_info[pu_id]["servant_node"].buffs:
		match skill["Name"]:
			"NP Gain Up" when source=="damage":
				number_to_add+=skill["Power"]
			"NP Gain Up X" when source=="damage":
				number_to_add*=skill["Power"]
	#number_to_add=max(0,number_to_add)
	pu_id_to_np_points[pu_id]+=number_to_add
	
	if pu_id_to_np_points[pu_id]<0:
		pu_id_to_np_points[pu_id]=0
	if pu_id_to_np_points[pu_id]>12:
		pu_id_to_np_points[pu_id]=12
	#change_phantasm_charge_on_pu_id
	if pu_id==Globals.self_pu_id:
		Globals.self_servant_node.phantasm_charge=pu_id_to_np_points[pu_id]
		$"../GUI/action/np_points_number_label".text=str(pu_id_to_np_points[pu_id])


func get_pu_id_traits(pu_id:String)->Array:
	var pu_node=Globals.pu_id_player_info[pu_id]["servant_node"]
	var default_traits:Array=pu_node.traits
	var output_traits:Array=default_traits.duplicate(true)
	for buff in get_pu_id_buffs(pu_id):
		if buff.get("Name")=="Trait Set":
			var buff_trait:String=buff.get("Trait","")
			if buff_trait:
				output_traits.append(buff_trait)

	return output_traits

func get_pu_id_gender(pu_id:String)->String:
	var pu_node=Globals.pu_id_player_info[pu_id]["servant_node"]
	var default_gender:String=pu_node.gender
	var output_gender:String=default_gender+""
	for buff in get_pu_id_buffs(pu_id):
		if buff.get("Name")=="Gender Set":
			var gennder:String=buff.get("Gender","")
			if gennder:
				output_gender=gennder

	return output_gender

func get_pu_id_strength(pu_id:String)->String:
	var pu_node=Globals.pu_id_player_info[pu_id]["servant_node"]
	var default_strength:String=pu_node.strength
	var output_strength:String=default_strength+""
	for buff in get_pu_id_buffs(pu_id):
		if buff.get("Name")=="Strength Set":
			var gennder:String=buff.get("Strength","")
			if gennder:
				output_strength=gennder

	return output_strength


func calculate_damage_to_take(attacker_pu_id:String,enemies_dice_results:Dictionary,damage_type:String="normal",special:String="regular"):
	#damage_type="normal"/"Magical"
	#special is to half the damage bc evade or defence
	print("calculating damage to take\n\n")
	
	var zero_damage=false
	
	#Магический урон у сейберов сначала делится на 2 потом вычитается магическая защита
	var damage_to_take
	var attacker_damage
	var self_defence=0
	var buff_types_to_ignore=[]
	var is_field_ignore_magic_defence=false
	var is_crit=false
	var crit_removed=false
	var damage_before_crit:int=0
	var self_traits=get_pu_id_traits(Globals.self_pu_id)
	var attacker_traits=get_pu_id_traits(attacker_pu_id)
	var additional_buffs=[]
	if damage_type=="Magical":
		damage_to_take=Globals.pu_id_player_info[attacker_pu_id]["servant_node"].magic["Power"]
		
		var cur_kletka_conf=field.kletka_preference[field.current_kletka]
		if cur_kletka_conf.is_empty():
			is_field_ignore_magic_defence=false
		else:
			if cur_kletka_conf.get("Owner",-1)==attacker_pu_id and cur_kletka_conf.get("Ignore Magical Defence",false):
				is_field_ignore_magic_defence=true
	else:
		damage_to_take=Globals.pu_id_player_info[attacker_pu_id]["servant_node"].attack_power
	
	if damage_type=="Phantasm":
		if !field.recieved_phantasm_config.is_empty():#for phantasm damage
			damage_to_take=field.recieved_phantasm_config["Damage"]
			if field.recieved_phantasm_config.has("Ignore"):
				buff_types_to_ignore=field.recieved_phantasm_config["Ignore"]
		additional_buffs= field.recieved_phantasm_config.get("Phantasm Buffs",[])
		
	print("damage_type="+str(damage_type)+" damage_to_take="+str(damage_to_take))
	
	#calculating attacker damage
	print("calculating attacker damage")

	#damage_to_take=get_peer_id_attack_power(attacker_peer_id,damage_type,[],additional_buffs)

	damage_to_take=calculate_pu_id_attack_against_pu_id(attacker_pu_id,Globals.self_pu_id,damage_type)
	
	is_crit=check_if_pu_id_got_crit(attacker_pu_id,enemies_dice_results)
	
	if is_crit:
		damage_before_crit=damage_to_take
		damage_to_take=calculate_crit_damage(attacker_pu_id,damage_to_take)
	
	print("calculating ignore buffs")
	
	for buff in buff_ignoring:
		if pu_id_has_buff(Globals.self_pu_id, buff):
			match buff:
				"Ignore Defence":
					buff_types_to_ignore.append("Defence")
				"Ignore DEF Buffs":
					buff_types_to_ignore.append("Buff Increase Defence")
				"Ignore Invincible":
					buff_types_to_ignore.append("Buff Invincible")
				"Sure Hit":
					buff_types_to_ignore.append("Buff Evade")
				"Ignore Evade":
					buff_types_to_ignore.append("Evade")

	
	
	
	var defence_multiplier=1
	#calculating self defence
	print("calculating self defence")
	#for skill in peer_id_player_info[Globals.self_peer_id]["servant_node"].buffs:
	for skill in get_pu_id_buffs(Globals.self_pu_id):
		var skill_type_array
		if skill.has("Types"):
			skill_type_array=skill["Types"]
		else:
			skill_type_array=Globals.buffs_types.get(skill["Name"],[])
		
		if skill_type_array.is_empty():
			push_error("No types found for skill=",skill)
			continue
		var ignore=false
		for skill_type in skill_type_array:
			for skill_to_ignore in buff_types_to_ignore:
				if skill_type==skill_to_ignore:
					ignore=true
		if ignore:
			continue
		match skill["Name"]:
			"Def Down X":
				defence_multiplier*=skill["Power"]
			"Def Down":
				damage_to_take+=skill["Power"]
			"Def Up":
				damage_to_take-=skill["Power"]
			"Def Up X":
				defence_multiplier=floor(damage_to_take/skill["Power"])
			"NP Damage Def Up":
				damage_to_take-=skill["Power"]
			"NP Damage Def Up X":
				defence_multiplier=floor(damage_to_take/skill["Power"])
			"Evade":
				return "evaded"
			"Invincibility":#if power==0 then all turns else for N hits
				zero_damage=true
				damage_to_take*=0
				break
			"Def Up Against Trait":
				if skill["Trait"] in attacker_traits:
					damage_to_take-=skill["Power"]
			"Def Up X Against Trait":
				if skill["Trait"] in attacker_traits:
					defence_multiplier=1.0/skill["Power"]
			"Def Down Against Trait":
				if skill["Trait"] in attacker_traits:
					damage_to_take+=skill["Power"]
			"Def Down X Against Trait":
				if skill["Trait"] in attacker_traits:
					defence_multiplier*=skill["Power"]
					
		var out_string=str("Buff= ",skill["Name"])
		if skill.has("Power"):
			out_string+=str(" power=",skill["Power"])
		out_string+=str(" damage_to_take=",damage_to_take)
		print(out_string)
	
	damage_to_take*=defence_multiplier
	
	if special=="Halfed Damage":
		damage_to_take=floor(damage_to_take/2)
		print("Halfed Damage   damage_to_take="+str(damage_to_take))
	
	if damage_type=="Magical":
		if not is_field_ignore_magic_defence:
			damage_to_take-=Globals.self_servant_node.magic["resistance"]
			print(str("magical resistange=",Globals.self_servant_node.magic["resistance"]," damage_to_take=",damage_to_take))
		else:
			print("field is ignoring magical defence")
		if Globals.pu_id_player_info[attacker_pu_id]["servant_node"].servant_class=="Saber":
			damage_to_take=floor(damage_to_take/2)
			print(str("Saber resistance", "damage_to_take=",damage_to_take))
		
	elif special=="Defence":
		var ignore=false
		if "Defence" in buff_types_to_ignore:
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
		
	trigger_buffs_on(Globals.self_pu_id,"Damage Taken",attacker_pu_id)
	trigger_buffs_on(Globals.self_pu_id,damage_type+" Damage Taken",attacker_pu_id)
	
	
	print(str("damage_to_take=",damage_to_take," type=",damage_type,"\n\n"))
	
	return damage_to_take

@rpc("any_peer","reliable","call_local")
func take_damage_to_pu_id(pu_id:String,damage_amount:int,can_kill:bool=true)->void:
	var start_hp=Globals.pu_id_player_info[pu_id]["servant_node"].hp
	var new_hp=start_hp-damage_amount
	
	if not can_kill and new_hp<=0:
		new_hp=1
	
	change_game_stat_for_pu_id(pu_id,"total_damage_taken",damage_amount)
	
	
	
	rpc("update_hp_on_pu_id",pu_id,new_hp)
	if pu_id==Globals.self_pu_id:
		field.rpc("systemlog_message",str(Globals.nickname," took ",damage_amount," damage, now HP=", new_hp))
	print(str(Globals.pu_id_to_nickname[pu_id]," HP is ",new_hp," now"))
	
	if new_hp<=0:
		print("death")
		trigger_death_to_pu_id(pu_id)


func trigger_death_to_pu_id(pu_id:String):
	#TODO replace loop with this func
	#if peer_id_has_buff(Globals.self_peer_id, buff):
	var guts_buff=pu_id_has_buff(pu_id,"Guts")
	if guts_buff:
		var hp_to_recover=guts_buff.get("HP To Recover",1)
		heal_pu_id(pu_id,hp_to_recover)
		trigger_buffs_on(pu_id,"Guts Used")
		rpc("remove_buff",[pu_id],"Guts")
		return
	
	if pu_id_to_command_spells_int[pu_id]>=3:
		var max_hp=Globals.pu_id_player_info[pu_id]["servant_node"].default_stats["hp"]
		rpc("update_hp_on_pu_id",pu_id,max_hp)
		reduce_command_spell_on_pu_id(pu_id)
		reduce_command_spell_on_pu_id(pu_id)
		reduce_command_spell_on_pu_id(pu_id)
		trigger_buffs_on(pu_id,"Command Spell Revive")
	else:#total death
		for i in range(9):
			Globals.pu_id_player_info[pu_id]["servant_node"].rotation_degrees+=10
			await get_tree().create_timer(0.1).timeout
			turns_order_by_pu_id.erase(pu_id)
	


@rpc("any_peer","reliable","call_local")
func update_hp_on_pu_id(pu_id:String,hp_to_set:int)->void:
	if pu_id==Globals.self_pu_id:
		current_hp_value_label.text=str(hp_to_set)
	Globals.pu_id_player_info[pu_id]["servant_node"].hp=hp_to_set

func _on_texture_rect_gui_input(event)->void:
	if event.is_action_pressed:
		print(event)
	pass # Replace with function body.

@rpc("any_peer","reliable","call_local")
func reduce_additional_moves_for_pu_id(pu_id:String,amount:int=1)->void:
	Globals.pu_id_player_info[pu_id]["servant_node"].additional_moves-=amount

@rpc("any_peer","reliable","call_local")
func set_pu_id_cooldown_for_skill_id(pu_id:String,skill_number,cooldown)->void:
	Globals.pu_id_player_info[pu_id]["servant_node"].skill_cooldowns[skill_number]=cooldown
	

func _on_use_skill_button_pressed():
	print("[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]")
	print(skill_info_tab_container.current_tab)
	field.hide_all_gui_windows("skill_info_tab_container")

	$"../GUI/actions_buttons/Skill".disabled=true
	field.skill_info_show_button.disabled=true
	var skill_consume_action=true
	var succesfully
	match skill_info_tab_container.current_tab+1:
		1:
			#Globals.self_servant_node.first_skill()
			skill_consume_action= Globals.self_servant_node.skills["First Skill"].get("Consume Action",true)

			succesfully=await use_skill(Globals.self_servant_node.skills["First Skill"]["Effect"])
			if succesfully:
				rpc("set_pu_id_cooldown_for_skill_id",Globals.self_pu_id,0,
				Globals.self_servant_node.skills["First Skill"]["Cooldown"])
		2:
			#Globals.self_servant_node.second_skill()
			skill_consume_action= Globals.self_servant_node.skills["Second Skill"].get("Consume Action",true)
			succesfully=await use_skill(Globals.self_servant_node.skills["Second Skill"]["Effect"])
			if succesfully:
				rpc("set_pu_id_cooldown_for_skill_id",Globals.self_pu_id,1,
				Globals.self_servant_node.skills["Second Skill"]["Cooldown"])
		3:
			#Globals.self_servant_node.third_skill()
			skill_consume_action= Globals.self_servant_node.skills["Third Skill"].get("Consume Action",true)
			succesfully=await use_skill(Globals.self_servant_node.skills["Third Skill"]["Effect"])
			if succesfully:
				rpc("set_pu_id_cooldown_for_skill_id",Globals.self_pu_id,2,
				Globals.self_servant_node.skills["Third Skill"]["Cooldown"])
		4:
			var class_skill_number= skill_info_tab_container.get_current_tab_control().current_tab+1

			skill_consume_action= Globals.self_servant_node.skills["Class Skill "+str(class_skill_number)].get("Consume Action",true)
			if Globals.self_servant_node.skills["Class Skill "+str(class_skill_number)]["Type"]=="Weapon Change":
				#print(skill_info_tab_container.get_current_tab_control().get_current_tab_control())
				var weapon_name_to_change_to=skill_info_tab_container.get_current_tab_control().get_current_tab_control().get_current_tab_control().name
				var tt=skill_info_tab_container.get_current_tab_control()
				var tt2=tt.get_current_tab_control()
				print(tt2.name)
				#var tt3=tt2.get_current_tab_control()
				print("eee")
				
				rpc("set_pu_id_cooldown_for_skill_id",Globals.self_pu_id,2+class_skill_number,
				Globals.self_servant_node.skills["Class Skill "+str(class_skill_number)]["Cooldown"])
				succesfully=true#idk
				change_weapon(weapon_name_to_change_to,class_skill_number)
			else:
				#Globals.self_servant_node.call("Class Skill "+str(class_skill_number))
				succesfully=await use_skill(Globals.self_servant_node.skills["Class Skill "+str(class_skill_number)]["Effect"])
				if succesfully:
					rpc("set_pu_id_cooldown_for_skill_id",Globals.self_pu_id,2+class_skill_number,
					Globals.self_servant_node.skills["Class Skill "+str(class_skill_number)]["Cooldown"])
	if skill_consume_action and succesfully:
		field.reduce_one_action_point()
	if succesfully:
		rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"skill_used_this_turn",1)
		rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"total_skill_used",1)
	$"../GUI/actions_buttons/Skill".disabled=false
	field.skill_info_show_button.disabled=false
	pass # Replace with function body.

func pu_id_has_buff(pu_id:String,buff_name:String):
	for buff in Globals.pu_id_player_info[pu_id]["servant_node"].buffs:
		if buff["Name"].to_lower()==buff_name.to_lower():
			return buff
	return false

@rpc("any_peer","call_local","reliable")
func change_pu_id_servant_stat(pu_id:String,stat:String,value:int)->void:
	match stat:
		"attack_range":
			Globals.pu_id_player_info[pu_id]["servant_node"].attack_range=value
		"attack_power":
			Globals.pu_id_player_info[pu_id]["servant_node"].attack_power=value

@rpc("any_peer","call_local","reliable")
func change_pu_id_sprite(pu_id:String,image_path:String)->void:
	var img = Image.new()
	img.load(image_path)
	#player_textureRect.texture=ImageTexture.create_from_image(img)
	Globals.pu_id_player_info[pu_id]["servant_node"].get_child(0).texture=ImageTexture.create_from_image(img)

func change_weapon(weapon_name_to_change_to,class_skill_number)->void:
	var weapons_array=Globals.self_servant_node.skills["Class Skill "+str(class_skill_number)]["weapons"]
	if weapons_array[Globals.self_servant_node.current_weapon].has("Buff"):
		var buff_array_to_remove=weapons_array[Globals.self_servant_node.current_weapon]["Buff"]
		if typeof(buff_array_to_remove)!=TYPE_ARRAY:
			buff_array_to_remove=[buff_array_to_remove]
		for buff in buff_array_to_remove:
			rpc("remove_buff",[Globals.self_pu_id],buff["Name"],true)
	print("weapon_name_to_change_to="+str(weapon_name_to_change_to))
	
	Globals.self_servant_node.current_weapon=weapon_name_to_change_to
	var folderr=""
	if OS.has_feature("editor"):
		folderr="res"
	else:
		folderr="user"
	
	rpc("change_pu_id_sprite",Globals.self_pu_id,
	str(folderr)+"://servants/"+Globals.pu_id_player_info[Globals.self_pu_id]["servant_name"]+
	"/sprite_"+str(weapon_name_to_change_to).to_lower()+".png")
	
	rpc("change_pu_id_servant_stat",Globals.self_pu_id,"attack_range",weapons_array[weapon_name_to_change_to]["Range"])
	rpc("change_pu_id_servant_stat",Globals.self_pu_id,"attack_power",weapons_array[weapon_name_to_change_to]["Damage"])
	
	if weapons_array[weapon_name_to_change_to]["Is One Hit Per Turn"]:
		rpc("remove_buff",[Globals.self_pu_id],"Maximum Hits Per Turn",true,true)
		rpc("add_buff",[Globals.self_pu_id],{"Name":"Maximum Hits Per Turn","Duration":"Passive", "Power":1})
	else:
		rpc("remove_buff",[Globals.self_pu_id],"Maximum Hits Per Turn",true,true)
	
	
	if weapons_array[weapon_name_to_change_to].has("Buff"):
		var buff_array_to_add=weapons_array[weapon_name_to_change_to]["Buff"]
		if typeof(buff_array_to_add)!=TYPE_ARRAY:
			buff_array_to_add=[buff_array_to_add]
		for buff in buff_array_to_add:
			rpc("add_buff",[Globals.self_pu_id],buff)



func _on_items_pressed()->void:
	#{ "Heal Potion": { "min_cost": { "Type": "Free", "value": 0 }, "Type": "potion creating", "Effect": [{ "Name": "Heal", "Power": 5 }], "range": 2, "description": "(Зелье лечения: Восполняет 5 очков здоровья, а также снимает все дебаффы себе или другому слуге в радиусе двух клеток)" } }
	
	
	var items_array=pu_id_to_items_owned[Globals.self_pu_id].duplicate(true)
	
	print("\n\nitems_array="+str(items_array))
	#var items_descriptions={}
	#var items_effects={}
	#print(items_array)
	#for item in items_array:
		#print(item)
		#var item_name=item.keys()[0]
		#items_descriptions[item_name]={"Text":item[item_name]["Description"]}
		#items_effects[item_name]=item[item_name]
		#items_effects[item_name].erase("Description")
		#items_descriptions[item]=items_array[item][]
	#print("items_descriptions="+str(items_descriptions)+" items_effects="+str(items_effects))
	#print('\n\n')
	fill_custom_thing(items_array,CUSTOM_TYPES.POTION_USING)
	field.hide_all_gui_windows("use_custom")
		
	pass # Replace with function body.


func set_random_command_spell_set()->void:
	var add=""
	
	if OS.has_feature("editor"):
		add="res"
	else:
		add="user"
		
	var dir = DirAccess.open(add+"://command_spells/")
	var files=dir.get_files()
	var types=[]
	for file in files:
		if file.ends_with(" 3.png"):
			print(file)
			print(file.find(" 3.png"))
			types.append(file.substr(0,file.find(" 3.png")))
	self_command_spell_type=types.pick_random()
	print("commnand_spell_load_path="+str(add,"://command_spells/",self_command_spell_type," 3.png"))
	var img = Image.new()
	img.load(str(add,"://command_spells/",self_command_spell_type," 3.png"))
	#player_textureRect.texture=ImageTexture.create_from_image(img)
	
	field.command_spells_button.texture_normal=ImageTexture.create_from_image(img)
	pass

@rpc("any_peer","call_remote","reliable")
func reduce_command_spell_on_pu_id(pu_id:String,amount:int=1)->void:
	
	print("pu_id_to_command_spells_int["+str(pu_id)+"]="+str(pu_id_to_command_spells_int[pu_id]))
	#trigger_buffs_on(pu_id,"Command Spell Decreased")

	pu_id_to_command_spells_int[pu_id]-=amount

	if pu_id==Globals.self_pu_id:
		var add
		if OS.has_feature("editor"):
			add="res"
		else:
			add="user"
		var iin=pu_id_to_command_spells_int[pu_id]
		if iin>3:
			iin=3
		if iin!=0:
			field.command_spells_button.texture_normal=load(str(add,"://command_spells/",self_command_spell_type," ",iin,".png"))
		else:
			field.command_spells_button.texture_normal=load(str("res://empty.png"))

@rpc("any_peer","reliable","call_local")
func flip_pu_id_sprite(pu_id:String)->void:
	var ff =Globals.pu_id_player_info[pu_id]["servant_node"].get_child(0).flip_h
	Globals.pu_id_player_info[pu_id]["servant_node"].get_child(0).flip_h = !ff
	pass

func _on_flip_sprite_button_pressed():
	rpc("flip_pu_id_sprite",Globals.self_pu_id)
	pass # Replace with function body.

