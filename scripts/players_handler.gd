extends Node2D

#region Onready
@onready var field = self.get_parent()

@onready var host_buttons:VBoxContainer = %host_buttons

@onready var file_dialog:FileDialog = $"../FileDialog"

@onready var servant_info_main_container:VBoxContainer = %Servant_info_main_container
@onready var servant_info_picture_and_stats_container:HBoxContainer = %servant_info_picture_and_stats_container
@onready var servant_info_picture:TextureRect = %servant_info_picture
@onready var servant_info_stats_textedit:TextEdit = %servant_info_stats_textedit
@onready var show_buffs_advanced_way_button:Button = %show_buffs_advanced_way_button
@onready var servant_info_skills_textedit:TextEdit = %servant_info_skills_textedit



@onready var current_hp_container:HBoxContainer = %current_hp_container
@onready var current_hp_value_label:Label = %current_hp_value_label


@onready var players_info_buttons_container:VBoxContainer = %players_info_buttons_container

@onready var get_selected_character_button:Button = %get_selected_character
@onready var char_select:Control = %Char_select

@onready var skill_info_tab_container:TabContainer = %Skill_info_tab_container
@onready var first_skill_text_edit:TextEdit = %First_Skill_text_edit
@onready var second_skill_text_edit:TextEdit = %"Second Skill_text_edit"
@onready var third_skill_text_edit:TextEdit = %"Third Skill_text_edit"
@onready var class_skills_text_edit:TabContainer = %"Class Skills_text_edit"




@onready var custom_choices_tab_container:TabContainer = %custom_choices_tab_container
@onready var use_custom_but_label_container:VBoxContainer = %use_custom_but_label_container
@onready var use_custom_label:Label = %use_custom_label
@onready var use_custom_button:Button = %use_custom_button
@onready var current_players_ready_label:Label = %Current_players_ready_label


@onready var teams_margin = %teams_margin
@onready var teams_panel_container = %teams_panel_container
@onready var teams_main_hboxcontainer = %teams_main_hboxcontainer
@onready var all_teams_vbox = %all_teams_vbox
@onready var all_teams_label = %all_teams_label
@onready var your_teams_vbox = %your_teams_vbox
@onready var your_teams_label = %your_teams_label
@onready var teams_options_vbox = %teams_options_vbox
@onready var teams_options_label = %teams_options_label
@onready var team_actions_vbox = %team_actions_vbox
@onready var betray_team_button = %Betray_team_button
@onready var ally_team_button = %ally_team_button
@onready var neutral_team_button = %neutral_team_button


#endregion
const BASE_SERVANT = preload("res://scenes/base_servant.tscn")
#region Usable Variables
var custom_id_to_skill:Dictionary={}
var turns_order_by_pu_id:Array=[]

var teams_by_pu_id:Array=[]


# team_name=>[pu_id,pu_id]
#var teams:Dictionary={}

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
var unit_uniq_id_player_game_stat_info={}

var pu_id_to_command_spells_int:Dictionary={}

var unit_unique_id_to_items_owned:Dictionary={}

var pu_id_to_inventory_array:Dictionary={}
var player_info_button_current_pu_id:String=""

var self_command_spell_type:String=""

#Current users ready 0/?
var current_users_ready:int=0
var choosen_allie_return_value:Node2D

var loaded_done_count:int=0
var loaded_arr:Array

var servant_name_to_pu_id={}

var last_player_button_pressed:Button=null
var player_in_teams_choosen_pu_id:String=""

var additional_allies={}
var additional_enemies=[]
#endregion

signal servant_loaded(char_info:Dictionary)
signal everyone_loaded

signal next_turn_pass
signal chosen_allie()
signal buff_removed
signal buffs_cooldown_reduced
signal skills_cooldown_reduced
signal iddd_reqw(id:String)

signal custom_choice_used(result:bool)
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


const TEAM_HOLDER = preload("res://scenes/team_holder.tscn")



func fuck_you():
	print("fuck you")


#region Starting and Loading
func _ready():
	self.z_index=50
	#Globals.self_peer_id=multiplayer.get_unique_id()
	$"../GUI/peer_id_label".text=str(Globals.self_pu_id)
	rpc("update_ready_users_count",current_users_ready,Globals.pu_id_player_info.size())
	#print(str(dir.get_directories()))
	skill_info_tab_container.set_tab_title(0,"First Skill")
	skill_info_tab_container.set_tab_title(1,"Second Skill")
	skill_info_tab_container.set_tab_title(2,"Third Skill")
	skill_info_tab_container.set_tab_title(3,"Class Skills")
	return

@rpc("any_peer","reliable","call_local")
func id_requested():
	var sender_peer_id = multiplayer.get_remote_sender_id()
	var id_to_send=Globals.uniqq_ids.pick_random()
	Globals.uniqq_ids.erase(id_to_send)

	rpc_id(sender_peer_id,"get_id",id_to_send)



@rpc("authority","reliable","call_local")
func get_id(id:String):

	iddd_reqw.emit(id)

func get_uniqq_id_from_host()->String:
	
	rpc_id(1,"id_requested")
	var output=await iddd_reqw
	return output


func add_servants_translations_for_servant_name(servant_node:Node2D,servant_path:String,servant_name_just_name:String)->void:
	var servant_folder=Globals.user_folder+"/servants/"+str(servant_path)

	var dir = DirAccess.open(servant_folder)
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			print("Found file: " + file_name)
			if file_name.get_extension()=="json" and file_name.get_basename().get_file().length()==2:
				print("found translation for lang="+file_name.get_basename().get_file()+" for servant="+servant_name_just_name)
				var json_as_text = FileAccess.get_file_as_string(servant_folder+'/'+file_name)
				var json_as_dict = JSON.parse_string(json_as_text)
				servant_node.translation[file_name.get_basename()]=json_as_dict
		file_name = dir.get_next()

	pass


func apply_all_translation_codes(servant_node:Node2D)->void:
	
	_recursive_merge_descriptions(servant_node.skills, servant_node.translation)
	_recursive_merge_descriptions(servant_node.phantasms, servant_node.translation)
	if servant_node.passive_skills:
		_recursive_merge_descriptions(servant_node.passive_skills, servant_node.translation)
	
	print_debug("_recursive_merge_descriptions skills=",servant_node.skills)


func _recursive_merge_descriptions(data, translations_map):
	match typeof(data):
		TYPE_DICTIONARY:
			# Сначала проверяем, есть ли в этом словаре нужный нам ключ
			if data.has("Description ID"):
				var desc_id = data["Description ID"]
				var descriptions = {}
				
				for lang_code in translations_map:
					if translations_map[lang_code].has(desc_id):
						descriptions[lang_code] = translations_map[lang_code][desc_id]
				
				if not descriptions.is_empty():
					data["Description"] = descriptions
			
			for value in data.values():
				_recursive_merge_descriptions(value, translations_map)
		
		TYPE_ARRAY:
			for item in data:
				_recursive_merge_descriptions(item, translations_map)

func apply_initial_weapon_buffs(player_node: Node2D) -> void:
	for skill_name in player_node.skills:
		var skill = player_node.skills[skill_name]
		if skill.get("Type") == "Weapon Change":
			
			var weapons = skill.get("weapons", {})
			if weapons.is_empty():
				continue
				
			var base_weapon_name = weapons.keys()[0]
			var base_weapon = weapons[base_weapon_name]
			
			# If weapon has buff, add it with unique ID
			if base_weapon.has("Buff"):
				var weapon_buffs = base_weapon["Buff"].duplicate(true)
				if typeof(weapon_buffs) != TYPE_ARRAY:
					weapon_buffs = [weapon_buffs]

				
				var weapon_uniq_id = get_uniq_string_from_object(base_weapon)
				print("adding group_uniq_id to weapon buffs from weapon desc=",base_weapon, " weapon_uniq_id=",weapon_uniq_id)
				
				# Add unique ID to each buff
				for buff in weapon_buffs:
					buff["group_uniq_id"] = weapon_uniq_id
					player_node.buffs.append(buff)





@rpc("call_local","any_peer","reliable")
func load_servant(pu_id:String,load_info:Dictionary,get_id_from_hostt:String,is_summon:bool=false,summon_buff_info:Dictionary={}):
	print("loading servant for pu_id=",pu_id)

	var servant_name=load_info["name"]
	#var servant_name:String=Globals.pu_id_player_info[pu_id].get("servant_name",null)
	if servant_name==null:
		push_error("servant is not found while loading")
		print("\n\nservant is not found while loading=",pu_id," Globals.pu_id_player_info=",Globals.pu_id_player_info)
		return
	
	var img_path=null

	#var ascentions:Array=Globals.pu_id_player_info[pu_id]["ascensions"]

	for servant in Globals.characters:
		if servant["Name"]==servant_name:
			#img=servant["image"]
			img_path = servant["ascensions"][load_info["ascension"]][load_info["costume"]]

	if img_path==null:
		push_error("No sprite Found while loading servant")
		return

	var player:Node2D=BASE_SERVANT.instantiate()
	player.image_path=img_path
	#var player_textureRect:TextureRect = player.get_node("%servant_sprite_textRect")
	#var effect_layer:TextureRect = player.get_node("%effect_layer_textRect")
	#var buff_name_label:Label= player.get_node("%buff_name_label")

	var servant_path=servant_name

	var servant_name_just_name=servant_path.get_file().get_basename()

	print_debug("loading script path="+str(Globals.user_folder+"/servants/"+str(servant_name)+"/"+str(servant_name)+".gd"))
	player.script_path="/servants/"+str(servant_path)+"/"+str(servant_name_just_name)+".gd"
	#player.set_script(load(Globals.user_folder+"/servants/"+str(servant_path)+"/"+str(servant_name_just_name)+".gd"))

	

	#player_textureRect.texture=ImageTexture.create_from_image(Globals.local_path_to_servant_sprite[img])
	#effect_layer.texture=load("res://images/white.png")
	
	#var sizes:Vector2=player_textureRect.texture.get_size()
	#texture.flat=true
	#texture.anchors_preset=
	#texture.button_down.connect(player_info_button_pressed.bind(peer_id))
	#player_textureRect.position=Vector2(-(TEXTURE_SIZE*1.0)/2,-TEXTURE_SIZE)
	#player_textureRect.scale=Vector2(TEXTURE_SIZE/sizes.x,TEXTURE_SIZE/sizes.y)
	
	
	#effect_layer.size=Vector2(TEXTURE_SIZE*1.1,TEXTURE_SIZE*1.1)
	#effect_layer.position=Vector2(-(TEXTURE_SIZE*1.1)/2,-TEXTURE_SIZE*1.1)
	
	#buff_name_label.position=Vector2(-(TEXTURE_SIZE*1.1)/2,-TEXTURE_SIZE*1.2)
	#buff_name_label.text="FUCK"
	
	
	#buff_name_label.add_theme_font_size_override("font_size",40)
	#buff_name_label.add_theme_color_override("font_outline_color",Color.WHITE)
	#buff_name_label.add_theme_constant_override("outline_size",5)
	#buff_name_label.add_theme_color_override("font_color",Color.BLACK)
	#buff_name_label.z_index=1
	#print("sizes="+str(sizes))
	#print("scale="+str(player.scale))
	#player.add_child(player,true)
	player.name=servant_name
	#effect_layer.z_index=-1
	#effect_layer.modulate=Color(1, 1, 1, 0)
	#buff_name_label.modulate=Color(1, 1, 1, 0)
	#player.add_child(player_textureRect)
	#player.add_child(effect_layer)
	#splayer.add_child(buff_name_label)
	
	
	
	print("pu_id==Globals.self_pu_id=",pu_id," ",Globals.self_pu_id)


	#adding passive skills

	if not player.passive_skills:
		print("no passive skills found for player.name="+str(player.name))
	else:
		var passive_buffs=player.passive_skills
		var buffs_to_append=[]
		for buff in passive_buffs:
			#func remove_buff(cast_array,skill_name,remove_passive=false,remove_only_passive_one=false):
			#players_handler.rpc("remove_buff",[pu_id],buff["Name"],true,true)
			#await players_handler.buff_removed
			var buff_copy=buff.duplicate(true)
			buff_copy["Type"]="Status"
			buffs_to_append.append(buff_copy)
		player.buffs.append_array(buffs_to_append)


	#setting charInfo
	var idd=0
	var pl_info:CharInfo
	if not is_summon:
		print_debug("loading servant ",servant_name," as main servant for pu_id=",pu_id)
		pl_info=CharInfo.new(pu_id,0)
		player.unit_id = 0
		player.servant =true
		Globals.pu_id_player_info[pu_id]["units"]={0:player}

	else:
		print_debug("loading servant ",servant_name," as summon servant for pu_id=",pu_id)
		for i in range(1,Globals.MAX_UNITS):
			if not Globals.pu_id_player_info[pu_id]["units"].has(i):
				pl_info=CharInfo.new(pu_id,i)
				
				idd=i


				var duration:int = summon_buff_info.get("Duration",-1)
				#var skills_enabled:bool = summon_buff_info.get("Skills Enabled",false)
				#var one_time_skills:bool = summon_buff_info.get("One Time Skills",false)
				#var can_use_phantasm:bool = summon_buff_info.get("Can Use Phantasm",false)
				#var dissapear_after_summoner_death:bool = summon_buff_info.get("Disappear After Summoner Death",true)
				#var mount:bool = summon_buff_info.get("Mount",false)
				#var can_attack:bool = summon_buff_info.get("Can Attack",true)
				#var can_evade:bool = summon_buff_info.get("Can Evade",true)
				#var can_defence:bool = summon_buff_info.get("Can Defence",true)
				#var move_points:int = summon_buff_info.get("Move Points",1)
				#var attack_points:int = summon_buff_info.get("Attack Points",1)
				#var phantasm_points_farm:bool = summon_buff_info.get("Phantasm Points Farm",false)
				#var summon_limit:int = summon_buff_info.get("Limit",3)


				var buff_info_stringify=str(summon_buff_info)
				var ctx = HashingContext.new()
				var buffer = buff_info_stringify.to_utf8_buffer()
				ctx.start(HashingContext.HASH_MD5)
				ctx.update(buffer)
				var unique_id_trait = ctx.finish()
				unique_id_trait=unique_id_trait.hex_encode()



				#player.set_meta("Duration", summon_buff_info.get("Duration", -1))
				player.skills_enabled=summon_buff_info.get("Skills Enabled", false)
				player.one_time_skills=summon_buff_info.get("One Time Skills", false)
				player.can_use_phantasm=summon_buff_info.get("Can Use Phantasm", false)
				player.disappear_after_summoner_death=summon_buff_info.get("Disappear After Summoner Death", true)
				player.mount=summon_buff_info.get("Mount", false)
				player.require_riding_skill=summon_buff_info.get("Require Riding Skill", false)
				player.can_attack=summon_buff_info.get("Can Attack", true)
				player.can_evade=summon_buff_info.get("Can Evade", true)
				player.can_parry=summon_buff_info.get("Can Parry", true)
				player.can_defence=summon_buff_info.get("Can Defence", true)
				player.move_points=summon_buff_info.get("Move Points", 1)
				player.attack_points=summon_buff_info.get("Attack Points", 1)
				player.phantasm_points_farm=summon_buff_info.get("Phantasm Points Farm", false)


				player.can_be_played=summon_buff_info.get("Can Be Played", true)
				player.can_be_played=summon_buff_info.get("Servant", false)


				
				player.summoner_char_infodic= summon_buff_info.get("Summoner_char_infodic")

				if duration>0:
					player.buffs.append({
						"Name":"Death After Turns",
						"Types":["Status"],
						"Type":"Status",
						"Trigger":"Delayed Effect",
						"Effect After Turns":duration,
						"Effect On Trigger":[
							{"Buffs":[
								{
									"Name":"Guaranteed Death",
									"Power":3
								}],
							"Cast":"self"},
						]
					})

				player.skill_uniq_summon_id=unique_id_trait
				player.summon_check=true

				if summon_buff_info.get("Starting Buffs", [])!=[]:
					player.buffs.append_array(summon_buff_info.get("Starting Buffs"))
				
				player.traits.append("Summonable")


				Globals.pu_id_player_info[pu_id]["units"][i]=player
				player.unit_id = i
				break
	
	if pu_id==Globals.self_pu_id and not is_summon:
		print("pu==Globals self, adding")

		#Globals.self_servant_node=player

		field.current_unit_id=idd

		#print("Globals.self_servant_node=",Globals.self_servant_node)
	self.add_child(player,true)

	
	for i in player.skills.size():
		player.skill_cooldowns.append(0)

	player.owner_pu_id = pu_id
	player.pu_id = pu_id

	player.charInfoDic=pl_info.to_dictionary()

	player.unit_unique_id=get_id_from_hostt

	player.servant_path=str("/servants/"+str(servant_path)+"/"+str(servant_name_just_name)+".gd").get_base_dir()
	
	player.servant_name=servant_name

	player.servant_name_just_name=servant_path.get_file().get_basename()

	player.ascension_stage= load_info["ascension"]+1
	

	add_servants_translations_for_servant_name(player,servant_path,servant_name_just_name)


	apply_all_translation_codes(player)

	apply_initial_weapon_buffs(player)

	unit_unique_id_to_items_owned[get_id_from_hostt]={}
	unit_uniq_id_player_game_stat_info[get_id_from_hostt]=DEFAULT_GAME_STAT.duplicate(true)
	field.kletka_owned_by_unit_uniq_id[get_id_from_hostt]=[]


	servant_name_to_pu_id[player.name]=pu_id
	#Globals.pu_id_player_info[pu_id]["servant_name"]=player.name
	
	print("servant_name_to_pu_id=",servant_name_to_pu_id)

	print("emiting servant_loaded = ",pl_info.to_dictionary())


	var servant_script_to_get_stats=load(Globals.user_folder+'/servants/'+player.script_path).new()

	player.default_stats=servant_script_to_get_stats.default_stats.duplicate(true)


	player.servant_class=player.default_stats["servant_class"]
	player.ideology=player.default_stats["ideology"]
	player.attack_range=player.default_stats["attack_range"]
	player.attack_power=player.default_stats["attack_power"]
	player.agility=player.default_stats["agility"]
	player.endurance=player.default_stats["endurance"]
	player.hp=player.default_stats["hp"]
	player.magic=player.default_stats["magic"]
	player.luck=player.default_stats["luck"]
	player.traits=player.default_stats["traits"]
	player.attribute=player.default_stats["attribute"]
	player.gender=player.default_stats["gender"]
	player.strength=player.default_stats["strength"]

	await get_tree().create_timer(0.1).timeout
	servant_loaded.emit(pl_info.to_dictionary())

	#print(rand_kletka)
	#print(cell_positions[rand_kletka])
	#jopa.position = cord
	#set_random_teams()
	#return player




func get_self_servant_node(unit_id:int=field.current_unit_id)->Node2D:
	
	return Globals.pu_id_player_info[Globals.self_pu_id]["units"][unit_id]
	#push_error("no self servant found for pu_id=",Globals.self_pu_id," unit_id=",unit_id,
	# 'Globals.pu_id_player_info[Globals.self_pu_id]["units"]=',Globals.pu_id_player_info[Globals.self_pu_id]["units"])




func get_selected_servant()->void:
	var servant_ascensions:Dictionary=char_select.get_current_servant()
	get_selected_character_button.disabled=true
	print(servant_ascensions)
	rpc("set_nickname_for_pu_id",Globals.self_pu_id,Globals.nickname)
	rpc_id(1,"check_if_players_ready",Globals.self_pu_id,servant_ascensions)

