extends Node2D
#1717486472.816
#1717743283.689

#region onready
@onready var players_handler = %players_handler

@onready var fsm = %StateMachine

@onready var character_selection_container = %character_selection_container

@onready var char_select:Control = %Char_select

@onready var alert_label = %alert_label

@onready var you_were_attacked_container = %You_were_attacked_container

@onready var you_were_attacked_label = %You_were_attacked_label

@onready var you_were_attacked_evade_option_button = %YOU_WERE_ATTACKED_EVADE_OPTION_BUTTON
@onready var you_were_attacked_def_option_button = %YOU_WERE_ATTACKED_DEF_OPTION_BUTTON
@onready var you_were_attacked_parry_option_button = %YOU_WERE_ATTACKED_PARRY_OPTION_BUTTON
@onready var you_were_attacked_phantasm_option_button = %YOU_WERE_ATTACKED_PHANTASM_OPTION_BUTTON


@onready var chat_hide_show_button = %Chat_hide_show_button

@onready var message_line_edit = %Message_LineEdit

@onready var chat_log_container = %ChatLog_container

@onready var chat_log_main = %ChatLog_main

@onready var char_info_choose_scroll_container = %char_info_choose_scroll_container

@onready var char_choose_main_VBoxContainer = %char_choose_main_VBoxContainer

@onready var char_choose_button = %char_choose_button

@onready var info_label_panel = %info_label_panel

@onready var custom_main_VBoxContainer = %custom_main_VBoxContainer

@onready var info_ok_button = %info_ok_button

@onready var info_label = %info_label

@onready var main_label_dont_touch = %Main_label_dont_touch


@onready var current_roll_container = %Current_roll_container

@onready var previous_roll_base_dice_label = %PREVIOUS_ROLL_BASE_DICE_LABEL
@onready var previous_roll_crit_dice_label = %PREVIOUS_ROLL_CRIT_DICE_LABEL
@onready var previous_roll_def_dice_label = %PREVIOUS_ROLL_DEF_DICE_LABEL



@onready var type_of_damage_choose_buttons_box = %type_of_damage_choose_buttons_box

@onready var regular_damage_button = %regular_damage_button

@onready var magical_damage_button = %magical_damage_button

@onready var reset_button = %HOST_BUTTON_RESET_FIELD

@onready var start_button = %HOST_BUTTON_START

@onready var finish_button = %finish_button

@onready var menu_vbox_container = %menu_vbox_container
@onready var disconnect_button = %disconnect_Button
@onready var reconnect_button = %reconnect_button
@onready var settings_button = %settings_button


@onready var make_action_button = %MAKE_ACTION_BUTTON

@onready var actions_buttons = %actions_buttons

@onready var custom_choices_main_Vboxcontainer = %custom_choices_main_Vboxcontainer

@onready var current_action_points_label = %current_action_points_label


@onready var action_button_attack = %ACTION_BUTTON_ATTACK

@onready var action_button_move = %ACTION_BUTTON_MOVE

@onready var action_button_skill = %ACTION_BUTTON_SKILL

@onready var action_button_phantasm = %ACTION_BUTTON_PHANTASM

@onready var action_button_unmount = %ACTION_BUTTON_UNMOUNT

@onready var action_button_items = %ACTION_BUTTON_ITEMS

@onready var action_button_cancel = %ACTION_BUTTON_CANCEL

@onready var are_you_sure_main_container = %are_you_sure_main_container
@onready var are_you_sure_label = %are_you_sure_label
@onready var are_you_sure_buttons_container = %are_you_sure_buttons_container
@onready var im_sure_button = %im_sure_button
@onready var im_not_sure_button = %im_not_sure_button

@onready var info_but_choose_1 = %info_but_choose_1
@onready var info_but_choose_2 = %info_but_choose_2


@onready var dices_main_VBoxContainer = %dices_main_VBoxContainer
@onready var dice_holder_hbox = %dice_holder_hbox
@onready var main_dice = %main_dice
@onready var crit_dice = %crit_dice
@onready var defence_dice = %defence_dice


@onready var roll_dice_control_container = %roll_dice_control_container
@onready var roll_dice_optional_label = %roll_dice_optional_label
@onready var roll_dices_button = %roll_dices_button


@onready var right_ange_buttons_container = %right_ange_buttons_container
@onready var self_info_show_button = %self_info_show_button
@onready var skill_info_show_button = %Skill_info_show_button
@onready var dices_toggle_button = %dices_toggle_button
@onready var end_turn_button = %End_turn_button


@onready var skill_info_tab_container = %Skill_info_tab_container

@onready var use_skill_but_label_container = %use_skill_but_label_container
@onready var current_skill_cooldown_label = %current_skill_cooldown_label
@onready var use_skill_button = %Use_skill_button


@onready var command_spells_button = %command_spells_button

@onready var command_spell_choices_container = %command_spell_choices_container

@onready var gui = %GUI

@onready var camera_2d = %Camera2D

@onready var day_or_night_sprite_2d:Sprite2D = %day_or_night_sprite2d

@onready var host_buttons = %host_buttons


#endregion


const LINE_BETWEEN_CELLS = preload("res://scenes/line_between_cells.tscn")
const CAPTUR_KLET = preload("res://scenes/captur_klet.tscn")
const GLOW_NODE = preload("res://scenes/glow_node.tscn")
var glow_array={}
var time
var is_game_started=false
var is_pole_generated=false


#var glow_cletki_node
#var captured_kletki_node=null
var captured_kletki_nodes_dict={}
#var kletki_holder

@onready var lines_holder = %lines_holder
@onready var kletki_holder = %kletki_holder
@onready var glow_cletki_node = %Glow_cletki_node
@onready var captured_kletki_node = %Captured_kletki_node


signal choose_two(choose:String)
#signal info_ok_button_clicked

# kletka: who is there node2d
#{ 6: [CharInfo], 25: [CharInfo,CharInfo(mount)]}
var kletka_id_to_char_info:Dictionary={}:
	set(value):
		kletka_id_to_char_info=value
	get:
		return kletka_id_to_char_info

func send_kletka_id_to_char_info_to_all_peers():
	var output:Dictionary={}
	for kletka_id in kletka_id_to_char_info.keys():
		output[kletka_id]=[]
		for char_info in kletka_id_to_char_info[kletka_id]:
			output[kletka_id].append(kletka_id_to_char_info[kletka_id].to_dictionary())
	rpc("sync_kletka_id_to_char_info",output)

@rpc("authority","call_local","reliable")
func sync_kletka_id_to_char_info(kletka_id_to_char_info_sync:Dictionary):
	var output:Dictionary={}
	for kletka_id in kletka_id_to_char_info_sync.keys():
		output[kletka_id]=[]
		for char_info in kletka_id_to_char_info_sync[kletka_id]:
			output[kletka_id].append(CharInfo.from_dictionary(kletka_id_to_char_info[kletka_id].to_dictionary()))
	kletka_id_to_char_info=output

#kletka_preference[cletka_id]=config
var kletka_preference:Dictionary={}
#peer_id:[cletka_id,kletka_id]
var unit_uniq_id_to_kletki_ids_owned:Dictionary={}
var enemy_to_pull:CharInfo

var current_player_name:String

var my_turn=false

signal movement_finished

var current_open_window=""


#var damage_type="physical"#"magic"
#var recieved_damage_type="physical"

var recieved_phantasm_config={}

var paralyzed=false



#var dice_roll_result_list:Dictionary={"main_dice":0,"crit_dice":0,"defence_dice":0,"additional_d6":0,"additional_d6_2":0,"additional_d100":0}
var char_uniq_id_to_dice_roll_result:Dictionary={}
#var recieved_dice_roll_result


var attacking_char_info:CharInfo


const CapturedKletkaScript = preload("res://scripts/cells_scripts/captured_kletka_script.gd")
signal glow_kletka_pressed_signal(kletka_id:int)
var blocked_previous_iteration=[]

var blinking_glow_button
var blink_timer_node

var done_blinking=false
signal done_blinking_signal

const cell_scene = preload("res://scenes/cell.tscn")

var pole_generated_seed

signal rolled_a_dice(result:Dictionary)

#var attack_responce_string=""

var attack_response_from_charinfo_uniq_to_charinfo_iniq:Dictionary

#var attacked_by_char_info:CharInfo

signal attack_response(status:String)

var self_action_status

var texture_size=200

signal klekta_captured
var config_of_kletka_to_capture
# Путь к сцене клетки
# Количество клеток
var cell_count # 100#randf_range(25,40)
# Размер клетки (ширина и высота)
var cell_size = Vector2(64, 64)
# Границы сцены, в которых могут располагаться клетки
var scene_bounds = Vector2(3000, 1500)
# Минимальное расстояние между клетками
var min_distance = 200.0


# Словарь позиций клеток, где ключ - индекс клетки, значение - позиция клетки
var cell_positions = {}
# Словарь соединений, где connected[i][j] == true, если клетка i соединена с клеткой j
var connected = {}
var const_connected:Dictionary

const SUN = preload("res://images/sun.png")
const MOON = preload("res://images/moon.png")


var field_status={"Default":["City"],"Field Buffs":[]}
var awaiting_responce_from_pu_id:String
#var char_info_attacked:CharInfo

signal char_on_kletka_selected(char_info:CharInfo)

signal player_moved

#signal attack_answered

signal dismounted

signal attacker_finished_attack(char_info_dic)


var gui_windows_dictionary:Dictionary={}

func _ready():
	gui_windows_dictionary={"servant_info_main_container":[players_handler.servant_info_main_container],
	"skill_info_tab_container":[%skill_info_main_VBoxContainer,skill_info_tab_container,use_skill_but_label_container],
	"actions_buttons":[actions_buttons],
	"use_custom":[custom_choices_main_Vboxcontainer,players_handler.use_custom_but_label_container,players_handler.custom_choices_tab_container],
	"command_spells":[command_spell_choices_container],
	"menu":[menu_vbox_container],
	"teams":[players_handler.teams_margin],
	"char_choose_on_kletka":[char_info_choose_scroll_container,char_choose_button,char_choose_main_VBoxContainer]
	}
	
	Globals.someone_status_changed.connect(disconnect_alert_show)
	
	
	
	day_or_night_sprite_2d.position=Vector2(scene_bounds.x/2,-400)
	if Globals.host_or_user=='host':
		pass
		%debug_character_control.visible=Globals.debug_mode
		%cheats_show_button.visible=Globals.debug_mode
	
	#connecting every GUI item to camera script
	#mouse_entered_gui_element()

	#mouse_exited_gui_element()
	if OS.has_feature("editor"):
		$GUI/free_phantasm_button.visible=true

	disable_every_button(true)
	end_turn_button.disabled=true

	character_selection_container.visible=true
	for child:Node in get_all_children($GUI):
		#if "Control" in str(child.get_class()):
		if child.is_class("Control"):
			if child.has_signal("mouse_entered"):
				if not child.mouse_entered.is_connected(camera_2d.mouse_entered_gui_element):
					child.mouse_entered.connect(camera_2d.mouse_entered_gui_element)
			if child.has_signal("mouse_exited"):
				if not child.mouse_exited.is_connected(camera_2d.mouse_exited_gui_element):
					child.mouse_exited.connect(camera_2d.mouse_exited_gui_element)
		#host_buttons.visible=true
	#gui.z_index=99
	players_handler.fuck_you()
	
	
	#print(get_all_children(self))

func generate_pole(preset_time):
	print("iiiiiiiiiii="+str(preset_time))
	cell_positions = {}
	connected = {}
	#time=1717424478.993
	print("seed"+str(preset_time))
	seed(preset_time)
	cell_count=round(randf_range(25,40))
	
	print(cell_count)
	generate_cells(preset_time)
	print("ooooo="+str(cell_count))
	connect_cells_minimum(preset_time)
	print("eeeee="+str(cell_count))
	print(cell_positions)
	const_connected=connected

func get_kletki_ids_with_players_you_can_reach_in_steps(steps:int,current_kletka_local:int):
	#get_current_kletka_id()
	var output=[]
	for end in kletka_id_to_char_info.keys():
		if current_kletka_local == end:
			continue
		var queue = []
		var visited = {}
		queue.append([current_kletka_local, 0])
		visited[current_kletka_local] = true
		while not queue.is_empty():
			var current = queue.front()
			queue.pop_front()
			var current_node = current[0]
			var current_steps = current[1]
			if current_steps >= steps:
				continue
			for neighbor in connected[current_node].keys():
				if kletka_preference[neighbor].has("Blocked"):
					continue
				if neighbor == end:
					if !output.has(neighbor):
						output.append(neighbor)
				if not visited.has(neighbor):
					visited[neighbor] = true
					queue.append([neighbor, current_steps + 1])
	output.erase(current_kletka_local)
	return output


func get_path_in_n_steps(start, end, steps)->Array:
	if start == end:
		return [start]
	
	var queue = []
	var visited = {}
	var paths = {}
	queue.append([start, 0])
	visited[start] = true
	paths[start] = [start]
	while not queue.is_empty():
		var current = queue.pop_front()
		var current_node = current[0]
		var current_steps = current[1]
		if current_steps >= steps:
			continue
		for neighbor in connected[current_node].keys():
			if not visited.has(neighbor):
				visited[neighbor] = true
				queue.append([neighbor, current_steps + 1])
				# Обновляем путь до этой клетки
				paths[neighbor] = paths[current_node] + [neighbor]
				# Если нашли конечную клетку, возвращаем путь
				if neighbor == end:
					return paths[neighbor]

	# Если путь не найден, возвращаем пустой массив
	return []



func char_info_pulling_enemy_char_info(char_info_master:CharInfo,char_info_slave:CharInfo):
	#TODO
	var path=get_path_in_n_steps(
		get_current_kletka_id_for_char_info(char_info_master),
		get_current_kletka_id_for_char_info(char_info_slave),999)
	path.erase(get_current_kletka_id_for_char_info(char_info_master))
	if path.size()!=1:
		#current_action="emeny pulling"
		enemy_to_pull=char_info_slave
		
		
		choose_glowing_cletka_by_ids_array(path)


func generate_cells(preset_time):
	var i=0
	if not kletki_holder:
		kletki_holder=Node2D.new()
		kletki_holder.name="kletki_holder"
		add_child(kletki_holder)
		kletki_holder.z_index=10
	for j in range(cell_count):
		var new_position = generate_random_position(preset_time)
		if new_position != Vector2():
			cell_positions[i] = new_position
			kletka_preference[i]={}
			var cell_instance = cell_scene.instantiate()
			cell_instance.position = new_position
			cell_instance.name="cell "+str(i)
			kletki_holder.add_child(cell_instance,true)
			
			connected[i] = {}
			i+=1
	print("iiiii="+str(i))
	print("fff="+str(cell_count))
	
	cell_count=i

func generate_random_position(preset_time):
	seed(preset_time)
	var max_attempts = 100
	for attempt in range(max_attempts):
		var position = Vector2(
			randf_range(0, scene_bounds.x - cell_size.x),
			randf_range(0, scene_bounds.y - cell_size.y)
		)

		var is_valid = true
		for key in cell_positions:
			if position.distance_to(cell_positions[key]) < cell_size.x + min_distance:
				is_valid = false
				break

		if is_valid:
			return position

	# Если не удалось найти подходящее место
	return Vector2()

func connect_cells_minimum(preset_time):
	seed(preset_time)
	print("nnnn="+str(cell_count))
	if not lines_holder:
		lines_holder=Node2D.new()
		lines_holder.name="lines_holder"
		add_child(lines_holder)
		lines_holder.z_index=0
	for i in range(cell_count):
		if connected[i].size() < 2:
			var distances = []
			for j in range(cell_count):
				if i != j and not connected[i].has(j):
					var distance = cell_positions[i].distance_to(cell_positions[j])
					distances.append({'index': j, 'distance': distance})
			distances.sort_custom(_sort_distance)

			var connections_needed = 2 - connected[i].size()
			var connections_made = 0
			for k in range(distances.size()):
				if connections_made >= connections_needed:
					break
				var j = distances[k]['index']
				if not check_line_intersection(cell_positions[i], cell_positions[j]):
					draw_lineff(cell_positions[i], cell_positions[j])
					connected[i][j] = true
					connected[j][i] = true
					connections_made += 1

	# Обеспечить максимум 5 соединений на каждую клетку
	for i in range(cell_count):
		var rng=round(randf_range(2,4))
		if connected[i].size() < rng:
			var distances = []
			for j in range(cell_count):
				if i != j and not connected[i].has(j):
					var distance = cell_positions[i].distance_to(cell_positions[j])
					distances.append({'index': j, 'distance': distance})
			distances.sort_custom(_sort_distance)

			for k in range(distances.size()):
				if connected[i].size() >= rng:
					break
				var j = distances[k]['index']
				if not check_line_intersection(cell_positions[i], cell_positions[j]):
					draw_lineff(cell_positions[i], cell_positions[j])
					connected[i][j] = true
					connected[j][i] = true

func _sort_distance(a, b):
	if a['distance'] < b['distance']:
		return true
	return false

func check_line_intersection(p1, p2):
	for i in connected:
		for j in connected[i]:
			if i == j:
				continue
			var q1 = cell_positions[i]
			var q2 = cell_positions[j]
			if q1 == p1 or q1 == p2 or q2 == p1 or q2 == p2:
				continue
			if segments_intersect(p1, p2, q1, q2):
				return true
	return false

func segments_intersect(p1, p2, q1, q2):
	return ccw(p1, q1, q2) != ccw(p2, q1, q2) and ccw(p1, p2, q1) != ccw(p1, p2, q2)