@rpc("call_local","any_peer","reliable")
func set_nickname_for_pu_id(pu_id:String,nickk:String):
	Globals.pu_id_to_nickname[pu_id]=nickk

@rpc("any_peer","call_local","reliable")
func check_if_players_ready(pu_id:String,servant_ascensions:Dictionary):
	print("\n\n check_if_players_ready id=",pu_id," sevanntName=",servant_ascensions)
	Globals.pu_id_player_info[pu_id]["servant_name"]=servant_ascensions["name"]#,"servant_node":null}
	Globals.pu_id_player_info[pu_id]["ascensions"]=servant_ascensions

	print("pu_id=",pu_id, "  "+str(Globals.pu_id_player_info)+" is ready")
	current_users_ready+=1
	rpc("update_ready_users_count",current_users_ready,Globals.pu_id_player_info.size())

	rpc("sync_pu_id_player_info",Globals.pu_id_player_info.duplicate(true))
	sync_pu_id_player_info(Globals.pu_id_player_info.duplicate(true))

	#print("Globals.connected_players="+str(Globals.connected_players)+"Globals.connected_players.size()="+str(Globals.connected_players.size()))
	print("=current_users_ready="+str(current_users_ready))
	if Globals.pu_id_player_info.size()==current_users_ready:
		if Globals.host_or_user=="host":
			var uniqq:Array=Globals.generate_unique_ids(Globals.pu_id_player_info.size()*Globals.MAX_UNITS_FOR_USER_TOTAL)
			var all_peers:Array=Globals.get_all_peer_ids()
			for i in range(Globals.pu_id_player_info.size()-1):
				var uniq_to_send=uniqq.slice(i*Globals.MAX_UNITS_FOR_USER_TOTAL,(i+1)*Globals.MAX_UNITS_FOR_USER_TOTAL)
				rpc_id(all_peers[i],"set_uniq_unit_ids_from_host",uniq_to_send)

			host_buttons.visible=true
	
@rpc("authority","call_local","reliable")
func set_uniq_unit_ids_from_host(uniq_id:Array):
	Globals.uniqq_ids=uniq_id
	return



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
func set_teams_and_turns_order(teams_array,turn_order):
	#var len_=shiffled_players_array.size()/2
	#teams_by_pu_id=[shiffled_players_array.slice(0,len_),shiffled_players_array.slice(len_)]
	teams_by_pu_id=teams_array
	print("teams="+str(teams_by_pu_id))


	turns_order_by_pu_id=turn_order
	for pu_id in turns_order_by_pu_id:
		var servant_button=Button.new()
		servant_button.text=Globals.pu_id_player_info[pu_id]["servant_name"]
		servant_button.button_down.connect(player_info_button_pressed.bind(pu_id))
		players_info_buttons_container.add_child(servant_button,true)
	

@rpc("authority","call_local","reliable")
func initialise_start_variables(char_info_list:Array):
	field.add_all_additional_nodes()
	for char_info in char_info_list:
		unit_unique_id_to_items_owned[char_info.get_uniq_id()]={}
		pu_id_to_inventory_array[char_info]=[]
		pu_id_to_command_spells_int[char_info.pu_id]=3
		unit_uniq_id_player_game_stat_info[char_info.get_uniq_id()]=DEFAULT_GAME_STAT.duplicate(true)
		field.kletka_owned_by_unit_uniq_id[char_info.get_uniq_id()]=[]
		Globals.pu_id_to_allies[char_info.pu_id]={"allies":[],"neutral":[]}
		Globals.self_field_color = Color(randf(), randf(), randf())
		
	start_camera_position=$"../Camera2D".position
	start_camera_zoom=$"../Camera2D".zoom
	
	for team in teams_by_pu_id:
		for player in team:
			var tmp_team=team.duplicate(true)
			tmp_team.erase(player)
			Globals.pu_id_to_allies[player]["allies"].append_array(tmp_team)
	pass





@rpc("any_peer","call_local","reliable")
func sent_that_loading_done(_pu_id):
	if not _pu_id in loaded_arr:
		loaded_arr.append(_pu_id)

	print("\n\n sent_that_loading_done")
	if loaded_arr.size()==Globals.pu_id_player_info.size():
		everyone_loaded.emit()
		print("\n\n\n EVERYONE READY\n\n\n")


@rpc("authority","call_local","reliable")
func starting_loading(teams_array,turns_order,pu_id_to_unit_uniq:Dictionary):
	print("\n START SELF PEER_ID=",Globals.get_self_peer_id(), " =", multiplayer.get_unique_id())

	for pu_id in Globals.pu_id_player_info.keys():
		#var servant_name_to_load = Globals.pu_id_player_info[pu_id].get("servant_name",null)
		var ascension=Globals.pu_id_player_info[pu_id]["ascensions"]
		print("right before load servant for id=",pu_id, "ascension=",ascension)
		#var node_to_add=load_servant_by_name(peer_id_player_info[peer_id]["servant_name"])
		var un_id=pu_id_to_unit_uniq[pu_id]
		
		load_servant(pu_id,ascension,un_id)
		#peer_id_player_info[peer_id]["servant_node"]=node_to_add
		#add_child(node_to_add,true)
		#print(node_to_add)
		#rpc_id(peer_id,"set_player_node",inst_to_dict(node_to_add))
	print("\nright after loading servants pu_id_player_info="+str(Globals.pu_id_player_info))
	
	print_debug("set_teams_and_turns_order=",teams_array,turns_order)
	set_teams_and_turns_order(teams_array,turns_order)
	
	initialise_start_variables(get_all_char_infos())
	rpc("sent_that_loading_done",Globals.self_pu_id)



func split_teams(array:Array,amount_of_teams:int)->Array:
	if amount_of_teams>array.size():
		return [array]
	var out_array=[]
	out_array.resize(amount_of_teams)
	for i in amount_of_teams:
		out_array[i]=[]
	for i in array.size():
		out_array[i%amount_of_teams].append(array[i])
	return out_array

func start():
	#выдаем каждому игроку свой NODE слуги
	rpc("sync_pu_id_player_info",Globals.pu_id_player_info.duplicate(true))
	sync_pu_id_player_info(Globals.pu_id_player_info.duplicate(true))
	var temp_pl=Globals.pu_id_player_info.keys()
	temp_pl.shuffle()
	print("temp_pl=",temp_pl,"Globals.start_teams_amount=",Globals.start_teams_amount)
	var teams_array=split_teams(temp_pl,Globals.start_teams_amount)

	print("teams_array=",teams_array)
	temp_pl.shuffle()
	var turns_order=temp_pl
	print("temp_pl+"+str(temp_pl))
	

	var pu_id_to_unit_uniq={}
	for pu_id in temp_pl:
		var id_to_send=Globals.uniqq_ids.pick_random()
		Globals.uniqq_ids.erase(id_to_send)
		print("get_id_from_hostt=",id_to_send)
		pu_id_to_unit_uniq[pu_id]=id_to_send
	
	

	print("\n\ninfo before loading=",Globals.pu_id_player_info)
	rpc("starting_loading",teams_array,turns_order,pu_id_to_unit_uniq)
	await everyone_loaded

	#первоначальное выставление слуг на поле
	for pu_id in turns_order_by_pu_id: 
		current_player_pu_id_turn=pu_id
		var pu_peer_id=Globals.pu_id_player_info[pu_id]["current_peer_id"]

		
		
		rpc_id(pu_peer_id,"inital_spawn_of_player_forwarder")
		await next_turn_pass
		print(pu_id)
	rpc("sync_relations","",Globals.pu_id_to_allies)
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

	for team in get_teams():
		for member in team:
			if team in teams_alive:
				break
			if member in pu_id_alive:
				teams_alive.append(team)

	print("teams_alive="+str(teams_alive), " teams=",get_teams())
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
	

	rpc("alert_end_game")

	%finish_button.visible=true


@rpc("authority","call_local","reliable")
func alert_end_game():
	field.info_table_show(tr("ONLY_ONE_TEAM_STANDING"))


@rpc("any_peer","call_local","reliable")
func update_current_player_turn(cur_player_turn_pu_id:String):
	current_player_pu_id_turn=cur_player_turn_pu_id

@rpc("any_peer","reliable","call_remote")
func turn_update(turn) -> void:
	%turns_label.text=str("Turn: ",turn)
	turns_counter=turn
	field.update_field_icon()

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


func choose_allie(range_to_search:int=-1)->Array:
	var ketki_with_allies=[]
	for char_info in get_allies_char_info():
		ketki_with_allies.append(field.char_info_to_kletka_number(char_info))
	
	if range_to_search<=0:
		pass
	else:
		var ids_in_range:Array=field.get_kletki_ids_with_players_you_can_reach_in_steps(range_to_search)
		var new_array=[]
		for kletka_id in ketki_with_allies:
			if kletka_id in ids_in_range:
				new_array.append(kletka_id)
		
		ketki_with_allies=new_array
	
	field.choose_glowing_cletka_by_ids_array(ketki_with_allies)
	field.current_action="choose_allie"
	await chosen_allie
	var return_pu_id=choosen_allie_return_value.owner_pu_id
	var return_unit_id=choosen_allie_return_value.unit_id

	return [CharInfo.new(return_pu_id,return_unit_id)]


func choose_enemie(range_to_search:int=-1)->Array:
	var ketki_with_allies=[]
	for char_info in get_enemies_teams_char_info():
		ketki_with_allies.append(field.char_info_to_kletka_number(char_info))
	
	if range_to_search<=0:
		pass
	else:
		var ids_in_range:Array=field.get_kletki_ids_with_players_you_can_reach_in_steps(range_to_search)
		var new_array=[]
		for kletka_id in ketki_with_allies:
			if kletka_id in ids_in_range:
				new_array.append(kletka_id)
		
		ketki_with_allies=new_array

	
	field.choose_glowing_cletka_by_ids_array(ketki_with_allies)
	field.current_action="choose_allie"
	await chosen_allie
	var return_pu_id=choosen_allie_return_value.owner_pu_id
	var return_unit_id=choosen_allie_return_value.unit_id

	return [CharInfo.new(return_pu_id,return_unit_id)]


func get_item_description(item)->String:
	#print_debug("TranslationServer.get_locale()=",TranslationServer.get_locale())
	var out=item.get("Description","")
	if out:
		if typeof(out)==TYPE_DICTIONARY:
			if out.get(TranslationServer.get_locale(),""):
				out=out.get(TranslationServer.get_locale())
			else:
				out=out.get("ru")
		else:
			return ""
	return out


func show_skill_info_tab(char_info:CharInfo=field.get_current_self_char_info())->void:
	print("=====================")
	#var servant_skills:Dictionary=Globals.pu_id_player_info[pu_id]["servant_node"].skills
	var servant_skills:Dictionary=char_info.get_node().skills
	
	
	
	#print(servant_nod)
	print("servant_skills=",servant_skills)
	print_debug("TranslationServer.get_locale()=",TranslationServer.get_locale())
	#first_skill_text_edit.text=servant_skills.get("First Skill").get("Description").get(TranslationServer.get_locale(),"ru")
	#second_skill_text_edit.text=servant_skills.get("Second Skill").get("Description").get(TranslationServer.get_locale(),"ru")
	#third_skill_text_edit.text=servant_skills.get("Third Skill").get("Description").get(TranslationServer.get_locale(),"ru")

	first_skill_text_edit.text=get_item_description(servant_skills.get("First Skill"))
	second_skill_text_edit.text=get_item_description(servant_skills.get("Second Skill"))
	third_skill_text_edit.text=get_item_description(servant_skills.get("Third Skill"))


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
			
			for weapon in char_info.get_node().skills[class_skill_name]["weapons"]:
				var t_edit_new=TextEdit.new()
				t_edit_new.editable=false
				t_edit_new.name=weapon
				t_edit_new.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
				t_edit_new.text=get_item_description(skill_info["weapons"][weapon])
				tab_cont.add_child(t_edit_new)
			class_skills_text_edit.add_child(tab_cont)
			tab_cont.tab_changed.connect(field._on_weapon_change_tab_changed)
		else:
			var t_edit=TextEdit.new()
			t_edit.editable=false
			t_edit.name="Class skill "+str(cct)
			t_edit.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
			t_edit.text=get_item_description(skill_info)
			class_skills_text_edit.add_child(t_edit)
		cct+=1
	pass

func servant_info_from_pu_id(pu_id:String,advanced:bool=show_buffs_advanced_way_button.button_pressed)->void:
	#displayed only main char and summons are displayed below main
	#so request from pu_id and not from char_info
	
	var info=Globals.pu_id_player_info[pu_id]["units"][0]
	#servant_info_main_container.visible= true#!servant_info_main_container.visible
	servant_info_stats_textedit.text="Name:%s\nHP:%s\nClass:%s\nIdeology:%s\nAgility:%s\nStrength:%s\nEndurance:%s\nLuck:%s\nMagic:%s\n
	"%[info.name,info.hp,info.servant_class,info.ideology,info.agility,str(info.strength,"(",info.attack_power,")")
	,info.endurance,info.luck,info.magic]
	var buffs:Array=info.buffs
	var display_buffs=""
	if advanced:
		for buff in buffs:
			display_buffs+=str(buff)+"\n"
	else:
		for buff in buffs:
			if buff.has("Display Name"):
				display_buffs+=str("\t",buff["Display Name"])
			else:
				display_buffs+=str("\t",buff["Name"])
			if buff.has("Power"):
				display_buffs+=str(" lvl ",buff["Power"])
			if buff.has("Duration"):
				display_buffs+=str(" for ",buff["Duration"],"turns")
				
			display_buffs+="\n"
	var peer_skills:Dictionary=info.skills
	servant_info_picture.texture=Globals.pu_id_player_info[pu_id]["units"][0].get_child(0).texture
	var skill_text_to_display=""
	for skill in peer_skills.keys():
		skill_text_to_display+=str("\t",get_item_description(peer_skills[skill]),"\n")
	servant_info_skills_textedit.text="Buffs:\n\t%sSkills:\n\t%s"%[display_buffs,skill_text_to_display]

	#units stats:
	
	for unit_id in Globals.pu_id_player_info[pu_id]["units"].keys():
		if unit_id==0:
			continue
		var unit_node=Globals.pu_id_player_info[pu_id]["units"][unit_id]

		buffs=unit_node.buffs
		display_buffs="Name:%s\nHP:%s\nClass:%s\nIdeology:%s\nAgility:%s\nStrength:%s\nEndurance:%s\nLuck:%s\nMagic:%s\n
		"%[unit_node.name,unit_node.hp,unit_node.servant_class,unit_node.ideology,unit_node.agility,str(info.strength,"(",info.attack_power,")"),
		unit_node.endurance,unit_node.luck,unit_node.magic]
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
		servant_info_skills_textedit.text+=display_buffs



	






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
		tt_edit.text=get_item_description(custom_item)#.get(TranslationServer.get_locale(),"ru")
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
		"Type":type,"Effect":current_buff_effect,"Description":get_item_description(custom_item)}
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
			
			if get_self_servant_node().phantasm_charge<costt["value"]:
					use_custom_button.disabled=true
	

func _on_use_custom_button_pressed()->void:
	#print(custom_id_to_skill[custom_choices_tab_container.current_tab])
	var custom_id=custom_choices_tab_container.get_current_tab_control().name
	custom_choices_tab_container.visible=false
	use_custom_but_label_container.visible=false
	field.hide_all_gui_windows("use_custom")
	
	print_debug("custom_id_to_skill[custom_id]="+str(custom_id_to_skill))
	match custom_id_to_skill[custom_id]["Type"]:
		CUSTOM_TYPES.PHANTASM:
			await use_phantasm(custom_id_to_skill[custom_id]["Effect"])
			field.reduce_one_action_point(-1,'CUSTOM_TYPES.PHANTASM used')
		CUSTOM_TYPES.POTION_CREATING:
			var dict={custom_id:custom_id_to_skill[custom_id]}
			#dict.merge(custom_id_to_skill[custom_id])
			rpc("add_item_to_char_info",field.get_current_self_char_info().to_dictionary(),dict,custom_id) #{"Name":custom_id,"Effect":custom_id_to_skill[custom_id]["Effect"],"range":custom_id_to_skill[custom_id]["range"]})
			field.reduce_one_action_point(0)
			#rpc("use_skill",custom_id_to_skill[custom_id]["Effect"])
		CUSTOM_TYPES.BUFF_CHOOSING:
			var result = await use_skill(custom_id_to_skill[custom_id]["Effect"])
			await field.sleep(0.1)
			custom_choice_used.emit(result)
		CUSTOM_TYPES.POTION_USING:
			print("\n\npotion using")
			#var kletki_ids=field.get_kletki_ids_with_players_you_can_reach_in_steps(custom_id_to_skill[custom_id]["range"])
			#{ "min_cost": { "Type": "Free", "value": 0 }, "Type": "potion creating", "Effect": [{ "Name": "Heal", "Power": 5 }], "range": 2 }
			var tmp=custom_id_to_skill[custom_id]["Effect"]
			for effect in tmp:
				var buf={"Buffs":effect,"Cast":"Single In Range","Cast Range":effect["Range"]}
				var result = await use_skill(buf)
				print_debug("custom_id_to_skill[custom_id][\"Effect\"]="+str(custom_id_to_skill[custom_id]["Effect"]))
				await field.sleep(0.1)
				custom_choice_used.emit(result)
	
	

@rpc("any_peer","call_local","reliable")
func add_item_to_char_info(char_info_dic:Dictionary,item:Dictionary,item_name:String)->void:
	var char_info=CharInfo.from_dictionary(char_info_dic)

	print("item for char_info.get_uniq_id()="+str(char_info.get_uniq_id())+" = "+str(item))
	var valid:bool=false
	var count:int=1
	var new_item_name=item_name+""
	while !valid:
		if unit_unique_id_to_items_owned[char_info.get_uniq_id()].has(new_item_name):
			new_item_name=item_name+str(count)
			count+=1
		else:
			valid=true
	#var new_dict_to_append={new_item_name:item[item_name]}
	unit_unique_id_to_items_owned[char_info.get_uniq_id()][new_item_name]=item[item_name]

@rpc("any_peer","call_local","reliable")
func change_game_stat_for_char_info(char_info_dic:Dictionary,stat:String,value_to_add:int,reset:bool=false)->void:

	var char_info=CharInfo.from_dictionary(char_info_dic)

	var uniqq_id=char_info.get_uniq_id()
	if reset:
		unit_uniq_id_player_game_stat_info[uniqq_id][stat]=value_to_add
	else:
		unit_uniq_id_player_game_stat_info[uniqq_id][stat]+=value_to_add
	pass


func check_field_buffs_under_char_info(char_info:CharInfo)->Array:
	#var kletk_id=get_pu_id_kletka_number(pu_id)
	var kletk_id=field.char_info_to_kletka_number(char_info)
	if kletk_id==-2:
		return []

	var kletka_config:Dictionary=field.kletka_preference[kletk_id]
	var out_buffs=[]
	if not kletka_config.is_empty():
		if kletka_config.get("Ignore Magical Defence",false):
			if kletka_config.get("Owner",0):
				out_buffs.append({"Name":"Disable Magic Resistance","Type":"Status","Pu Id":kletka_config["Owner"]})
	return out_buffs


#region Stat get

func get_char_info_buffs(char_info:CharInfo)->Array:
	var default_buffs:Array=char_info.get_node().buffs.duplicate(true)

	var new_buffs=default_buffs

	new_buffs.append_array(check_field_buffs_under_char_info(char_info))

	return new_buffs