func ccw(a, b, c):
	return (c.y - a.y) * (b.x - a.x) > (b.y - a.y) * (c.x - a.x)

func draw_lineff(start, end):
	var line = LINE_BETWEEN_CELLS.instantiate()
	
	line.width = 3
	line.z_index=-1
	line.default_color = Color.WHITE
	line.add_point(start)
	line.add_point(end)
	lines_holder.add_child(line,true)

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

func array_unique(array) -> Array:
	var unique = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique


@rpc("call_local","reliable")
func reset_pole(cur_time,generated_pole=true):
	is_pole_generated=true
	if kletki_holder==null or lines_holder==null:
		generate_pole(cur_time)
		return
	
	for i in get_all_children(kletki_holder):
		if i.name.contains("cell") or i.name.contains("Line2D"):
			kletki_holder.remove_child(i)
			i.queue_free()
	for i in get_all_children(lines_holder):
		if i.name.contains("cell") or i.name.contains("Line2D"):
			lines_holder.remove_child(i)
			i.queue_free()
	#await get_tree().process_frame
	#call_deferred()
	pole_generated_seed=cur_time
	if generated_pole:
		generate_pole(cur_time)

func _on_reset_pressed():
	time=Time.get_unix_time_from_system()
	reset_pole(time)

func add_glow_kletka_to_kletka_id(kletka_numebr:int):
	var pos = cell_positions[int(kletka_numebr)]
	var glow_node=GLOW_NODE.instantiate()
	var glow = glow_node.get_child(0)
	glow_node.visible=false
	
	glow_node.position = pos
	glow_node.name="glow "+str(kletka_numebr)
	#glow.button_down.connect(glow_cletka_pressed)
	#print(glow.name)
	glow.button_down.connect(glow_cletka_pressed.bind(glow_node))
	
	#glow.size=Vector2(100,100)
	
	
	
	#glow_node.set_script(load("res://scripts/glow_cell_script.gd"))
	#glow_node.add_child(glow)
	glow.set_anchors_preset(8)#PRESET_CENTER
	glow.position=Vector2(-glow.size.x/2,-glow.size.y/2)
	
	glow_cletki_node.add_child(glow_node,true)
	glow_array[kletka_numebr]=(glow_node)
	print("added glow to kletka id="+str(kletka_numebr))



func glow_cletki_intiate():
	glow_array={}
	#glow_cletki_node=Node2D.new()
	#glow_cletki_node.z_index=100
	#glow_cletki_node.name="Glow_cletki_node"
	#add_child(glow_cletki_node,true)
	for i in get_all_children(self):
		if str(i.name).contains("cell"):
			var kletka_numebr=int(i.name.trim_prefix("cell "))
			add_glow_kletka_to_kletka_id(kletka_numebr)
			

func get_unoccupied_kletki():
	var output=[]
	for i in range(glow_array.size()):
		if kletka_id_to_char_info.has(i):
			continue
		if kletka_preference[i].has("Blocked"):
			continue
		output.append(i)
	return output


@rpc("authority","reliable","call_local")
func show_gui_depends_on_situation(situation:String):
	
	match situation:
		"initianl_spawn":
			players_handler.current_hp_value_label.text=str(players_handler.get_self_servant_node().hp)
			make_action_button.visible=true
			right_ange_buttons_container.visible=true
			%Chat_send_button.disabled=false
			disable_every_button(false)
			make_action_button.disabled=true
			end_turn_button.disabled=true
			my_turn=false
		"action_points_runs_out":
			make_action_button.disabled=true
		"attacker_cant_attack_due_to_debuff":
			info_table_show(tr("PLAYER_CANT_ATTACK_CERTAN_DUE_TO_DEBUFF"))
		"hide_you_were_attacked":
			dices_main_VBoxContainer.visible=false
			you_were_attacked_container.visible=false
			are_you_sure_main_container.visible=false
		"awaiting_enemie_attack_responce":
			disable_every_button()	
			alert_label_text(true,"WAITING_ENEMIE_ATTACK_RESPONCE")
		_:
			push_error("no such situation in show_gui_depends_on_situation: "+situation)

	pass

@rpc("authority","call_local","reliable")
func set_node_property(node_path: NodePath, property_name: String, value):
	var node = get_node_or_null(node_path)
	
	if node:
		node.set(property_name, value)
	else:
		print("Error no node found on path: ", node_path)


func choose_glowing_cletka_by_ids_array(glow_kletki_to_blink):
	#param: "unoccupied"
	#print("glow_array="+str(glow_array))
	glow_kletki_to_blink=array_unique(glow_kletki_to_blink)
	print("glow_kletki_to_blink="+str(glow_kletki_to_blink))
	var blink=1
	glow_cletki_node.visible=true
	blinking_glow_button=true
	for i in glow_kletki_to_blink:#adding visibility
		glow_array[i].modulate=Color(1,1,1,1)
		glow_array[i].visible=true
		#print(i)
	while (blinking_glow_button):#blinking
		#glow_cletki_node.visible=blink
		glow_cletki_node.modulate=Color(1,1,1,blink)
		
		if blink==1:
			blink=0
		else:
			blink=1
		blink_timer_node=get_tree().create_timer(1.0)
		await blink_timer_node.timeout
	if !blinking_glow_button:#removing
		for i in glow_kletki_to_blink:
			glow_array[i].modulate=Color(1,1,1,0)
			glow_array[i].visible=false
	glow_cletki_node.visible=false

func get_base_fsm_data_for_pu_id(pu_id:String):
	var char_info:CharInfo=get_current_char_info_for_pu_id(pu_id)
	var action_points:int=players_handler.get_current_action_points_for_char_info(char_info)
	return {
		"char_info_dic":char_info.to_dictionary(),
		"action_points":action_points,
	}


func glow_cletka_pressed(glow_kletka_selected):
	
	#var glow_kletka_selected=glow_array[glowing_kletka_number_selected]
	blinking_glow_button=false
	blink_timer_node.timeout.emit()
	var glowing_kletka_number_selected_local=int(glow_kletka_selected.name.trim_prefix("glow "))
	rpc_id(1,"client_pressed_glow_kletka",glowing_kletka_number_selected_local,Globals.self_pu_id)
	pass

@rpc("any_peer","call_local","reliable")
func client_pressed_glow_kletka(glowing_kletka_number_selected_temp,pu_id):
	if not multiplayer.is_server():
		return
	
	print("glow_cletka_pressed, current_action="+str(Globals.pu_id_to_action_points[pu_id]))
	var glowing_kletka_number_selected=glowing_kletka_number_selected_temp
	
	
	var glow_kletka_selected:Node2D=glow_array[glowing_kletka_number_selected]
	var char_info:CharInfo=get_current_char_info_for_pu_id(pu_id)

	var current_action=Globals.pu_id_to_current_action[char_info.pu_id]
	
	print(glow_kletka_selected)
	print(current_action)
	match current_action:
		"initial_spawn":
			
			pass
		"field capture":
			#rpc("sync_owned_kletki",unit_uniq_id_to_kletki_ids_owned)
			Globals.pu_id_player_info[pu_id]["temp_kletka_capture_config"]["Color"]=Globals.self_field_color
			capture_single_kletka_sync_for_char_info(
				char_info,
				glowing_kletka_number_selected,
				Globals.pu_id_player_info[pu_id]["temp_kletka_capture_config"]
				)
			print("temp_kletka_capture_config  222="+str(Globals.pu_id_player_info[pu_id]["temp_kletka_capture_config"]))
			klekta_captured.emit()
			Globals.pu_id_to_current_action[char_info.pu_id]="wait"
		"move":
			pass
		"choosing_target":
			
			var choose_unit_on_sell_data = get_base_fsm_data_for_pu_id(pu_id)
			
			choose_unit_on_sell_data.merge(
				{
					"kletka_id_to_choose_unit_on":glowing_kletka_number_selected,
					"damage_type":Globals.unit_uniq_id_to_damage_type[char_info.get_uniq_id()]
				}
			)
			
			fsm.change_state_for_pu_ud(pu_id,"ChoosingUnitOnCell",choose_unit_on_sell_data)
			
		"choose_allie":
			var char_infffo=await await_choose_char_info_on_kletka_id_from_client(char_info.pu_id,glowing_kletka_number_selected)
			
			players_handler.chosen_allie.emit(char_infffo)
		"emeny pulling":
			var atk_char_info=attacking_char_info
			move_player_from_kletka_id1_to_id2(
				atk_char_info,
				char_info_to_kletka_number(atk_char_info),
				glowing_kletka_number_selected)
			
			
	glow_kletka_pressed_signal.emit(glowing_kletka_number_selected)

func check_if_char_info_can_ride_mount_on_kletka_id(char_info:CharInfo,kletka_id:int)->bool:
	var can_ride:bool=false
	

	if kletka_id_to_char_info[kletka_id].size()==0:
		return false
	
	if kletka_id_to_char_info[kletka_id].size()>=2:
		#TODO mounts that can hold multiple servants
		return false
	var mount_node = kletka_id_to_char_info[kletka_id][0]

	if not mount_node.mount:
		return false



	if not mount_node.require_riding_skill:
		can_ride=true
	else:
		#finding riding skill
		if char_info.get_node().passive_skills:
			for skill in char_info.get_node().passive_skills:
				if skill["Name"]=="Riding":
					can_ride=true

	return can_ride

func sit_char_info_on_mount_on_kletka_id(char_info_dic:Dictionary,kletka_id:int):
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)

	#alredy checked that on kletka_id just mount
	var mount_node=kletka_id_to_char_info[kletka_id][0]

	var char_kletka=get_current_kletka_id_for_char_info(char_info)

	if char_kletka!=kletka_id:
		push_error("Mount and charinfo are on different kletki")
		return
	
	mount_node.mounted_by_uniq_ids_array=[char_info.get_uniq_id()]
	char_info.get_node().mounts_uniq_id_array=[mount_node.unit_unique_id]


	return


func sleep(seconds:float):
	await get_tree().create_timer(seconds).timeout


func _on_char_choose_button_pressed():
	var char_info:CharInfo = char_info_choose_scroll_container.get_char_info_selected()
	char_on_kletka_selected.emit(char_info)
	pass



func dismount_char_info(char_info_to_dismount:CharInfo):
	#var char_info_to_dismount = CharInfo.from_dictionary(char_info_dic)

	var pu_id=char_info_to_dismount.pu_id
	#var mount_uniq_id = char_info_to_dismount.get_node().get_meta("Mounts_uniq_id_array")
	

	var mount_char_info = await await_choose_char_info_on_kletka_id_from_client(
		pu_id,
		get_current_kletka_id_for_char_info(char_info_to_dismount),
		true)

	var currently_on_mount:Array = mount_char_info.get_node().mounted_by_uniq_ids_array
	currently_on_mount.erase(char_info_to_dismount.get_uniq_id())
	mount_char_info.get_node().mounted_by_uniq_ids_array=currently_on_mount

	var current_mounts:Array = char_info_to_dismount.get_node().mounts_uniq_id_array
	current_mounts.erase(mount_char_info.get_uniq_id())
	char_info_to_dismount.get_node().mounts_uniq_id_array=current_mounts
	await sleep(0.1)
	print("emiting dismounted")
	dismounted.emit()

	pass

func get_kletki_ids_available_to_move_to_for_char_info(char_info)->Array:
	var move_ck=[]
	var skip=false
	for i in connected[get_current_kletka_id_for_char_info(char_info)]:
		skip=false
		if kletka_id_to_char_info.has(i):
			skip=true
		if skip:
			continue
		if kletka_preference[i].has("Blocked"):
			continue
		move_ck.append(int(glow_array[i].name.trim_prefix("glow ")))
	
	return move_ck

signal kletki_ids_available_to_move_to(array)

@rpc("any_peer","call_local","reliable")
func request_kletki_to_move_to(char_info_dic:Dictionary):
	if multiplayer.is_server():
		var sender_peer_id = multiplayer.get_remote_sender_id()
		var out = get_kletki_ids_available_to_move_to_for_char_info(char_info_dic)
		rpc_id(sender_peer_id,"send_kletki_awailable_to_move_to",out)

@rpc("authority","call_local","reliable")
func send_kletki_awailable_to_move_to(out):
	await sleep(0.1)
	kletki_ids_available_to_move_to.emit(out)


func get_kletki_available_to_move_to_for_char_info_from_server(char_info:CharInfo)->Array:

	rpc_id(1,"request_kletki_to_move_to",char_info.to_dictionary())
	var kletki_ids= await kletki_ids_available_to_move_to
	return kletki_ids


@rpc("any_peer","call_local","reliable")
func unmount_pressed_by_pu_id(pu_id):
	print("dismounting")
	var char_info=get_current_char_info_for_pu_id(pu_id)
	
	#checking if available kletki exists
	
	var move_ck=get_kletki_ids_available_to_move_to_for_char_info(char_info)

	if move_ck.size()<=0:
		#info_table_show(tr("UNMOUNT_ABORTED_NO_VALID_CELLS_FOUND"))
		#await info_ok_button.pressed

		await await_info_ok_button_pressed_from_char_info(char_info,"UNMOUNT_ABORTED_NO_VALID_CELLS_FOUND")
		return

	dismount_char_info(char_info)
	
	await dismounted

	print("dismounted, waiting for glowing kletka pressed")

	Globals.pu_id_to_current_action[char_info.pu_id]="move"
	_on_move_pressed()
	#current_action="move"
	#await glowing_kletka_number_selected
	



func _on_unmount_pressed():
	var answer=await choose_between_two(
		"UNMOUNT_QUESTION",
		"UNMOUNT_QUESTION_AGREEMENT",
		"UNMOUNT_QUESTION_DISAGREEMENT"
		)

	

	if answer=="UNMOUNT_QUESTION_AGREEMENT":
		%action_button_cancel.disabled=true
		rpc_id(1,"unmount_pressed_by_pu_id",Globals.self_pu_id)
		%action_button_cancel.disabled=false
	pass

signal char_on_kletka_selected_for_pu_id(char_info:CharInfo)

func await_get_char_info_on_kletka_id_for_pu_id(pu_id:String,kletka_id:int,mounts_only=false,playable_only=false)->CharInfo:
	var pu_peer_id=Globals.pu_id_player_info[pu_id]["current_peer_id"]
	rpc_id(pu_peer_id,"request_get_char_info_on_kletka_id_from_client",pu_id,kletka_id,mounts_only,playable_only)
	var char_info_out = await char_on_kletka_selected_for_pu_id
	return char_info_out

@rpc("authority","reliable","call_local")
func request_get_char_info_on_kletka_id_from_client(pu_id:String,kletka_id:int,mounts_only=false,playable_only=false):
	if multiplayer.is_server():
		var sender_peer_id = multiplayer.get_remote_sender_id()
		var char_info_out = await get_char_info_on_kletka_id(pu_id,kletka_id,mounts_only,playable_only)
		rpc_id(sender_peer_id,"send_get_char_info_on_kletka_id_to_server",char_info_out.to_dictionary())

@rpc("any_peer","call_local","reliable")
func send_get_char_info_on_kletka_id_to_server(char_info_dic:Dictionary):
	await sleep(0.1)
	var char_info_out=CharInfo.from_dictionary(char_info_dic)
	char_on_kletka_selected_for_pu_id.emit(char_info_out)

func get_char_info_on_kletka_id(_pu_id:String,kletka_id:int,mounts_only=false,playable_only=false):

	if kletka_id_to_char_info[kletka_id].is_empty():
		push_error("No enemies on kletka id = ",kletka_id, " kletka_id_to_char_info=",kletka_id_to_char_info)

	if kletka_id_to_char_info[kletka_id].size()==1:
		print("kletka has just one unit")
		var serv_node = kletka_id_to_char_info[kletka_id][0]
		var kletka_unit_id=serv_node.unit_id
		var kletka_pu_id=serv_node.pu_id
		return CharInfo.new(kletka_pu_id,kletka_unit_id)
	else:
		return await choose_char_info_on_kletka_id(kletka_id,mounts_only,playable_only)



signal choose_char_info_on_kletka_id_from_client(char_info_dic)

func await_choose_char_info_on_kletka_id_from_client(pu_id,kletka_id:int,mounts_only=false,playable_only=false)->CharInfo:
	var peer_id=Globals.pu_id_player_info[pu_id]["current_peer_id"]

	rpc_id(peer_id,"choose_char_info_on_kletka_id",kletka_id,mounts_only,playable_only)
	var char_info_dic_choosen = await choose_char_info_on_kletka_id_from_client
	var char_info_choosen=CharInfo.from_dictionary(char_info_dic_choosen)
	return char_info_choosen


@rpc("any_peer","reliable","call_local")
func send_choose_char_info_on_kletka_id_to_server(char_info_dic):
	if multiplayer.is_server():
		await sleep(0.1)
		choose_char_info_on_kletka_id_from_client.emit(char_info_dic)

@rpc("authority","reliable","call_local")
func choose_char_info_on_kletka_id(kletka_id:int,mounts_only=false,playable_only=false)->CharInfo:

	var char_infos:Array=[]

	for char_info in kletka_id_to_char_info[kletka_id]:
		var node=char_info.get_node()
		if mounts_only:
			if node.mount:
				if playable_only:
					if node.can_be_played:
						char_infos.append(char_info)
				else:
					char_infos.append(char_info)
		else:
			if playable_only:
				if node.can_be_played:
					char_infos.append(char_info)
			else:
				char_infos.append(char_info)
	

	if char_infos.size()==1:
		return char_infos[0]

	char_info_choose_scroll_container.add_char_infos(char_infos)
	await sleep(0.1)
	hide_all_gui_windows("char_choose_on_kletka")
	
	var char_info_out = await char_on_kletka_selected

	hide_all_gui_windows("char_choose_on_kletka")

	#rpc_id(1,"send_choose_char_info_on_kletka_id_to_server",char_info_out.to_dictionary())
	return char_info_out


func check_if_kletka_has_mount(kletka_id:int)->bool:
	print("\ncheck_if_kletka_has_mount")
	if not kletka_id_to_char_info.has(kletka_id):
		return false

	if kletka_id_to_char_info[kletka_id].size()==0:
		return false
	
	if kletka_id_to_char_info[kletka_id].size()>=2:
		#TODO mounts that can hold multiple servants
		return false
	var kletka_node = kletka_id_to_char_info[kletka_id][0]

	if kletka_node.mount:
		return true

	return false


func capture_single_kletka_sync_for_char_info(char_info:CharInfo,glowing_kletka_number_selected_temp,temp_kletka_capture_config):
	var kletka_owner=temp_kletka_capture_config["Owner"]
	#var own_pu=kletka_owner["pu_id"]
	#var own_uni_id=kletka_owner["unit_id"]

	var kletka_color=temp_kletka_capture_config["Color"]

	if !unit_uniq_id_to_kletki_ids_owned.has(kletka_owner):
		unit_uniq_id_to_kletki_ids_owned[kletka_owner]=[]

	print(str(glowing_kletka_number_selected_temp," is captured"))
	kletka_preference[glowing_kletka_number_selected_temp]=temp_kletka_capture_config
	
	unit_uniq_id_to_kletki_ids_owned[kletka_owner].append(glowing_kletka_number_selected_temp)
	
	var captur_klet=CAPTUR_KLET.instantiate()
	var pos = cell_positions[int(glowing_kletka_number_selected_temp)]
	captur_klet.position = pos
	captur_klet.name="field "+str(glowing_kletka_number_selected_temp)
	
	captur_klet.set_script(CapturedKletkaScript)
	
	captur_klet.color=kletka_color
	
	captured_kletki_node.add_child(captur_klet,true)
	captur_klet.queue_redraw()
	captured_kletki_nodes_dict[glowing_kletka_number_selected_temp]=captur_klet

func reduce_one_action_point_for_pu_id(pu_id,amount_to_reduce=-1,why=""):
	print("reduce_one_action_point for pu_id=",pu_id," why=",why)
	
	Globals.pu_id_to_action_points[pu_id]+=amount_to_reduce
	current_action_points_label.text=str(Globals.pu_id_to_action_points[pu_id])
	if Globals.pu_id_to_action_points[pu_id]==0 and pu_id==Globals.self_pu_id:
		rpc_id(
			Globals.pu_id_to_action_points[pu_id]["current_peer_id"],
			"show_gui_depends_on_situation",
			"action_points_runs_out")
	print("reduce_one_action_point done, current_action_points="+str(Globals.pu_id_to_action_points[pu_id])+"\n\n")


func get_current_kletka_id_for_char_info(char_info:CharInfo)->int:
	#current_player_name=""
	print("occupied_kletki=",kletka_id_to_char_info)
	for kletka_id in kletka_id_to_char_info:
		print_debug("kletka_id=",kletka_id)
		for char_info_in_kletka in kletka_id_to_char_info[kletka_id]:
			print_debug("char_info_in_kletka=",char_info_in_kletka)
			if char_info_in_kletka.get_uniq_id()==char_info.get_uniq_id():
				return kletka_id
	return -1


func get_char_info_from_uniq_id(uniq_id:String)->CharInfo:

	for char_info in players_handler.get_all_char_infos():
		if char_info.get_uniq_id()==uniq_id:
			return char_info
	
	push_error("No char info found on get_char_info_from_uniq_id=",uniq_id)
	return CharInfo.new("",0)





@rpc("any_peer","call_local","reliable")
func move_player_from_kletka_id1_to_id2(char_info:CharInfo,current_kletka_local:int,_glowing_kletka_number_selected:int,is_partial:bool=false,visually_only:bool=false):
	print("_________________movement______________-")
	#var char_info=CharInfo.from_dictionary(char_info_dic)


	var pu_id=char_info.pu_id
	#var unit_id=char_info.unit_id

	print("pu_id="+str(pu_id)+" Globals.pu_id_player_info="+str(Globals.pu_id_player_info))
	print("From ",current_kletka_local," to ",_glowing_kletka_number_selected," is_partial=",is_partial," visually_only=",visually_only)
	var player_node_to_move=char_info.get_node()

	
	if current_kletka_local==_glowing_kletka_number_selected and visually_only:
		player_node_to_move.position=cell_positions[_glowing_kletka_number_selected]
		return
	
	var chastei=10
	var addition=0
	if is_partial:
		addition=-3
		
	if current_kletka_local!=-1:
		#print("player_node_to_move.position="+str(player_node_to_move.position)+" cell_positions[glowing_kletka_number_selected]="+str(cell_positions[glowing_kletka_number_selected]))
		#print("player_node_to_move.position="+str(player_node_to_move.position)+" cell_positions[current_kletka_local]="+str(cell_positions[current_kletka_local]))
		var one=player_node_to_move.position.round()!=cell_positions[_glowing_kletka_number_selected].round()
		var second=player_node_to_move.position.round()!=cell_positions[current_kletka_local].round()
		if one and second:
			addition=0
	
	
	
	#""""""animation"""""
	#cell_positions[glowing_kletka_number_selected]
					#from 											to
	var mnoghitel=(cell_positions[_glowing_kletka_number_selected]-player_node_to_move.position)/chastei

	#collecting all nodes to move (mounts)
	var array_of_nodes_to_move:Array=[player_node_to_move]
	if char_info.get_node().mounts_uniq_id_array:
		var mounts_ids=char_info.get_node().mounts_uniq_id_array
		print("mounts_ids=",mounts_ids)
		for mount_uniq_id in mounts_ids:
			var mount_node = get_char_info_from_uniq_id(mount_uniq_id).get_node()
			if not mount_node in array_of_nodes_to_move:
				array_of_nodes_to_move.append(mount_node)
			#getting_all_units that rides this mount
			for unit_uniq_id in mount_node.mounted_by_uniq_ids_array:
				var player_nodee = get_char_info_from_uniq_id(mount_uniq_id).get_node()
				if not player_nodee in array_of_nodes_to_move:
					array_of_nodes_to_move.append(player_nodee)
	else:
		print("player doent ride any mount")


	
	if current_kletka_local==-1:
		player_node_to_move.position=cell_positions[_glowing_kletka_number_selected]
	else:
		
		if visually_only:
			for node_to_move in array_of_nodes_to_move:
				node_to_move.position=cell_positions[current_kletka_local]
		for i in range(chastei+addition):
			for node_to_move in array_of_nodes_to_move:
				node_to_move.position+=mnoghitel
				await get_tree().create_timer(0.01).timeout
	
	if not is_partial or current_kletka_local==-1:
		if not visually_only:
			for node_to_move in array_of_nodes_to_move:
				var pu_id_local=node_to_move.pu_id
				var unit_id_local=node_to_move.unit_id
				var char_info_local=CharInfo.new(pu_id_local,unit_id_local)
				
				if current_kletka_local!=-1:
					remove_char_info_from_kletka_id(char_info_local,current_kletka_local)

				if not kletka_id_to_char_info.has(_glowing_kletka_number_selected):
					kletka_id_to_char_info[_glowing_kletka_number_selected]=[]

				if kletka_id_to_char_info[_glowing_kletka_number_selected].is_empty():
					kletka_id_to_char_info[_glowing_kletka_number_selected]=[node_to_move.char_info]
				else:
					kletka_id_to_char_info[_glowing_kletka_number_selected].append(node_to_move.char_info)

				players_handler.change_game_stat_for_char_info(char_info_local.to_dictionary(),"total_kletki_moved",1)
				players_handler.change_game_stat_for_char_info(char_info_local.to_dictionary(),"kletki_moved_this_turn",1)
	#if pu_id==Globals.self_pu_id and not visually_only and not is_partial:
		#get_current_kletka_id()=glowing_kletka_number_selected
	
	
	await sleep(0.1)
	player_moved.emit()
	


func remove_char_info_from_kletka_id(char_info:CharInfo,kletka_id:int):


	kletka_id_to_char_info[kletka_id].erase(char_info.get_node())
	if kletka_id_to_char_info[kletka_id].is_empty():
		kletka_id_to_char_info.erase(kletka_id)



func _on_start_pressed():
	#for i in get_all_children(self):
		#print(i)
	if !is_pole_generated:
		_on_reset_pressed()
	await sleep(0.2)
	rpc("main_game")

#region dice rolls
signal got_dice_from_client(dice_result:Dictionary)

func await_dice_roll_including_rerolls_from_char_info(char_info:CharInfo,type:String)->Dictionary:
	rpc_id(
		Globals.pu_id_player_info[char_info.pu_id]["current_peer_id"],
		"request_dice_roll_including_rerolls_from_client",
		type,
		get_char_info_rerolls_amount_for_type(char_info,type),
		can_char_info_reroll_dice_for_type(char_info,type)
		)
	char_uniq_id_to_dice_roll_result[char_info.get_uniq_id()]=await got_dice_from_client
	return char_uniq_id_to_dice_roll_result[char_info.get_uniq_id()]


@rpc("authority","reliable","call_local")
func request_dice_roll_including_rerolls_from_client(type:String,reroll_amount:int,can_reroll:bool):
	var output = await await_dice_including_rerolls(type,can_reroll,reroll_amount)
	rpc_id(1,"send_dice_roll_to_server",output)

@rpc("any_peer","call_local","reliable")
func send_dice_roll_to_server(output:Dictionary):
	if multiplayer.is_server():
		await sleep(0.1)
		got_dice_from_client.emit(output)

func await_dice_roll()->Dictionary:
	dices_main_VBoxContainer.visible=true

	
	var result=await rolled_a_dice
	await hide_dice_rolls_with_timeout(2)

	return result

func hide_dice_rolls_with_timeout(timeout_in_seconds):
	await get_tree().create_timer(timeout_in_seconds).timeout
	dices_main_VBoxContainer.visible=false



func await_dice_including_rerolls(type:String,can_reroll:bool,rerolls:int)->Dictionary:
	var result=await await_dice_roll()

	if rerolls<=0:
		return result
	if can_reroll:
		var answ=await choose_between_two(
			"DO_YOU_WANT_TO_REROLL_QUESTION",
			"DO_YOU_WANT_TO_REROLL_QUESTION_AGREEMENT",
			"DO_YOU_WANT_TO_REROLL_QUESTION_DISAGREEMENT"
			)
		print("rerolls=",rerolls)
		if answ == "DO_YOU_WANT_TO_REROLL_QUESTION_AGREEMENT":
			result=await await_dice_including_rerolls(type,can_reroll,rerolls-1)
			return result
		#else:
		#	rpc_id(1,"send_dice_roll_to_server",result)
		#	return result
	#rpc_id(1,"send_dice_roll_to_server",result)
	return result

func can_char_info_reroll_dice_for_type(char_info:CharInfo,type:String)->bool:
	var reroll_buffs=players_handler.get_all_buffs_with_name_for_char_info(char_info,"Dice Reroll")

	for buff in reroll_buffs:
		if buff["Action"]==type:
			return true

	return false

func get_char_info_rerolls_amount_for_type(char_info:CharInfo,type:String)->int:
	var reroll_buffs=players_handler.get_all_buffs_with_name_for_char_info(char_info,"Dice Reroll")
	var amount:int=0
	for buff in reroll_buffs:
		if buff["Action"]==type:
			amount+=buff["Power"]

	return amount

#endregion


func disable_every_button(block=true):
	hide_all_gui_windows("all")
	var blocked_this_iteration=[]
	if block:
		for child in get_all_children(%GUI):
			if "Button" in str(child.get_class()):
				if child.is_visible_in_tree():
					child.disabled=block
					blocked_this_iteration.append(child)
	else:
		for button in blocked_previous_iteration:
			button.disabled=false
		if players_handler.current_player_pu_id_turn==Globals.self_pu_id:
			end_turn_button.disabled=false
	%Chat_send_button.disabled=false
	
	blocked_previous_iteration=blocked_this_iteration
	pass

signal ok_button_pressed_from_client

func await_info_ok_button_pressed_from_char_info(char_info,text):
	print_debug("await_info_ok_button_pressed_from_char_info=",char_info.to_dictionary()," text=",text)
	var peer_id = Globals.pu_id_player_info[char_info.pu_id]["current_peer_id"]
	rpc_id(peer_id,"send_info_table_show_to_client",text)
	await ok_button_pressed_from_client

@rpc("authority","call_local","reliable")
func send_info_table_show_to_client(text):
	info_table_show(text)

@rpc("any_peer","call_local","reliable")
func send_ok_button_pressed_to_server():
	await sleep(0.01)
	ok_button_pressed_from_client.emit()
	pass

func info_table_show(text="someone forgot to set this, contact anyone, SCREAM"):
	hide_all_gui_windows()
	#disable_every_button(true)
	info_label.text=text
	custom_main_VBoxContainer.visible=true
	
	info_but_choose_1.visible=false
	info_but_choose_2.visible=false
	info_label_panel.visible=true
	info_ok_button.visible=true

	

func _on_info_ok_button_pressed():
	custom_main_VBoxContainer.visible=false
	info_label_panel.visible=false
	info_ok_button.visible=false
	#info_ok_button_clicked.emit()
	
	#disable_every_button(false)

func alert_label_text(show=false,text=""):
	
	if show:
		alert_label.visible=true
		alert_label.text=text
		alert_label.grab_focus()
	else:
		alert_label.text=""
		alert_label.visible=false
		

func increase_dice_result_to_action_name_with_buffs_for_char_info(char_info:CharInfo,type:String):
	var dice_plus_buff=players_handler.char_info_has_active_buff(char_info,"Dice +")
	if dice_plus_buff:
		if dice_plus_buff.has("Action"):
			if dice_plus_buff["Action"]==type:
				var new_value=char_uniq_id_to_dice_roll_result[char_info.get_uniq_id()].duplicate(true)
				new_value+=dice_plus_buff.get("Power",1)
				char_uniq_id_to_dice_roll_result[char_info.get_uniq_id()]=min(new_value,6)
				players_handler.rpc("add_to_advanced_logs",
					"ADVANCED_LOG_USER_HAS_REROLL_DICE_BUFF",
					{
						"type":type,
						"dice_roll_result_list":new_value
					}
				)
					
	pass

func can_char_info_evade_defence_parry_against_char_info(defender_char_info:CharInfo,attacker_char_info:CharInfo,attack_type:String)->Dictionary:
	
	var defender_node=defender_char_info.get_node()
	
	var can_evade=defender_node.can_evade
	var can_defence=defender_node.can_defence
	
	#checking parry
	var can_parry=defender_node.can_parry
	
	if can_parry:
		var defender_atk_range=players_handler.get_char_info_attack_range(defender_char_info)
		var distance_between_enemie=get_path_in_n_steps(
			get_current_kletka_id_for_char_info(defender_char_info),
			get_current_kletka_id_for_char_info(attacker_char_info),
			defender_atk_range
		).size()
		
		var magic_distance_between_enemie=-1
		if players_handler.get_char_info_magical_attack(defender_char_info):
			magic_distance_between_enemie=get_path_in_n_steps(
				get_current_kletka_id_for_char_info(defender_char_info),
				get_current_kletka_id_for_char_info(attacker_char_info),
				3
			).size()
		
		var parry_option=""
		
		if distance_between_enemie!=0:
			if distance_between_enemie > magic_distance_between_enemie:
				parry_option = players_handler.DAMAGE_TYPE.PHYSICAL
			
			if magic_distance_between_enemie > distance_between_enemie:
				parry_option = players_handler.DAMAGE_TYPE.MAGICAL
			
			if distance_between_enemie == magic_distance_between_enemie:
				parry_option = "all"
			
		if attack_type != "Phantasm" or parry_option=="" or not can_parry:
			can_parry=false
	
	
	return {"can_parry":can_parry,"can_defence":can_defence,"can_evade":can_evade}