func check_if_char_info_got_crit(char_info:CharInfo,dice_results:Dictionary)->bool:
	var crit_removed=false
	var is_crit=false
	
	is_crit = dice_results["main_dice"]==dice_results["crit_dice"]
	rpc("add_to_advanced_logs",
		"ADVANCED_LOG_CHECK_IF_USER_GOT_CRIT_DICES",
		{
			"main_dice":dice_results["main_dice"],
			"crit_dice":dice_results["crit_dice"],
			"is_crit":is_crit
		}
	)

	for skill in get_char_info_buffs(char_info):
		match skill["Name"]:
			"Critical Remove":
				crit_removed=true
				rpc("add_to_advanced_logs","ADVANCED_LOG_CRIT_REMOVED_BY_BUFF")
			"Critical Hit Rate Up":
				rpc("add_to_advanced_logs",
					"ADVANCED_LOG_ATTACKER_HAS_CRIT_UP_BUFF",
					{"crit_dice":skill["Crit Chances"]}
				)
				if dice_results["crit_dice"] in skill["Crit Chances"]:
					rpc("add_to_advanced_logs","ADVANCED_LOG_CRIT_CHANCES_FROM_BUFF_VALID")
					is_crit=true
				else:
					rpc("add_to_advanced_logs","ADVANCED_LOG_CRIT_CHANCES_FROM_BUFF_NOT_VALID")
	if crit_removed:
		is_crit=false
	return is_crit

func calculate_crit_damage(char_info:CharInfo,damage:int)->int:
	var new_damage:int=damage+0
	
	for skill in get_char_info_buffs(char_info):
		match skill["Name"]:
			"Critical Strength Up":
				new_damage+=skill.get("Power",1)
			"Critical Strength Up X":
				new_damage*=skill.get("Power",1)
	new_damage*=2
	return new_damage

func get_char_info_attack_power(char_info:CharInfo)->int:
	var base_attack:int=char_info.get_node().attack_power

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
		rpc("add_to_advanced_logs","ADVANCED_LOG_BUFF_CONDITION_FIELDS_ERROR")
		return false
	
	#var pu_id_to_check:Array
	var char_info_to_check:Array
	match who_to_check:
		"Enemie":
			char_info_to_check=get_enemies_teams()
		"Self":
			char_info_to_check=[field.get_current_self_char_info()]
		
	rpc("add_to_advanced_logs",
		"ADVANCED_LOG_BUFF_CONDITION_WHO_TO_CHECK",
		{"who_to_check":who_to_check}
	)

	var condition_check=false
	for char_info in char_info_to_check:
		#var pu_id_node=Globals.pu_id_player_info[pu_id]["servant_node"]
		var char_info_node=char_info.get_node()
		var stat_to_check
		match what_to_check:
			"Magic Power":
				#stat_to_check=peer_node.magic["Power"]
				stat_to_check=get_char_info_magical_attack(char_info)
			"Magic Resistance":
				#stat_to_check=peer_node.magic["Resistance"]
				stat_to_check=get_char_info_magical_defence(char_info)
			"Magic Rank":
				stat_to_check=char_info_node.magic["Rank"]
			"Attack Power":
				stat_to_check=get_char_info_attack_power(char_info)
			"Trait":
				var traits=get_char_info_traits(char_info)
				return intersect(traits,exact)
			"Attack Range":
				stat_to_check=get_char_info_attack_range(char_info)
			"Attribute":
				stat_to_check=char_info_node.attribute
			"Ideology":
				var ideology=char_info_node.ideology
				if typeof(exact)!=TYPE_ARRAY:
					continue
				return intersect(ideology,exact)
				
			"Class":
				var ser_class=get_char_info_class(char_info)
				if typeof(exact)!=TYPE_STRING:
					continue
				return exact==ser_class
			"HP":
				stat_to_check=char_info_node.hp
			"Gender":
				stat_to_check=get_char_info_gender(char_info)
			"Ascension Stage":
				stat_to_check=char_info.get_node().ascension_stage
			"Strength":
				stat_to_check=get_char_info_strength(char_info)
			"Agility":
				stat_to_check=get_char_info_agility_rank(char_info)
			"Endurance":
				stat_to_check=get_char_info_endurance(char_info)
			"Luck":
				stat_to_check=get_char_info_luck(char_info)
			"Buff Name":
				if char_info_has_active_buff(char_info,exact):
					rpc("add_to_advanced_logs",
						"ADVANCED_LOG_BUFF_CONDITION_CHECK_BUFF_NAME",
						{"buff":exact}
					)
					return true
				else:
					rpc("add_to_advanced_logs",
						"ADVANCED_LOG_BUFF_CONDITION_CHECK_BUFF_NAME_NOT_VALID",
						{"buff":exact}
					)
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
		rpc("add_to_advanced_logs",str("what_to_check=",what_to_check))
		if bigger!=null:
			print_debug("Bigger=",stat_to_check,">",bigger,"?")
			print("typeof(bigger)=",typeof(bigger))
			rpc("add_to_advanced_logs",str("Bigger=",stat_to_check,">",bigger,"?"))
			if typeof(bigger)==TYPE_FLOAT:
				if stat_to_check>bigger:
					return true
			if typeof(bigger)==TYPE_STRING:
				return stat_one_bigger_than_second(stat_to_check,bigger)
		if smaller!=null:
			rpc("add_to_advanced_logs",str("smaller=",stat_to_check,"<",bigger,"?"))
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

func calculate_char_info_attack_against_char_info(attacker_char_info:CharInfo,taker_char_info:CharInfo,damage_type:String,phantasm_config:Dictionary={})->int:
	var attack_total

	rpc("add_to_advanced_logs",str("damage_type=",damage_type))
	match damage_type:
		DAMAGE_TYPE.PHANTASM:
			attack_total=phantasm_config.get("Damage",1)
		DAMAGE_TYPE.MAGICAL:
			attack_total=get_char_info_magical_attack(attacker_char_info)
		DAMAGE_TYPE.PHYSICAL:
			attack_total=get_char_info_attack_power(attacker_char_info)
		_:
			push_error("Wrong damage type while calculate_pu_id_attack_against_pu_id, damage_type=",damage_type)
			attack_total=1
	
	rpc("add_to_advanced_logs",str("calculate_char_info_attack_against_char_info attack_total_start=",attack_total))

	var taker_servant
	var taker_traits
	var taker_gender

	if not taker_char_info.is_valid():
		#taker_servant=Globals.pu_id_player_info[taker_pu_id]["servant_node"]
		taker_servant=taker_char_info.get_node()
		taker_traits=taker_servant.traits
		taker_gender=get_char_info_gender(taker_char_info)



	var attacker_servant=attacker_char_info.get_node()
	var attacker_buffs=get_char_info_buffs(attacker_char_info)


	var phantasm_additional_buffs=phantasm_config.get("Phantasm Buffs",[])
	
	

	attacker_buffs.append_array(phantasm_additional_buffs)

	rpc("add_to_advanced_logs",
	"ADVANCED_LOG_CHECKING_ATTACKER_BUFFS",
	{"attacker_buffs":attacker_buffs})
	for buff in attacker_buffs:
		rpc("add_to_advanced_logs",
			"ADVANCED_LOG_CHECKING_ATTACKER_BUFF",
			{"buff":buff}
		)
		if buff.has("Condition"):
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_BUFF_HAS_CONDITION",
				{"condition":buff["Condition"]}
			)
			var check_buff=check_condition_wrapper(buff["Condition"])
			print_debug("check_buff=",check_buff)
			if not check_buff:
				rpc("add_to_advanced_logs","ADVANCED_LOG_BUFF_CONDITION_FALSE")
				continue
			rpc("add_to_advanced_logs","ADVANCED_LOG_BUFF_CONDITION_TRUE")
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
			"ATK Up Against Gender" when not taker_char_info.is_valid():
				if buff.get("Gender","")==taker_gender:
					attack_total+=buff["Power"]
			"ATK Up Against Trait" when not taker_char_info.is_valid():
				if buff.get("Trait","") in taker_traits:
					attack_total+=buff["Power"]
			"ATK Down Against Trait" when not taker_char_info.is_valid():
				if buff.get("Trait","") in taker_traits:
					attack_total-=buff["Power"]
			"ATK Up X Against Class" when not taker_char_info.is_valid():
				if buff.get("Class","")==taker_servant.class:
					attack_total+=buff["Power"]
			"ATK Up Against Alignment" when not taker_char_info.is_valid():
				if buff.get("Alignment","") in taker_servant.ideology:
					attack_total+=buff["Power"]
		var poww=""
		if buff.has("Power"):
			poww=str("Buff={buff_name} power={buff_power} damage_to_take={total_damage}").format(
				{
					"buff_name":buff["Name"],
					"buff_power":buff["Power"],
					"total_damage":attack_total
				}
			)
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_DAMAGE_CALCULATE_BUFF_POWER_DAMAGE",
				{
					"buff_name":buff["Name"],
					"buff_power":buff["Power"],
					"total_damage":attack_total
				}
			)
		else:
			poww=str("Buff={buff_name} damage_to_take={total_damage}").format(
				{
					"buff_name":buff["Name"],
					"total_damage":attack_total
				}
			)
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_DAMAGE_CALCULATE_BUFF_NO_POWER_DAMAGE",
				{
					"buff_name":buff["Name"],
					"total_damage":attack_total
				}
			)
		print(poww)
	
	rpc("add_to_advanced_logs","ADVANCED_LOG_DAMAGE_CALCULATE_MULTY_BUFFS")
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
			"ATK Up X Against Gender" when not taker_char_info.is_valid():
				if buff.get("Gender","")==taker_gender:
					attack_total*=buff["Power"]
			"ATK Up X Against Attribute":
				if buff.get("Attribute","")==taker_servant.attribute:
					attack_total*=buff["Power"]
			"ATK Up X Against Trait" when not taker_char_info.is_valid():
				if buff.get("Trait","") in taker_traits:
					attack_total*=buff["Power"]
			"ATK Down X Against Trait" when not taker_char_info.is_valid():
				if buff.get("Trait","") in taker_traits:
					attack_total=floor(attack_total/buff["Power"])
			"ATK Up X Against Class" when not taker_char_info.is_valid():
				if buff.get("Class","")==taker_servant.class:
					attack_total*=buff["Power"]
			"ATK Up X Against Alignment" when not taker_char_info.is_valid():
				if buff.get("Alignment","") in taker_servant.ideology:
					attack_total*=buff["Power"]
		
		var poww=""
		if buff.has("Power"):
			poww=str("Buff={buff_name} power={buff_power} damage_to_take={total_damage}").format(
				{
					"buff_name":buff["Name"],
					"buff_power":buff["Power"],
					"total_damage":attack_total
				}
			)
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_DAMAGE_CALCULATE_BUFF_POWER_DAMAGE",
				{
					"buff_name":buff["Name"],
					"buff_power":buff["Power"],
					"total_damage":attack_total
				}
			)
		else:
			poww=str("Buff={buff_name} damage_to_take={total_damage}").format(
				{
					"buff_name":buff["Name"],
					"total_damage":attack_total
				}
			)
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_DAMAGE_CALCULATE_BUFF_NO_POWER_DAMAGE",
				{
					"buff_name":buff["Name"],
					"total_damage":attack_total
				}
			)
		
	attack_total=ceil(attack_total)
	return attack_total

func get_char_info_agility_rank(char_info:CharInfo)->String:
	var base_agility:String=char_info.get_node().agility
	#TODO fix this later AKA after Andersen
	var _new_agility:String=""
	for skill in get_char_info_buffs(char_info):
		match skill["Name"]:
			"Agility Add":
				_new_agility+=""#skill.get("Power",0)*1.0/base_agility
			"Agility Set":
				_new_agility=""#get_agility_in_numbers(skill.get("Power","C"))
	return base_agility#int(base_agility+new_agility)

func get_char_info_endurance(char_info:CharInfo)->String:
	var base_stat:String=char_info.get_info().endurance
	var _new_stat:String=base_stat+""
	#TODO fix this later AKA after Andersen
	for skill in get_char_info_buffs(char_info):
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

func get_char_info_attack_range(char_info:CharInfo)->int:
	var base_range:int=char_info.get_node().attack_range
	var new_range:int=base_range+0
	for skill in get_char_info_buffs(char_info):
		match skill["Name"]:
			"Attack Range Add":
				new_range+=skill.get("Power",0)
			"Attack Range Set":
				new_range=skill.get("Power",1)
	return new_range

func get_char_info_magical_attack(char_info:CharInfo)->int:
	var base_stat:int=char_info.get_node().magic.get("Power",0)
	var new_stat:int=base_stat+0
	for skill in get_char_info_buffs(char_info):
		match skill["Name"]:
			"Magical Attack Add":
				new_stat+=skill.get("Power",0)
			"Magical Attack Set":
				new_stat=skill.get("Power",1)
	return new_stat

func get_char_info_magical_defence(char_info:CharInfo)->int:
	print("char_info.get_node().magic=",char_info.get_node().magic)
	var base_stat:int=char_info.get_node().magic.get("Resistance",0)
	var new_stat:int=base_stat+0
	for skill in get_char_info_buffs(char_info):
		match skill["Name"]:
			"Magical Defence Add":
				new_stat+=skill.get("Power",0)
			"Magical Defence Set":
				new_stat=skill.get("Power",1)
	return new_stat

func get_char_info_luck(char_info:CharInfo)->String:
	var base_stat:String=char_info.get_node().luck
	var _new_stat:String=base_stat+""
	#TODO fix this later AKA after Andersen
	for skill in get_char_info_buffs(char_info):
		match skill["Name"]:
			"Luck Add":
				_new_stat+=skill.get("Power",0)
			"Luck Set":
				_new_stat=skill.get("Power",1)
	return base_stat	

#endregion



func servant_name_to_pu_id_(servant_name:String)->String:
	
	return ""

func _on_phantasm_pressed()->void:
	use_custom_button.disabled=false
	use_custom_label.visible=false
	if get_self_servant_node().phantasm_charge<6:
		use_custom_label.text="COST:6"
		
		use_custom_button.disabled=true
		pass
	
	if char_info_has_active_buff(field.get_current_self_char_info(),"NP Seal"):
		custom_choices_tab_container.visible=false
		use_custom_but_label_container.visible=false
		field.info_table_show(tr("NP_IS_SEALED_BY_DEBUFF"))
		await field.info_ok_button.pressed
		return
	
	
	fill_custom_thing(get_self_servant_node().phantasms,CUSTOM_TYPES.PHANTASM)
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

	var overcharge_up_buff=char_info_has_active_buff(field.get_current_self_char_info(),"Overcharge Up")

	var sorted_by_cost = []
	for phantasm_name in phantasms_config:
		if phantasms_config[phantasm_name].has("Cost"):
			sorted_by_cost.append({"Name": phantasm_name, "Cost": phantasms_config[phantasm_name]["Cost"]})
	sorted_by_cost.sort_custom(func(a, b): return a.Cost < b.Cost)

	var maximum_item = -1

	for i in range(sorted_by_cost.size()):
		var item = sorted_by_cost[i]
		if item.Cost <= get_self_servant_node().phantasm_charge:
			
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
	
	await field.sleep(0.1)
	if overcharge_use.has("effect_after_attack"):
		print("effect_after_attack=true")
		await use_skill(overcharge_use["effect_after_attack"],attacked_by_phantasm)
	
	
	rpc("charge_np_to_char_info_by_number",field.get_current_self_char_info().to_dictionary(),-overcharge_use["Cost"])
	#for effect in 
	rpc("finish_attack",field.get_current_self_char_info().to_dictionary())
	
	pass

@rpc("any_peer","call_local","reliable")
func finish_attack(char_info_dic):
	field.attacker_finished_attack.emit(char_info_dic)


func get_char_info_kletka_number(char_info:CharInfo)->int:
	var servant_name=char_info.get_node().name
	print("servant_name=",servant_name," char_info=",char_info)
	for kletka_id in field.occupied_kletki:
		for node in field.occupied_kletki[kletka_id]:
			if node.name==servant_name:
				return kletka_id
	push_error("couldn't get char_info's kletka number=",char_info, " name=",servant_name," field.occupied_kletki=",field.occupied_kletki)
	return 0


func bomb_phantasm(phantasm_config):
	var range_to_choose_enemie=phantasm_config["Range"]
	var aoe_range=phantasm_config["AOE_Range"]
	var kletki_to_attack_array=[]
	var attacked_enemies=[]
	var first_char_info=await choose_single_in_range(range_to_choose_enemie)
	kletki_to_attack_array.append(get_char_info_kletka_number(first_char_info[0]))

	var char_infos_around=get_all_enemies_in_range(aoe_range,first_char_info[0])

	kletki_to_attack_array.append_array(char_infos_around)
	
	await field.await_dice_including_rerolls("Attack")
	await field.hide_dice_rolls_with_timeout(1)
	for kletka in kletki_to_attack_array:
		var etmp=await field.attack_player_on_kletka_id(kletka,"Phantasm",false,phantasm_config)
		if typeof(etmp)==TYPE_STRING:
			if etmp=="ERROR":
				continue
		attacked_enemies.append(etmp)
		if field.attack_responce_string!="evaded" or field.attack_responce_string!="parried":
			if phantasm_config.has("effect_on_success_attack"):
				await use_skill(phantasm_config["effect_on_success_attack"])
	
	return attacked_enemies


func phantasm_in_range(phantasm_config,type="Single"):
	var atk_range=phantasm_config["Range"]
	var attacked_enemies=[]
	var kletki_to_attack_array=[]
	#var enemies_array=get_enemies_teams()
	var tmp
	
	match type:
		"Single":
			tmp=await choose_single_in_range(atk_range)
			tmp.erase(field.get_current_self_char_info())
		"All enemies":
			tmp=await get_all_enemies_in_range(atk_range)
	for char_info in tmp:
		kletki_to_attack_array.append(get_char_info_kletka_number(char_info))
	await field.await_dice_including_rerolls("Attack")
	await field.hide_dice_rolls_with_timeout(1)
	for kletka in kletki_to_attack_array:
		var etmp=await field.attack_player_on_kletka_id(kletka,"Phantasm",false,phantasm_config)
		if typeof(etmp)==TYPE_STRING:
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
	rpc("charge_np_to_char_info_by_number",field.get_current_self_char_info().to_dictionary(),6)
	pass

func get_all_pu_ids():


	return Globals.get_connected_persistent_ids()

	var output=[]
	var teams=get_teams()
	for team in teams:
		for member in team:
			output.append(member)
	return output

func get_all_char_infos():

	var out_arr:Array=[]
	for pu_id in Globals.pu_id_player_info:
		for unit_id in Globals.pu_id_player_info[pu_id]["units"].keys():
			#var new_cr_inf:CharInfo
			out_arr.append(CharInfo.new(pu_id,unit_id))
	return out_arr

func choose_single_in_range(_range,char_info_to_search:CharInfo=field.get_current_self_char_info()):
	var ketki_array=[]
	var pur_id_kletka=get_char_info_kletka_number(char_info_to_search)
	print("choose_single_in_range pur_id_kletka=",pur_id_kletka)
	for kletka_id in field.get_kletki_ids_with_players_you_can_reach_in_steps(_range,pur_id_kletka):
		ketki_array.append(kletka_id)
	
	ketki_array.append(field.get_current_kletka_id())
	field.choose_glowing_cletka_by_ids_array(ketki_array)
	print("choose_single_in_range=",ketki_array)
	field.current_action="choose_allie"
	await chosen_allie
	var choosen_allie_return_value_node = choosen_allie_return_value
	#return choosen_allie_return_value_node.get_meta("CharInfoDic")
	var charInfo_to_return=CharInfo.from_dictionary(choosen_allie_return_value_node.CharInfoDic)
	return [charInfo_to_return]