func pu_id_attack_player_on_kletka_id(pu_id:String, kletka_id:int, data={}):
	if not multiplayer.is_server(): return
	
	var damage_type:String = data.get("damage_type","Physical")
	var consume_action_point:bool = data.get("consume_action_point",true)
	var phantasm_config = data.get("phantasm_config",{})
	
	
	
	var attacker_char_info:CharInfo=get_current_char_info_for_pu_id(pu_id)
	
	var defender_char_info:CharInfo =await await_choose_char_info_on_kletka_id_from_client(attacker_char_info.pu_id,kletka_id)
	var attacker_peer_id=Globals.pu_id_player_info[pu_id]["current_peer_id"]
	
	players_handler.rpc("add_to_advanced_logs",
		"ADVANCED_LOG_ATTACK_ATTEMPT",
		{
			"Attacker_name":attacker_char_info.get_node().name,
			"Taker_name":defender_char_info.get_node().name
		}
	)
	
	if not players_handler.can_char_info_attack_char_info(attacker_char_info,defender_char_info):
		rpc_id(attacker_peer_id,"show_gui_depends_on_situation","attacker_cant_attack_due_to_debuff")
		
		players_handler.rpc("add_to_advanced_logs",
			"ADVANCED_LOG_PLAYER_CANT_ATTACK_CERTAIN_DUE_TO_DEBUFF",
			{
				"Attacker_name":attacker_char_info.get_node().name,
				"Taker_name":defender_char_info.get_node().name
			}
		)
		return "ERROR"
	
	
	if damage_type=="Physical" and attacker_char_info.get_node().attack_range<=2:# and attack_responce_string!="parried":
		move_player_from_kletka_id1_to_id2(
			attacker_char_info,
			get_current_kletka_id_for_char_info(attacker_char_info),
			kletka_id,
			true
		)
	
	#var attack_responce=attack_response_from_charinfo_uniq_to_charinfo_iniq[defender_char_info.get_uniq_id()][attacker_peer_id.get_uniq_id()]
	var attack_responce=data.get("attack_responce")
	
	
	#if regular attack
	if damage_type==players_handler.DAMAGE_TYPE.PHYSICAL or damage_type==players_handler.DAMAGE_TYPE.MAGICAL:
		if attack_responce!="parried":
			rpc_id(
				attacker_peer_id,
				"set_node_property",
				type_of_damage_choose_buttons_box.get_path(),
				"visible",
				false
			)
			
			var confirm_action_data=get_base_fsm_data_for_pu_id(pu_id)
			
			confirm_action_data.merge(
				{
					"action":"attack_start_no_parry",
					"confirm_action_action_text":"ARE_YOU_SURE_YOU_WANT_TO_ACTION_ATTACK"
				}
			)
			
			fsm.change_state_for_pu_ud(pu_id,"ConfirmAction",confirm_action_data)
			
			var are_you_sure_result=await are_you_sure_signal_from_client
			
			if are_you_sure_result=="ARE_YOU_SURE_DISAGREEMENT":
				players_handler.rpc("add_to_advanced_logs",
				"ADVANCED_LOG_USER_STOPPED_ATTACK_AFTER_ARE_YOU_SURE")
				
				fsm.change_state_for_pu_ud(pu_id,"Idle",get_base_fsm_data_for_pu_id(pu_id))
				
				return
			
		#else:
			#rpc_id(
				#attacker_peer_id,
				#"set_node_property",
				#roll_dice_optional_label.get_path(),
				#"text",
				#"ENEMY_PARRIED_ATTACK_REROLLING"
			#)
			##roll_dice_optional_label.text=tr("ENEMY_PARRIED_ATTACK_REROLLING")
			##roll_dice_optional_label.visible=true
			#rpc_id(
				#attacker_peer_id,
				#"set_node_property",
				#roll_dice_optional_label.get_path(),
				#"visible",
				#true
			#)
		
		
		
		var dice_roll_data=get_base_fsm_data_for_pu_id(pu_id)
		dice_roll_data.merge(data)
		
		dice_roll_data.merge(
			{
				"action_name":"Attack",
				"can_reroll":can_char_info_reroll_dice_for_type(attacker_char_info,"Attack"),
				"reroll_amount":get_char_info_rerolls_amount_for_type(attacker_char_info,"Attack"),
				
				"action_after_dice_roll":"attack_after_attacker_dice_roll",
				
				"attacker_char_info_dic":attacker_char_info.to_dictionary(),
				"defender_char_info_dic":defender_char_info.to_dictionary(),
				"damage_type":damage_type
			}
		)
		
		
		
		fsm.change_state_for_pu_ud(pu_id,"DiceRoll",dice_roll_data)
		
func attack_after_attacker_dice_roll(data={}):
	
	var attacker_char_info:CharInfo = CharInfo.from_dictionary(data.get("attacker_char_info_dic"))
	var defender_char_info:CharInfo = CharInfo.from_dictionary(data.get("defender_char_info_dic"))
	var attacker_dice_roll = data.get("dice_roll_result")
	var damage_type = data.get("damage_type")
	
	char_uniq_id_to_dice_roll_result[attacker_char_info.get_uniq_id()] = attacker_dice_roll
	
	players_handler.rpc("add_to_advanced_logs",
		"ADVANCED_LOG_SHOWING_ATTACKER_ROLL",
		{
			"attacker_roll":char_uniq_id_to_dice_roll_result[attacker_char_info.get_uniq_id()]
		}
	)
	
	#rpc_id(attacker_peer_id,"show_gui_depends_on_situation","hide_you_were_attacked")
		
	
	var parry_count_max=0
	parry_count_max=players_handler.get_char_info_agility_rank(attacker_char_info)
	parry_count_max=players_handler.get_agility_in_numbers(parry_count_max)
	increase_dice_result_to_action_name_with_buffs_for_char_info(attacker_char_info,"Attack")
	
	
	var defender_pu_id = defender_char_info.pu_id
	var defender_unit_id = defender_char_info.unit_id
	
	var peer_id_to_attack=Globals.pu_id_player_info[defender_pu_id].current_peer_id
	
	if not Globals.pu_id_player_info[defender_pu_id]["is_connected"]:
		await_info_ok_button_pressed_from_char_info(attacker_char_info,"Enemy disconnected, aborting")
		return
	
	
	var attacker_dices = char_uniq_id_to_dice_roll_result[attacker_char_info.get_uniq_id()]
	
	
	
	
	var can_char_info=can_char_info_evade_defence_parry_against_char_info(defender_char_info,attacker_char_info,damage_type)
	
	var can_parry = can_char_info["can_parry"]
	var can_defence = can_char_info["can_defence"]
	var can_evade = can_char_info["can_evade"]
	
	
	var all_actions_blocked=not can_parry and not can_evade and not can_defence
	if all_actions_blocked:
		calculating_damage_after_attack_ended(
			{
				"defender_char_info":defender_char_info,
				"attacker_char_info":attacker_char_info,
				"damage_type":damage_type,
				"attacker_dices":attacker_dice_roll
			}
		)
		return
	
	var defending_date=get_base_fsm_data_for_pu_id(defender_pu_id)
	defending_date.merge(
		{
			"attacker_char_info_dic":attacker_char_info.to_dictionary(),
			"defender_char_info_dic":defender_char_info.to_dictionary(),
			"attacker_dices":attacker_dices,
			"defender_can_parry":can_parry,
			"defender_can_defence":can_defence,
			"defender_can_evade":can_evade,
			"parry_count_max":parry_count_max
		}
	)
	
	fsm.change_state_for_pu_ud(defender_pu_id,"Defending",defending_date)
	

func parry_rolled(data={}):
	
	var attacker_char_info:CharInfo = CharInfo.from_dictionary(data.get("attacker_char_info_dic"))
	var defender_char_info:CharInfo = CharInfo.from_dictionary(data.get("defender_char_info_dic"))
	var defender_dices = data.get("dice_roll_result")
	var attacker_dices = data.get("attacker_dices")
	var damage_type = data.get("damage_type")
	
	#var attacked_by_peer_id=Globals.pu_id_player_info[attacker_char_info.pu_id].current_peer_id
	increase_dice_result_to_action_name_with_buffs_for_char_info(defender_char_info,"Parry")


	#if rolled+-1==recieved
	if defender_dices["main_dice"]==attacker_dices["main_dice"]+1 or \
	defender_dices["main_dice"]==attacker_dices["main_dice"]-1 or \
	defender_dices["main_dice"]==attacker_dices["main_dice"]:
		print("parried")
		var responce_data = get_base_fsm_data_for_pu_id(attacker_char_info.pu_id)
		responce_data["defender_char_info_dic"]=defender_char_info.to_dictionary()
		responce_data["attack_responce"]="evaded"
			
		fsm.change_state_for_pu_ud(attacker_char_info.pu_id,"GettingAttackResponce",responce_data)
		#rpc_id(attacked_by_peer_id,"answer_attack","parried")
		#attack_answered.emit()
		rpc("systemlog_message",str(get_char_info_nick(defender_char_info)," parried"))
		return
	print("dont parried")
	
	
	
	rpc("systemlog_message",str(get_char_info_nick(defender_char_info)," got hit"))
	
	calculating_damage_after_attack_ended(
		{
			"defender_char_info":defender_char_info,
			"attacker_char_info":attacker_char_info,
			"damage_type":damage_type
		}
	)
	
	#var damage_to_take=players_handler.calculate_damage_to_take(attacker_char_info,attacker_dices,damage_type)
	
			
		
		

	#dices_main_VBoxContainer.visible=false


func evade_pressed(data={}):
	
	var dice_roll_result = data.get("dice_roll_result")
	var attacker_dices = data.get("attacker_dices")
	var defender_char_info = CharInfo.from_dictionary(data.get("defender_char_info_dic"))
	var attacker_char_info = CharInfo.from_dictionary(data.get("attacker_char_info_dic"))
	var damage_type = data.get("damage_type")
	
	players_handler.rpc("add_to_advanced_logs","ADVANCED_LOG_TAKER_ATTEMPT_EVADING")
	#print("\n\n_on_evade_button_pressed   dice_roll_result_list= ",dice_roll_result," recieved_dice_roll_result=",attacker_dices)
	
	#print("\n\n_on_evade_button_pressed  2 dice_roll_result_list= ",dice_roll_result_list," recieved_dice_roll_result=",recieved_dice_roll_result)
	
	increase_dice_result_to_action_name_with_buffs_for_char_info(defender_char_info,"Evade")
	
	var enemy_agility=players_handler.get_char_info_agility_rank(attacker_dices)
	var self_agility=players_handler.get_char_info_agility_rank(defender_char_info)
	var agility_bonus=calculate_agility_bonus(self_agility,enemy_agility)
	var counter_attack=false
	counter_attack = dice_roll_result["main_dice"]==dice_roll_result["crit_dice"]
	print("counter attack=",counter_attack," (",dice_roll_result["main_dice"],"==",dice_roll_result["crit_dice"],") ?")

	players_handler.rpc("add_to_advanced_logs",
	"ADVANCED_LOG_COUNTER_ATTACK_CHECHKING",
		{
			"counter_attack_flag":counter_attack,
			"main_dice_roll":dice_roll_result["main_dice"],
			"crit_dice_roll":dice_roll_result["crit_dice"]
		}
	)

	#dice_roll_result_list
	#recieved_dice_roll_result
	#var attacked_by_peer_id=Globals.pu_id_player_info[attacked_by_char_info.pu_id].current_peer_id
	var enemy_has_ignore_evade=players_handler.char_info_has_active_buff(attacker_char_info,"Ignore Evade")

	if enemy_has_ignore_evade:
		players_handler.rpc("add_to_advanced_logs",
			"ADVANCED_LOG_ENEMY_HAS_IGNORE_EVADE_CHECK",
			{"ignore_evade_buff":enemy_has_ignore_evade}
		)

	var dice_with_agility_bonus=min(6,dice_roll_result["main_dice"]+agility_bonus)


	players_handler.rpc("add_to_advanced_logs",
		"ADVANCED_LOG_AGILITY_DIFFERENCE_SHOW",
		{
			"self_agility":self_agility,
			"enemy_agility":enemy_agility,
			"agility_bonus":agility_bonus

		}
	)
	
	var responce_data = get_base_fsm_data_for_pu_id(attacker_char_info.pu_id)
	responce_data["defender_char_info_dic"]=defender_char_info.to_dictionary()
	responce_data.merge(data)
	#responce_data["attack_responce"]="evaded"
	
	
	if dice_with_agility_bonus>attacker_dices["main_dice"] and not enemy_has_ignore_evade:
		responce_data["attack_responce"]="evaded"
		#rpc_id(attacked_by_peer_id,"answer_attack","evaded")

		rpc("systemlog_message",str("{self_name} evaded by throwing {dice_result} agility_bonus={agility_bonus}").format({
				"self_name":get_char_info_nick(defender_char_info),
				"dice_result":dice_roll_result["main_dice"],
				"agility_bonus":agility_bonus
			})
			)
		players_handler.rpc("add_to_advanced_logs",
			"ADVANCED_LOG_USER_EVADED_ATTACK",
			{
				"self_name":get_char_info_nick(defender_char_info),
				"dice_result":dice_roll_result["main_dice"],
				"agility_bonus":agility_bonus
			}
		)
	elif dice_with_agility_bonus==attacker_dices["main_dice"] and not enemy_has_ignore_evade:
		var damage_to_take=players_handler.calculate_damage_to_take(attacker_char_info,attacker_dices,damage_type,"Halfed Damage")
		if typeof(damage_to_take)==TYPE_STRING:
			if damage_to_take=="evaded":
				#rpc_id(attacked_by_peer_id,"answer_attack","evaded")
				responce_data["attack_responce"]="evaded"
				rpc("systemlog_message",str(defender_char_info," evaded by buff"))
				players_handler.rpc("add_to_advanced_logs",
				"ADVANCED_LOG_TAKER_EVADED_BY_BUFF",
					{
						"self_name":get_char_info_nick(defender_char_info)
					}
				)
		else:
			responce_data["attack_responce"]="Halfed Damage"
			#rpc_id(attacked_by_peer_id,"answer_attack","Halfed Damage")
			#attack_answered.emit()
			if damage_to_take==0:
				rpc("remove_invinsibility_after_hit_for_pu_id",defender_char_info)
			rpc("systemlog_message",str(get_char_info_nick(defender_char_info)," halfed damage by throwing ",dice_roll_result["main_dice"]))
			#print_debug("take_damage_to_char_info, self_pu_id=",Globals.self_pu_id," damage_to_take=",damage_to_take,"attacked_by_char_info=",attacked_by_char_info.to_dictionary())
			players_handler.take_damage_to_char_info(defender_char_info.to_dictionary(),damage_to_take,true,attacker_char_info.to_dictionary())
			players_handler.change_game_stat_for_char_info(attacker_char_info.to_dictionary(),"total_damage_dealt",damage_to_take)
	else:
		var damage_to_take=players_handler.calculate_damage_to_take(attacker_char_info,attacker_dices,damage_type)
		
		if typeof(damage_to_take)==TYPE_STRING:
			if damage_to_take=="evaded":
				responce_data["attack_responce"]="evaded"
				rpc("systemlog_message",str(defender_char_info," evaded by buff"))
				players_handler.rpc("add_to_advanced_logs",
				"ADVANCED_LOG_TAKER_EVADED_BY_BUFF",
					{
						"self_name":get_char_info_nick(defender_char_info)
					}
				)
		else:
			responce_data["attack_responce"]="damaged"
			#rpc_id(attacked_by_peer_id,"answer_attack","damaged")
			#attack_answered.emit()
			if damage_to_take==0:
				rpc("remove_invinsibility_after_hit_for_char_info",defender_char_info.to_dictionary())
			#print_debug("take_damage_to_char_info, self_pu_id=",Globals.self_pu_id," damage_to_take=",damage_to_take,"attacked_by_char_info=",attacked_by_char_info.to_dictionary())
			players_handler.take_damage_to_char_info(defender_char_info.to_dictionary(),damage_to_take,true,attacker_char_info.to_dictionary())
			players_handler.rpc("change_game_stat_for_char_info",attacker_char_info.to_dictionary(),"total_damage_dealt",damage_to_take)
			rpc("systemlog_message",str(get_char_info_nick(defender_char_info)," got damaged thowing ",dice_roll_result["main_dice"]))
	
	
	
	
	if counter_attack and defender_char_info.get_node().can_attack:
		var atk_rng=players_handler.get_char_info_attack_range(defender_char_info)
		var attacker_kletka_id=char_info_to_kletka_number(attacker_char_info)
		
		#var distance_between_enemie=get_path_in_n_steps(get_current_kletka_id(),attacker_kletka_id,atk_rng).size()

		var kletki_with_players=get_kletki_ids_with_players_you_can_reach_in_steps(atk_rng,get_current_kletka_id_for_char_info(defender_char_info))

		print("attempting counter attack kletki_with_players=",kletki_with_players," ? attacker_kletka_id=",attacker_kletka_id)

		if attacker_kletka_id in kletki_with_players:
			
			responce_data.merge(
				{
					"counter_attack_after_action":true,
					"counter_attack_attacker_char_info_dic":defender_char_info.to_dictionary(),
					"counter_attack_defender_char_info_dic":attacker_char_info.to_dictionary(),
				}
			)
			
			rpc("systemlog_message",str(get_char_info_nick(defender_char_info)," counter attacking"))
			var player_has_magic_attack=players_handler.get_char_info_magical_attack(defender_char_info)
			var damage_type_new=players_handler.DAMAGE_TYPE.PHYSICAL
			if player_has_magic_attack:
				damage_type_new=await choose_between_two("Choose damage type",players_handler.DAMAGE_TYPE.PHYSICAL,players_handler.DAMAGE_TYPE.MAGICAL)
			await attack_player_on_kletka_id(attacker_kletka_id,damage_type_new,false)
	
	fsm.change_state_for_pu_ud(attacker_char_info.pu_id,"GettingAttackResponce",responce_data)
	
	#attack_answered.emit()


func calculating_damage_after_attack_ended(data={}):
	var defender_char_info:CharInfo = data.get("defender_char_info")
	var attacker_char_info:CharInfo = data.get("attacker_char_info")
	var attacker_dices = data.get("attacker_dices")
	var damage_type:String = data.get("damage_type")
	
	var damage_to_take=players_handler.calculate_damage_to_take(
		attacker_char_info,
		attacker_dices,
		damage_type
	)
	
	var responce_data = get_base_fsm_data_for_pu_id(attacker_char_info.pu_id)
	responce_data["defender_char_info_dic"]=defender_char_info.to_dictionary()
	responce_data.merge(data)
	if typeof(damage_to_take)==TYPE_STRING:
		if damage_to_take=="evaded":
			remove_evade_buff_after_hit_for_char_info(defender_char_info.to_dictionary())
			responce_data["attack_responce"]="evaded"
			
			fsm.change_state_for_pu_ud(attacker_char_info.pu_id,"GettingAttackResponce",responce_data)
			
			rpc("systemlog_message",str(get_char_info_nick(defender_char_info)," evaded by buff"))
	else:
		responce_data["attack_responce"]="damaged"
		
		if damage_to_take==0:
			rpc("remove_invinsibility_after_hit_for_char_info",defender_char_info.to_dictionary())
		#print_debug("take_damage_to_char_info, self_pu_id=",Globals.self_pu_id," damage_to_take=",damage_to_take,"attacked_by_char_info.=",attacked_by_char_info.to_dictionary())
		players_handler.take_damage_to_char_info(defender_char_info.to_dictionary(),damage_to_take,true,attacker_char_info.to_dictionary())
		players_handler.change_game_stat_for_char_info(attacker_char_info.to_dictionary(),"total_damage_dealt",damage_to_take)
		
		fsm.change_state_for_pu_ud(attacker_char_info.pu_id,"GettingAttackResponce",responce_data)
	

	rpc("systemlog_message",str(get_char_info_nick(defender_char_info)," got damaged thowing ",
			char_uniq_id_to_dice_roll_result[defender_char_info.get_uniq_id()]["main_dice"]
		)
	)
	pass