func check_if_hp_is_bigger_than_max_hp_for_char_info(char_info:CharInfo)->void:
	print("\n---check_if_hp_is_bigger_than_max_hp_for_char_info name=",char_info.get_node().name)
	var max_hp=get_char_info_maximun_hp(char_info)
	print("max_hp=",max_hp)
	var servant_node=char_info.get_node()
	if servant_node.hp>max_hp:
		print("servant_node.hp>max_hp => hp before fix=",servant_node.hp)
		servant_node.hp=max_hp
	print("servant_node.hp after fix=",servant_node.hp)
	update_hp_on_char_info(char_info.to_dictionary(),servant_node.hp)
	print("---check_if_hp_is_bigger_than_max_hp_for_char_info name ended---\n")
	return


func get_enemies_teams_char_info()->Array:
	var enemies_pu_ids=get_enemies_teams()

	var output_char_infos=[]
	for pu_id in enemies_pu_ids:
		for unit_id in Globals.pu_id_player_info[pu_id]["units"].keys():
			output_char_infos.append(CharInfo.new(pu_id,unit_id))
			
	return output_char_infos

func get_enemies_teams()->Array:

	return get_full_relations()[Globals.self_pu_id]["enemies"]
	#var all_enemies_pu_id=[]
	#var teams=get_teams()
	#for team in teams:
	#	for member in team:
	#		if Globals.self_pu_id!=member:
	#			all_enemies_pu_id+=team
	#return all_enemies_pu_id

func get_allies(pu_id_to_search:String=Globals.self_pu_id):


	return get_full_relations()[pu_id_to_search]["allies"]
	var teams=get_teams()
	for team in teams:
		for member in team:
			if pu_id_to_search==member:
				return team
	pass
	#cast self,allies, 

func get_allies_char_info(char_info_to_search:CharInfo=field.get_current_self_char_info()):

	var enemies_pu_ids=get_allies(char_info_to_search.pu_id)
	print("enemies_pu_ids=",enemies_pu_ids)
	var output_char_infos=[]
	for pu_id in enemies_pu_ids:
		print("pu_id=",pu_id)
		for unit_id in Globals.pu_id_player_info[pu_id]["units"].keys():
			output_char_infos.append(CharInfo.new(pu_id,unit_id))
	print("get_allies_char_info=",output_char_infos)
	output_char_infos.append(field.get_current_self_char_info())
	return output_char_infos
	#cast self,allies, 

func get_enemies_teams_char_info_uniq_ids()->Array:
	var enemies_pu_ids=get_enemies_teams()

	var output_char_infos=[]
	for pu_id in enemies_pu_ids:
		for unit_id in Globals.pu_id_player_info[pu_id]["units"].keys():
			var char_info=CharInfo.new(pu_id,unit_id)
			output_char_infos.append(char_info.get_uniq_id())
			
	return output_char_infos

func get_all_enemies_in_range(_range,char_info_to_search:CharInfo=field.get_current_self_char_info())->Array:
	var enemies=get_enemies_teams_char_info_uniq_ids()
	var out=[]
	for char_info in get_everyone_in_range(_range,char_info_to_search):
		if char_info.get_uniq_id() in enemies:
			out.append(char_info)
	return out

func get_everyone_in_range(range_local:int,char_info_to_search:CharInfo=field.get_current_self_char_info())->Array:
	var out=[]
	#var kletka_id=0
	var char_info_kletk_id=get_char_info_kletka_number(char_info_to_search)
	for kletka_id in field.get_kletki_ids_with_players_you_can_reach_in_steps(range_local,char_info_kletk_id):
		if field.occupied_kletki.get(kletka_id,0):
			for servant_node in field.occupied_kletki[kletka_id]:
				var serv_pu_id=servant_node.owner_pu_id
				var serv_unit_id=servant_node.unit_id
				out.append(CharInfo.new(serv_pu_id,serv_unit_id))
	return out


func check_if_char_info_has_skill_currency(char_info:CharInfo,currency:String,amount:int)->bool:
	match currency:
		"NP":
			if char_info.get_node().phantasm_charge>=amount:
				return true
		"HP":
			if char_info.get_node().hp>=amount:
				return true
		_:
			push_warning("UNKNOWN CURRENCY:"+str(currency))
	return false

func reduce_char_info_currency(char_info:CharInfo,currency:String,amount:int)->void:
	match currency:
		"NP":
			rpc("charge_np_to_char_info_by_number",char_info.to_dictionary(),-amount)
		"HP":
			rpc("take_damage_to_char_info",char_info.to_dictionary(),amount,false)
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

func get_all_allies_in_range(_range:int,char_info_to_search:CharInfo=field.get_current_self_char_info())->Array:
	var allies=get_allies_char_info(char_info_to_search)
	var out=[]
	for char_info in get_everyone_in_range(_range,char_info_to_search):
		if char_info in allies:
			out+=char_info
	return out

func can_char_info_attack_char_info(char_info:CharInfo,char_into_to_attack:CharInfo)->bool:
	
	var restrict_buffs=get_all_buffs_with_name_for_char_info(char_info,"Attack Restrict Against Player")
	var unqi_id=char_into_to_attack.get_uniq_id()

	for buff in restrict_buffs:
		if buff["player_id"]==unqi_id:
			return false
	return true


func can_use_mandness_enhancement() -> bool:
	var self_bufs=get_char_info_buffs(field.get_current_self_char_info())
	
	for buff in self_bufs:
		if buff.get("Type",""):
			continue
		if "Buff Positive Effect" in get_buff_types(buff):
			return false
	return true

func replace_value_with_dice_result(replace_wrap_info:Dictionary, buff_info_array:Array)->Array:
	var minimum=replace_wrap_info.get("Limit Minimum Value",0)
	var maximum=replace_wrap_info.get("Limit Maximum Value",100)
	var what_to_replace=replace_wrap_info.get("What To Replace","")
	var dice_name=replace_wrap_info.get("Dice Name","Main")
	var calculations=replace_wrap_info.get("Calculations",{})

	if what_to_replace=="":
		push_error("No what to replace in replace_value_with_dice_result")
		return buff_info_array
	
	if not (dice_name in field.dice_roll_result_list.keys()):
		push_error("No dice with name="+str(dice_name))
		return buff_info_array
	
	var desc=replace_wrap_info.get("Description",{})
	if desc:
		field.roll_dice_optional_label.text=get_item_description(replace_wrap_info)
		field.roll_dice_optional_label.visible=true

	var result=await field.await_dice_roll()
	field.roll_dice_optional_label.visible=false

	var nedded_result=result[dice_name]

	if calculations:
		for calculation in calculations:
			match calculation["Operation"]:
				"Add":
					nedded_result+=calculation.get("Value",0)
				"Substract":
					nedded_result-=calculation.get("Value",0)
				"Multiply":
					nedded_result*=calculation.get("Value",1)
				"Divide":
					nedded_result=floor(nedded_result/calculation.get("Value",1))


	print("nedded_result=",nedded_result)
	if nedded_result<minimum:
		nedded_result=minimum

	if nedded_result>maximum:
		nedded_result=maximum
	
	print("final nedded_result=",nedded_result)
	var out_buff_array=[]
	for buff in buff_info_array:
		var st=str(buff)
	
		if what_to_replace in st:
			st=st.replace(str("\"",what_to_replace,"\""),str(nedded_result))
			buff=JSON.parse_string(st)
		
		out_buff_array.append(buff)
	return out_buff_array



func use_skill(skill_info_dictionary,custom_cast:Array=[],used_by_char_info:CharInfo=field.get_current_self_char_info())->bool:
	#trait_name is used if "Damange 2х Against Trait"
	#String
	var was_skill_used=false
	print("\n\nuse_skill="+str(skill_info_dictionary)+"\n")
	rpc("zoom_out_in_camera_before_buff",true)

	if typeof(skill_info_dictionary)==TYPE_DICTIONARY:
		skill_info_dictionary=[skill_info_dictionary]


	var self_char_info=used_by_char_info

	
	
	print(str("using skills=",skill_info_dictionary))
	for skill_info_hash:Dictionary in skill_info_dictionary:
		var remove_currency=false
		var usage_successful=false
		if skill_info_hash.has("Cost"):
			print("checking cost")
			var curr=skill_info_hash["Cost"].get("Currency","")
			var amount=skill_info_hash["Cost"].get("Amount",0)
			if check_if_char_info_has_skill_currency(self_char_info,curr,amount):
				print_debug("you have currency"+str(curr)+" value:"+str(amount))
				remove_currency=true
				#reduce_char_info_currency(self_char_info,curr,amount)
			else:
				field.info_table_show(
					tr("NOT_ENOUGHT_CURRENCY_AMOUNT").format(
						{
							"currency_name":curr,
							"amount":amount
						}
					)
					)
				await field.info_ok_button.pressed
				remove_currency=false
				continue
		if skill_info_hash.has("Choose Buff"):
			fill_custom_thing(skill_info_hash["Choose Buff"],CUSTOM_TYPES.BUFF_CHOOSING)
			field.hide_all_gui_windows("use_custom")
			was_skill_used = await custom_choice_used
			continue
		
		if '"Madness Enhancement"' in str(skill_info_hash):
			print_debug('"Madness Enhancement" in str(skill_info_hash)')
			if can_use_mandness_enhancement():
				pass
			else:
				field.info_table_show(tr("CANT_APPLY_MAD_ENCHANCEMENT_BUFFS"))
				await field.info_ok_button.pressed
				continue
		
		var cast=skill_info_hash.get("Cast","self")
		var cast_range=skill_info_hash.get("Cast Range",0)
		var cast_condition:Dictionary=skill_info_hash.get("Cast Condition",{})

		var replace_with_dice=skill_info_hash.get("Replace Value With Dice Result",[])

		
		#if typeof(cast)==TYPE_ARRAY:
		#	range=cast[1]
		#	cast=cast[0]
		var skill_info_array=skill_info_hash["Buffs"]

		if replace_with_dice:
			for replace in replace_with_dice:
				skill_info_array=await replace_value_with_dice_result(replace,skill_info_array)
		
		if typeof(skill_info_array)==TYPE_DICTIONARY:
			skill_info_array=[skill_info_array]
		print("1 cast=",cast)
		match cast.to_lower():
			"all allies":
				cast=get_allies_char_info()
			"all allies except self":
				cast=get_allies_char_info()
				cast.erase(self_char_info)
			"all allies in range":
				cast=get_all_allies_in_range(cast_range)
			"all allies in range except self":
				cast=get_all_allies_in_range(cast_range)
				cast.erase(self_char_info)
			"self":
				cast=[self_char_info]
			"all enemies":
				cast=get_enemies_teams_char_info()
			"single allie":
				cast=await choose_allie()
			"single allie in range":
				cast=await choose_allie(cast_range)
			"single enemie":
				cast=await choose_enemie()
			"single enemie in range":
				cast=await choose_enemie(cast_range)
			"everyone":
				cast=get_all_char_infos()
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
		print("2 cast=",cast)
		if cast==[]:
			continue
		print("cast_condition=",cast_condition)
		if not cast_condition.is_empty():
			var new_cast=get_char_infos_satisfying_condition(cast,cast_condition)
			print_debug("New cast=",new_cast)
			if new_cast.is_empty():
				continue
			cast=new_cast
		for single_skill_info in skill_info_array:
			print("single_skill_info="+str(single_skill_info))
			match single_skill_info["Name"]:
				"Potion creation":
					usage_successful = await create_potion(single_skill_info["Potions"])
				"Field Change":
					usage_successful = change_field(single_skill_info,self_char_info)
				"Field Creation":
					usage_successful = await field.capture_field_kletki(single_skill_info["Amount"],single_skill_info["Config"],self_char_info)
				"Field Manipulation":
					usage_successful = await field.field_manipulation(single_skill_info)
				"Roll dice for effect":
					usage_successful = await roll_dice_for_result(single_skill_info,cast)
				"Summon":
					usage_successful = await summon_someone(self_char_info,single_skill_info)
				"Create New Field Cell":
					usage_successful = await field.create_new_cell(single_skill_info)
				"Appearance Change":
					usage_successful = await change_appearance_for_char_info(self_char_info,single_skill_info)
				"Attacking Phantasm Absorb":
					usage_successful = absorb_attacking_phantasm_from_cast(self_char_info,cast)
				"Attack Restrict Against Player":
					single_skill_info["player_id"]=field.get_current_self_char_info().get_uniq_id()
					var new_cast=[]
					for cast_single in cast:
						new_cast=cast_single.to_dictionary()
					rpc("add_buff",new_cast,single_skill_info)
					usage_successful=true
				_:#default/else
					var new_cast=[]
					for cast_single in cast:
						new_cast=cast_single.to_dictionary()
					rpc("add_buff",new_cast,single_skill_info)
					usage_successful=true
		was_skill_used=true
		print_debug("remove_currency=",remove_currency," usage_successful=",usage_successful)
		if remove_currency and usage_successful:
			var curr=skill_info_hash["Cost"].get("Currency","")
			var amount=skill_info_hash["Cost"].get("Amount",0)
			reduce_char_info_currency(self_char_info,curr,amount)
	await get_tree().create_timer(2).timeout
	rpc("zoom_out_in_camera_before_buff",false)
	print("use skill ending was_skill_used=",was_skill_used)
	return was_skill_used

signal sprite_path_loaded(path:String)

func change_appearance_for_char_info(char_info:CharInfo,_appearance_change_info:Dictionary)->bool:

	var answer=await field.choose_between_two(
						tr("CHANGE_APPEARANCE_QUESTION_IMAGE_LOCATION"),
						tr("CHANGE_APPEARANCE_QUESTION_IMAGE_LOCATION_UPLOAD"),
						tr("CHANGE_APPEARANCE_QUESTION_IMAGE_LOCATION_SPRITE")
						)

	if answer==tr("CHANGE_APPEARANCE_QUESTION_IMAGE_LOCATION_UPLOAD"):
		#upload custom
		print("upload custom")
		%sprite_choose_FileDialog.visible=true
		var path = await sprite_path_loaded
		#print("image path=",path)
		var image = Image.new()
		image.load(path)
#
		var imageData = image.data
		imageData["format"] = image.get_format()
		print("imageData=",imageData)
		rpc("change_char_info_sprite_from_image_data",char_info.to_dictionary(),imageData)
	else:
		fill_choose_sprite_containter()
		field.hide_all_gui_windows()
		%choose_sprite_main_VBoxContainer.visible=true
		await %confirm_sprite_Button.pressed
		%choose_sprite_main_VBoxContainer.visible=false
		#getting sprite with visible panel
		for cont in %choose_sprite_sub_VBoxContainer.get_children():
			for child in cont.get_children():
				if child.get_child(0).visible==true:
					var img_texture:ImageTexture=child.texture_normal
					var imageData=img_texture.get_image().data
					imageData["format"] = img_texture.get_image().get_format()
					rpc("change_char_info_sprite_from_image_data",char_info.to_dictionary(),imageData)
					
					print("change_appearance_for_char_info done")
					return true

	print("change_appearance_for_char_info done")
	return true

func _on_sprite_choose_file_dialog_file_selected(path)->void:
	#print("image path=",path)
	await field.sleep(0.1)
	sprite_path_loaded.emit(path)
	#var image = Image.new()
	#image.load(path)
#
	#var imageData = image.data
	#imageData["format"] = image.get_format()
	#print("imageData=",imageData)
	#var char_info=field.get_current_self_char_info()
	#rpc("change_char_info_sprite_from_image_data",char_info.to_dictionary(),imageData)
	pass


func sprite_in_choose_sprite_pressed(text_butt:TextureButton)->void:
	for cont in %choose_sprite_sub_VBoxContainer.get_children():
		for child in cont.get_children():
			child.get_child(0).visible=false
	text_butt.get_child(0).visible=true
	pass

func _on_choose_sprite_scroll_container_resized()->void:
	fill_choose_sprite_containter()
	pass

func fill_choose_sprite_containter()->void:
	var conta=%choose_sprite_sub_VBoxContainer

	var max_size=%choose_sprite_main_VBoxContainer.size.x
	var amount_in_line=int(floor(max_size/200))


	for child in conta.get_children():
		conta.remove_child(child)
		child.queue_free()
	
	var all_sprites=[]
	print("Globals.characters=",Globals.characters)
	for character in Globals.characters:
		print("character=",character)
		var ascensions=character.get("ascensions",[])
		print("ascensions=",ascensions)
		if ascensions:
			for ascension in ascensions:
				for costume in ascension:
					all_sprites.append(Globals.local_path_to_servant_sprite[costume])
			#var tmp=[]
			#tmp.append_array(ascensions)
			#all_sprites.append_array(tmp)
	var hbox=HBoxContainer.new()
	var counter=0
	print("all_sprites=",all_sprites)
	for sprite in all_sprites:
		var text_butt=TextureButton.new()
		var panel_cont=PanelContainer.new()
		text_butt.add_child(panel_cont)
		panel_cont.visible=false
		panel_cont.show_behind_parent=true
		panel_cont.set_anchors_preset(15)#LayoutPreset.PRESET_FULL_RECT
		
		text_butt.custom_minimum_size=Vector2(200,200)
		text_butt.ignore_texture_size=true
		text_butt.texture_normal=ImageTexture.create_from_image(sprite)
		text_butt.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED

		hbox.add_child(text_butt)

		text_butt.pressed.connect(sprite_in_choose_sprite_pressed.bind(text_butt))

		counter+=1
		print("counter=",counter," amount_in_line=",amount_in_line)
		if counter==amount_in_line:
			conta.add_child(hbox)
			hbox=HBoxContainer.new()
			counter=0
		

	pass

func absorb_attacking_phantasm_from_cast(char_info:CharInfo,cast:Array,_amount:int=-1)->bool:
	var all_cast_phantasms:Dictionary={}
	for single_char_info in cast:
		var phantasms=single_char_info.get_node().phantasms
		for phantasm_name in phantasms:
			var new_name=str(single_char_info.get_node().name)+"'s "+phantasm_name
			all_cast_phantasms[new_name]=phantasms[phantasm_name]

	rpc("add_phantasms_to_char_info",char_info.to_dictionary(),all_cast_phantasms)
	return true


@rpc("any_peer","call_local","reliable")
func add_phantasms_to_char_info(char_info_dic:Dictionary,phantasms:Dictionary)->void:
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)
	effect_on_buff(char_info,"Attacking Phantasm Absorb")

	char_info.get_node().phantasms.merge(phantasms)
	pass


func change_field(skill:Dictionary,char_info:CharInfo)->bool:
	#field.field_status={"Default":"City","Field Buffs":[]}
	var new_skill=skill.duplicate(true)
	new_skill["Owner"]=char_info
	field.field_status["Field Buffs"].append(new_skill)
	return true


@rpc("any_peer","reliable","call_remote")
func reduce_field_skills_cooldowns(char_info_dic:Dictionary):
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)
	var field_buffs=field.field_status.get("Field Buffs",[])
	if field_buffs.is_empty():
		return
	var buffs_to_remove:Array=[]

	for i in range(field_buffs.size()):
		print("i="+str(i)+" "+str(field_buffs[i]))
		var buff_owner=field_buffs[i].get("Owner",-1)
		if buff_owner!=char_info:
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