func attack_responce_handle_for_char_info_from_char_info(data={}):
	
	var attack_responce_string:String = data.get("attack_responce")
	var defender_char_info:CharInfo = data.get("defender_char_info")
	var attacker_char_info:CharInfo =  data.get("attacker_char_info")
	var damage_type:String = data.get("damage_type")
	var parry_count_max = data.get("parry_count_max")
	var kletka_id_selected = data.get("kletka_id_selected")
	var consume_action_point = data.get("consume_action_point")
	
	var counter_attack_after_action = data.get("counter_attack_after_action",false)
	var counter_attack_attacker_char_info:CharInfo = null
	var counter_attack_defender_char_info:CharInfo = null
	
	if counter_attack_after_action:
		print("counter_attack_after_action = data=",data)
		counter_attack_attacker_char_info = CharInfo.from_dictionary(data.get("counter_attack_attacker_char_info_dic"))
		counter_attack_defender_char_info = CharInfo.from_dictionary(data.get("counter_attack_defender_char_info_dic"))
		
	
	var hitted=false
	match attack_responce_string:
		"parried":
			players_handler.rpc("add_to_advanced_logs",
				"ADVANCED_LOG_TAKER_PARRIED",
				{"parry_count_max":parry_count_max}
			)
			parry_count_max-=1
			if parry_count_max!=0:
				rpc("systemlog_message",str(attacker_char_info.get_node().name," stamina left:",parry_count_max))
				
				var parry_data = data.duplicate()
				parry_data["current_parry_count"] = parry_data["current_parry_count"]+1
				
				#await attack_player_on_kletka_id(kletka_id,damage_type)
				await players_handler.trigger_buffs_on(attacker_char_info,"enemy parried",defender_char_info)
				return
			else:
				players_handler.rpc("add_to_advanced_logs","ADVANCED_LOG_ATTACKER_RUN_OUT_OF_STAMINA_FULL_PARRY")
		"Halfed Damage":
			#players_handler.charge_np_to_peer_id_by_number(Globals.self_peer_id,1)
			players_handler.rpc("add_to_advanced_logs","ADVANCED_LOG_TAKER_HALFED_DAMAGE")
			hitted=true
			players_handler.change_game_stat_for_char_info(attacker_char_info.to_dictionary(),"total_success_hit",1)
			players_handler.change_game_stat_for_char_info(attacker_char_info.to_dictionary(),"attacked_this_turn",1)
			
			await players_handler.trigger_buffs_on(attacker_char_info,"Success Attack",defender_char_info)
			await players_handler.trigger_buffs_on(attacker_char_info,"enemy halfed damage",defender_char_info)
		"damaged":
			#players_handler.charge_np_to_peer_id_by_number(Globals.self_peer_id,1)
			players_handler.rpc("add_to_advanced_logs","ADVANCED_LOG_DIRECT_HIT")
			hitted=true
			players_handler.change_game_stat_for_char_info(attacker_char_info.to_dictionary(),"total_success_hit",1)
			players_handler.change_game_stat_for_char_info(attacker_char_info.to_dictionary(),"attacked_this_turn",1)
			#current_action="wait"
			await players_handler.trigger_buffs_on(attacker_char_info,"Success Attack",defender_char_info)
		"defending":
			#players_handler.charge_np_to_peer_id_by_number(Globals.self_peer_id,1)
			players_handler.rpc("add_to_advanced_logs","ADVANCED_LOG_TAKER_DEFENDED")
			hitted=true
			#current_action="wait"
			players_handler.change_game_stat_for_char_info(attacker_char_info.to_dictionary(),"total_success_hit",1)
			players_handler.change_game_stat_for_char_info(attacker_char_info.to_dictionary(),"attacked_this_turn",1)
			await players_handler.trigger_buffs_on(attacker_char_info,"Success Attack",defender_char_info)
			await players_handler.trigger_buffs_on(attacker_char_info,"enemy defended",defender_char_info)
		"evaded":
			players_handler.rpc("add_to_advanced_logs","ADVANCED_LOG_TAKER_EVADED")
			#current_action="wait"
			players_handler.change_game_stat_for_char_info(attacker_char_info.to_dictionary(),"attacked_this_turn",1)
			await players_handler.trigger_buffs_on(attacker_char_info,"enemy evaded",defender_char_info)
		

	if hitted and damage_type!="Phantasm":
		players_handler.charge_np_to_char_info_by_number(attacker_char_info.to_dictionary(),1)
		players_handler.add_to_advanced_logs("ADVANCED_LOG_ATTACKER_CHARGING_PHANTASM")
	roll_dice_optional_label.visible=false
	
	if damage_type=="Physical" and players_handler.get_char_info_attack_range(attacker_char_info)<=2: 
		move_player_from_kletka_id1_to_id2(attacker_char_info,kletka_id_selected,get_current_kletka_id_for_char_info(attacker_char_info),true)
	
	if damage_type!="Phantasm" or consume_action_point:
		if defender_char_info.get_node().additional_attack>=1:
			players_handler.reduce_additional_attacks_for_char_info(attacker_char_info.to_dictionary())
		else:
			#print("reducing action point after attack attack_type=",attack_type," consume_action_point=",consume_action_point)
			reduce_one_action_point_for_pu_id(attacker_char_info.pu_id,-1,"attack")
			players_handler.rpc("add_to_advanced_logs","ADVANCED_LOG_ATTACKER_REDUCED_ACTION_POINT")
	
	
	if counter_attack_after_action:
		var counter_attack_data = {
			"defender_char_info_dic":data.get("counter_attack_defender_char_info_dic"),
			"kletka_id_selected":get_current_kletka_id_for_char_info(defender_char_info),
			
			"confirm_action_action_text":"ARE_YOU_SURE_YOU_WANT_TO_ACTION_COUNTER_ATTACK",
			"action_after_confirming_action":"choose_damage_type_before_counter_attack",
		
			
			"choose_between_two_question":"Choose damage type",
			
			"first_option":players_handler.DAMAGE_TYPE.PHYSICAL,
			"second_option":players_handler.DAMAGE_TYPE.MAGICAL,
			"first_option_action":"choosed_physical_damage_type_for_counter_attack",
			"second_option_action":"choosed_magical_damage_type_for_counter_attack",
		}
		fsm.change_state_for_pu_ud(counter_attack_attacker_char_info.pu_id,"ConfirmAction",counter_attack_data)
	



func attack_player_on_kletka_id(attacker_char_info,kletka_id,attack_type="Physical",consume_action_point:bool=true,phantasm_config={}):

	#set_action_status(
			#attacker_char_info,#who
			#"getting_attacked",#what doint
			#enemy_char_info,#to who
			#dice_roll_result_list,
			#attack_type#,
			##phantasm_config
			#)
	
	
	
	#if attacker_char_info.pu_id != enemy_char_info.pu_id:
		#rpc_id(attacker_peer_id,"show_gui_depends_on_situation","waiting_enemie_attack_responce")
		#disable_every_button()	
		#alert_label_text(true,tr("WAITING_ENEMIE_ATTACK_RESPONCE"))
	
	var hitted=false
	
	var status= await attack_response


	match status:
		"OK":
			pass
		"Disconnect":
			return "ERROR"

	

	dices_main_VBoxContainer.visible=false
	if players_handler.current_player_pu_id_turn==Globals.self_pu_id:
		disable_every_button(false)
		end_turn_button.disabled=false
	alert_label_text(false)
	
	
	#this was for counter attack
	#if attack_type != "Phantasm":
	#	players_handler.rpc("finish_attack",get_current_self_char_info().to_dictionary())
	
	#return enemy_char_info
	
	

func get_char_info_from_node_name(unit_name:String)->CharInfo:
	
	var serv_nod#=players_handler.get_self_servant_node(unit_name)
	for kletka_id in kletka_id_to_char_info:
		for char_info in kletka_id_to_char_info[kletka_id]:
			serv_nod = char_info.get_node()
			if serv_nod.name==unit_name:
				break


	
	var pu_id=serv_nod.owner_pu_id
	var unit_id=serv_nod.unit_id

	var return_info:CharInfo=CharInfo.new(pu_id,unit_id)
	return return_info

func get_current_char_info_for_pu_id(pu_id)->CharInfo:

	#if char_info_attacked!=null:
	#	return char_info_attacked
	#var pu_id=Globadls.self_pu_iddd
	#var nnode=Globals.pu_id_player_info[pu_idd]["units"][current_unit_id]

	var current_unit_id = Globals.pu_id_player_info[pu_id]["current_unit_id"]
	var rett_value=CharInfo.new(pu_id,current_unit_id)

	return rett_value


func roll_a_dice():
	
	randomize()
	var dice_roll_result_list:Dictionary={"main_dice":0,"crit_dice":0,"defence_dice":0,"additional_d6":0,"additional_d6_2":0,"additional_d100":0}
	
	#var set_dices=players_handler.char_info_has_active_buff(get_current_self_char_info(),"Faceless Moon")
	var set_dices=false
	if set_dices:
		dice_roll_result_list=set_dices.get("Dices",{})
	
	if not set_dices:
		dice_roll_result_list["main_dice"]=randi_range(1,6)
		dice_roll_result_list["crit_dice"]=randi_range(1,6)
		dice_roll_result_list["defence_dice"]=randi_range(1,4)
		dice_roll_result_list["additional_d6"]=randi_range(1,6)
		dice_roll_result_list["additional_d6_2"]=randi_range(1,6)
		dice_roll_result_list["additional_d100"]=randi_range(1,100)
	
	
	main_dice.roll(dice_roll_result_list["main_dice"])
	previous_roll_base_dice_label.text=tr("PREVIOUS_ROLL_BASE_DICE")+str(dice_roll_result_list["main_dice"])
	
	crit_dice.roll(dice_roll_result_list["crit_dice"])
	previous_roll_crit_dice_label.text=tr("PREVIOUS_ROLL_CRIT_DICE")+str(dice_roll_result_list["crit_dice"])
	
	defence_dice.roll(dice_roll_result_list["defence_dice"])
	previous_roll_def_dice_label.text=tr("PREVIOUS_ROLL_DEF_DICE")+str(dice_roll_result_list["defence_dice"])
	
	
	
	print(dice_roll_result_list)
	#rpc_id("receice_dice_roll_results",dice_roll_result_list)
	
	rpc("get_message",str(Globals.nickname,"'s roll"),str("main:",dice_roll_result_list["main_dice"]," crit:",dice_roll_result_list["crit_dice"]," def:",dice_roll_result_list["defence_dice"]))
	return dice_roll_result_list

func _roll_dices_button_pressed():
	var res=roll_a_dice()
	rolled_a_dice.emit(res)
	pass



@rpc("any_peer","call_local","reliable")
func set_action_status(char_info_setting_status:CharInfo,status:String,char_info_getting_status:CharInfo,attack_type="Physical",phantasm_config={}):
	print("set_action_status status=",status," by_whom_char_info_dic=",char_info_setting_status)

	var setting_dice_roll=char_uniq_id_to_dice_roll_result[char_info_setting_status.get_uniq_id()]
		
	await get_tree().create_timer(0.2).timeout
	
	var self_unit_hit=false
	
	if char_info_setting_status.pu_id == char_info_getting_status.pu_id:
		self_unit_hit = true
	var attacked_by_peer_id=Globals.pu_id_player_info[char_info_setting_status.pu_id].current_peer_id
	
	#recieved_damage_type=attack_type
	#recieved_phantasm_config=phantasm_config
	
	#print(str("status=",status," attacked_by_char_info=",attacked_by_char_info))
	match status:
		"getting_attacked":
			pass
			#await attack_answered
		"parrying":
			#await _on_parry_button_pressed()
			pass
			#await attack_answered
		"roll_dice_for_result":
			pass
			#TODO
			
			
			#roll_dice_optional_label.text=tr("ROLL_DICE_FOR_RESULT_STATEMENT").format(
				#{
					#"dice_result":recieved_dice_roll_result["main_dice"]
				#}
			#)
			#roll_dice_optional_label.visible=true
			#await await_dice_roll()
			#roll_dice_optional_label.visible=false
			#if dice_roll_result_list["main_dice"]>recieved_dice_roll_result["main_dice"] or dice_roll_result_list["main_dice"]==6:
				#rpc_id(attacked_by_peer_id,"answer_attack","Evaded bad status")
				#rpc("systemlog_message",str(self_char_info.get_node().name, " evaded bad status"))
			#elif dice_roll_result_list["main_dice"]==recieved_dice_roll_result["main_dice"]:
				#rpc_id(attacked_by_peer_id,"answer_attack","Even dice rolls, reroll for status")
				#rpc("systemlog_message",str(self_char_info.get_node().name, " rolled the same number, reroll"))
			#else:
				#rpc_id(attacked_by_peer_id,"answer_attack","Getting bad status")
				#rpc("systemlog_message",str(self_char_info.get_node().name, " getting bad status"))
	
	#char_info_attacked=null
	#_on_dices_toggle_button_pressed()????



func get_char_info_nick(char_info:CharInfo)->String:
	return char_info.get_node().name


func calculate_agility_bonus(self_agility_rank: String, attacker_agility_rank: String) -> int:
	var parse_rank = func(rank_str: String) -> Dictionary:
		if rank_str == "EX":
			return {"letter": "EX", "value": 5, "pluses": 0}
			
		var letter: String = rank_str[0]
		var value: int = 0
		
		match letter:
			"A": value = 4
			"B": value = 3
			"C": value = 2
			"D": value = 1
			"E": value = 0
			
		var pluses = rank_str.count("+")
		return {"letter": letter, "value": value, "pluses": pluses}
	# ==========================================================
	var self_data = parse_rank.call(self_agility_rank)
	var attacker_data = parse_rank.call(attacker_agility_rank)
	
	var bonus: int = 0
	
	if self_data.value > attacker_data.value:
		match self_data.letter:
			"EX":
				match attacker_data.letter:
					"A": bonus = 1
					"B": bonus = 2
					_: bonus = 3 # Против C, D, E
			"A":
				match attacker_data.letter:
					"B": bonus = 1
					_: bonus = 2 # Против C, D, E
			"B":
				bonus = 1 # Против C, D, E
				
	elif self_data.value == attacker_data.value:
		bonus = max(0, self_data.pluses - attacker_data.pluses)
	return bonus


@rpc("any_peer","call_local","reliable")
func remove_invinsibility_after_hit_for_char_info(char_info_dic:Dictionary):
	#var pu_id_buffs=Globals.pu_id_player_info[pu_id]["servant_node"].buffs
	var char_info=CharInfo.from_dictionary(char_info_dic)

	var char_info_buffs=char_info.get_node().buffs
	for i in range(char_info_buffs.size()):
		var buff=char_info_buffs[i]
		if buff["Name"]=="Invincible":
			if buff.has("Power"):
				var evade_power=buff.get("Power",1)
				if evade_power==1:
					Globals.pu_id_player_info[char_info.pu_id]["units"][char_info.unit_id].buffs.pop_at(i)
				else:
					Globals.pu_id_player_info[char_info.pu_id]["units"][char_info.unit_id].buffs[i]["Power"]-=1


@rpc("any_peer","call_local","reliable")
func remove_evade_buff_after_hit_for_char_info(char_info_dic:Dictionary):
	var char_info=CharInfo.from_dictionary(char_info_dic)

	var char_info_buffs=char_info.get_node().buffs
	for i in range(char_info_buffs.size()):
		var buff=char_info_buffs[i]
		if buff["Name"]=="Evade":
			if buff.has("Power"):
				var evade_power=buff.get("Power",1)
				if evade_power==1:
					Globals.pu_id_player_info[char_info.pu_id]["units"][char_info.unit_id].buffs.pop_at(i)
				else:
					Globals.pu_id_player_info[char_info.pu_id]["units"][char_info.unit_id].buffs[i]["Power"]-=1
				

func defence_rolled(data={}):
	
	var dice_roll_result = data.get("dice_roll_result")
	var attacker_dices = data.get("attacker_dices")
	var defender_char_info = CharInfo.from_dictionary(data.get("defender_char_info_dic"))
	var attacker_char_info = CharInfo.from_dictionary(data.get("attacker_char_info_dic"))
	var damage_type = data.get("damage_type")
	
	
	increase_dice_result_to_action_name_with_buffs_for_char_info(defender_char_info,"Defence")
	
	var responce_data = get_base_fsm_data_for_pu_id(attacker_char_info.pu_id)
	responce_data["defender_char_info_dic"]=defender_char_info.to_dictionary()
	responce_data.merge(data)
	responce_data["attack_responce"]="defending"
	
	
	
	#rpc_id(attacked_by_peer_id,"answer_attack","defending")
	var damage_to_take=players_handler.calculate_damage_to_take(attacker_char_info,attacker_dices,damage_type,"Defence")
	
	
	calculating_damage_after_attack_ended(
			{
				"defender_char_info":defender_char_info,
				"attacker_char_info":attacker_char_info,
				"damage_type":damage_type,
				"attacker_dices":attacker_dices
			}
		)
	
	
	#rpc("systemlog_message",str(get_char_info_nick(defender_char_info)," defending by throwing ",dice_roll_result["defence_dice"]))
	
	fsm.change_state_for_pu_ud(attacker_char_info.pu_id,"GettingAttackResponce",responce_data)
	#dices_main_VBoxContainer.visible=false



func _on_parry_button_pressed():
	
	pass


func _on_phantasm_evation_button_pressed():
	#TBA
	#TODO
	pass # Replace with function body.

@rpc('any_peer',"call_local","reliable")
func answer_attack(status):
	#attack_responce_string=status
	#var attack_responce=attack_response_from_charinfo_uniq_to_charinfo_iniq[defender_char_info.get_uniq_id()][attacker_peer_id.get_uniq
	attack_response.emit("OK")

#@rpc("any_peer","call_local","reliable")
#func receice_dice_roll_results(recieved_dice_roll_result_temp):
	#print("receice_dice_roll_results=",recieved_dice_roll_result_temp)
	#recieved_dice_roll_result=recieved_dice_roll_result_temp.duplicate()
	
func new_turn():
	make_action_button.disabled=false

@rpc("authority","call_local","reliable")
func main_game():
	print("GAME STARTED")
	
	%character_selection_container.queue_free()
	#print("connected="+str(connected))
	#spawn random dommies
	#generate_characters_on_random_kletkax()
	
	#choose kletka so spawn
	print("occupied_kletki="+str(kletka_id_to_char_info))
	reset_button.queue_free()
	#random_kletka()
	if multiplayer.get_unique_id()==1:
		glow_cletki_intiate()
		players_handler.start()
	start_button.queue_free()
	#attack_button.visible=true
	#move_button.visible=true
	#cancel_button.visible=true
	#current_action_points=3
	#current_action_points_label.text=str(current_action_points)
	
	pass
	
	
@rpc("any_peer","call_local","reliable")
func sync_owned_kletki(unit_uniq_id_to_kletki_ids_owned_local):
	unit_uniq_id_to_kletki_ids_owned=unit_uniq_id_to_kletki_ids_owned_local
	
@rpc("authority","call_local","reliable")
func initial_spawn():
	pass
	
func inital_spawn_of_player(pu_id):
	#still operates on host
	print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	var pu_peer_id=Globals.pu_id_player_info[pu_id]["current_peer_id"]
	
	Globals.pu_id_to_action_points[pu_id]=3

	var kletka_to_initial_spawn=get_unoccupied_kletki()
	
	var move_data={
			"char_info_dic":get_current_char_info_for_pu_id(pu_id),
			"Current Kletka":-1,
			"Available Kletki":kletka_to_initial_spawn,
			"Initial Spawn":true
		}
	fsm.change_state_for_pu_ud(pu_id,"MoveSelection",move_data)


@rpc("any_peer","reliable","call_local")
func pu_id_pressed_attack_button(pu_id:String,counter_attack:bool):
	if not multiplayer.is_server(): return
	
	var char_info=get_current_char_info_for_pu_id(pu_id)
	
	var player_has_magic_attack=players_handler.get_char_info_magical_attack(char_info)
	
	var addit_attacks=char_info.get_node().additional_attack>=1
	
	if Globals.pu_id_to_action_points[pu_id]>=1 or counter_attack or addit_attacks:
		rpc_id(
			Globals.pu_id_player_info[pu_id]["current_peer_id"],
			"show_attack_choises_for_client",
			player_has_magic_attack
			)
		pass
	

@rpc("authority","reliable","call_local")
func show_attack_choises_for_client(player_has_magic_attack:bool):
	if player_has_magic_attack:
		magical_damage_button.disabled=false
	type_of_damage_choose_buttons_box.visible=true
	actions_buttons.visible=false


func _on_attack_pressed(counter_attack:bool=false):
	print("_________________attack______________")
	#print("occupied_kletki="+str(occupied_kletki))
	#print("get_current_kletka_id()="+str(get_current_kletka_id()))
	magical_damage_button.disabled=true
	#var magic_power=players_handler.get_peer_id_magical_attack(Globals.self_peer_id)
	
	rpc_id(1,"pu_id_pressed_attack_button",Globals.self_pu_id)



func pu_id_pressed_damage_type_button(pu_id:String,type:String):
	if not multiplayer.is_server(): return
	#const DAMAGE_TYPE= {PHYSICAL="Physical", MAGICAL="Magical", PHANTASM="Phantasm"}
	var char_info=get_current_char_info_for_pu_id(pu_id)
	var attack_range
	Globals.unit_uniq_id_to_damage_type[char_info.get_uniq_id()]=type
	match type:
		players_handler.DAMAGE_TYPE.PHYSICAL:
			attack_range=players_handler.get_char_info_attack_range(char_info)
		players_handler.DAMAGE_TYPE.MAGICAL:
			attack_range=3
	
	var kk=get_kletki_ids_with_players_you_can_reach_in_steps(
		attack_range,
		get_current_kletka_id_for_char_info(char_info)
		)
	
	if kk.size()==0:
		rpc_id(
			Globals.pu_id_player_info[pu_id]["current_peer_id"],
			"send_info_table_show_to_client",
			"No enemies available to attack"
		)
		fsm.change_state_for_pu_ud(pu_id,"Idle")
		return
	
	var state_data:Dictionary=get_base_fsm_data_for_pu_id(pu_id)
	
	state_data.merge(
		{
			"cells_to_choose":kk,
			"type":"attack",
			"damage_type":type
		}
	)
	
	fsm.change_state_for_pu_ud(pu_id,"ChoosingTarget",state_data)
	
	pass



func _on_regular_damage_button_pressed():
	rpc_id(1,"pu_id_pressed_damage_type_button",players_handler.DAMAGE_TYPE.PHYSICAL)

func _on_magical_damage_button_pressed():
	rpc_id(1,"pu_id_pressed_damage_type_button",players_handler.DAMAGE_TYPE.MAGICAL)

func deal_damage():
	pass

func update_field_icon()->void:
	match players_handler.get_current_time():
		"Day":
			day_or_night_sprite_2d.texture=SUN
		"Night":
			day_or_night_sprite_2d.texture=MOON
		_:
			push_error("UNKNOWN TIME REQUEST URGENT HELP, YOU BROKE TIMELINE")
	return

func get_cells_with_unplayer_units_for_pu_id(pu_id):
	var kletki_with_non_played_units:Array=[]
	for unit_id in Globals.pu_id_player_info[pu_id]['units'].keys():
		if not unit_id in Globals.pu_id_player_info[pu_id]["unit_ids_already_played_this_turn"]:
			var char_info_temp=CharInfo.new(pu_id,unit_id)
			print(char_info_temp.get_node().name+" Can_Be_Played=",char_info_temp.get_node().can_be_played)
			if char_info_temp.get_node().can_be_played and\
			not char_info_temp.get_node().total_dead:
				kletki_with_non_played_units.append(
					players_handler.get_char_info_kletka_number(
						char_info_temp
					)
				)
	var pu_peer_id=Globals.pu_id_player_info[pu_id]["current_peer_id"]
	if kletki_with_non_played_units.size()<=0:
		Globals.pu_id_player_info[pu_id]["unit_ids_already_played_this_turn"]=[]
		Globals.pu_id_player_info[pu_id]["maximum_playable_units"]=0
	return kletki_with_non_played_units

#var unit_ids_already_played_this_turn:Array=[]
#var maximum_playable_units:int

func choose_unit_to_play_for_pu_id(pu_id,maximum_playable_units,unit_ids_already_played_this_turn)->bool:
	
	#Globals.pu_id_player_info[pu_id]["current_unit_id"]#=unit_id_choosen

	return true
	
func get_additional_actions_for_char_info_from_mount(char_info_dic:Dictionary):
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)

	var char_info_node=char_info.get_node()

	for mount_uniq_id in char_info_node.mounts_uniq_id_array:
		var mount_char_info=get_char_info_from_uniq_id(mount_uniq_id)
		var mount_node=mount_char_info.get_node()

		if mount_char_info.move_points:
			players_handler.reduce_additional_moves_for_char_info(
				char_info_dic,
				-mount_node.move_points
			)
		if mount_char_info.attack_points:
			players_handler.reduce_additional_attacks_for_char_info(
				char_info_dic,
				-mount_node.attack_points
			)

	pass

	
func calculate_maximum_playable_units_for_pu_id(pu_id:String):
	var kletki_with_non_played_units:Array=[]
	for unit_id in Globals.pu_id_player_info[pu_id]['units'].keys():
		var char_info_temp=CharInfo.new(pu_id,unit_id)
		if char_info_temp.get_node().can_be_played and\
			not char_info_temp.get_node().total_dead:
			kletki_with_non_played_units.append(
				players_handler.get_char_info_kletka_number(
					char_info_temp
				)
			)
	return kletki_with_non_played_units.size()
	pass

func prepare_start_turn_data_for_pu_id(pu_id:String):
	#unit_ids_already_played_this_turn=[]
	
	Globals.pu_id_player_info[pu_id]["unit_ids_already_played_this_turn"]=[]
	Globals.pu_id_player_info[pu_id]["maximum_playable_units"]=calculate_maximum_playable_units_for_pu_id(pu_id)
	
	var start_turn_data = {
		"maximum_playable_units": Globals.pu_id_player_info[pu_id]["maximum_playable_units"],
		"unit_ids_already_played_this_turn": Globals.pu_id_player_info[pu_id]["unit_ids_already_played_this_turn"],
		"kletki_with_non_played_units": get_cells_with_unplayer_units_for_pu_id(pu_id)
	}
	
	fsm.change_state_for_pu_ud(pu_id,"StartTurn",start_turn_data)


func handle_pre_unit_turn_things(data:Dictionary={}):
	var pu_id:String = data.get("pu_id")
	var char_info_dic:Dictionary=data.get("char_info_dic")
	var char_info:CharInfo=CharInfo.from_dictionary(char_info_dic)

	var paralyzed_local=false

	var char_node = char_info.get_node()
	
	#print(players_handler.unit_uniq_id_player_game_stat_info)

	var skills_enabledd=true
	if char_node.summon_check:
		skills_enabledd = char_node.skills_enabled
	
	players_handler.change_game_stat_for_char_info(char_info.to_dictionary(),"attacked_this_turn",0,true)

	players_handler.change_game_stat_for_char_info(char_info.to_dictionary(),"skill_used_this_turn",0,true)

	players_handler.change_game_stat_for_char_info(char_info.to_dictionary(),"kletki_moved_this_turn",0,true)

	var unit_turn_data = {
		"skills_enabledd": skills_enabledd
	}
	if is_game_started:
		if players_handler.char_info_has_active_buff(char_info,"Paralysis") or \
		players_handler.char_info_has_active_buff(char_info,"Stun"):
			unit_turn_data["paralyzed"] = true
			unit_turn_data["paralyzed_reason"] = "Stun"
		if players_handler.char_info_has_active_buff(char_info,"Charm"):
			unit_turn_data["paralyzed"] = true
			unit_turn_data["paralyzed_reason"] = "Charm"
		
		

		if players_handler.char_info_has_active_buff(char_info,"Presence Concealment"):
			var buff_info=players_handler.char_info_has_active_buff(char_info,"Presence Concealment")
			var turns_passed=players_handler.turns_counter-buff_info["Turn Casted"]
			var minimum_turns=buff_info["Minimum Turns"]
			var maximum_turns=buff_info["Maximum Turns"]

			unit_turn_data["Presence_Concealment"]=true
			unit_turn_data["maximum_turns"]=maximum_turns
			unit_turn_data["minimum_turns"]=minimum_turns
			unit_turn_data["turns_passed"]=turns_passed
			#if turns_passed>=maximum_turns:
				#release_from_Presence_Concealment(false)
				#unit_turn_data["Presence_Concealment_min_turn_reached"]=true
				#unit_turn_data["Presence_Concealment_Stun"]=false
			#elif turns_passed>minimum_turns:
				#release_from_Presence_Concealment(true)
				#unit_turn_data["Presence_Concealment_min_turn_reached"]=true
				#unit_turn_data["Presence_Concealment_Stun"]=true
			#else:#waiting for minumum turns
				#disable_every_button()
				#unit_turn_data["min_turn_reached"]=false
				#info_table_show(
				#	tr("YOU_IN_PRESENCE_CONCEALMENT_FOR_TURNS").format(
				#	{
				#		"amount":abs(turns_passed-minimum_turns)
				#	}
				#))
				
				#await info_ok_button.pressed


	if unit_turn_data.get("Presence_Concealment_min_turn_reached",false):
		fsm.change_state_for_pu_ud(pu_id,"ReleasePresenceConcealment",unit_turn_data)
	else:
		fsm.change_state_for_pu_ud(pu_id,"UnitTurnState",unit_turn_data)
	

	


@rpc("authority","call_local","reliable")
func start_turn(pu_id:String):
	
	#choosing char_info to play
	
	prepare_start_turn_data_for_pu_id(pu_id)

	#print("It is my turn:",Globals.self_pu_id," char info:",get_current_self_char_info())
	
	
	players_handler.unit_uniq_id_player_game_stat_info[Globals.self_peer_id]["attacked_this_turn"]=0

	

	#print("Current_action="+str(current_action)+"\n\n")
func finishing_unit_start_turn_for_char_info(char_info):
	
	players_handler.reduce_all_cooldowns(char_info)

	players_handler.trigger_buffs_on(char_info,"Turn Started")
	players_handler.check_if_hp_is_bigger_than_max_hp_for_char_info(char_info)
	#removing and adding skill in case it got remove by something
	

func release_from_Presence_Concealment(stun:bool):
	pass
	#if stun:
		#info_table_show(tr("EXIT_PRECENCE_CONCEALMENT_EARLIER"))
		#await info_ok_button.pressed
		#fill_are_you_sure_screen(tr("ARE_YOU_SURE_YOU_WANT_TO_ACTION_RELEASE_PRESENCE_CONCEALMENT"))
		#var choose=await are_you_sure_signal
		#print("choose="+str(choose))
		#if choose==tr("ARE_YOU_SURE_DISAGREEMENT"):
		#	return
		
		
		#current_action="move"
		#var kletka_to_initial_spawn=get_unoccupied_kletki()
		#choose_glowing_cletka_by_ids_array(kletka_to_initial_spawn)
		#await glow_kletka_pressed_signal
		#rpc("show_char_info_servant_node",get_current_self_char_info().to_dictionary(),true)
		#players_handler.rpc("add_buff",[get_current_self_char_info().to_dictionary()],{"Name":"Paralysis","Duration":1,"Power":1})
	#else:
		#info_table_show(tr("PRESENCE_CONSEALMENT_END"))
		#await info_ok_button.pressed
		
		#current_action="move"
		#var kletka_to_initial_spawn=get_unoccupied_kletki()
		#choose_glowing_cletka_by_ids_array(kletka_to_initial_spawn)
		#await glow_kletka_pressed_signal
		#rpc("show_char_info_servant_node",get_current_self_char_info().to_dictionary(),true)
	#players_handler.rpc("remove_buff",[get_current_self_char_info().to_dictionary()],"Presence Concealment",true)



@rpc("any_peer","reliable","call_local")
func show_char_info_servant_node(char_info_dic:Dictionary,visible_loc:bool):
	var char_info=CharInfo.from_dictionary(char_info_dic)
	#Globals.pu_id_player_info[pu_id]["servant_node"].visible=visible_loc
	char_info.get_node().visible=visible_loc

@rpc("any_peer","reliable","call_local")
func pu_id_pressed_cancel_button(pu_id):
	if not multiplayer.is_server(): return
	
	var char_info=get_current_char_info_for_pu_id(pu_id)
	if Globals.pu_id_to_action_points[char_info.pu_id]>=1:
		var state_data:Dictionary=get_base_fsm_data_for_pu_id(pu_id)
		state_data["action"]="wait"
		fsm.change_state_for_pu_ud(pu_id,"Idle",state_data)


func _on_cancel_pressed():
	rpc_id(1,"pu_id_pressed_cancel_button",Globals.self_pu_id)

@rpc("any_peer","reliable","call_local")
func on_move_pressed_by_pu_id(pu_id):
	if not multiplayer.is_server(): return
	
	var char_info=get_current_char_info_for_pu_id(pu_id)
	print("char_name=",char_info.get_node().name," current_action_points=",Globals.pu_id_to_action_points[pu_id]," additional_moves=",char_info.get_node().additional_moves)
	if Globals.pu_id_to_action_points[char_info.pu_id]>=1 or char_info.get_node().additional_moves>=1:
		
		var move_ck=get_kletki_ids_available_to_move_to_for_char_info(char_info)

		var move_data={
			"char_info_dic":char_info.to_dictionary(),
			"Current Kletka":players_handler.get_char_info_kletka_number(char_info),
			"Available Kletki":move_ck
		}
		
		fsm.change_state_for_pu_ud(char_info.pu_id, "MoveSelection", move_data)
	else:
		#if it is pressed then resync accured need sync
		#TODO after FSM implemented
		pass
		
		


func _on_move_pressed(unmounting=false):
	rpc_id(1,"on_move_pressed_by_pu_id",Globals.self_pu_id)
		