func check_if_all_items_from_arr1_in_arr2(arr1:Array,arr2:Array)->bool:
	for item in arr1:
		if !arr2.has(item):
			return false
	return true


func get_char_infos_satisfying_condition(cast: Array, cast_condition: Dictionary) -> Array:
	print("--get_char_infos_satisfying_condition cast_condition=",cast_condition," ---")
	# Конфигурация для каждого типа проверки.
	# Ключ - название условия из cast_condition.
	# Значение - Callable, который получает данные для проверки.
	# Для полей, не связанных с персонажем (char_info), мы игнорируем аргумент.
	var check_configs = {
		"Trait": func(char_info): return get_char_info_traits(char_info),
		"Class": func(char_info): return [get_char_info_class(char_info)],
		"Gender": func(char_info): return [get_char_info_gender(char_info)],
		"Buff": func(char_info): return get_char_info_buffs(char_info),
		"Field": func(_char_info): return get_current_fields()
	}

	var output: Array = []
	var condition_type = cast_condition.get("Condition", "")
	var is_strict_mode = (condition_type == "All")

	# Получаем список условий, которые нужно проверить в этот раз.
	# Это ключи из cast_condition, которые также есть в нашей конфигурации.
	var conditions_to_check = cast_condition.keys().filter(func(key): return check_configs.has(key))

	if conditions_to_check.is_empty():
		return cast # Если условий нет, возвращаем всех персонажей.

	for char_info in cast:
		var is_match_found = false
		
		if is_strict_mode:
			# "ALL"
			print("is_strict_mode=true")
			var all_conditions_met = true
			for condition_key in conditions_to_check:
				var required_values = cast_condition[condition_key]
				var character_values = check_configs[condition_key].call(char_info)
				
				if not check_if_all_items_from_arr1_in_arr2(required_values, character_values):
					all_conditions_met = false
					print("Condition not met for key=",condition_key," required_values=",required_values," character_values=",character_values)
					break 
			
			if all_conditions_met:
				is_match_found = true
		else:
			# "ANY": 
			print("is_strict_mode=false")
			for condition_key in conditions_to_check:
				var required_values = cast_condition[condition_key]
				var character_values = check_configs[condition_key].call(char_info)
				
				if intersect(required_values, character_values):
					is_match_found = true
					print("Condition met for key=",condition_key," required_values=",required_values," character_values=",character_values)
					break 

		if is_match_found:
			output.append(char_info)
	print("--get_char_infos_satisfying_condition end---")
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

	await use_custom_button.pressed

	return true

func reduce_all_cooldowns(char_info:CharInfo,type="Turn Started"):
	match type:
		"Turn Started":
			await reduce_buffs_cooldowns(char_info.to_dictionary(),type)
			rpc("reduce_buffs_cooldowns",char_info.to_dictionary(),type)
			#await buffs_cooldown_reduced
			
			await reduce_skills_cooldowns(char_info.to_dictionary(),type)
			rpc("reduce_skills_cooldowns",char_info.to_dictionary(),type)

			await reduce_field_skills_cooldowns(char_info.to_dictionary())
			rpc("reduce_field_skills_cooldowns",char_info.to_dictionary())

			#await skills_cooldown_reduced
			print("skills_cooldown_reduced")
		"End Turn":
			await reduce_buffs_cooldowns(char_info.to_dictionary(),type)
			rpc("reduce_buffs_cooldowns",char_info.to_dictionary(),type)
			#await buffs_cooldown_reduced
	
	field.update_field_icon()




@rpc("any_peer","reliable","call_remote")
func reduce_buffs_cooldowns(char_info_dic:Dictionary,type="Turn Started"):
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)
	
	print("reduce_buffs_cooldowns\n\n")
	#var buffs=Globals.pu_id_player_info[pu_id]["servant_node"].buffs
	var buffs=char_info.get_node().buffs

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
								#Globals.pu_id_player_info[pu_id]["servant_node"].buffs[i]["Duration"]-=1
								Globals.pu_id_player_info[char_info.pu_id]["units"][char_info.unit_id].get_node().buffs[i]["Duration"]-=1
								char_info.get_node().buffs[i]["Duration"]-=1
							continue
					"Turn Started":
						if buff_duration-1<=0:
							print_debug("removing buff")
							buffs_list_to_remove.append(buffs[i])
						else:
							#Globals.pu_id_player_info[pu_id]["servant_node"].buffs[i]["Duration"]-=1
							#Globals.pu_id_player_info[char_info.pu_id]["units"][char_info.unit_id].get_node().buffs[i]["Duration"]-=1
							char_info.get_node().buffs[i]["Duration"]-=1
					_:
						push_error("attemt reducing buffs cooldown with unhandled type=",type)
			
	print("\nbuffs_list_to_remove="+str(buffs_list_to_remove))
	
	#it is removing buff by erasing full inclusion so it it valid
	#it is removing not by ids
	for i in buffs_list_to_remove:
		#Globals.pu_id_player_info[pu_id]["servant_node"].buffs.erase(i)


		#Globals.pu_id_player_info[char_info.pu_id]["units"][char_info.unit_id].get_node().buffs.erase(i)
		char_info.get_node().buffs.erase(i)
	
	#remove_buffs_for_peer_id_at_index_array(peer_id,buffs_list_to_remove)
	
	
	buffs_cooldown_reduced.emit()
	
@rpc("any_peer","reliable","call_remote")
func reduce_skills_cooldowns(char_info_dic:Dictionary,_type="Turn Started",amount:int=1):
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)
	for i in range(char_info.get_node().skill_cooldowns.size()):
		char_info.get_node().skill_cooldowns[i]-=amount
		if char_info.get_node().skill_cooldowns[i]<=0:
			char_info.get_node().skill_cooldowns[i]=0
	
	skills_cooldown_reduced.emit()


@rpc("any_peer","reliable","call_local")
func reduce_custom_param(char_info_dic:Dictionary,buff_id_array:Array,param:String):
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)
	print_debug("reduce_custom_param, char_info=",char_info," param=",param," buff_id_array=",buff_id_array)
	buff_id_array.sort()
	print_debug("buff_id_array.size()=",buff_id_array.size())
	print_debug(range(buff_id_array.size() - 1, -1, -1))
	#for i in range(0,buff_id_array.size(),-1):
	for i in range(buff_id_array.size() - 1, -1, -1):
		var buff_id=buff_id_array[i]
		print("buff_id=",buff_id)
		if char_info.get_node().buffs[buff_id][param]-1<=0:
			char_info.get_node().buffs.pop_at(buff_id)
			print_debug("buff popped at",buff_id)
		else:
			char_info.get_node().buffs[buff_id][param]-=1
			print_debug("param=",param," reduces")

@rpc("any_peer","reliable","call_local")
func remove_buffs_for_char_info_at_index_array(char_info_dic:Dictionary,ids:Array)->void:
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)
	ids.sort()
	for i in range(ids.size() - 1, -1, -1):
		var buff_id=ids[i]
		print_debug("buff_id=",buff_id)
		char_info.get_node().buffs.pop_at(buff_id)
		print_debug("buff popped at",buff_id)