func field_manipulation(buff_config:Dictionary):
	#{"Buffs":[
	#	{"Name":"Field Manipulation",
	#	"Amount":3,"Range":3,"Config":
	#		{"Owner":Globals.self_peer_id,
	#			"Stats Up By":1,
	#			"Additional":null}
	#		}
	#	],
	var _BLOCKED_KLETKA_CONFIG={
		"Owner":CharInfo.new("",0).get_uniq_id(),
		"Blocked":true
	}
	var amount_to_manipulate=buff_config.get("Amount",0)
	var range_of_manipulatons=buff_config.get("Range",0)
	var kletka_config=buff_config.get("Config",0)
	var amount_kletki=buff_config.get("Amount",1)
	kletka_config["Owner"]=get_current_self_char_info().get_uniq_id()
	kletka_config["Turn Casted"]=players_handler.turns_counter
	kletka_config["Color"]=Globals.self_field_color
	
	if not (amount_to_manipulate and range_of_manipulatons and kletka_config):
		push_error("Bad field manipulation config=",buff_config)
		return
	for i in range(amount_kletki+1):
		var type=await choose_between_two("Choose manipulation type","Capture", "Manipulate")
		
		if type=="Capture":
			var kletki=get_unoccupied_kletki()
			choose_glowing_cletka_by_ids_array(kletki)
			var kletka_to_capture=await glow_kletka_pressed_signal
			rpc("capture_single_kletka_sync",kletka_to_capture,kletka_config)
		else:
			var kletki=get_unoccupied_kletki()
			choose_glowing_cletka_by_ids_array(kletki)
			var kletka_to_capture=await glow_kletka_pressed_signal
			kletka_config["Blocked"]=true
			kletka_config["Color"]=Color.FUCHSIA
			rpc("capture_single_kletka_sync",kletka_to_capture,kletka_config)
		
	return true

signal choose_between_two_client_answer(answer)

func await_choose_between_two_from_pu_id(pu_id:String,question:String,first:String,second:String)->String:
	var peer_id=Globals.pu_id_player_info[pu_id]["current_peer_id"]
	rpc_id(peer_id,"choose_between_two",question,first,second)

	var answer=await choose_between_two_client_answer
	return answer


@rpc("any_peer","call_local","reliable")
func send_choose_between_two_answer_to_host(answer:String)->void:
	await sleep(0.1)
	choose_between_two_client_answer.emit(answer)
	pass


@rpc("authority","call_local","reliable")
func choose_between_two(question:String,first:String,second:String)->String:
	var out:String
	
	info_but_choose_1.text=first
	info_but_choose_2.text=second
	info_label.text=question

	info_but_choose_1.pressed.connect(info_but_choose.bind(first))
	info_but_choose_2.pressed.connect(info_but_choose.bind(second))
	disable_every_button()
	custom_main_VBoxContainer.visible=true
	info_but_choose_1.visible=true
	info_but_choose_2.visible=true
	info_label_panel.visible=true
	info_ok_button.visible=false
	
	out=await choose_two
	custom_main_VBoxContainer.visible=false
	info_but_choose_1.visible=false
	info_but_choose_2.visible=false
	info_label_panel.visible=false
	disable_every_button(false)
	info_but_choose_1.pressed.disconnect(info_but_choose.bind(first))
	info_but_choose_2.pressed.disconnect(info_but_choose.bind(second))

	#rpc_id(1,"send_choose_between_two_answer_to_host",out)

	return out

func info_but_choose(choose_local:String):
	choose_two.emit(choose_local)


func capture_field_kletki(amount,config_of_kletka,owner_char_info:CharInfo):
	
	print("capture_field_kletki, pu_id="+str(Globals.self_pu_id))
	print("amount=="+str(amount))
	
	var available_to_capture=[]
	config_of_kletka_to_capture=config_of_kletka
	current_action="field capture"
	
	
	#var owner_pu_id=config_of_kletka["Owner"]
	
	#print("connected="+str(connected))
	temp_kletka_capture_config=config_of_kletka
	
	temp_kletka_capture_config.merge({"turn_casted":players_handler.turns_counter})
	
	
	#var owner_char_info=temp_kletka_capture_config["Owner"]
	var owner_uniq_id=owner_char_info.get_uniq_id()
	temp_kletka_capture_config["Owner"]=owner_uniq_id



	print("owner_uniq_id=",owner_uniq_id)
	#var owner_char_info=players_handler.get_charInfo_from_pu_id_unit_id(own_pu,own_uni_id)


	if !unit_uniq_id_to_kletki_ids_owned.has(owner_uniq_id):
		unit_uniq_id_to_kletki_ids_owned[owner_uniq_id]=[]
	



	temp_kletka_capture_config["Color"]=Globals.self_field_color
	if unit_uniq_id_to_kletki_ids_owned[owner_uniq_id]==[]:
		unit_uniq_id_to_kletki_ids_owned[owner_uniq_id]=[char_info_to_kletka_number(owner_char_info)]
		rpc("sync_owned_kletki",unit_uniq_id_to_kletki_ids_owned)
		rpc("capture_single_kletka_sync", char_info_to_kletka_number(owner_char_info),temp_kletka_capture_config)
	else:
		unit_uniq_id_to_kletki_ids_owned[owner_uniq_id]+=[char_info_to_kletka_number(owner_char_info)]
		
		
	print(str("unit_uniq_id_to_kletki_ids_owned=",unit_uniq_id_to_kletki_ids_owned))
	var to_glow_depends_on_owned=[]
	for amount_to_capture in range(amount):
		for klettka in unit_uniq_id_to_kletki_ids_owned[owner_uniq_id]:
			to_glow_depends_on_owned+=connected[klettka].keys()
			
		print(str("to_glow_depends_on_owned=",to_glow_depends_on_owned))
		for klekta_number in to_glow_depends_on_owned:
			if not kletka_preference[klekta_number].is_empty():
				continue
			available_to_capture.append(int(glow_array[klekta_number].name.trim_prefix("glow ")))#.visible=true
		available_to_capture=array_unique(available_to_capture)
		for already_captured_kletki in unit_uniq_id_to_kletki_ids_owned[owner_uniq_id]:
			available_to_capture.erase(already_captured_kletki)
		print("available_to_capture="+str(available_to_capture))
		choose_glowing_cletka_by_ids_array(array_unique(available_to_capture))
		await klekta_captured
		available_to_capture=[]
		to_glow_depends_on_owned=[]
		print(str("unit_uniq_id_to_kletki_ids_owned=",unit_uniq_id_to_kletki_ids_owned))
	pass
	
	current_action="wait"
	return true

var kletka_to_add:Node2D
signal new_cell_created

var temp_lines_to_draw:Array=[]

func create_new_cell(single_skill_info:Dictionary):
	#var amount=single_skill_info.get("Amount",1)
	var cell_config=single_skill_info.get("Config",{})


	
	for i in range(2):
		var line = LINE_BETWEEN_CELLS.instantiate()
		lines_holder.add_child(line,true)
		line.width = 3
		line.z_index=-1
		line.default_color = Color.WHITE
		temp_lines_to_draw.append(line)

	#cell_config["Owner"]=get_current_self_char_info().get_uniq_id()
	
	var new_id=connected.size()
	kletka_to_add=cell_scene.instantiate()
	kletki_holder.add_child(kletka_to_add,true)

	kletka_to_add.name="cell "+str(new_id)

	current_action="create_new_cell"
	
	var lines_points_array:Array=[]

	
	
	await new_cell_created

	for line in temp_lines_to_draw:
		lines_points_array.append([line.get_point_position(0),line.get_point_position(1)])

	rpc("create_new_cell_sync",kletka_to_add.position,cell_config,new_id,lines_points_array)
	kletka_preference[new_id]=cell_config
	

	
	
	#connecting kletki
	var kletki_ids_to_connect_to=get_neareset_cells_to_cell_position(kletka_to_add.position,2)
	print("new_id="+str(new_id)+" kletki_ids_to_connect_to="+str(kletki_ids_to_connect_to), "connected="+str(connected))
	connected[new_id]={}
	cell_positions[new_id]=kletka_to_add.position
	
	for kletka_id in kletki_ids_to_connect_to:
		connected[new_id][kletka_id]=true
		connected[kletka_id][new_id]=true

	print("new_id after="+str(new_id)+" kletki_ids_to_connect_to="+str(kletki_ids_to_connect_to), "connected="+str(connected))
	
	#adding glow kletka
	add_glow_kletka_to_kletka_id(new_id)

	
	return true

@rpc("any_peer","call_remote","reliable")
func create_new_cell_sync(new_position:Vector2,cell_config:Dictionary,new_id:int,lines_cords_to_draw:Array):
	var kletka_to_add=cell_scene.instantiate()
	kletki_holder.add_child(kletka_to_add,true)
	kletka_to_add.position=new_position

	for line_cords in lines_cords_to_draw:
		var new_line=Line2D.new()
		new_line.add_point(line_cords[0])
		new_line.add_point(line_cords[1])


		new_line.width = 3
		new_line.z_index=-1
		new_line.default_color = Color.WHITE

		lines_holder.add_child(new_line,true)

	kletka_preference[new_id]=cell_config
	connected[new_id]={}
	
	var kletki_ids_to_connect_to=get_neareset_cells_to_cell_position(kletka_to_add.position,2)
	print("new_id="+str(new_id)+" kletki_ids_to_connect_to="+str(kletki_ids_to_connect_to), "connected="+str(connected))
	cell_positions[new_id]=kletka_to_add.position
	
	for kletka_id in kletki_ids_to_connect_to:
		connected[new_id][kletka_id]=true
		connected[kletka_id][new_id]=true
	
	#adding glow kletka
	add_glow_kletka_to_kletka_id(new_id)

	

	rpc("systemlog_message",str("New cell created at ",new_position))


func get_neareset_cells_to_cell_position(cell_position:Vector2, number_of_cells:int)->Array:
	var nearest_cells:Array = []
	var cell_distances:Dictionary = {}
	
	# Calculate distances from the given position to all cells
	for kletka_id in cell_positions.keys():
		var dist = cell_positions[kletka_id].distance_to(cell_position)
		cell_distances[kletka_id] = dist
	
	# Sort the cell IDs by their distances
	var sorted_keys = cell_distances.keys()
	sorted_keys.sort_custom(func(a, b):
		return cell_distances[a] < cell_distances[b]
	)

	for i in range(min(number_of_cells, sorted_keys.size())):
		nearest_cells.append(sorted_keys[i])
	
	return nearest_cells


func _process(_delta):
	if current_action=="create_new_cell":
		var mouse_pos = get_global_mouse_position()
		kletka_to_add.position=mouse_pos
		var kletki_ids_to_draw_temp_lines_to=get_neareset_cells_to_cell_position(mouse_pos,2)

		temp_lines_to_draw[0].clear_points()
		temp_lines_to_draw[1].clear_points()


		temp_lines_to_draw[0].add_point(mouse_pos,0)
		temp_lines_to_draw[1].add_point(mouse_pos,0)
		
		temp_lines_to_draw[0].add_point(cell_positions[kletki_ids_to_draw_temp_lines_to[0]],1)
		temp_lines_to_draw[1].add_point(cell_positions[kletki_ids_to_draw_temp_lines_to[1]],1)

	pass

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if OS.has_feature("editor"):
				disconnect_button.visible=true
				reconnect_button.visible=true
			if check_if_hidable_gui_windows_active():
				hide_all_gui_windows("all")
			#if current_action!="wait" and current_action!="Create New Field Cell":
			#	current_action="wait"
			#	blinking_glow_button=false
			#	glow_cletki_node.visible=false
		if event.keycode == KEY_TAB and event.pressed:
			%advanced_logs_textedit.visible=!%advanced_logs_textedit.visible
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pass
			#if current_action=="create_new_cell":
			#	current_action="wait"
			#	kletka_to_add.position=kletka_to_add.position#.snapped(Vector2(64,64))#+Vector2(32,32)
			#	temp_lines_to_draw[0].points=temp_lines_to_draw[0].points
			#	temp_lines_to_draw[1].points=temp_lines_to_draw[1].points
#
			#	new_cell_created.emit()

func line_attack_phantasm(phantasm_config,dash:bool=false):
	
	var amount=phantasm_config["Range"]
	var already_clicked=[]
	var temp_current_kletka=get_current_kletka_id()
	var move_ck=[]
	var attacked_enemies=[]
	var phantasm_damage=phantasm_config["Damage"]
	current_action="wait"
	for count in range(amount):
		print("get_current_kletka_id()="+str(temp_current_kletka)+" connected[get_current_kletka_id()]="+str(connected[temp_current_kletka]))
		for i in connected[temp_current_kletka]:
			if already_clicked.has(i) or i==get_current_kletka_id():
				continue
			move_ck.append(int(glow_array[i].name.trim_prefix("glow ")))#.visible=true
		pass
		print("move_ck="+str(move_ck))
		if !move_ck.size()<=0:
			choose_glowing_cletka_by_ids_array(move_ck)
			await glow_kletka_pressed_signal
		#current_action="wait"
		move_ck=[]
		print("cr-klet="+str(temp_current_kletka))
		temp_current_kletka=glowing_kletka_number_selected
		already_clicked.append(temp_current_kletka)
		rpc("line_attack_add_remove_kletka_number",glowing_kletka_number_selected,"add")
	
	if dash:
		var last_kletka=already_clicked[-1]
		var kletka_to_dash=find_nearest_free_cell(last_kletka)
		var kletki_to_dash_array=already_clicked.duplicate(true)
		kletki_to_dash_array[-1]=kletka_to_dash
		var temp_kletka_id=get_current_kletka_id()
		if kletka_to_dash==-1:
			pass#no available kletki nearly impossible
		else:
			for kletka in kletki_to_dash_array:
				rpc("move_player_from_kletka_id1_to_id2",get_current_self_char_info(),temp_kletka_id,kletka,false,true)
				await get_tree().create_timer(0.5).timeout
				temp_kletka_id=kletka
			await get_tree().create_timer(2).timeout
			print("get_current_kletka_id()=",get_current_kletka_id()," kletka_to_dash=",kletka_to_dash)
			rpc("move_player_from_kletka_id1_to_id2",get_current_self_char_info(),get_current_kletka_id(),kletka_to_dash)


	await await_dice_including_rerolls("Attack")
	await hide_dice_rolls_with_timeout(1)
	
	for kletka in already_clicked:
		if kletka in occupied_kletki.keys():
			var uniq_ids_on_kletka=[]
			for node in occupied_kletki[kletka]:
				uniq_ids_on_kletka.append(node.uniq_id)

			# if self char uniq id is on this kletka
			if players_handler.intersect(uniq_ids_on_kletka,[get_current_self_char_info().get_uniq_id()]):
				rpc("line_attack_add_remove_kletka_number",kletka,"remove")
				await get_tree().create_timer(1).timeout
				continue
			var etmp=await attack_player_on_kletka_id(kletka,"Phantasm",false,phantasm_config)
			if typeof(etmp)==TYPE_STRING:
				if etmp=="ERROR":
					continue
			attacked_enemies.append(etmp)
			if phantasm_config.has("effect_on_success_attack"):
				if attack_responce_string!="evaded" or attack_responce_string!="parried":
					players_handler.use_skill(phantasm_config["effect_on_success_attack"])
			
		rpc("line_attack_add_remove_kletka_number",kletka,"remove")
		await get_tree().create_timer(1).timeout
	#hide_dice_rolls_with_timeout(4)
	

	return attacked_enemies

@rpc("any_peer","call_local","reliable")
func line_attack_add_remove_kletka_number(number,add_or_remove="add"):
	match add_or_remove:
		"add":
			var captur_klet=Node2D.new()
			var pos = cell_positions[int(number)]
			captur_klet.position = pos
			captur_klet.name="attack "+str(number)
			captur_klet.set_script(CapturedKletkaScript)
			captur_klet.color=Color.DARK_RED
			captured_kletki_node.add_child(captur_klet,true)
			captured_kletki_nodes_dict[number]=captur_klet
			
		"remove":
			for node in get_all_children(self):
				if node.name.contains("attack "+str(number)):
					captured_kletki_node.remove_child(node)
	
	#return captur_klet


func find_nearest_free_cell(start_id)->int:
	var visited = {}
	var queue = []
	queue.append(start_id)
	visited[start_id] = true

	while not queue.is_empty():
		var current = queue.pop_front()

		if not kletka_id_to_char_info.has(current):
			return current

		for neighbor in connected.get(current, {}).keys():
			if not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)

	return -1




func _on_make_action_pressed():
	action_button_items.visible=true
	blinking_glow_button=false
	glow_cletki_node.visible=false
	
	var char_info = fsm.current_char_info
	var cur_node=char_info.get_node()
	var skills_enabledd=true
	var attack_enabledd=true
	var phantasm_enabledd=true

	var mounting_something=false
	if cur_node.summon_check:
		skills_enabledd = cur_node.skills_enabled
		attack_enabledd = cur_node.can_attack
		phantasm_enabledd = cur_node.can_use_phantasm

	mounting_something=cur_node.mounts_uniq_id_array!=[]
	
	print(str("players_handler.unit_unique_id_to_items_owned=",players_handler.unit_unique_id_to_items_owned))

	if players_handler.unit_unique_id_to_items_owned[char_info.get_uniq_id()].is_empty():
		action_button_items.visible=false
	else:
		#{ "Name": &"Heal Potion", "Effect": [{ "Name": "Heal", "Power": 5 }] }
		print("players_handler.unit_unique_id_to_items_owned[char_info.get_uniq_id()]="+str(players_handler.unit_unique_id_to_items_owned[char_info.get_uniq_id()]))
	var max_hit= players_handler.char_info_has_active_buff(char_info,"Maximum Hits Per Turn")
	
	var maximum_skills=players_handler.char_info_has_active_buff(char_info,"Maximum Skills Per Turn")


	if maximum_skills:
		var used_skills_this_turn=players_handler.unit_uniq_id_player_game_stat_info[char_info.get_uniq_id()]["skill_used_this_turn"]
		if used_skills_this_turn>=maximum_skills["Power"]:
			action_button_skill.disabled=true
			print("max skills reached")
		else:
			action_button_skill.disabled=false
			print("max skills not reached")
	else:
		action_button_skill.disabled=false

	action_button_unmount.visible=mounting_something


	print("\nmax_hit="+str(max_hit or false))
	if max_hit:
		
		print("\n\nmax hit is true")
		print(max_hit)
		var attacked_this_turn=players_handler.unit_uniq_id_player_game_stat_info[char_info.get_uniq_id()]["attacked_this_turn"]
		print("attacked_this_turn="+str(attacked_this_turn))
		
		if attacked_this_turn>=max_hit["Power"]:
			action_button_attack.disabled=true
			print("max hit reached")
		else:
			action_button_attack.disabled=false
			print("max hit not reached")
	else:
		action_button_attack.disabled=false
	

	if not skills_enabledd:
		action_button_skill.disabled=true
		print("summon can't use skills")
	
	if not attack_enabledd:
		action_button_attack.disabled=true
		print("summon can't attack")
	
	if not phantasm_enabledd:
		action_button_phantasm.disabled=true
		print("summon can't use phantasm")
		
	
	hide_all_gui_windows("actions_buttons")
	#actions_buttons.visible=!actions_buttons.visible
	pass # Replace with function body.

@rpc("any_peer","call_local","reliable")
func on_end_turn_pressed_by_pu_id(pu_id:String):
	if not multiplayer.is_server(): return
	
	fsm.change_state_for_pu_ud(pu_id,"EndTurnState",{})

func _on_end_turn_pressed():
	#print_debug("_on_end_turn_pressed, pu_id=",get_current_self_char_info())
	

	rpc_id(1,"on_end_turn_pressed_by_pu_id",Globals.self_pu_id)
	
	
	
	pass # Replace with function body.


func _on_skill_pressed():
	#print(occupied_kletki)
	_on_skill_info_show_button_pressed()
	pass # Replace with function body.


func _on_chat_send_button_pressed():
	if message_line_edit.text=="":
		return
	rpc("get_message",Globals.nickname,message_line_edit.text)
	message_line_edit.text=""

@rpc("any_peer","call_local","reliable")
func systemlog_message(message):
	chat_log_main.text+=str(message, "\n")
	#chat_log_main.scroll_vertical = INF
	chat_log_main.set_deferred("scroll_vertical", INF)

@rpc("any_peer","call_local","reliable")
func get_message(username,message):
	chat_log_main.text+=str(username, ": ", message, "\n")
	chat_log_main.set_deferred("scroll_vertical", INF)


func _on_chat_hide_show_button_pressed():
	if chat_log_container.visible:
		chat_log_container.visible=false
	else:
		chat_log_container.visible=true
	pass # Replace with function body.

@rpc("authority","call_local","reliable")
func fill_are_you_sure_screen(text:String=""):
	are_you_sure_label.text=tr("ARE_YOU_SURE_YOU_WANT_TO_QUESTION").format({"action":text})
	are_you_sure_main_container.visible=true

func _on_im_sure_button_pressed():
	are_you_sure_main_container.visible=false
	%ConfirmAction.answer_button_pressed_agreed.emit(true)
	#are_you_sure_result="yes"
	#are_you_sure_signal.emit()
	#rpc_id(1,"send_are_you_sure_answer_to_host","ARE_YOU_SURE_AGREEMENT")
	#emit_signal("are_you_sure_signal", tr("ARE_YOU_SURE_AGREEMENT"))
	
	pass # Replace with function body.


func _on_im_not_sure_button_pressed():
	are_you_sure_main_container.visible=false
	#are_you_sure_result="no"
	%ConfirmAction.answer_button_pressed_agreed.emit(false)
	#rpc_id(1,"send_are_you_sure_answer_to_host","ARE_YOU_SURE_DISAGREEMENT")
	#emit_signal("are_you_sure_signal", tr("ARE_YOU_SURE_DISAGREEMENT"))
	#are_you_sure_signal.emit()
	
	pass # Replace with function body.


func _on_dices_toggle_button_pressed():
	#var vis=roll_dice_control_container.visible
	dices_main_VBoxContainer.visible= !dices_main_VBoxContainer.visible
	#for pu_id in Globals.pu_id_player_info.keys():
		#print(Globals.pu_id_player_info[pu_id]["servant_node"].buffs)
	pass # Replace with function body.


func _on_skill_info_show_button_pressed():
	_on_skill_info_tab_container_tab_changed(-1)
	players_handler.show_skill_info_tab()
	var a='''	if skill_info_tab_container.visible:
		skill_info_tab_container.visible=false
		use_skill_button.visible=false
	else:
		skill_info_tab_container.visible=true
		use_skill_button.visible=true
	'''
	hide_all_gui_windows("skill_info_tab_container")
	pass # Replace with function body.

func check_if_hidable_gui_windows_active()->bool:
	var dictio=gui_windows_dictionary
	for key in dictio:
		for item in dictio[key]:
			if item.visible:
				return true
	return false

@rpc("authority","call_local","reliable")
func set_pu_id_gui_node_uniq_name_visibility(_pu_id,node_uniq_name,visible_new):

	gui.get_node(node_uniq_name).visiblily=visible_new

	pass


func hide_all_gui_windows(except_name="all"):
	if except_name!="servant_info_main_container":
		players_handler.player_info_button_current_pu_id=""
	print("hide_all_gui_windows= "+str(except_name))
	var dictio=gui_windows_dictionary
	
	var did_changed=false
	for key in dictio:
		if key==except_name:
			did_changed=true
			for item in dictio[key]:
				item.visible=!item.visible
		else:
			for item in dictio[key]:
				item.visible=false
	if not did_changed and except_name!="all":
		push_error("wrong hide_all_gui_windows=",except_name)

func _on_self_info_show_button_pressed():
	players_handler.servant_info_from_pu_id(Globals.self_pu_id)
	players_handler.player_info_button_current_pu_id=Globals.self_pu_id
	hide_all_gui_windows("servant_info_main_container")
	#players_handler.servant_info_main_container.visible= !players_handler.servant_info_main_container.visible
	

	pass # Replace with function body.


func _on_weapon_change_tab_changed(_tab):
	_on_skill_info_tab_container_tab_changed()

func _on_class_skill_tab_changed(_tab):
	_on_skill_info_tab_container_tab_changed()

func _on_skill_info_tab_container_tab_changed(tab=-1):
	if tab==-1:
		tab=skill_info_tab_container.current_tab
	use_skill_button.disabled=true

	var self_char_info = fsm.current_char_info
	var self_servant_node = self_char_info.get_node()

	var skills_available=true
	var servant_skills:Dictionary=self_char_info.get_node().skills
	var skill_info={}

	var skills_blocked=false

	var is_skill_free_from_actions=false
	if !my_turn:
		skills_available=false
	for buff in self_servant_node.buffs:
		if buff["Name"]=="Skill Seal":
			skills_blocked=true
			break



	var maximum_skills=players_handler.char_info_has_active_buff(self_char_info,"Maximum Skills Per Turn")

	if maximum_skills:
		var used_skills_this_turn=players_handler.unit_uniq_id_player_game_stat_info[self_char_info.get_uniq_id()]["skill_used_this_turn"]
		print("used_skills_this_turn=",used_skills_this_turn," =maximum_skills['Power']=",maximum_skills["Power"])
		if used_skills_this_turn>=maximum_skills["Power"]:
			skills_available=false
			print("max skills reached")
		else:
			skills_available=true
			print("max skills not reached")
	var skill_cooldown=0

	print("_on_skill_info_tab_container_tab_changed tab="+str(tab))
	match tab:
		0:
			skill_cooldown=self_servant_node.skill_cooldowns[0]
			skill_info=servant_skills.get("First Skill")
		1:
			skill_cooldown=self_servant_node.skill_cooldowns[1]
			skill_info=servant_skills.get("Second Skill")
		2:
			skill_cooldown=self_servant_node.skill_cooldowns[2]
			skill_info=servant_skills.get("Third Skill")
		3:
			var class_skill_number=skill_info_tab_container.get_current_tab_control().current_tab+1

			print("_on_skill_info_tab_container_tab_changed class_skill_number="+str(class_skill_number))
			
			skill_info=servant_skills.get("Class Skill "+str(class_skill_number),{})
			if skill_info.is_empty():
				skills_available=false
			else:
				if skill_info["Type"]=="Weapon Change":
					print("Weapon Change on tab changed")
					if skill_info.get("free_unequip",false):
						print("free_unequip on tab changed")
						var weapon_name_to_change_to=skill_info_tab_container.get_current_tab_control().get_current_tab_control().get_current_tab_control().name
						print('skill_info["weapons"].keys()[0]='+str(skill_info["weapons"].keys()[0]))
						if skill_info["weapons"].keys()[0]==weapon_name_to_change_to:
							print("set_cooldown false on tab changed")
							skill_cooldown=0
						else:
							skill_cooldown=self_servant_node.skill_cooldowns[2+class_skill_number]
					else:
						skill_cooldown=self_servant_node.skill_cooldowns[2+class_skill_number]
				else:
					skill_cooldown=self_servant_node.skill_cooldowns[2+class_skill_number]
	
	if not skill_info.get("Consume Action",true):
		is_skill_free_from_actions=true

	var self_action_points = Globals.pu_id_to_action_points[Globals.self_pu_id]
	if (skill_cooldown==0) and (self_action_points>0 or is_skill_free_from_actions) and skills_available and not skills_blocked:
		use_skill_button.disabled=false
	else:
		print("Skills blocked")
		print("skill_cooldown==0 true or false: "+str(skill_cooldown==0))
		print("current_action_points>0 true or false = "+str(self_action_points>0))
		print("skills_available="+str(skills_available))
		
	current_skill_cooldown_label.text=str("Cooldown: ",skill_cooldown)
	pass # Replace with function body.


func _on_refresh_buffs_button_pressed():
	var self_servant_node = fsm.current_char_info.get_node()

	var buffs=self_servant_node.buffs
	var display_buffs=""
	
	var buff_duration
	for buff in buffs:
		buff_duration=buff.get("Duration","-")
		if buff.has("Display Name"):
			display_buffs+=str(buff["Display Name"],"(",buff_duration,")\n")
		else:
			display_buffs+=str(buff["Name"],"(",buff_duration,")\n")
		
	$GUI/buffs_temp_container/buffs_label.text="Buffs:"+display_buffs
	pass # Replace with function body.


func _on_command_spells_button_pressed():
	if players_handler.pu_id_to_command_spells_int[Globals.self_pu_id]<=0:
		return
	hide_all_gui_windows("command_spells")
	
	pass # Replace with function body.

@rpc("any_peer","call_local","reliable")
func pu_id_used_command_spell(pu_id:String,command_spell_action_name:String):
	var char_info=get_current_char_info_for_pu_id(pu_id)

	if players_handler.char_info_has_active_buff(char_info,"Code Cast"):
		pass
		#TODO
		#remake after skills refactored
		return
	
	use_command_spell_action_to_char_info(pu_id,char_info,command_spell_action_name)

func use_command_spell_action_to_char_info(pu_id_using_command_spell:String, char_info_to_cast_to:CharInfo, command_spell_action_name:String):
	match command_spell_action_name:
		"Heal":
			players_handler.heal_char_info(char_info_to_cast_to,0,"command_spell")
		"NP Charge":
			players_handler.charge_np_to_char_info_by_number(char_info_to_cast_to.to_dictionary(),6,"command_spell")
		"Add Moves":
			players_handler.reduce_additional_moves_for_char_info(char_info_to_cast_to.to_dictionary(),-3)
		"Transfer":
			_on_command_spell_transfer_button_pressed()
	
	players_handler.reduce_command_spell_on_pu_id(pu_id_using_command_spell)

func _on_command_spell_heal_button_pressed():
	hide_all_gui_windows("command_spells")
	#var char_info_to_cast_to=get_current_self_char_info()
	#if players_handler.char_info_has_active_buff(get_current_self_char_info(),"Code Cast"):
	#	char_info_to_cast_to=await players_handler.choose_allie()
	#	char_info_to_cast_to=char_info_to_cast_to[0]
	
	rpc_id(1,"pu_id_used_command_spell",Globals.self_pu_id,"Heal")


func _on_command_spell_np_charge_button_pressed():
	hide_all_gui_windows("command_spells")

	rpc_id(1,"pu_id_used_command_spell",Globals.self_pu_id,"NP Charge")


func _on_command_spell_add_moves_button_pressed():
	hide_all_gui_windows("command_spells")

	rpc_id(1,"pu_id_used_command_spell",Globals.self_pu_id,"Add Moves")


func _on_command_spell_transfer_button_pressed():
	hide_all_gui_windows("command_spells")

	#TODO
	#remake after skills refactored

	info_table_show(tr("CHOOSE_PLAYER_TO_TRANSFER_COMMAND_SPELL"))
	await info_ok_button.pressed
	var pu_id_to_cast_to=await players_handler.choose_single_in_range(999)
	pu_id_to_cast_to=pu_id_to_cast_to[0]

	if players_handler.pu_id_to_command_spells_int[pu_id_to_cast_to]>=3:
		info_table_show(tr("FAILED_TO_TRANSFER_COMMAND_SPELL_TO_MANY"))
		await info_ok_button.pressed
		return
	players_handler.rpc("reduce_command_spell_on_pu_id",pu_id_to_cast_to,-1)
	players_handler.reduce_command_spell_on_pu_id(pu_id_to_cast_to,-1)
	players_handler.rpc("reduce_command_spell_on_pu_id",Globals.self_pu_id)
	players_handler.reduce_command_spell_on_pu_id(Globals.self_pu_id)
	
	pass # Replace with function body.


func get_players_array_sorted_by_points():
	var points=[]
	var pu_id_to_points={}
	var stat_dic=players_handler.unit_uniq_id_player_game_stat_info
	for pu_id in Globals.pu_id_player_info.keys():
		pu_id_to_points[pu_id]=0
		for stat in stat_dic[pu_id].keys():
			match stat:
				"total_kletki_moved":
					pu_id_to_points[pu_id]+=stat_dic[pu_id][stat]
				"total_success_hit":
					pu_id_to_points[pu_id]+=stat_dic[pu_id][stat]*2
				"total_crit_hit":
					pu_id_to_points[pu_id]+=stat_dic[pu_id][stat]*2
				"total_skill_used":
					pu_id_to_points[pu_id]+=stat_dic[pu_id][stat]
		points.append(points)
	points.sort()
	pass

@rpc("any_peer","reliable","call_local")
func generate_ending():
	$GUI.visible=false
	var players_ar=[]
	for pu_id in Globals.pu_id_player_info.keys():
		players_ar.append(Globals.pu_id_player_info[pu_id]["servant_node"])
	
	reset_pole(1,false)
	$finish_screen.do_the_thing(players_ar)
	
	
func _on_finish_button_pressed():
	rpc("generate_ending")
	
	pass # Replace with function body.





func _on_show_buffs_advanced_way_button_toggled(toggled_on):
	players_handler.servant_info_from_pu_id(players_handler.player_info_button_current_pu_id,toggled_on)
	pass # Replace with function body.

func disconnect_alert_show(pu_id:String,peer_disconnected:bool,disconnect_names:String=""):
	#print("\n\ndisconnect_alert_show_ ",peer_connected)
	#disable_every_button(not peer_connected)
	print("\ndisconnect_alert_show=",pu_id," ",peer_disconnected)
	#peer_disconnected=!peer_disconnected
	if pu_id==awaiting_responce_from_pu_id and peer_disconnected:
		attack_response.emit("Disconnect")
		if disconnect_names=="":
			%disconnect_alert_label.text="Someone disconnected\nawaiting reconnection"
		else:
			%disconnect_alert_label.text=disconnect_names

	%disconnect_alert_panel.visible=peer_disconnected


func char_info_to_kletka_number(char_info:CharInfo)->int:
	var node_name=char_info.get_node().name

	for kletka_id in kletka_id_to_char_info.keys():
		for _char_info in kletka_id_to_char_info[kletka_id]:
			if _char_info.get_node().name==node_name:
				return kletka_id
	
	push_error("no kletka found for char_info=",char_info.to_dictionary())

	return -2


func _on_disconnect_button_pressed():
	Globals.disconnection_request.emit()
	pass # Replace with function body.


func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_reconnect_button_pressed():
	Globals.reconnect_requested.emit()
	pass # Replace with function body.



func _on_cheats_show_button_pressed():
	%debug_character_control.visible=!%debug_character_control.visible
	pass # Replace with function body.


func _on_kletki_multiplayer_spawner_spawned(node: Node) -> void:
	var cell_number=int(node.name.trim_prefix("cell "))
	cell_positions[cell_number]=node.position
	pass # Replace with function body.


func _on_glow_kletki_multiplayer_spawner_spawned(node: Node) -> void:
	node.get_child(0).button_down.connect(glow_cletka_pressed.bind(node))
	var glow_nubmer=int(node.name.trim_prefix("glow "))
	glow_array[glow_nubmer]=node
	pass # Replace with function body.


func _on_captured_kletki_multiplayer_spawner_spawned(node: Node) -> void:
	var captured_kletka_number_selected=int(node.name.trim_prefix("field "))
	captured_kletki_nodes_dict[captured_kletka_number_selected]=node
	pass # Replace with function body.