func trigger_buffs_on(char_info:CharInfo,trigger:String,triggered_by_char_info=null):
	var buffs=char_info.get_node().buffs
	var i=0
	var buffs_ids_to_reduce_trigger_uses:Array=[]
	var buffs_to_reduce_custom_param:Array=[]
	var count=0
	print("trigger_buffs_on="+str(trigger)+" triggered_by_char_info="+str(triggered_by_char_info))
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
							rpc("take_damage_to_char_info",char_info.to_dictionary(),buff["Power"])
						"pull enemies on attack":
							field.pull_enemy(field.attacking_char_info)
						_:
							push_error("Wrong set trigger effect="+str(buff["Effect On Trigger"]))
				else:
					print("using trigger buff")
					var buffs_to_add=buff["Effect On Trigger"].duplicate(true)
					if typeof(buffs_to_add)==TYPE_DICTIONARY:
						buffs_to_add=[buffs_to_add]

					if char_info.pu_id==Globals.self_pu_id:
						for effect in buffs_to_add:
							await use_skill(effect,[triggered_by_char_info],char_info)
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
						rpc("reduce_custom_param",char_info.to_dictionary(),[i],"Hit Times")
						break
		i+=1
	if !buffs_ids_to_reduce_trigger_uses.is_empty():
		rpc("reduce_custom_param",char_info.to_dictionary(),buffs_ids_to_reduce_trigger_uses,"Total Trigger Uses")
	
	for buff in buffs_to_reduce_custom_param:
		print_debug("buffs_to_reduce_custom_param=",buff)
		rpc("reduce_custom_param",char_info.to_dictionary(),[buff["Id"]],buff["Param"])
	
	var _calculata="""just in case to variable
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
		if field.get_current_kletka_id()!=-1:
			var cu_klet_config=field.kletka_preference[field.get_current_kletka_id()]
			#{ "Owner": 1, "Np Up Every N Turn": 1,"turn_casted":1 , "Additional": <null> }
			#print("type="+str(typeof(cu_klet_config)))
			if not cu_klet_config.is_empty():
				print("\n\ncu_klet_config="+str(cu_klet_config))
				if cu_klet_config["Owner"]==char_info.get_uniq_id():
					print(str("cu_klet_config[owner]=",cu_klet_config["Owner"]))
					if cu_klet_config.has("Np Up Every N Turn"):
						print(str("cal=",turns_counter,"-",cu_klet_config["turn_casted"],"%",cu_klet_config["Np Up Every N Turn"],"=",(turns_counter-cu_klet_config["turn_casted"])%cu_klet_config["Np Up Every N Turn"]))
						if (turns_counter-cu_klet_config["turn_casted"])%cu_klet_config["Np Up Every N Turn"]==0:
							
							print("Np Up Every N Turn for char_info=",char_info)
							rpc("charge_np_to_char_info_by_number",char_info.to_dictionary(),1)
		
	
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
			if cu_klet_config["Owner"].pu_id==current_player_pu_id_turn:
				print("Is owner turn=true")
				var kletka_duration=cu_klet_config["Duration"]
				var turn_casted=cu_klet_config.get("Turn Casted",1)
				#cur turn 6
				#casted 3
				#6-3=3
				print("\n duration= ",turns_counter,"-",turn_casted,">",kletka_duration)
				if turns_counter-turn_casted>kletka_duration:
					print("duration expired")
					field.kletka_preference[field.get_current_kletka_id()]={}
					for captured in field.get_all_children(field.captured_kletki_node):
						if captured.name=="field "+str(kletka_id):
							captured.queue_free()

func roll_dice_for_result(skill_info:Dictionary,cast:Array):
	await field.sleep(0.5)
	var dice_result
	var is_casted=null
	field.rpc("systemlog_message",str(Globals.nickname," thowing to decide bad status"))
	print("roll_dice_for_result skill_info=",skill_info," cast=",cast)
	for char_info in cast:
		is_casted=null
		var pu_peer_id=Globals.pu_id_player_info[char_info.pu_id]["current_peer_id"]
		print("pu_peer_id=",pu_peer_id)
		while true:
			
			#await field.sleep(0.2)
			#field.rpc_id(pu_peer_id,"receice_dice_roll_results",dice_result)
			await field.sleep(0.2)
			field.rpc_id(pu_peer_id,"set_action_status",field.get_current_self_char_info().to_dictionary(),"roll_dice_for_result",char_info.to_dictionary(),dice_result)

			var status= await field.attack_response
			print("Status dice roll result=",status)
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
					field.roll_dice_optional_label.text=tr("DICE_ROLL_RESULT_REROLL_DICES")
					dice_result = await field.await_dice_roll()
				"Getting bad status":
					for single_skill in skill_info["Buff To Add"]:#shit
						rpc("add_buff",[char_info.to_dictionary()],single_skill)
						await field.sleep(0.1)
					is_casted=true
			if is_casted!=null:
				break
		#field._on_dices_toggle_button_pressed()
	return true

func apply_madness_enhancement(char_info:CharInfo,buff_info:Dictionary)->void:
	#already in rpc invoke
	var user_buffs=char_info.get_node().buffs.duplicate(true)
	print_debug("apply_madness_enhancement, char_info=",char_info)
	var main_buff_duration=buff_info.get("Duration",1)
	var main_buff_power=buff_info.get("Power",2)
	for buff in user_buffs:
		print("buff=",buff)
		var buff_type= buff.get("Type","")
		if buff_type:
			print("buff not removed")
			continue
		print_debug("removing buff")
		await remove_buff([char_info],buff.get("Name"))

	
	add_buff([char_info.to_dictionary()],{"Name":"ATK Up X","Display Name":"Madness Enhancement","Type":"Status","Duration":main_buff_duration,"Power":main_buff_power})

	var smart=buff_info.get("Can Use 1 Skill",false)
	if smart:
		add_buff([char_info.to_dictionary()],{"Name":"Maximum Skills Per Turn","Type":"Status","Power":1,"Duration":main_buff_duration})
	else:
		add_buff([char_info.to_dictionary()],{"Name":"Skill Seal","Type":"Status","Duration":main_buff_duration})
	return

func reduce_custom_param_for_buff_name(char_info:CharInfo,buff_name:String,param:String,first_only:bool=true):
	var buffs_ids=[]
	var char_info_buffs_arr=char_info.get_node().buffs
	for i in range(char_info_buffs_arr.size()):
		if char_info_buffs_arr[i]["Name"]==buff_name:
			if char_info_buffs_arr[i].has(param):
				buffs_ids.append(i)
				if first_only:
					break
	reduce_custom_param(char_info.to_dictionary(),buffs_ids,param)

func get_char_info_class(char_info:CharInfo)->String:
	var peer_node=char_info.get_node()
	var default_peer_class=peer_node.servant_class
	
	var class_buff=char_info_has_active_buff(char_info,"Class Change")
	var buffs_class:String
	if class_buff:
		buffs_class = class_buff.get("Class","")
		if buffs_class in Globals.CLASS_NAMES:
			return buffs_class
		else:
			push_warning("Wrong class name=",class_buff)
	return default_peer_class

func intersect(array1, array2):
	print("--intersect= array1=",array1," array2=",array2," ---")
	for item in array1:
		if array2.has(item):
			print("---intersect found item=",item," ---")
			return true
	print("---intersect no items found---")
	return false

func get_all_buffs_with_name_for_char_info(char_info:CharInfo, buff_name:String)->Array:
	var out:Array=[]
	for buff in char_info.get_node().buffs:
		if buff["Name"].to_lower()==buff_name.to_lower():
			out.append(buff)
	return out

func char_info_can_get_buff(char_info:CharInfo, buff_info:Dictionary)->bool:

	var buff_types=buff_info.get("Types",[])
	if buff_types.is_empty():
		buff_types=Globals.buffs_types.get(buff_info.get("Name"),"")
		if not buff_types:
			push_error("No buff types found for buff=",buff_info)

	var char_buffs=get_char_info_buffs(char_info)

	#char_buffs.reverse() 
	# cant do this bc reduce_custom_param_for_buff_name reduces from start

	for buff:Dictionary in char_buffs:
		match buff["Name"]:
			"Nullify Buff":
				var typ = buff.get("Types To Block",["Buff Positive Effect"])
				if intersect(typ,buff_types):
					if buff.has("Uses"):
						reduce_custom_param_for_buff_name(char_info,buff["Name"],"Uses")
					return false
			"Nullify Debuff":
				var typ = buff.get("Types To Block",["Buff Negative Effect"])
				if intersect(typ,buff_types):
					if buff.has("Uses"):
						reduce_custom_param_for_buff_name(char_info,buff["Name"],"Uses")
					return false

	var user_has_resistance=false
	var user_resistance_removed=false
	for buff:Dictionary in char_buffs:
		match buff["Name"]:
			"Resistance For Buff":
				var typ = buff.get("Types",[])
				if intersect(typ,buff_types):
					if buff.has("Uses"):
						reduce_custom_param_for_buff_name(char_info,buff["Name"],"Uses")
					user_has_resistance =  true
			"Disable Resistance For Buff":
				var typ = buff.get("Types",[])
				if intersect(typ,buff_types):
					user_resistance_removed = true

	if user_has_resistance:
		if user_resistance_removed:
			pass
		else:
			return false
	
	if buff_info.has("Cast Condition"):
		var cast_condition:Dictionary=buff_info.get("Cast Condition",{})
		var new_cast=get_char_infos_satisfying_condition([char_info],cast_condition)
		if new_cast.is_empty():
			return false
	return true

func buffs_removal(char_info: CharInfo, buff_info: Dictionary) -> void:
	var buff_types_to_remove: Array = buff_info.get("Types To Remove", [])
	var is_buff_removal_resist=char_info_has_active_buff(char_info,"Buff Removal Resist")
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
	
	var target_buffs_array: Array = char_info.get_node().buffs
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
	
	rpc("remove_buffs_for_char_info_at_index_array",char_info.to_dictionary(),indices_to_remove)
	
	
	#for index_val in indices_to_remove:
	#	if index_val >= 0 and index_val < target_buffs_array.size():
	#		target_buffs_array.remove_at(index_val)
	#	else:
	#		push_warning("Attempted to remove buff at out-of-bounds index: ", index_val)
	pass

func get_absorbs_buffs()->Array:
	var output=[]
	for char_info in get_all_char_infos():
		var ubsb=char_info_has_active_buff(char_info,"Absorb Buffs")
		if ubsb:
			output.append({"Buffs Names":ubsb.get("Buffs Names",[]),"char_info":char_info})
	return output


@rpc("any_peer","reliable","call_local")
func add_buff_array(cast_array,skill_info_array:Array):
	for skill_info in skill_info_array:
		await add_buff(cast_array,skill_info)
	pass

@rpc("any_peer","reliable","call_local")
func add_buff(cast_array,skill_info:Dictionary):
	if typeof(cast_array)!=TYPE_ARRAY:
		cast_array=[cast_array]
	
	if skill_info.get("Type","")!="":
		var ubsorb=get_absorbs_buffs()
		print_debug("ubsorb=",ubsorb)
		for single_absorb in ubsorb:
			if skill_info["Name"] in single_absorb["Buffs Names"]:
				cast_array=[single_absorb["char_info"]]
	
	print("add_buff cast_array=",cast_array)
	for who_to_cast_char_info_dic in cast_array:
		var who_to_cast_char_info:CharInfo=CharInfo.from_dictionary(who_to_cast_char_info_dic)

		effect_on_buff(who_to_cast_char_info,skill_info["Name"])
		if skill_info.get("Type",""):
			pass
		else:
			if not char_info_can_get_buff(who_to_cast_char_info,skill_info):
				continue
			skill_info.erase("Cast Condition")
		match skill_info["Name"]:
			"Madness Enhancement":
				await apply_madness_enhancement(who_to_cast_char_info,skill_info)
			"NP Charge":
				charge_np_to_char_info_by_number(who_to_cast_char_info.to_dictionary(),skill_info.get("Power",1),"Skill")
			"Reduce Skills Cooldown":
				reduce_skills_cooldowns(who_to_cast_char_info.to_dictionary(),"skill",skill_info.get("Power",1))
			"Buff Removal":
				buffs_removal(who_to_cast_char_info,skill_info)
			"Debuff Removal":
				buffs_removal(who_to_cast_char_info,skill_info)
			"NP Discharge":
				charge_np_to_char_info_by_number(who_to_cast_char_info.to_dictionary(),-skill_info.get("Power",1),"Skill")
			"Multiply NP":
				var current_peer_id_np:int=who_to_cast_char_info.get_phantasm_charge_points()
				var multyply_power=skill_info.get("Power",1)-1
				var end_np_points:int=ceil(current_peer_id_np*multyply_power)
				end_np_points=min(end_np_points,12)
				charge_np_to_char_info_by_number(who_to_cast_char_info.to_dictionary(),end_np_points,"Skill")
			"Heal":
				heal_char_info(who_to_cast_char_info,skill_info.get("Power",5))
			"HP Drain":
				heal_char_info(who_to_cast_char_info,-skill_info.get("Power",5),"Drain")
			"Additional Move":
				reduce_additional_moves_for_char_info(who_to_cast_char_info.to_dictionary(),-skill_info.get("Power",1))
			"Delayed Effect":
				skill_info["Turn Casted"]=turns_counter
				who_to_cast_char_info.get_node().buffs.append(skill_info)
			"Faceless Moon":
				skill_info["Dices"]=field.dice_roll_result_list.duplicate(true)
				who_to_cast_char_info.get_node().buffs.append(skill_info)
			"Presence Concealment":
				start_presence_concealment_for_char_info(who_to_cast_char_info)
				var copy_info=skill_info.duplicate(true)
				copy_info["Turn Casted"]=turns_counter
				who_to_cast_char_info.get_node().buffs.append(copy_info)
			"Guaranteed Death":
				who_to_cast_char_info.get_node().buffs=[]
				trigger_death_to_char_info(who_to_cast_char_info)
			"Invincibility":#if power==0 then all turns else for N hits
				who_to_cast_char_info.get_node().buffs.append(skill_info)
			_:#else
				who_to_cast_char_info.get_node().buffs.append(skill_info)
	pass


func get_uniq_string_from_object(object_tmp)->String:
	var object=object_tmp.duplicate()
	if typeof(object) == TYPE_DICTIONARY:
		if object.get("Description",""):
			object["Description"]={}

	var buff_info_stringify=str(object)
	var ctx = HashingContext.new()
	var buffer = buff_info_stringify.to_utf8_buffer()
	ctx.start(HashingContext.HASH_MD5)
	ctx.update(buffer)
	var unique_id_trait = ctx.finish()
	unique_id_trait=unique_id_trait.hex_encode()

	return unique_id_trait




func summon_someone(char_info:CharInfo,summon_buff_info:Dictionary):

	#{
	#	"Name":"Summon",
	#	"Duration":3,
	#	"Summon Name":"Rama",
	#	"Skills Enabled":false,
	#	"One Time Skills":false,
	#	"Can Use Phantasm":false,
	#	"Disappear After Summoner Death":true,
	#	"Mount":false,
	#	"Can Attack":true,
	#	"Can Evade":true,
	#	"Can Defence":true,
	#	"Move Points":1,
	#	"Attack Points":1,
	#	"Phantasm Points Farm":false,
	#	"Limit":3,
	#	"Servant Data Location":"Main"
	#}
	
	
	#var servant_node_name=Globals.pu_id_player_info[pu_id]["servant_node"]

	var summon_name=summon_buff_info.get("Summon Name","")
	if summon_name=="":
		push_error("Summon Name is not specifyed, aborting")
		return

	var unique_id_trait=get_uniq_string_from_object(summon_buff_info)


	var limit=summon_buff_info.get("Limit", 3)

	var id_to_check=unique_id_trait
	var counter:int=0

	#checking if limit reached
	for unit_id in Globals.pu_id_player_info[Globals.self_pu_id]["units"].keys():
		var node=Globals.pu_id_player_info[Globals.self_pu_id]["units"][unit_id]

		if node.skill_uniq_summon_id==id_to_check:
			counter+=1
	

	if counter>=limit:
		field.info_table_show(tr("MAXIMUM_SUMMONABLE_UNITS_REACHED_FOR_SKILL"))
		await field.info_ok_button.pressed
		return false



	summon_buff_info["Summoner_char_infodic"]=char_info.to_dictionary()


	#var buff_info_stringify=str(summon_buff_info)
	#var ctx = HashingContext.new()
	#var buffer = buff_info_stringify.to_utf8_buffer()
	#ctx.start(HashingContext.HASH_MD5)
	#ctx.update(buffer)
	#var unique_id_trait = ctx.finish()

	var data_location = summon_buff_info.get("Servant Data Location","Main")
	if data_location == "Main":
		pass
	elif data_location == "Sub":
		summon_name=Globals.pu_id_player_info[Globals.self_pu_id]["servant_name"]+'/'+summon_name
	var id_to_send=Globals.uniqq_ids.pick_random()
	Globals.uniqq_ids.erase(id_to_send)

	var ascention={
		"name": summon_name,
		"ascension": 0,
		"costume": 0
	}

	rpc("load_servant",Globals.self_pu_id,ascention,id_to_send,true,summon_buff_info)
	var char_info_loaded=await servant_loaded

	char_info_loaded=CharInfo.from_dictionary(char_info_loaded)
	print("servant loaded signal got")
	#handle summon position

	field.current_action="wait"
	var kletka_to_initial_spawn=field.get_unoccupied_kletki()
	field.choose_glowing_cletka_by_ids_array(kletka_to_initial_spawn)
	var glow_pressed = await field.glow_kletka_pressed_signal
	field.rpc("move_player_from_kletka_id1_to_id2",char_info_loaded.to_dictionary(),-1,glow_pressed)
	
	print("checking hp buffs to get if hp is bigger than max hp for char_info_loaded")
	check_if_hp_is_bigger_than_max_hp_for_char_info(char_info_loaded)

	print("summon_someone completed returning true")
	return true




func start_presence_concealment_for_char_info(char_info:CharInfo):
	char_info.get_node().visible=false
	var cur_kletka_before=field.get_current_kletka_id()
	if char_info.get_uniq_id()==field.get_current_self_char_info().get_uniq_id():
		#field.get_current_kletka_id()=-1
		pass
	field.dismount_char_info(char_info)
	field.occupied_kletki[cur_kletka_before].erase(char_info.get_node)
	if field.occupied_kletki[cur_kletka_before].is_empty():
		field.occupied_kletki.erase(cur_kletka_before)
	
	#field.pu_id_to_kletka_number[pu_id]=-1
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

func effect_on_buff(char_info_buff_given_to:CharInfo,buff_name)->void:

	for i in range (10):
		char_info_buff_given_to.get_node().get_child(1).modulate=Color(1,1,1,i*0.1)
		await get_tree().create_timer(0.05).timeout
	char_info_buff_given_to.get_node().get_child(2).text=buff_name
	
	for i in range (5):
		char_info_buff_given_to.get_node().get_child(2).modulate=Color(1,1,1,i*0.2)
		await get_tree().create_timer(0.006).timeout
	
	
	await get_tree().create_timer(0.1).timeout
	for i in range (10,-1,-1):
		char_info_buff_given_to.get_node().get_child(1).modulate=Color(1,1,1,i*0.1)
		char_info_buff_given_to.get_node().get_child(2).modulate=Color(1,1,1,i*0.1)
		await get_tree().create_timer(0.05).timeout
	
	pass

@rpc("any_peer","reliable","call_local")
func remove_buff(cast_array:Array,skill_name:String,remove_passive=false,remove_only_passive_one=false):
	#remove SINGLE BUFF
	#if need to remove bath then await buff_removed to sync
	# OR remove_buff_array
	for who_to_remove_buff_char_info_dic in cast_array:
		var who_to_remove_buff_char_info=CharInfo.from_dictionary(who_to_remove_buff_char_info_dic)
		var i=0
		for buff in who_to_remove_buff_char_info.get_node().buffs:
			if buff["Name"]==skill_name:
				var buf_type=buff.get("Type","")
				if buf_type=="Status":
					i+=1
					continue
				if buf_type=="Passive":
					if remove_passive: 
						who_to_remove_buff_char_info.get_node().buffs.pop_at(i)
						buff_removed.emit()
						return
				else:
					if not remove_only_passive_one:
						who_to_remove_buff_char_info.get_node().buffs.pop_at(i)
						buff_removed.emit()
						return
			i+=1
	buff_removed.emit()
	

func get_char_info_maximun_hp(char_info:CharInfo)->int:
	var servant_node:Node2D=char_info.get_node()
	var default_max_hp:int=servant_node.default_stats["hp"]
	var additional_hp:int=0
	for buff:Dictionary in get_char_info_buffs(char_info):
		if buff.get("Name","")=="Max HP Plus":
			additional_hp+=buff.get("Power",1)
		if buff.get("Name","")=="Maximum HP Add":
			additional_hp+=buff.get("Power",1)
		if buff.get("Name","")=="Maximum HP Set":
			return buff.get("Power",5)
			

	return default_max_hp+additional_hp

func heal_char_info(char_info:CharInfo,amount:int,type:String="normal"):
	print(str("\nheal_char_info=",char_info," by ",amount))
	
	
	var servant_node_to_heal:Node2D=char_info.get_node()
	var current_hp:int=servant_node_to_heal.hp
	var amount_to_heal:int
	var max_hp:int=get_char_info_maximun_hp(char_info)
	if type=="command_spell":
		amount_to_heal=ceil(max_hp*0.7)
	else:#command spell is static 70%
		amount_to_heal=amount
		for buff in get_char_info_buffs(char_info):
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
	
	

	rpc("update_hp_on_char_info",char_info.to_dictionary(),servant_node_to_heal.hp)
	print(str("hp now is ",servant_node_to_heal.hp,"\n"))
	
@rpc("any_peer","call_local","reliable")
func charge_np_to_char_info_by_number(char_info_dic:Dictionary,number:int,source="damage"):
	var char_info=CharInfo.from_dictionary(char_info_dic)
	print("\n===charge_np_to_char_info_by_number===")
	#print("unit_uniq_id_to_np_points[pu_id]="+str(unit_uniq_id_to_np_points[pu_id])+"+"+str(number))

	if char_info.get_node().phantasm_points_farm:
		var summoner_dic:Dictionary=char_info.get_node().summoner_char_infodic
		var summoner_char_info:CharInfo=CharInfo.from_dictionary(summoner_dic)
		source="farm"
		char_info=summoner_char_info

	var number_to_add=number
	for skill in char_info.get_node().buffs:
		match skill["Name"]:
			"NP Gain Up" when source=="damage":
				number_to_add+=skill["Power"]
			"NP Gain Up X" when source=="damage":
				number_to_add*=skill["Power"]
	#number_to_add=max(0,number_to_add)
	print("amount_np_to_add=",number_to_add)
	char_info.get_node().phantasm_charge+=number_to_add
	var new_number=char_info.get_node().phantasm_charge
	print("new np charge num=",new_number)
	if new_number<0:
		char_info.get_node().phantasm_charge=0
	if new_number>12:
		char_info.get_node().phantasm_charge=12
	#change_phantasm_charge_on_pu_id
	if char_info.get_uniq_id()==field.get_current_self_char_info().get_uniq_id():
		get_self_servant_node().phantasm_charge=char_info.get_node().phantasm_charge
		%np_points_number_label.text=str(char_info.get_node().phantasm_charge)


func get_char_info_traits(char_info:CharInfo)->Array:
	var char_info_node=char_info.get_node()
	var default_traits:Array=char_info_node.traits
	var output_traits:Array=default_traits.duplicate(true)
	for buff in get_char_info_buffs(char_info):
		if buff.get("Name")=="Trait Set":
			var buff_trait:String=buff.get("Trait","")
			if buff_trait:
				output_traits.append(buff_trait)

	return output_traits

func get_char_info_gender(char_info:CharInfo)->String:
	var char_info_node=char_info.get_node()
	var default_gender:String=char_info_node.gender
	var output_gender:String=default_gender+""
	for buff in get_char_info_buffs(char_info):
		if buff.get("Name")=="Gender Set":
			var gennder:String=buff.get("Gender","")
			if gennder:
				output_gender=gennder

	return output_gender

func get_char_info_strength(char_info:CharInfo)->String:
	var char_info_node=char_info.get_node()
	var default_strength:String=char_info_node.strength
	var output_strength:String=default_strength+""
	for buff in get_char_info_buffs(char_info):
		if buff.get("Name")=="Strength Set":
			var gennder:String=buff.get("Strength","")
			if gennder:
				output_strength=gennder

	return output_strength



func get_charInfo_from_pu_id_unit_id(pu_id:String,unit_id:int)->CharInfo:
	var rett_val=CharInfo.new(pu_id,unit_id)
	return rett_val
	#return Globals.pu_id_player_info[pu_id]["units"][unit_id]


@rpc("any_peer","reliable","call_local")
func add_to_advanced_logs(text_code:String,formats:Dictionary={}):	
	text_code=tr(text_code)
	var text_to_add=text_code.format(formats)
	%advanced_logs_textedit.text+=text_to_add+"\n"
	print(text_to_add+"\n")


func calculate_damage_to_take(attacker_char_info:CharInfo,enemies_dice_results:Dictionary,damage_type:String=DAMAGE_TYPE.PHYSICAL,special:String="regular"):
	#damage_type="normal"/"Magical"
	#special is to half the damage bc evade or defence
	print("calculating damage to take\n\n")
	var self_char_attacked=field.char_info_attacked
	var current_kletka=field.char_info_to_kletka_number(self_char_attacked)

	rpc("add_to_advanced_logs",
	"ADVANCED_LOG_CALCULATE_DAMAGE_TO_TAKE_START",
		{
			"taker_name":self_char_attacked.get_node().name,
			"attacker_name":attacker_char_info.get_node().name,
			"enemy_dices":enemies_dice_results,
			"damage_type":damage_type,
			"special":special
		}
	)


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
	var self_traits=get_char_info_traits(self_char_attacked)
	var attacker_traits=get_char_info_traits(attacker_char_info)
	var additional_buffs=[]

	
	if damage_type==DAMAGE_TYPE.MAGICAL:
		#damage_to_take=Globals.pu_id_player_info[attacker_pu_id]["servant_node"].magic["Power"]
		damage_to_take=get_char_info_magical_attack(attacker_char_info)
		rpc("add_to_advanced_logs","ADVANCED_LOG_CALCULATE_DAMAGE_ATTACKER_MAGICAL_ATTACK")

		
		var cur_kletka_conf=field.kletka_preference[current_kletka]

		var attacker_kletka=field.char_info_to_kletka_number(attacker_char_info)
		var attacker_kletka_conf=field.kletka_preference[attacker_kletka]
		if cur_kletka_conf.is_empty():
			is_field_ignore_magic_defence=false
		else:#checking if you on field
			if cur_kletka_conf.get("Owner","")==attacker_char_info.get_uniq_id() and cur_kletka_conf.get("Ignore Magical Defence",false) \
			and attacker_kletka_conf.get("Owner","")==attacker_char_info.get_uniq_id() and attacker_kletka_conf.get("Ignore Magical Defence",false):
				is_field_ignore_magic_defence=true
				rpc("add_to_advanced_logs",
				"ADVANCED_LOG_CALCULATE_DAMAGE_ALL_ON_MAGICAL_FIELD")
	else:
		#damage_to_take=Globals.pu_id_player_info[attacker_pu_id]["servant_node"].attack_power
		damage_to_take=get_char_info_attack_power(attacker_char_info)

	
	if damage_type==DAMAGE_TYPE.PHANTASM:
		if !field.recieved_phantasm_config.is_empty():#for phantasm damage
			damage_to_take=field.recieved_phantasm_config["Damage"]
			rpc("add_to_advanced_logs","ADVANCED_LOG_CALCULATE_DAMAGE_PHANTASM_ATTACK")
			if field.recieved_phantasm_config.has("Ignore"):
				buff_types_to_ignore=field.recieved_phantasm_config["Ignore"]
				rpc("add_to_advanced_logs",
					"ADVANCED_LOG_CALCULATE_DAMAGE_PHANTASM_IGNORE_TYPES",
					{"types":buff_types_to_ignore}
				)
		additional_buffs= field.recieved_phantasm_config.get("Phantasm Buffs",[])
		
	print("damage_type="+str(damage_type)+" damage_to_take="+str(damage_to_take))

	rpc("add_to_advanced_logs",
		"ADVANCED_LOG_CALCULATE_DAMAGE_BASE_DAMAGE",
		{"damage":damage_to_take}
	)
	
	#calculating attacker damage
	print("calculating attacker damage")

	#damage_to_take=get_peer_id_attack_power(attacker_peer_id,damage_type,[],additional_buffs)

	damage_to_take=calculate_char_info_attack_against_char_info(attacker_char_info,self_char_attacked,damage_type,field.recieved_phantasm_config)

	rpc("add_to_advanced_logs",
		"ADVANCED_LOG_CALCULATE_DAMAGE_AFTER_ATTACKER_BUFFS",	{"damage_to_take":damage_to_take}
	)

	rpc("add_to_advanced_logs","ADVANCED_LOG_CALCULATE_DAMAGE_CHECK_ATTACKER_CRIT")
	is_crit=check_if_char_info_got_crit(attacker_char_info,enemies_dice_results)

	
	if is_crit:
		print("it is crit")
		rpc("add_to_advanced_logs","ADVANCED_LOG_CALCULATE_DAMAGE_ATTACKER_CRIT_VALID")
		damage_before_crit=damage_to_take
		damage_to_take=calculate_crit_damage(attacker_char_info,damage_to_take)
	else:
		print("it is not crit")
		rpc("add_to_advanced_logs","ADVANCED_LOG_CALCULATE_DAMAGE_ATTACKER_CRIT_NOT_VALID")
	
	print("calculating ignore buffs")

	rpc("add_to_advanced_logs","ADVANCED_LOG_CALCULATE_DAMAGE_IGNORE_BUFFS")
	
	for buff in buff_ignoring:
		var buff_infoo=char_info_has_active_buff(attacker_char_info, buff)
		if buff_infoo:
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

	
	
	rpc("add_to_advanced_logs",
		"ADVANCED_LOG_CALCULATE_DAMAGE_TOTAL_TYPES_TO_IGNORE",
		{"types":buff_types_to_ignore}
	)
	var defence_multiplier=1
	#calculating self defence
	print("calculating self defence")
	rpc("add_to_advanced_logs","ADVANCED_LOG_CALCULATE_DAMAGE_TAKER_DEFENCE")
	#for skill in peer_id_player_info[Globals.self_peer_id]["servant_node"].buffs:
	for skill in get_char_info_buffs(self_char_attacked):
		var skill_type_array
		if skill.has("Types"):
			skill_type_array=skill["Types"]
		else:
			skill_type_array=Globals.buffs_types.get(skill["Name"],[])
		
		if skill_type_array.is_empty():
			push_error("No types found for skill=",skill)
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_CALCULATE_DAMAGE_NO_TYPES_FOR_BUFF",
				{"buff":skill}
			)
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
				rpc("add_to_advanced_logs",
					"ADVANCED_LOG_CALCULATE_DAMAGE_TAKER_HAS_EVADE_BUFF"
				)
				return "evaded"
			"Invincibility":
				zero_damage=true
				rpc("add_to_advanced_logs",
					"ADVANCED_LOG_CALCULATE_DAMAGE_TAKER_HAS_INVINCIBILITY_BUFF"
				)
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
					
	
		var out_string=""
		if skill.has("Power"):
			out_string=str("Buff={buff_name} power={buff_power} damage_to_take={total_damage}").format(
				{
					"buff_name":skill["Name"],
					"buff_power":skill["Power"],
					"total_damage":damage_to_take
				}
			)
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_DAMAGE_CALCULATE_BUFF_POWER_DAMAGE",
				{
					"buff_name":skill["Name"],
					"buff_power":skill["Power"],
					"total_damage":damage_to_take
				}
			)
		else:
			out_string=str("Buff={buff_name} damage_to_take={total_damage}").format(
				{
					"buff_name":skill["Name"],
					"total_damage":damage_to_take
				}
			)
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_DAMAGE_CALCULATE_BUFF_NO_POWER_DAMAGE",
				{
					"buff_name":skill["Name"],
					"total_damage":damage_to_take
				}
			)



		#out_string+=str(" damage_to_take=",damage_to_take)
		print(out_string)
	
	damage_to_take*=defence_multiplier

	rpc("add_to_advanced_logs",
		"ADVANCED_LOG_CALCULATE_DAMAGE_MULTIPLYING_DEFENCE",
		{"damage_to_take":damage_to_take}
	)
	
	print("special=",special, " buff_types_to_ignore=",buff_types_to_ignore)
	if special=="Halfed Damage":
		damage_to_take=floor(damage_to_take/2)
		print("Halfed Damage   damage_to_take="+str(damage_to_take))
		rpc("add_to_advanced_logs",
			"ADVANCED_LOG_CALCULATE_DAMAGE_HALFED_DAMAGE",
			{"damage_to_take":damage_to_take}
		)
	
	if damage_type==DAMAGE_TYPE.MAGICAL:
		if not is_field_ignore_magic_defence:
			var self_magic_res=get_char_info_magical_defence(self_char_attacked)
			damage_to_take-=self_magic_res
			print(str("magical resistange=",self_magic_res," damage_to_take=",damage_to_take))

			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_CALCULATE_DAMAGE_MAGICAL_DEFENCE",
				{
					"self_magic_res":self_magic_res,
					"damage_to_take":damage_to_take
				}
			)
		else:
			print("field is ignoring magical defence")
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_CALCULATE_DAMAGE_FIELD_IGNORING_MAGICAL_DEFENCE"
			)

		if get_char_info_class(self_char_attacked)=="Saber":
			if char_info_has_active_buff(self_char_attacked,"Magic Resistance"):
				damage_to_take=floor(damage_to_take/2)
				print(str("Saber resistance", "damage_to_take=",damage_to_take))
				rpc("add_to_advanced_logs",
					"ADVANCED_LOG_CALCULATE_DAMAGE_SABER_HAS_MAGICAL_RESISTANCE",
					{"damage_to_take":damage_to_take}
				)
		
	if special=="Defence":
		var ignore=false
		rpc("add_to_advanced_logs","ADVANCED_LOG_CALCULATE_DAMAGE_TAKER_DEFENDING")
		if "Defence" in buff_types_to_ignore:
			print("ignoring defence")
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_CALCULATE_DAMAGE_ATTACKER_IGNORES_DEFENDING"
			)
			ignore=true
		if ignore:
			pass
		else:
			damage_to_take-=field.dice_roll_result_list["defence_dice"]
			print(str("defending=",field.dice_roll_result_list["defence_dice"]," damage_to_take=",damage_to_take))

			rpc("add_to_advanced_logs",
			"ADVANCED_LOG_CALCULATE_DAMAGE_TAKER_DEFENCE_RESULT",
				{
					"defence_dice":field.dice_roll_result_list["defence_dice"],
					"damage_to_take":damage_to_take
				}
			)
	if damage_to_take<=1:
		damage_to_take=1
		
	if zero_damage:
		damage_to_take=0
		
	#Globals.self_servant_node.hp-=damage_to_take
		
	trigger_buffs_on(self_char_attacked,"Damage Taken",attacker_char_info)
	trigger_buffs_on(self_char_attacked,damage_type+" Damage Taken",attacker_char_info)
	
	
	print(str("damage_to_take=",damage_to_take," type=",damage_type,"\n\n"))

	rpc("add_to_advanced_logs",
		"ADVANCED_LOG_CALCULATE_DAMAGE_TOTAL_DAMAGE_TO_TAKE",
		{
			"damage_to_take":damage_to_take,
			"damage_type":damage_type
		}
	)
	
	return damage_to_take

@rpc("any_peer","reliable","call_local")
func take_damage_to_char_info(char_info_dic:Dictionary,damage_amount:int,can_kill:bool=true,by_whom_char_info_dic=null)->void:
	var char_info=CharInfo.from_dictionary(char_info_dic)

	var start_hp=char_info.get_node().hp
	var new_hp=start_hp-damage_amount
	
	if not can_kill and new_hp<=0:
		new_hp=1
	
	change_game_stat_for_char_info(char_info.to_dictionary(),"total_damage_taken",damage_amount)
	
	
	update_hp_on_char_info(char_info.to_dictionary(),new_hp)
	if char_info.get_uniq_id()==field.get_current_self_char_info().get_uniq_id():
		field.rpc("systemlog_message",str(Globals.nickname," took ",damage_amount," damage, now HP=", new_hp))
		rpc("add_to_advanced_logs",
			"ADVANCED_LOG_PLAYER_TOOK_DAMAGE",
			{
				"player_name":char_info.get_node().name,
				"new_hp":new_hp
			}
		)
	print(str(char_info.get_node().name," HP is ",new_hp," now"))
	
	
	
	if new_hp<=0:
		print("death")
		trigger_death_to_char_info(char_info,by_whom_char_info_dic)


func trigger_death_to_char_info(char_info_died:CharInfo,by_whom_char_info_dic=null):
	#TODO replace loop with this func
	#if peer_id_has_buff(Globals.self_peer_id, buff):
	add_to_advanced_logs(
		"ADVANCED_LOG_PLAYER_TOOK_LETAL_DAMAGE_DEATH",
		{
			"player_name":char_info_died.get_node().name,
		}
	)
	if by_whom_char_info_dic!=null:
		by_whom_char_info_dic=CharInfo.from_dictionary(by_whom_char_info_dic)
	
	var node_died = char_info_died.get_node()
	
	var guts_buff=char_info_has_active_buff(char_info_died,"Guts")
	if guts_buff:
		var hp_to_recover=guts_buff.get("HP To Recover",1)

		add_to_advanced_logs("ADVANCED_LOG_PLAYER_REVIVES_WITH_GUTS_BUFF",
			{
				"player_name":node_died.name,
				"hp_to_recover":hp_to_recover
			}
		)

		heal_char_info(char_info_died,hp_to_recover)
		trigger_buffs_on(char_info_died,"Guts Used",by_whom_char_info_dic)
		remove_buff([char_info_died.to_dictionary()],"Guts")
		return
	
	

	var summoned = node_died.summon_check

	if pu_id_to_command_spells_int[char_info_died.pu_id]>=3 and not summoned:
		var max_hp=node_died.default_stats["hp"]
		rpc("update_hp_on_char_info",char_info_died.to_dictionary(),max_hp)
		reduce_command_spell_on_pu_id(char_info_died.pu_id,3)
		add_to_advanced_logs("ADVANCED_LOG_REVIVE_WITH_COMMAND_SPELLS",
			{
				"player_name":node_died.name,
			}
		)
		trigger_buffs_on(char_info_died,"Command Spell Revive")
	else:#total death
		for i in range(9):
			node_died.rotation_degrees+=10
			await get_tree().create_timer(0.1).timeout
		if check_if_all_pu_id_units_dead(char_info_died.pu_id):
			add_to_advanced_logs("ADVANCED_LOG_ALL_PLAYER_UNITS_DEAD",
				{
					"pu_id":char_info_died.pu_id
				}
			)
			turns_order_by_pu_id.erase(char_info_died.pu_id)
		
		trigger_buffs_on(by_whom_char_info_dic,"Total Kill",char_info_died)
		node_died.total_dead=true

		#unmounting if mount
		if node_died.mount:
			var mount_char_info=char_info_died
			add_to_advanced_logs("ADVANCED_LOG_UNMOUNTING_DEAD_UNIT")
			var currently_on_mount:Array = mount_char_info.get_node().mounted_by_uniq_ids_array
			for uniq_id in currently_on_mount:
				var char_info_to_dismount=field.get_char_info_from_uniq_id(uniq_id)
				currently_on_mount.erase(char_info_to_dismount.get_uniq_id())
				mount_char_info.get_node().mounted_by_uniq_ids_array=currently_on_mount

				var current_mounts:Array = char_info_to_dismount.get_node().mounts_uniq_id_array
				current_mounts.erase(mount_char_info.get_uniq_id())
				char_info_to_dismount.get_node().mounts_uniq_id_array=current_mounts

		for char_info_single in get_all_char_infos():
			var summoner=char_info_single.get_node().summoner_char_infodic
			if not summoner.is_empty():
				var summoner_char_info=CharInfo.from_dictionary(summoner)
				if summoner_char_info.get_uniq_id() == char_info_died.get_uniq_id():
					add_to_advanced_logs(str("Summoner_char_infodic killing all servant's unit"))
					trigger_death_to_char_info(char_info_single)
		field.remove_char_info_from_kletka_id(char_info_died,field.get_current_kletka_id(char_info_died))

	
func check_if_all_pu_id_units_dead(pu_id:String)->bool:
	for unit_id in Globals.pu_id_player_info[pu_id]["units"].keys():
		var unit_node=Globals.pu_id_player_info[pu_id]["units"][unit_id]
		if not unit_node.total_dead:
			return false
	return true

@rpc("any_peer","reliable","call_local")
func update_hp_on_char_info(char_info_dic:Dictionary,hp_to_set:int)->void:
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)
	if char_info.get_uniq_id()==field.get_current_self_char_info().get_uniq_id():
		current_hp_value_label.text=str(hp_to_set)
	char_info.get_node().hp=hp_to_set

func _on_texture_rect_gui_input(event)->void:
	if event.is_action_pressed:
		print(event)
	pass # Replace with function body.

@rpc("any_peer","reliable","call_local")
func reduce_additional_moves_for_char_info(char_info_dic:Dictionary,amount:int=1)->void:
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)
	char_info.get_node().additional_moves-=amount
	add_to_advanced_logs("ADVANCED_LOG_REDUCE_ADDITIONAL_MOVES",
		{
			"player_name":char_info.get_node().name,
			"amount":amount
		}
	)

@rpc("any_peer","reliable","call_local")
func reduce_additional_attacks_for_char_info(char_info_dic:Dictionary,amount:int=1)->void:
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)
	char_info.get_node().additional_attack-=amount
	add_to_advanced_logs("ADVANCED_LOG_REDUCE_ADDITIONAL_ATTACKS",
		{
			"player_name":char_info.get_node().name,
			"amount":amount
		}
	)

@rpc("any_peer","reliable","call_local")
func set_char_info_cooldown_for_skill_id(char_info_dic:Dictionary,skill_number,cooldown)->void:
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)
	char_info.get_node().skill_cooldowns[skill_number]=cooldown
	

func _on_use_skill_button_pressed():
	print("[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]")
	print(skill_info_tab_container.current_tab)
	field.hide_all_gui_windows("skill_info_tab_container")
	
	%MAKE_ACTION_BUTTON.disabled=true
	field.skill_info_show_button.disabled=true
	var skill_consume_action=true
	var succesfully

	var char_info:CharInfo=field.get_current_self_char_info()

	var one_time_skills=false
	var cur_node=field.get_current_self_char_info().get_node()
	if cur_node.summon_check:
		one_time_skills = cur_node.one_time_skills

	
	match skill_info_tab_container.current_tab+1:
		1:
			#Globals.self_servant_node.first_skill()
			rpc("add_to_advanced_logs","ADVANCED_LOG_PLAYER_USING_FIRST_SKILL",
				{
					"player_name":get_self_servant_node().name
				}
			)

			skill_consume_action= get_self_servant_node().skills["First Skill"].get("Consume Action",true)

			succesfully=await use_skill(get_self_servant_node().skills["First Skill"]["Effect"])

			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_SKILL_USAGE_RESULT",
				{"result":succesfully}
			)

			var skill_cooldown=get_self_servant_node().skills["First Skill"]["Cooldown"]
			
			if one_time_skills:
				skill_cooldown=NAN
			
			if succesfully:
				rpc("set_char_info_cooldown_for_skill_id",char_info.to_dictionary(),0,
				skill_cooldown)
		2:
			#Globals.self_servant_node.second_skill()
			rpc("add_to_advanced_logs","ADVANCED_LOG_PLAYER_USING_SECOND_SKILL",
				{
					"player_name":get_self_servant_node().name
				}
			)
			skill_consume_action= get_self_servant_node().skills["Second Skill"].get("Consume Action",true)
			succesfully=await use_skill(get_self_servant_node().skills["Second Skill"]["Effect"])
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_SKILL_USAGE_RESULT",
				{"result":succesfully}
			)
			
			var skill_cooldown=get_self_servant_node().skills["Second Skill"]["Cooldown"]


			if one_time_skills:
				skill_cooldown=NAN
			
			if succesfully:
				rpc("set_char_info_cooldown_for_skill_id",char_info.to_dictionary(),1,
				skill_cooldown)
		3:
			#Globals.self_servant_node.third_skill()
			skill_consume_action= get_self_servant_node().skills["Third Skill"].get("Consume Action",true)
			rpc("add_to_advanced_logs","ADVANCED_LOG_PLAYER_USING_THIRD_SKILL",
				{
					"player_name":get_self_servant_node().name
				}
			)
			succesfully=await use_skill(get_self_servant_node().skills["Third Skill"]["Effect"])
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_SKILL_USAGE_RESULT",
				{"result":succesfully}
			)
			var skill_cooldown=get_self_servant_node().skills["Third Skill"]["Cooldown"]

			
			if one_time_skills:
				skill_cooldown=NAN
			
			if succesfully:
				rpc("set_char_info_cooldown_for_skill_id",char_info.to_dictionary(),2,
				skill_cooldown)
		4:
			var class_skill_number= skill_info_tab_container.get_current_tab_control().current_tab+1
			var skill_info= get_self_servant_node().skills["Class Skill "+str(class_skill_number)]
			skill_consume_action= skill_info.get("Consume Action",true)
			rpc("add_to_advanced_logs",
				"ADVANCED_LOG_PLAYER_USING_CLASS_SKILL",
				{
					"player_name":get_self_servant_node().name,
					"class_skill_number":class_skill_number
				}
			)

			var skill_cooldown=skill_info["Cooldown"]

			if one_time_skills:
				skill_cooldown=NAN
			
			if skill_info["Type"]=="Weapon Change":
				#print(skill_info_tab_container.get_current_tab_control().get_current_tab_control())
				var weapon_name_to_change_to=skill_info_tab_container.get_current_tab_control().get_current_tab_control().get_current_tab_control().name
				var tt=skill_info_tab_container.get_current_tab_control()
				var tt2=tt.get_current_tab_control()
				print(tt2.name)
				#var tt3=tt2.get_current_tab_control()
				print("eee")
				
				var set_cooldown=true
				if skill_info.get("free_unequip",false):
					print("free_unequip true")
					if skill_info["weapons"].keys()[0]==weapon_name_to_change_to:
						print("set_cooldown false")
						set_cooldown=false

				if set_cooldown:
					rpc("set_char_info_cooldown_for_skill_id",char_info.to_dictionary(),2+class_skill_number,
					skill_cooldown)
				succesfully=true#idk how to check it properly
				change_weapon(weapon_name_to_change_to,class_skill_number)

				rpc("add_to_advanced_logs",
					"ADVANCED_LOG_PLAYER_USING_WEAPON_CHANGE",
					{
						"player_name":get_self_servant_node().name
					}
				)
			else:
				#Globals.self_servant_node.call("Class Skill "+str(class_skill_number))
				rpc("add_to_advanced_logs",
					"ADVANCED_LOG_PLAYER_USING_CLASS_SKILL",
					{
						"player_name":get_self_servant_node().name,
						"class_skill_number":class_skill_number
					}
				)
				succesfully=await use_skill(get_self_servant_node().skills["Class Skill "+str(class_skill_number)]["Effect"])
				if succesfully:
					rpc("set_char_info_cooldown_for_skill_id",char_info.to_dictionary(),2+class_skill_number,
					skill_cooldown)
				rpc("add_to_advanced_logs",
				"ADVANCED_LOG_SKILL_USAGE_RESULT",
				{"result":succesfully}
			)
	if skill_consume_action and succesfully:
		field.reduce_one_action_point(-1,"_on_use_skill_button_pressed")
	if succesfully:
		rpc("change_game_stat_for_char_info",char_info.to_dictionary(),"skill_used_this_turn",1)
		rpc("change_game_stat_for_char_info",char_info.to_dictionary(),"total_skill_used",1)
	%MAKE_ACTION_BUTTON.disabled=false
	field.skill_info_show_button.disabled=false
	rpc("finish_attack",field.get_current_self_char_info().to_dictionary())
	pass # Replace with function body.

func char_info_has_buff(char_info:CharInfo,buff_name:String):
	#for buff in Globals.pu_id_player_info[pu_id]["servant_node"].buffs:
	for buff in char_info.get_node().buffs:
		if buff["Name"].to_lower()==buff_name.to_lower():
			return buff
	return false

func char_info_has_active_buff(char_info:CharInfo,buff_name:String):
	var buff=char_info_has_buff(char_info,buff_name)
	var condition_true=true
	if buff:
		if buff.has("Condition"):
			condition_true=check_condition_wrapper(buff.get("Condition",{}))#
		if condition_true:
			return buff
	return false

@rpc("any_peer","call_local","reliable")
func change_char_info_servant_stat(char_info_dic:Dictionary,stat:String,value:int)->void:
	var char_info=CharInfo.from_dictionary(char_info_dic)
	match stat:
		"attack_range":
			char_info.get_node().attack_range=value
		"attack_power":
			char_info.get_node().attack_power=value

@rpc("any_peer","call_local","reliable")
func change_char_info_sprite_from_path(char_info_dic:Dictionary,image_path:String)->void:
	var char_info=CharInfo.from_dictionary(char_info_dic)
	var img = Image.new()
	img.load(image_path)
	#player_textureRect.texture=ImageTexture.create_from_image(img)
	char_info.get_node().get_child(0).texture=ImageTexture.create_from_image(img)

@rpc("any_peer","call_local","reliable")
func change_char_info_sprite_from_image_data(char_info_dic:Dictionary,image_data)->void:
	print("--change_char_info_sprite_from_image_data called char_info_dic="+str(char_info_dic))
	var char_info=CharInfo.from_dictionary(char_info_dic)
	var data = image_data
	var img = Image.new()
	#FaceImg is just what I called the dictionary in the resource file
	img = Image.create_from_data(data["width"], data["height"], data["mipmaps"], data["format"], data["data"])

	#var texture = ImageTexture.new()
	#texture.set_image(img)
	var player_textureRect=char_info.get_node().get_child(0)
	player_textureRect.texture=null
	player_textureRect.scale=Vector2(1,1)
	player_textureRect.size=Vector2(0,0)
	
	#player_textureRect.texture.set_image(img)
	player_textureRect.texture=ImageTexture.create_from_image(img)
	
		
	var sizes:Vector2=player_textureRect.texture.get_size()
	player_textureRect.position=Vector2(-(TEXTURE_SIZE*1.0)/2,-TEXTURE_SIZE)
	player_textureRect.scale=Vector2(TEXTURE_SIZE/sizes.x,TEXTURE_SIZE/sizes.y)

	

@rpc("any_peer","call_remote","reliable")
func remove_char_info_buffs_by_uniq_id(char_info_dic:Dictionary,buff_uniq_id:String,remove_passive:bool=false,remove_only_passive:bool=false)->void:
	var char_info=CharInfo.from_dictionary(char_info_dic)
	var buffs_array=get_char_info_buffs(char_info)
	print("remove_char_info_buffs_by_uniq_id called buff_uniq_id="+str(buff_uniq_id))
	for buff in buffs_array:
		print("group_uniq_id="+str(buff.get("group_uniq_id","")))
		if buff.get("group_uniq_id","") == buff_uniq_id:
			print("removing buff="+str(buff))
			remove_buff([char_info_dic],buff["Name"],remove_passive,remove_only_passive)

func change_weapon(weapon_name_to_change_to,class_skill_number)->void:
	var weapons_array=get_self_servant_node().skills["Class Skill "+str(class_skill_number)]["weapons"]
	var current_weapon_description=weapons_array[get_self_servant_node().current_weapon]
	if current_weapon_description.has("Buff"):
		var current_weapon_buffs = current_weapon_description["Buff"]
		if typeof(current_weapon_buffs) != TYPE_ARRAY:
			current_weapon_buffs = [current_weapon_buffs]


		var weapon_uniq_id = get_uniq_string_from_object(current_weapon_description)

		print("removing group_uniq_id to weapon buffs from weapon desc=",current_weapon_description, " weapon_uniq_id=",weapon_uniq_id)
		
		remove_char_info_buffs_by_uniq_id(field.get_current_self_char_info().to_dictionary(), weapon_uniq_id, true, true)
		rpc("remove_char_info_buffs_by_uniq_id", field.get_current_self_char_info().to_dictionary(), weapon_uniq_id, true, true)
		
		
		print("previous weapon buffs removed")
	
	print("weapon_name_to_change_to="+str(weapon_name_to_change_to))
	
	get_self_servant_node().current_weapon=weapon_name_to_change_to
	var folderr=""
	if OS.has_feature("editor"):
		folderr="res:/"
	else:
		folderr=Globals.user_folder
	
	print("change_char_info_sprite_from_path")
	rpc("change_char_info_sprite_from_path",field.get_current_self_char_info().to_dictionary(),
	str(folderr)+field.get_current_self_char_info().get_node().servant_path+
	"/sprite_"+str(weapon_name_to_change_to).to_lower()+".png")
	
	rpc("change_char_info_servant_stat",field.get_current_self_char_info().to_dictionary(),
		"attack_range",weapons_array[weapon_name_to_change_to]["Range"])
	rpc("change_char_info_servant_stat",field.get_current_self_char_info().to_dictionary(),
		"attack_power",weapons_array[weapon_name_to_change_to]["Damage"])
	
	if weapons_array[weapon_name_to_change_to].get("Is One Hit Per Turn",false):
		rpc("remove_buff",[field.get_current_self_char_info().to_dictionary()],"Maximum Hits Per Turn",true,true)
		rpc("add_buff",[field.get_current_self_char_info().to_dictionary()],{"Name":"Maximum Hits Per Turn","Type":"Passive", "Power":1})
	else:
		rpc("remove_buff",[field.get_current_self_char_info().to_dictionary()],"Maximum Hits Per Turn",true,true)
	
	print("adding new weapon buff")
	if weapons_array[weapon_name_to_change_to].has("Buff"):
		var new_weapon_buffs = weapons_array[weapon_name_to_change_to]["Buff"].duplicate(true)
		if typeof(new_weapon_buffs) != TYPE_ARRAY:
			new_weapon_buffs = [new_weapon_buffs]
			
		var new_weapon_uniq_id = get_uniq_string_from_object(weapons_array[weapon_name_to_change_to])

		for i in range(new_weapon_buffs.size()):
			new_weapon_buffs[i]["group_uniq_id"] = new_weapon_uniq_id

		rpc("add_buff_array", [field.get_current_self_char_info().to_dictionary()], new_weapon_buffs)



func _on_items_pressed()->void:
	#{ "Heal Potion": { "min_cost": { "Type": "Free", "value": 0 }, "Type": "potion creating", "Effect": [{ "Name": "Heal", "Power": 5 }], "range": 2, "description": "(Зелье лечения: Восполняет 5 очков здоровья, а также снимает все дебаффы себе или другому слуге в радиусе двух клеток)" } }
	
	
	var items_array=unit_unique_id_to_items_owned[field.get_current_self_char_info().get_uniq_id()].duplicate(true)
	
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
			field.command_spells_button.texture_normal=load(str("res://images/empty.png"))

@rpc("any_peer","reliable","call_local")
func flip_char_info_sprite(char_info_dic:Dictionary)->void:
	var char_info=CharInfo.from_dictionary(char_info_dic)

	var ff =char_info.get_node().get_child(0).flip_h
	char_info.get_node().get_child(0).flip_h = !ff
	pass

func _on_flip_sprite_button_pressed():
	rpc("flip_char_info_sprite",field.get_current_self_char_info().to_dictionary())
	pass # Replace with function body.


func fill_teams_gui():
	var counter=1
	var pu_ids_with_no_team=get_all_pu_ids()

	for child in all_teams_vbox.get_children():
		if child is VBoxContainer:
			child.queue_free()
	
	for child in your_teams_vbox.get_children():
		if child is VBoxContainer:
			child.queue_free()
	
	#filling all teams
	var teams=get_teams()
	for team in teams:
		var new_team=TEAM_HOLDER.instantiate()
		var vbox_add_players_to=new_team.find_child("team_players_holder")
		var team_label=new_team.find_child("team_name_label")
		#new_team.name="team_holder"+str(counter)
		team_label.text="team="+str(counter)
		for player in team:
			print("player=",player)
			
			var player_button:Button=Button.new()
			player_button.text=Globals.pu_id_player_info[player]["nickname"]
			player_button.toggle_mode=true
			player_button.size_flags_horizontal=4
			
			
			player_button.toggled.connect(player_button_in_teams_pressed.bind(player_button,player))
			vbox_add_players_to.add_child(player_button)
			
			pu_ids_with_no_team.erase(player)
		counter+=1
		all_teams_vbox.add_child(new_team,true)

	
	#filling self teams
	for team in teams:
		if Globals.self_pu_id in team:
			var new_team=TEAM_HOLDER.instantiate()
			var vbox_add_players_to=new_team.find_child("team_players_holder")
			var team_label=new_team.find_child("team_name_label")
			#new_team.name=team_name
			team_label.text="Team "+str(counter)
			for player in team:
				
				print("player=",player)
				var player_button:Button=Button.new()
				player_button.text=Globals.pu_id_player_info[player]["nickname"]
				player_button.toggle_mode=true
				player_button.size_flags_horizontal=4
				
				
				player_button.toggled.connect(player_button_in_teams_pressed.bind(player_button,player))
				vbox_add_players_to.add_child(player_button)
			your_teams_vbox.add_child(new_team,true)
			counter+=1
	

	var additional_teams={
		"You are neutral to:":get_full_relations()[Globals.self_pu_id]["neutral"],
		"One-sided allies:":get_one_sided_allies_for_pu_id(Globals.self_pu_id)
	}

	

	for key in additional_teams:
		var team=additional_teams[key]
		var new_team=TEAM_HOLDER.instantiate()
		var vbox_add_players_to=new_team.find_child("team_players_holder")
		var team_label=new_team.find_child("team_name_label")
		#new_team.name=team_name
		team_label.text=key
		for player in team:
			print("player=",player)
			
			var player_button:Button=Button.new()
			player_button.text=Globals.pu_id_player_info[player]["nickname"]
			player_button.toggle_mode=true
			player_button.size_flags_horizontal=4
			
			
			player_button.toggled.connect(player_button_in_teams_pressed.bind(player_button,player))
			vbox_add_players_to.add_child(player_button)
			
			pu_ids_with_no_team.erase(player)
		your_teams_vbox.add_child(new_team,true)
		
	




func player_button_in_teams_pressed(_toggled:bool,button:Button,pu_id:String):
	
	if last_player_button_pressed!=null:
		last_player_button_pressed.button_pressed=false
	last_player_button_pressed=button
	player_in_teams_choosen_pu_id=pu_id


func get_one_sided_allies_for_pu_id(pu_id) -> Array:
	var all_relations=get_full_relations()
	var one_sided_list: Array = []

	if not all_relations.has(pu_id) or not all_relations[pu_id].has("allies"):
		return one_sided_list
	

	var my_declared_allies: Array = all_relations[pu_id]["allies"]

	
	for potential_ally_id in my_declared_allies:
		
		var is_mutual = false
		
		
		if all_relations.has(potential_ally_id):
			var their_relations = all_relations[potential_ally_id]
			
			if their_relations.has("allies") and their_relations["allies"].has(pu_id):
				is_mutual = true
		
		
		if not is_mutual:
			one_sided_list.push_back(potential_ally_id)
			
	return one_sided_list


func _on_teams_button_pressed():
	# button -> size_flags_horizontal=4

	fill_teams_gui()
	



	
	
	
	field.hide_all_gui_windows("teams")
	
	
	
	
	pass # Replace with function body.


func _on_betray_team_button_pressed():
	var who_to_betray_pu_id=player_in_teams_choosen_pu_id

	if current_player_pu_id_turn!=Globals.self_pu_id:
		#how can you betray enemy?
		field.info_table_show(tr("CAN_BETRAY_ONLY_DURING_SELF_TURN"))
		return

	if who_to_betray_pu_id==Globals.self_pu_id:
		#how can you betray yourself?
		field.info_table_show(tr("ATTEMPT_TO_BETRAY_YOURSELF"))
		return

	if not (who_to_betray_pu_id in get_allies()):
		#how can you betray enemy?
		field.info_table_show(tr("ATTEMPT_TO_BETRAY_ENEMY"))
		return
	
	field.disable_every_button()
	var type=await field.choose_between_two(
		str("Are you sure you want to betray "+Globals.pu_id_player_info[who_to_betray_pu_id]["nickname"]+" "+Globals.pu_id_player_info[who_to_betray_pu_id]["servant_name"]+" ?"),
		"Yes",
		"No"
	)
	field.disable_every_button(false)
	
	if type=="Yes":
		Globals.pu_id_to_allies[Globals.self_pu_id]["allies"].erase(who_to_betray_pu_id)

		field.disable_every_button()
		type=await field.choose_between_two(
			str("Do you want to make it public?"),
			"Yes",
			"No"
		)
		field.disable_every_button(false)
		if type=="Yes":
			field.rpc("systemlog_message",str(Globals.nickname+" betrayed "+Globals.pu_id_player_info[who_to_betray_pu_id]["nickname"]))
	else:
		return
	rpc("sync_relations",Globals.self_pu_id,Globals.pu_id_to_allies.duplicate(true))
	
	
	

	pass # Replace with function body.

func update_teams_for_pu_id(main_pu_id:String,pu_id_changed:String,status:String):
	match status:
		"Ally":
			Globals.pu_id_to_teams[main_pu_id]["allies"].append(pu_id_changed)
		"Betray":
			Globals.pu_id_to_teams[main_pu_id]["enemies"].append(pu_id_changed)

signal team_confirm_answer(answer:bool)
func _on_ally_button_pressed():
	var who_to_ally_pu_id=player_in_teams_choosen_pu_id

	if current_player_pu_id_turn!=Globals.self_pu_id:
		#how can you betray enemy?
		field.info_table_show(tr("CAN_BETRAY_ONLY_DURING_SELF_TURN"))
		return

	if who_to_ally_pu_id==Globals.self_pu_id:
		#how can you betray enemy?
		field.info_table_show(tr("ATTEMPT_TO_ALLY_YOURSELF"))
		return
	

	if (who_to_ally_pu_id in get_allies()):
		#how can you betray enemy?
		field.info_table_show(tr("ATTEMPT_TO_ALLY_ALLY"))
		return
	
	var peer_id_to_ally=Globals.pu_id_player_info[who_to_ally_pu_id]["current_peer_id"]

	rpc_id(peer_id_to_ally,"request_alliance")
	field.disable_every_button()
	field.info_table_show(tr("AWAITING_ALLIANCE_REQUEST_ANSWER"))
	var answer=await team_confirm_answer
	field.disable_every_button(false)
	if answer:
		additional_allies[who_to_ally_pu_id]="two-sided"

		Globals.pu_id_to_allies[Globals.self_pu_id]["allies"].append(who_to_ally_pu_id)

		field.info_table_show(tr("SUCCESFULLY_MADE_ALLIANCE"))
	else:
		field.disable_every_button()
		var type=await field.choose_between_two(
			tr("ALLIANCE_REQUEST_DECLINED_ONE_SIDE_QUESTION"),
			tr("ALLIANCE_REQUEST_DECLINED_ONE_SIDE_QUESTION_AGREEMENT"),
			tr("ALLIANCE_REQUEST_DECLINED_ONE_SIDE_QUESTION_DISAGREEMENT")
		)
		field.disable_every_button(false)
		if type==tr("ALLIANCE_REQUEST_DECLINED_ONE_SIDE_QUESTION_AGREEMENT"):
			additional_allies[who_to_ally_pu_id]="one-sided"


			Globals.pu_id_to_allies[Globals.self_pu_id]["allies"].append(who_to_ally_pu_id)
			field.info_table_show(tr("ONE_SIDED_SUCCESS").format(
				{
					"player_nick":Globals.pu_id_player_info[who_to_ally_pu_id]["nickname"],
					"servant_name":Globals.pu_id_player_info[who_to_ally_pu_id]["servant_name"]
				}
			) )

			field.disable_every_button()
			type=await field.choose_between_two(
				tr("MAKE_PUBLIC_ONE_SIDED_QUESTION"),
				tr("MAKE_PUBLIC_ONE_SIDED_QUESTION_AGREEMENT"),
				tr("MAKE_PUBLIC_ONE_SIDED_QUESTION_DISAGREEMENT")
			)
			field.disable_every_button(false)
			if type==tr("MAKE_PUBLIC_ONE_SIDED_QUESTION_AGREEMENT"):
				field.rpc("systemlog_message",str(Globals.nickname+" allied with "+Globals.pu_id_player_info[who_to_ally_pu_id]["nickname"]))
		
		else:
			return
	rpc("sync_relations",Globals.self_pu_id,Globals.pu_id_to_allies.duplicate(true))
	pass # Replace with function body.

@rpc("call_local","any_peer","reliable")
func request_alliance():
	var sender_peer_id = multiplayer.get_remote_sender_id()
	var pu_id_requested_alliance=Globals.peer_to_persistent_id[sender_peer_id]

	var sender_servant_name=Globals.pu_id_player_info[pu_id_requested_alliance]["servant_name"]
	var sender_nickname=Globals.pu_id_player_info[pu_id_requested_alliance]["nickname"]
	field.disable_every_button()
	var type=await field.choose_between_two(
		str(sender_nickname," proposed an alliance, his character is ",sender_servant_name,".\nWill you accept the alliance?"),
		"Accept",
		"Decline"
	)
	field.disable_every_button(false)
	if type=="Accept":
		additional_allies[pu_id_requested_alliance]="two-sided"
		Globals.pu_id_to_allies[Globals.self_pu_id]["allies"].append(pu_id_requested_alliance)
		rpc("sync_relations",Globals.self_pu_id,Globals.pu_id_to_allies.duplicate(true))
	else:
		pass
	pass

	rpc_id(sender_peer_id,"answer_team_request",type)


@rpc("call_local","any_peer","reliable")
func answer_team_request(answer:String):
	match answer:
		"Accept":
			team_confirm_answer.emit(true)
		"Decline":
			team_confirm_answer.emit(false)


func get_full_relations() -> Dictionary:
	var partial_relations=Globals.pu_id_to_allies
	var all_ids=Globals.get_connected_persistent_ids()
	var full_relations: Dictionary = {}
	for player_id in all_ids:
		var player_allies: Array = []
		var player_neutrals: Array = []
		if partial_relations.has(player_id):
			var data = partial_relations[player_id]
			if data.has("allies"): player_allies = data["allies"]
			if data.has("neutral"): player_neutrals = data["neutral"]
		var player_enemies: Array = []
		for other_player_id in all_ids:
			if other_player_id == player_id: continue
			if player_allies.has(other_player_id): continue
			if player_neutrals.has(other_player_id): continue
			player_enemies.push_back(other_player_id)
		full_relations[player_id] = {
			"allies": player_allies,
			"enemies": player_enemies,
			"neutral": player_neutrals
		}
	return full_relations


func get_teams() -> Array:
	"""
	Находит команды игроков, включая команды из одного человека (одиночек).
	"""
	var data=get_full_relations()
	print_debug("get_teams data=",data)
	var teams: Array = []
	var processed_players: Dictionary = {}
	
	for player_id in data:
		if processed_players.has(player_id):
			continue
		
		var current_team: Array = []
		var queue: Array = [player_id]
		var visited_in_component: Dictionary = { player_id: true }
		
		while not queue.is_empty():
			var current_player = queue.pop_front()
			current_team.push_back(current_player)
			
			if not data.has(current_player) or not data[current_player].has("allies"):
				continue
			
			var player_allies: Array = data[current_player]["allies"]
			
			for potential_ally in player_allies:
				if visited_in_component.has(potential_ally):
					continue
				
				var is_mutual = false
				if data.has(potential_ally):
					var ally_data = data[potential_ally]
					if ally_data.has("allies") and ally_data["allies"].has(current_player):
						is_mutual = true
				
				if is_mutual:
					queue.push_back(potential_ally)
					visited_in_component[potential_ally] = true
				
		for member_id in current_team:
			processed_players[member_id] = true
		teams.push_back(current_team)
	return teams


func _on_neutral_button_pressed():

	var who_to_neutral_pu_id=player_in_teams_choosen_pu_id

	if current_player_pu_id_turn!=Globals.self_pu_id:
		#how can you betray enemy?
		field.info_table_show(tr("ATTEMPT_TO_NEUTRAL_DURING_OTHERS_TURN"))
		return

	if who_to_neutral_pu_id==Globals.self_pu_id:
		#how can you betray enemy?
		field.info_table_show(tr("ATTEMPT_TO_NEUTRAL_YOURSELF"))
		return

	field.disable_every_button()
	var type=await field.choose_between_two(
		str("Are you sure you want to neutral "+Globals.pu_id_player_info[who_to_neutral_pu_id]["nickname"]+" "+Globals.pu_id_player_info[who_to_neutral_pu_id]["servant_name"]+" ?"),
		"Yes",
		"No"
	)
	field.disable_every_button(false)
	
	if type=="Yes":
		Globals.pu_id_to_allies[Globals.self_pu_id]["neutral"].append(who_to_neutral_pu_id)

		field.disable_every_button()
		type=await field.choose_between_two(
			str("Do you want to make it neutral?"),
			"Yes",
			"No"
		)
		field.disable_every_button(false)
		if type=="Yes":
			field.rpc("systemlog_message",str(Globals.nickname+" is now neutral to "+Globals.pu_id_player_info[who_to_neutral_pu_id]["nickname"]))
	else:
		return

@rpc("any_peer","reliable","call_local")
func sync_relations(pu_id_update_to:String,full_relations:Dictionary):
	if pu_id_update_to=="":
		Globals.pu_id_to_allies=full_relations
	else:
		Globals.pu_id_to_allies[pu_id_update_to]=full_relations[pu_id_update_to]


func _on_servants_multiplayer_spawner_spawned(node: Node) -> void:
	add_servants_translations_for_servant_name(node,node.servant_path,node.servant_name_just_name)
	apply_all_translation_codes(node)
	pass # Replace with function body.
