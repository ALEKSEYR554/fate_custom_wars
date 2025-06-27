extends Node2D
#1717486472.816
#1717743283.689
var glow_array=[]
const Glow = preload("res://сцены/glow.tscn")
var time
var glowing_kletka_number_selected
var is_game_started=false
@onready var players_handler = $players_handler
var is_pole_generated=false
@onready var character_selection_container = $GUI/character_selection_container

@onready var char_select:Control = $GUI/character_selection_container/Char_select
@onready var alert_label = $GUI/alert_label

var glow_cletki_node
var captured_kletki_node=null
var captured_kletki_nodes_dict={}
var kletki_holder
var lines_holder



signal choose_two(choose:String)
#signal info_ok_button_clicked

# kletka: who is there node2d
#{ 6: el_melloy:<Node2D#62159586689>, 25: bunyan:<Node2D#61807265149>}
var occupied_kletki={}
var pu_id_to_kletka_number={}
#kletka_preference[cletka_id]=config
var kletka_preference={}
#peer_id:[cletka_id,kletka_id]
var kletka_owned_by_pu_id={}
var self_player_node
var enemy_to_pull
var temp_kletka_capture_config

@onready var you_were_attacked_container = $GUI/You_were_attacked_container
@onready var you_were_attacked_label = $GUI/You_were_attacked_container/You_were_attacked_label
@onready var evade_button = $GUI/You_were_attacked_container/HBoxContainer/Evade_button
@onready var defence_button = $GUI/You_were_attacked_container/HBoxContainer/Defence_button
@onready var parry_button = $GUI/You_were_attacked_container/HBoxContainer/Parry_button
@onready var phantasm_evade_button = $GUI/You_were_attacked_container/HBoxContainer/Phantasm_evation_button



@onready var chat_hide_show_button = $GUI/Chat_hide_show_button
@onready var message_line_edit = $GUI/ChatLog_container/HBoxContainer/Message_LineEdit
@onready var chat_log_container = $GUI/ChatLog_container
@onready var chat_log_main = $GUI/ChatLog_container/ChatLog_main


var current_action
var current_action_points
var paralyzed=false
var current_kletka

var my_turn=false
@onready var info_label_panel = $GUI/info_label_panel
@onready var info_ok_button = $GUI/info_ok_button
@onready var info_label = $GUI/info_label_panel/info_label

signal movement_finished

var current_open_window=""

@onready var main_label_dont_touch = $GUI/Current_roll_container/Current_roll_marg_conta/Current_roll_vbox/Main_label_dont_touch
@onready var attack_label = $GUI/Current_roll_container/Current_roll_marg_conta/Current_roll_vbox/Attack_label
@onready var crit_label = $GUI/Current_roll_container/Current_roll_marg_conta/Current_roll_vbox/Crit_label
@onready var defence_label = $GUI/Current_roll_container/Current_roll_marg_conta/Current_roll_vbox/Defence_label

var damage_type="physical"#"magic"
var recieved_damage_type="physical"
var recieved_phantasm_config={}

@onready var type_of_damage_choose_buttons_box = $GUI/type_of_damage_choose_buttons_box
@onready var regular_damage_button = $GUI/type_of_damage_choose_buttons_box/regular_damage_button
@onready var magical_damage_button = $GUI/type_of_damage_choose_buttons_box/magical_damage_button


@onready var reset_button = $GUI/host_buttons/reset
@onready var start_button = $GUI/host_buttons/start

var dice_roll_result_list:Dictionary={"main_dice":0,"crit_dice":0,"defence_dice":0,"additional_d6":0,"additional_d6_2":0,"additional_d100":0}
var recieved_dice_roll_result
var attacking_player_on_kletka_id
var attacking_pu_id


const CapturedKletkaScript = preload("res://скрипты/captured_kletka_script.gd")
signal glow_kletka_pressed_signal(kletka_id:int)
var blocked_previous_iteration=[]

var blinking_glow_button
var blink_timer_node

var done_blinking=false
signal done_blinking_signal

const cell_scene = preload("res://сцены/клетка.tscn")

var pole_generated_seed

@onready var menu_vbox_container = $GUI/menu_vbox_container
@onready var disconnect_button = $GUI/menu_vbox_container/disconnect_Button
@onready var settings_button = $GUI/menu_vbox_container/settings_button



@onready var actions_buttons = $GUI/actions_buttons

@onready var current_action_points_label = $GUI/action/current_actions
@onready var make_action_button = $GUI/make_action
@onready var items_button = $GUI/actions_buttons/Items


@onready var are_you_sure_main_container = $GUI/are_you_sure_main_container
@onready var are_you_sure_label = $GUI/are_you_sure_main_container/are_you_sure_label
@onready var im_sure_button = $GUI/are_you_sure_main_container/are_you_sure_buttons_container/im_sure_button

signal are_you_sure_signal(result:String)
@onready var info_but_choose_1 = $GUI/info_but_choose_1
@onready var info_but_choose_2 = $GUI/info_but_choose_2

@onready var im_not_sure_button = $GUI/are_you_sure_main_container/are_you_sure_buttons_container/im_not_sure_button

#var are_you_sure_result#"yes","no"

#@onready var dice_holder_hbox = $GUI/dice_holder_node2d
#@onready var main_dice_node = $GUI/dice_holder_node2d/main_dice
#@onready var crit_dice_node = $GUI/dice_holder_node2d/crit_dice
#@onready var defence_dice_node = $GUI/dice_holder_node2d/defence_dice


@onready var dice_holder_hbox = $GUI/dice_holder_hbox
@onready var main_dice_node = $GUI/dice_holder_hbox/main_dice
@onready var crit_dice_node = $GUI/dice_holder_hbox/crit_dice
@onready var defence_dice_node = $GUI/dice_holder_hbox/defence_dice



@onready var roll_dice_control_container = $GUI/roll_dice_control_container
@onready var roll_dice_optional_label = $GUI/roll_dice_control_container/roll_dice_optional_label
@onready var roll_dices_button = $GUI/roll_dice_control_container/roll_dices_button

@onready var right_ange_buttons_container = $GUI/right_ange_buttons_container
@onready var dices_toggle_button = $GUI/right_ange_buttons_container/dices_toggle_button
@onready var end_turn_button = $GUI/right_ange_buttons_container/End_turn
@onready var skill_info_show_button = $GUI/right_ange_buttons_container/Skill_info_show_button
@onready var self_info_show_button = $GUI/right_ange_buttons_container/self_info_show_button



@onready var skill_info_tab_container = $GUI/Skill_info_tab_container
@onready var use_skill_button = $GUI/use_skill_but_label_container/Use_skill_button
@onready var current_skill_cooldown_label = $GUI/use_skill_but_label_container/current_skill_cooldown_label
@onready var use_skill_but_label_container = $GUI/use_skill_but_label_container

@onready var command_spells_button = $GUI/command_spells_button
@onready var command_spell_choices_container = $GUI/command_spell_choices_container


signal rolled_a_dice

var parry_count_max=0

var attack_responce_string=""
var attacked_by_pu_id

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
@onready var gui = $GUI

@onready var camera_2d = $Camera2D

# Словарь позиций клеток, где ключ - индекс клетки, значение - позиция клетки
var cell_positions = {}
# Словарь соединений, где connected[i][j] == true, если клетка i соединена с клеткой j
var connected = {}
var const_connected:Dictionary

@onready var day_or_night_sprite_2d:Sprite2D = $day_or_night_sprite2d
const SUN = preload("res://sun.png")
const MOON = preload("res://moon.png")

@onready var host_buttons = $GUI/host_buttons

var field_status={"Default":"City","Field Buffs":[]}

func _ready():
	
	
	Globals.someone_status_changed.connect(disconnect_alert_show)
	
	character_selection_container.visible=true
	#$GUI/peer_id_label/android_debug_label.text=str(char_select.characters)
	
	day_or_night_sprite_2d.position=Vector2(scene_bounds.x/2,-400)
	if Globals.host_or_user=='host':
		pass
		
		$GUI/debug_character_control.visible=Globals.debug_mode
	
	#connecting every GUI item to camera script
	#mouse_entered_gui_element()

	#mouse_exited_gui_element()
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

@rpc("call_local","reliable","authority")
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

func get_random_unoccupied_kletka():
	var rand_kletka
	for p in range(10):
		rand_kletka=int(round(randf_range(0,cell_count-1)))
		if !occupied_kletki.has(rand_kletka):
			break
	return rand_kletka

func get_kletki_ids_with_enemies_you_can_reach_in_steps(steps,current_kletka_local=current_kletka):
	#current_kletka
	var output=[]
	for end in occupied_kletki.keys():
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

# Функция для определения пути между клетками через N шагов (BFS способ)
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



func pull_enemy(enemy_pu_id:String):
	
	var path=get_path_in_n_steps(current_kletka,pu_id_to_kletka_number[enemy_pu_id],999)
	path.erase(current_kletka)
	if path.size()!=1:
		current_action="emeny pulling"
		enemy_to_pull=enemy_pu_id
		
		
		choose_glowing_cletka_by_ids_array(path)


func generate_characters_on_random_kletkax():
	for player in players_handler.players_nodes:
		var rand_kletka=get_random_unoccupied_kletka()
		#var jopa = ANGRA.instantiate()
		var cord = cell_positions[rand_kletka]
		player.position=cord
		player.set_process(true)
		occupied_kletki[rand_kletka]=player
		#players_handler.add_child(player,true)

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
			kletki_holder.add_child(cell_instance,true)
			cell_instance.position = new_position
			cell_instance.name="клетка "+str(i)
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
	var line = Line2D.new()
	lines_holder.add_child(line,true)
	line.width = 3
	line.z_index=-1
	line.default_color = Color.WHITE
	line.add_point(start)
	line.add_point(end)

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
		if i.name.contains("клетка") or i.name.contains("Line2D"):
			kletki_holder.remove_child(i)
	for i in get_all_children(lines_holder):
		if i.name.contains("клетка") or i.name.contains("Line2D"):
			lines_holder.remove_child(i)
	#await get_tree().process_frame
	#call_deferred()
	pole_generated_seed=cur_time
	if generated_pole:
		generate_pole(cur_time)

func _on_reset_pressed():
	time=Time.get_unix_time_from_system()
	rpc("reset_pole",time)

func glow_cletki_intiate():
	glow_array=[]
	glow_cletki_node=Node2D.new()
	glow_cletki_node.z_index=100
	glow_cletki_node.name="Glow_cletki_node"
	add_child(glow_cletki_node,true)
	for i in get_all_children(self):
		if str(i.name).contains("клетка"):
			var kletka_numebr=int(i.name.trim_prefix("клетка "))
			var pos = cell_positions[int(kletka_numebr)]
			var glow_node=Node2D.new()
			var glow = Button.new()
			glow_node.visible=false
			
			glow_node.position = pos
			glow_node.name="glow "+str(kletka_numebr)
			#glow.button_down.connect(glow_cletka_pressed)
			#print(glow.name)
			glow.button_down.connect(glow_cletka_pressed.bind(glow_node))
			
			glow.size=Vector2(100,100)
			glow.modulate=Color(1,1,1,0)
			
			
			glow_node.set_script(load("res://скрипты/скрипт glow.gd"))
			glow_node.add_child(glow)
			glow.set_anchors_preset(8)#PRESET_CENTER
			glow.position=Vector2(-glow.size.x/2,-glow.size.y/2)
			
			glow_cletki_node.add_child(glow_node,true)
			glow_array.append(glow_node)

func add_all_additional_nodes():
	print("add_all_additional_nodes")
	captured_kletki_node=Node2D.new()
	captured_kletki_node.z_index=30
	captured_kletki_node.name="Captured_kletki_node"
	add_child(captured_kletki_node,true)
	print("-add_all_additional_nodes----")
	

func get_unoccupied_kletki():
	var output=[]
	for i in range(glow_array.size()):
		if occupied_kletki.has(i):
			continue
		if kletka_preference[i].has("Blocked"):
			continue
		output.append(i)
	return output

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

func glow_cletka_pressed(glow_kletka_selected):
	print("glow_cletka_pressed, current_action="+str(current_action))
	glowing_kletka_number_selected=int(glow_kletka_selected.name.trim_prefix("glow "))
	blinking_glow_button=false
	blink_timer_node.timeout.emit()
	print(glow_kletka_selected)
	print(current_action)
	match current_action:
		"initial_spawn":
			current_action="wait"
			players_handler.set_random_command_spell_set()
			make_action_button.visible=true
			#if Globals.host_or_user!="host":
				#Globals.self_servant_node=instance_from_id(Globals.self_servant_node.object_id)
			self_player_node = Globals.self_servant_node
			self_player_node.visible=true
			self_player_node.position=glow_kletka_selected.position
			print(self_player_node)
			#move_player_from_kletka_id1_to_id2(Globals.self_peer_id,-1,glowing_kletka_number_selected)
			rpc("move_player_from_kletka_id1_to_id2",Globals.self_pu_id,-1,glowing_kletka_number_selected)
			#await movement_finished
			current_kletka=glowing_kletka_number_selected
			print("current kletka="+str(current_kletka))
			print(connected[current_kletka])
			#make_action_button.disabled=false
			right_ange_buttons_container.visible=true
			$GUI/ChatLog_container/HBoxContainer/Chat_send_button.disabled=false
			
			players_handler.current_hp_value_label.text=str(Globals.self_servant_node.hp)
			await add_passive_skills_for_pu_id(Globals.self_pu_id)
			players_handler.rpc("pass_next_turn",Globals.self_pu_id)
			is_game_started=true
			Globals.is_game_started=true
		"field capture":
			rpc("sync_owned_kletki",kletka_owned_by_pu_id)
			temp_kletka_capture_config["Color"]=Globals.self_field_color
			rpc("capture_single_kletka_sync", glowing_kletka_number_selected,temp_kletka_capture_config)
			print("temp_kletka_capture_config  222="+str(temp_kletka_capture_config))
			klekta_captured.emit()
		"move":
			current_action="wait"
			if current_kletka!=-1:
				print("cr-klet="+str(current_kletka))
				
				var cn=connected[current_kletka]
				print("cn= "+str(cn))
				for i in cn:
					if occupied_kletki.has(i):
						continue
					glow_array[i].visible=true
				pass
			
			if Globals.self_servant_node.additional_moves>=1 or current_kletka==-1:
				players_handler.rpc("reduce_additional_moves_for_pu_id",Globals.self_pu_id)
			else:
				reduce_one_action_point()
			#move_player_from_kletka_id1_to_id2(Globals.self_peer_id,current_kletka,glowing_kletka_number_selected)
			rpc("move_player_from_kletka_id1_to_id2",Globals.self_pu_id,current_kletka,glowing_kletka_number_selected)
			current_kletka=glowing_kletka_number_selected
		"attack":
			attacking_player_on_kletka_id=glowing_kletka_number_selected
			#SHIT START
			attacking_pu_id=occupied_kletki[glowing_kletka_number_selected].name
			attacking_pu_id=players_handler.servant_name_to_pu_id[attacking_pu_id]
			#SHIT END
			await attack_player_on_kletka_id(attacking_player_on_kletka_id,damage_type)
			players_handler.pu_id_player_game_stat_info[Globals.self_pu_id]["attacked_this_turn"]+=1
		"choose_allie":
			print("occupied_kletki="+str(occupied_kletki))
			players_handler.choosen_allie_return_value=occupied_kletki[glowing_kletka_number_selected]
			players_handler.chosen_allie.emit()
		"emeny pulling":
			var atk_id=attacking_pu_id
			rpc("move_player_from_kletka_id1_to_id2",atk_id,pu_id_to_kletka_number[atk_id],glowing_kletka_number_selected)
			
			
	glow_kletka_pressed_signal.emit(glowing_kletka_number_selected)

@rpc("any_peer","call_local","reliable")
func capture_single_kletka_sync(glowing_kletka_number_selected_temp,temp_kletka_capture_config):
	var kletka_owner=temp_kletka_capture_config["Owner"]
	var kletka_color=temp_kletka_capture_config["Color"]
	if typeof(captured_kletki_node)==TYPE_NIL:
		captured_kletki_node=Node2D.new()
		captured_kletki_node.z_index=30
		captured_kletki_node.name="Captured_kletki_node"
		add_child(captured_kletki_node,true)
	if !kletka_owned_by_pu_id.has(kletka_owner):
		kletka_owned_by_pu_id[kletka_owner]=[]
	print(str(glowing_kletka_number_selected_temp," is captured"))
	kletka_preference[glowing_kletka_number_selected_temp]=temp_kletka_capture_config
	kletka_owned_by_pu_id[kletka_owner].append(glowing_kletka_number_selected_temp)
	
	var captur_klet=Node2D.new()
	var pos = cell_positions[int(glowing_kletka_number_selected_temp)]
	captur_klet.position = pos
	captur_klet.name="field "+str(glowing_kletka_number_selected_temp)
	
	captur_klet.set_script(CapturedKletkaScript)
	
	captur_klet.color=kletka_color
	
	captured_kletki_node.add_child(captur_klet,true)
	captur_klet.queue_redraw()
	captured_kletki_nodes_dict[glowing_kletka_number_selected_temp]=captur_klet

func reduce_one_action_point(amount_to_reduce=-1):
	current_action_points+=amount_to_reduce
	current_action_points_label.text=str(current_action_points)
	if current_action_points==0:
		make_action_button.disabled=true

@rpc("any_peer","call_local","reliable")
func move_player_from_kletka_id1_to_id2(pu_id:String,current_kletka_local:int,glowing_kletka_number_selected:int,is_partial:bool=false,visually_only:bool=false):
	print("_________________movement______________-")
	print("pu_id="+str(pu_id)+" Globals.pu_id_player_info="+str(Globals.pu_id_player_info))
	print("From ",current_kletka_local," to ",glowing_kletka_number_selected," is_partial=",is_partial," visually_only=",visually_only)
	var player_node_to_move=Globals.pu_id_player_info[pu_id]["servant_node"]
	
	if current_kletka_local==glowing_kletka_number_selected and visually_only:
		player_node_to_move.position=cell_positions[glowing_kletka_number_selected]
		return
	
	var chastei=10
	var addition=0
	if is_partial:
		addition=-3
		
	if current_kletka_local!=-1:
		#print("player_node_to_move.position="+str(player_node_to_move.position)+" cell_positions[glowing_kletka_number_selected]="+str(cell_positions[glowing_kletka_number_selected]))
		#print("player_node_to_move.position="+str(player_node_to_move.position)+" cell_positions[current_kletka_local]="+str(cell_positions[current_kletka_local]))
		var one=player_node_to_move.position.round()!=cell_positions[glowing_kletka_number_selected].round()
		var second=player_node_to_move.position.round()!=cell_positions[current_kletka_local].round()
		if one and second:
			addition=0
	
	
	
	#""""""animation"""""
	#cell_positions[glowing_kletka_number_selected]
					#from 											to
	var mnoghitel=(cell_positions[glowing_kletka_number_selected]-player_node_to_move.position)/chastei
	
	if current_kletka_local==-1:
		player_node_to_move.position=cell_positions[glowing_kletka_number_selected]
	else:
		if visually_only:
			player_node_to_move.position=cell_positions[current_kletka_local]
		for i in range(chastei+addition):
			player_node_to_move.position+=mnoghitel
			await get_tree().create_timer(0.01).timeout
	
	if not is_partial or current_kletka_local==-1:
		if not visually_only:
			if current_kletka_local!=-1:
				occupied_kletki.erase(current_kletka_local)
			occupied_kletki[glowing_kletka_number_selected]=player_node_to_move
			pu_id_to_kletka_number[pu_id]=glowing_kletka_number_selected
	if pu_id==Globals.self_pu_id and not visually_only and not is_partial:
		current_kletka=glowing_kletka_number_selected
	
func _on_start_pressed():
	#for i in get_all_children(self):
		#print(i)
	if !is_pole_generated:
		_on_reset_pressed()
	rpc("main_game")


func await_dice_roll():
	roll_dice_control_container.visible=true
	dice_holder_hbox.visible=true
	
	await rolled_a_dice
	await hide_dice_rolls_with_timeout(2)

func hide_dice_rolls_with_timeout(timeout_in_seconds):
	await get_tree().create_timer(timeout_in_seconds).timeout
	roll_dice_control_container.visible=false
	dice_holder_hbox.visible=false


func disable_every_button(block=true):
	hide_all_gui_windows("all")
	var blocked_this_iteration=[]
	if block:
		for child in get_all_children($GUI):
			if "Button" in str(child.get_class()):
				if child.is_visible_in_tree():
					child.disabled=block
					blocked_this_iteration.append(child)
	else:
		for button in blocked_previous_iteration:
			button.disabled=false
	$GUI/ChatLog_container/HBoxContainer/Chat_send_button.disabled=false
	end_turn_button.disabled=false
	blocked_previous_iteration=blocked_this_iteration
	pass

func info_table_show(text="someone forgot to set this, contact anyone, SCREAM"):
	hide_all_gui_windows()
	#disable_every_button(true)
	info_label.text=text
	info_label_panel.visible=true
	info_ok_button.visible=true

func _on_info_ok_button_pressed():
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
		

var awaiting_responce_from_pu_id:String

func attack_player_on_kletka_id(kletka_id,attack_type="Physical",consume_action_point:bool=true,phantasm_config={}):
	end_turn_button.disabled=true
	if attack_type=="Physical" or attack_type=="Magical":
		if attack_responce_string!="parried":
			type_of_damage_choose_buttons_box.visible=false
			#are_you_sure_main_container.visible=true
			fill_are_you_sure_screen("Attack")
			var are_you_sure_result=await are_you_sure_signal
			if are_you_sure_result=="no":
				type_of_damage_choose_buttons_box.visible=true
				return
			parry_count_max=players_handler.get_pu_id_agility(Globals.self_pu_id)
			parry_count_max=players_handler.get_agility_in_numbers(parry_count_max)
		else: 
			roll_dice_optional_label.text="Enemy parried, reroll"
			roll_dice_optional_label.visible=true
		await await_dice_roll()
		roll_dice_control_container.visible=false
		you_were_attacked_container.visible=false
		are_you_sure_main_container.visible=false
		

	var dice_plus_buff=players_handler.pu_id_has_buff(Globals.self_pu_id,"Dice +")
	if dice_plus_buff:
		if dice_plus_buff.has("Action"):
			if dice_plus_buff["Action"]=="Attack":
				dice_roll_result_list["main_dice"]+=dice_plus_buff.get("Power",1)

	var pu_id_to_attack = players_handler.servant_name_to_pu_id[occupied_kletki[kletka_id].name]
	var peer_id_to_attack=Globals.pu_id_player_info[pu_id_to_attack].current_peer_id

	if not Globals.pu_id_player_info[pu_id_to_attack]["is_connected"]:
		return


	awaiting_responce_from_pu_id=pu_id_to_attack

	rpc_id(peer_id_to_attack,"receice_dice_roll_results",dice_roll_result_list)
	
	if attack_responce_string!="parried":
		rpc_id(peer_id_to_attack,"set_action_status",Globals.self_pu_id,"getting_attacked",attack_type,phantasm_config)
	else:#ignore this
		rpc_id(peer_id_to_attack,"set_action_status",Globals.self_pu_id,"getting_attacked",attack_type,phantasm_config)
	
	disable_every_button()
	
	if attack_type=="Physical" and Globals.self_servant_node.attack_range<=2:
		rpc("move_player_from_kletka_id1_to_id2",Globals.self_pu_id,current_kletka,kletka_id,true)
		
	alert_label_text(true,"You've attacked an enemie, waiting for it's responce")
	
	var hitted=false
	
	var status= await attack_response

	match status:
		"OK":
			pass
		"Disconnect":
			return "ERROR"

	match attack_responce_string:
		"parried":
			parry_count_max-=1
			if parry_count_max!=0:
				current_action="wait"
				rpc("systemlog_message",str(Globals.nickname," stamina left:",parry_count_max))
				await attack_player_on_kletka_id(kletka_id,damage_type)
				await players_handler.trigger_buffs_on(Globals.self_pur_id,"enemy parried",pu_id_to_attack)
				return
		"Halfed Damage":
			#players_handler.charge_np_to_peer_id_by_number(Globals.self_peer_id,1)
			hitted=true
			current_action="wait"
			players_handler.rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"total_success_hit",1)
			players_handler.rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"attacked_this_turn",1)
			
			await players_handler.trigger_buffs_on(Globals.self_pu_id,"Success Attack",pu_id_to_attack)
			await players_handler.trigger_buffs_on(Globals.self_pu_id,"enemy halfed damage",pu_id_to_attack)
		"damaged":
			#players_handler.charge_np_to_peer_id_by_number(Globals.self_peer_id,1)
			hitted=true
			players_handler.rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"total_success_hit",1)
			players_handler.rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"attacked_this_turn",1)
			current_action="wait"
			await players_handler.trigger_buffs_on(Globals.self_pu_id,"Success Attack",pu_id_to_attack)
		"defending":
			#players_handler.charge_np_to_peer_id_by_number(Globals.self_peer_id,1)
			hitted=true
			current_action="wait"
			players_handler.rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"total_success_hit",1)
			players_handler.rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"attacked_this_turn",1)
			await players_handler.trigger_buffs_on(Globals.self_pu_id,"Success Attack",pu_id_to_attack)
			await players_handler.trigger_buffs_on(Globals.self_pu_id,"enemy defended",pu_id_to_attack)
		"evaded":
			current_action="wait"
			await players_handler.trigger_buffs_on(Globals.self_pu_id,"enemy evaded",pu_id_to_attack)
		

	if hitted:
		players_handler.charge_np_to_pu_id_by_number(Globals.self_pu_id,1)
	roll_dice_optional_label.visible=false
	if attack_type=="Physical" and Globals.self_servant_node.attack_range<=2:
		rpc("move_player_from_kletka_id1_to_id2",Globals.self_pu_id,kletka_id,current_kletka,true)
	if attack_type!="Phantasm" or not consume_action_point:
		reduce_one_action_point()
	dice_holder_hbox.visible=false
	roll_dice_control_container.visible=false
	disable_every_button(false)
	alert_label_text(false)
	end_turn_button.disabled=false
	return pu_id_to_attack
	
	

func roll_a_dice():
	randomize()
	var set_dices=players_handler.pu_id_has_buff(Globals.self_pu_id,"Faceless Moon")
	if set_dices:
		dice_roll_result_list=set_dices.get("Dices",{})
	
	if not set_dices:
		dice_roll_result_list["main_dice"]=randi_range(1,6)
		dice_roll_result_list["crit_dice"]=randi_range(1,6)
		dice_roll_result_list["defence_dice"]=randi_range(1,4)
		dice_roll_result_list["additional_d6"]=randi_range(1,6)
		dice_roll_result_list["additional_d6_2"]=randi_range(1,6)
		dice_roll_result_list["additional_d100"]=randi_range(1,100)
	
	
	main_dice_node.roll(dice_roll_result_list["main_dice"])
	attack_label.text="Attack roll: "+str(dice_roll_result_list["main_dice"])
	
	crit_dice_node.roll(dice_roll_result_list["crit_dice"])
	crit_label.text="Crit roll: "+str(dice_roll_result_list["crit_dice"])
	
	defence_dice_node.roll(dice_roll_result_list["defence_dice"])
	defence_label.text="Defence roll: "+str(dice_roll_result_list["defence_dice"])
	
	
	
	print(dice_roll_result_list)
	#rpc_id("receice_dice_roll_results",dice_roll_result_list)
	
	rpc("get_message",str(Globals.nickname,"'s roll"),str("main:",dice_roll_result_list["main_dice"]," crit:",dice_roll_result_list["crit_dice"]," def:",dice_roll_result_list["defence_dice"]))
	#return dice_roll_result_list

func _roll_dices_button_pressed():
	roll_a_dice()
	rolled_a_dice.emit()
	pass

@rpc("any_peer","call_remote","reliable")
func set_action_status(by_whom_pu_id:String,status,attack_type="Physical",phantasm_config={}):
	self_action_status=status
	attacked_by_pu_id=by_whom_pu_id

	var attacked_by_peer_id=Globals.pu_id_player_info[attacked_by_pu_id].current_peer_id
	
	recieved_damage_type=attack_type
	recieved_phantasm_config=phantasm_config
	
	print(str("status=",status," attacked_by_pu_id=",attacked_by_pu_id))
	match status:
		"getting_attacked":
			you_were_attacked_label.text=str("You were attacked with this dice rolls:\n",
"Attack: ", recieved_dice_roll_result["main_dice"] ,"Crit: ",recieved_dice_roll_result["crit_dice"],
"\nWhat do you do?")

			var atk_rng=players_handler.get_pu_id_attack_range(Globals.self_pu_id)
			var attacker_kletka_id=pu_id_to_kletka_number[attacked_by_pu_id]
			
			var distance_between_enemie=get_path_in_n_steps(current_kletka,attacker_kletka_id,atk_rng).size()
			if attack_type=="Phantasm" or distance_between_enemie>atk_rng:
				$GUI/You_were_attacked_container/HBoxContainer/Parry_button.disabled=true
			else: 
				$GUI/You_were_attacked_container/HBoxContainer/Parry_button.disabled=false
			you_were_attacked_container.visible=true
		"parrying":
			_on_parry_button_pressed()
		"roll_dice_for_result":
			roll_dice_optional_label.text="You need to throw above %s to not get bad status"%[recieved_dice_roll_result["main_dice"]]
			roll_dice_optional_label.visible=true
			await await_dice_roll()
			roll_dice_optional_label.visible=false
			if dice_roll_result_list["main_dice"]>recieved_dice_roll_result["main_dice"]:
				rpc_id(attacked_by_peer_id,"answer_attack","Evaded bad status")
				systemlog_message(str(Globals.nickname, " evaded bad status"))
			elif dice_roll_result_list["main_dice"]==recieved_dice_roll_result["main_dice"]:
				rpc_id(attacked_by_peer_id,"answer_attack","Even dice rolls, reroll for status")
				systemlog_message(str(Globals.nickname, " rolled the same number, reroll"))
			else:
				rpc_id(attacked_by_peer_id,"answer_attack","Getting bad status")
				systemlog_message(str(Globals.nickname, " getting bad status"))
	
	#_on_dices_toggle_button_pressed()????

func _on_evade_button_pressed():
	you_were_attacked_container.visible=false
	fill_are_you_sure_screen("Evade")
	var are_you_sure_result=await are_you_sure_signal
	if are_you_sure_result=="no":
		you_were_attacked_container.visible=true
		return
	
	await await_dice_roll()

	var dice_plus_buff=players_handler.pu_id_has_buff(Globals.self_pu_id,"Dice +")
	if dice_plus_buff:
		if dice_plus_buff.has("Action"):
			if dice_plus_buff["Action"]=="Evade":
				dice_roll_result_list["main_dice"]+=dice_plus_buff.get("Power",1)


	var counter_attack=false

	counter_attack = dice_roll_result_list["main_dice"]==dice_roll_result_list["crit_dice"]

	#dice_roll_result_list
	#recieved_dice_roll_result
	var attacked_by_peer_id=Globals.pu_id_player_info[attacked_by_pu_id].current_peer_id
	var enemy_has_ignore_evade=players_handler.pu_id_has_buff(attacked_by_pu_id,"Ignore Evade")

	if dice_roll_result_list["main_dice"]>recieved_dice_roll_result["main_dice"] and not enemy_has_ignore_evade:
		rpc_id(attacked_by_peer_id,"answer_attack","evaded")
		rpc("systemlog_message",str(Globals.nickname," evaded by throwing ",dice_roll_result_list["main_dice"]))
	elif dice_roll_result_list["main_dice"]==recieved_dice_roll_result["main_dice"] and not enemy_has_ignore_evade:
		var damage_to_take=players_handler.calculate_damage_to_take(attacked_by_pu_id,recieved_dice_roll_result,recieved_damage_type,"Halfed Damage")
		
		if typeof(damage_to_take)==TYPE_STRING:
			if damage_to_take=="evaded":
				rpc_id(attacked_by_peer_id,"answer_attack","evaded")
				rpc("systemlog_message",str(Globals.nickname," evaded by buff"))
		else:
			rpc_id(attacked_by_peer_id,"answer_attack","Halfed Damage")
			if damage_to_take==0:
				rpc("remove_invinsibility_after_hit_for_pu_id",Globals.self_pu_id)
			rpc("systemlog_message",str(Globals.nickname," halfed damage by throwing ",dice_roll_result_list["main_dice"]))
			players_handler.rpc("take_damage_to_pu_id",Globals.self_pu_id,damage_to_take)
			players_handler.rpc("change_game_stat_for_pu_id",attacked_by_pu_id,"total_damage_dealt",damage_to_take)
	else: 
		var damage_to_take=players_handler.calculate_damage_to_take(attacked_by_pu_id,recieved_dice_roll_result,recieved_damage_type)
		
		if typeof(damage_to_take)==TYPE_STRING:
			if damage_to_take=="evaded":
				rpc("remove_evade_buff_after_hit_for_pu_id",Globals.self_pu_id)
				rpc_id(attacked_by_pu_id,"answer_attack","evaded")
				rpc("systemlog_message",str(Globals.nickname," evaded by buff"))
		else:
			rpc_id(attacked_by_pu_id,"answer_attack","damaged")
			if damage_to_take==0:
				rpc("remove_invinsibility_after_hit_for_pu_id",Globals.self_pu_id)
			players_handler.rpc("take_damage_to_pu_id",Globals.self_pu_id,damage_to_take)
			players_handler.rpc("change_game_stat_for_pu_id",attacked_by_pu_id,"total_damage_dealt",damage_to_take)
			rpc("systemlog_message",str(Globals.nickname," got damaged thowing ",dice_roll_result_list["main_dice"]))
	


	roll_dice_control_container.visible=false
	dice_holder_hbox.visible=false


	if counter_attack:
		var atk_rng=players_handler.get_pu_id_attack_range(Globals.self_pu_id)
		var attacker_kletka_id=pu_id_to_kletka_number[attacked_by_pu_id]
		
		var distance_between_enemie=get_path_in_n_steps(current_kletka,attacker_kletka_id,atk_rng).size()
		if atk_rng>=distance_between_enemie:
			info_table_show("You rolled crit during evade. You can counter attack!")
			await info_ok_button.pressed
			fill_are_you_sure_screen("Counter Attack")
			are_you_sure_result=await are_you_sure_signal
			if are_you_sure_result=="no":
				return
			systemlog_message(str(Globals.nickname," counter attacking"))
			
			await attack_player_on_kletka_id(attacker_kletka_id,false)


@rpc("any_peer","call_local","reliable")
func remove_invinsibility_after_hit_for_pu_id(pu_id:String):
	var pu_id_buffs=Globals.pu_id_player_info[pu_id]["servant_node"].buffs
	for i in range(pu_id_buffs.size()):
		var buff=pu_id_buffs[i]
		if buff["Name"]=="Invincible":
			if buff.has("Power"):
				var evade_power=buff.get("Power",1)
				if evade_power==1:
					Globals.pu_id_player_info[pu_id]["servant_node"].buffs.pop_at(i)
				else:
					Globals.pu_id_player_info[pu_id]["servant_node"].buffs[i]["Power"]-=1


@rpc("any_peer","call_local","reliable")
func remove_evade_buff_after_hit_for_pu_id(pu_id:int):
	var pu_id_buffs=Globals.pu_id_player_info[pu_id]["servant_node"].buffs
	for i in range(pu_id_buffs.size()):
		var buff=pu_id_buffs[i]
		if buff["Name"]=="Evade":
			if buff.has("Power"):
				var evade_power=buff.get("Power",1)
				if evade_power==1:
					Globals.pu_id_player_info[pu_id]["servant_node"].buffs.pop_at(i)
				else:
					Globals.pu_id_player_info[pu_id]["servant_node"].buffs[i]["Power"]-=1
				


func _on_defence_button_pressed():
	you_were_attacked_container.visible=false
	fill_are_you_sure_screen("Defence")
	var are_you_sure_result=await are_you_sure_signal
	if are_you_sure_result=="no":
		you_were_attacked_container.visible=true
		return
	
	await await_dice_roll()
	var attacked_by_peer_id=Globals.pu_id_player_info[attacked_by_pu_id].current_peer_id
	var dice_plus_buff=players_handler.pu_id_has_buff(Globals.self_pu_id,"Dice +")
	if dice_plus_buff:
		if dice_plus_buff.has("Action"):
			if dice_plus_buff["Action"]=="Defence":
				dice_roll_result_list["main_dice"]+=dice_plus_buff.get("Power",1)


	rpc_id(attacked_by_peer_id,"answer_attack","defending")
	var damage_to_take=players_handler.calculate_damage_to_take(attacked_by_pu_id,recieved_dice_roll_result,recieved_damage_type,"Defence")
		
	if typeof(damage_to_take)==TYPE_STRING:
		if damage_to_take=="evaded":
			rpc("remove_evade_buff_after_hit_for_pu_id",Globals.self_pu_id)
			rpc_id(attacked_by_peer_id,"answer_attack","evaded")
			rpc("systemlog_message",str(Globals.nickname," evaded by buff"))
	else:
		rpc_id(attacked_by_peer_id,"answer_attack","damaged")
		if damage_to_take==0:
			rpc("remove_invinsibility_after_hit_for_pu_id",Globals.self_pu_id)
		players_handler.rpc("take_damage_to_pu_id",Globals.self_pu_id,damage_to_take)
		players_handler.rpc("change_game_stat_for_pu_id",attacked_by_pu_id,"total_damage_dealt",damage_to_take)
		rpc("systemlog_message",str(Globals.nickname," got damaged thowing ",dice_roll_result_list["main_dice"]))
	
	
	
	rpc("systemlog_message",str(Globals.nickname," defending by throwing ",dice_roll_result_list["defence_dice"]))
	
	dice_holder_hbox.visible=false


func _on_parry_button_pressed():
	
	if self_action_status!="parrying":
		you_were_attacked_container.visible=false
		fill_are_you_sure_screen("Parry")
		var are_you_sure_result=await are_you_sure_signal
		if are_you_sure_result=="no":
			you_were_attacked_container.visible=true
			return
		
	await await_dice_roll()
	var attacked_by_peer_id=Globals.pu_id_player_info[attacked_by_pu_id].current_peer_id
	var dice_plus_buff=players_handler.pu_id_has_buff(Globals.self_pu_id,"Dice +")
	if dice_plus_buff:
		if dice_plus_buff.has("Action"):
			if dice_plus_buff["Action"]=="Parry":
				dice_roll_result_list["main_dice"]+=dice_plus_buff.get("Power",1)

	you_were_attacked_container.visible=false
	are_you_sure_main_container.visible=false
	#if rolled+-1==recieved
	if dice_roll_result_list["main_dice"]==recieved_dice_roll_result["main_dice"]+1 or dice_roll_result_list["main_dice"]==recieved_dice_roll_result["main_dice"]-1 or dice_roll_result_list["main_dice"]==recieved_dice_roll_result["main_dice"]:
		print("parried")
		rpc_id(attacked_by_peer_id,"answer_attack","parried")
		rpc("systemlog_message",str(Globals.nickname," parried"))
		return
	print("dont parried")
	rpc("systemlog_message",str(Globals.nickname," got hit"))
	
	var damage_to_take=players_handler.calculate_damage_to_take(attacked_by_pu_id,recieved_dice_roll_result,recieved_damage_type)
	
	if typeof(damage_to_take)==TYPE_STRING:
		if damage_to_take=="evaded":
			rpc("remove_evade_buff_after_hit_for_pu_id",Globals.self_pu_id)
			rpc_id(attacked_by_peer_id,"answer_attack","evaded")
			rpc("systemlog_message",str(Globals.nickname," evaded by buff"))
	else:
		rpc_id(attacked_by_peer_id,"answer_attack","damaged")
		if damage_to_take==0:
			rpc("remove_invinsibility_after_hit_for_pu_id",Globals.self_pu_id)
		players_handler.rpc("take_damage_to_pu_id",Globals.self_pu_id,damage_to_take)
		players_handler.rpc("change_game_stat_for_pu_id",attacked_by_pu_id,"total_damage_dealt",damage_to_take)
		
		
		
		rpc("systemlog_message",str(Globals.nickname," got damaged thowing ",dice_roll_result_list["main_dice"]))
	dice_holder_hbox.visible=false


func _on_phantasm_evation_button_pressed():
	#TBA
	#TODO
	pass # Replace with function body.

@rpc('any_peer',"call_remote","reliable")
func answer_attack(status):
	attack_responce_string=status
	attack_response.emit("OK")

@rpc("any_peer","call_remote","reliable")
func receice_dice_roll_results(recieved_dice_roll_result_temp):
	recieved_dice_roll_result=recieved_dice_roll_result_temp
	#a
	#attack_label.text="Attack roll: "+str(recieved_dice_roll_result["main_dice"])
	#crit_label.text="Crit roll: "+str(recieved_dice_roll_result["crit_dice"])
	#defence_label.text="Defence roll: "+str(recieved_dice_roll_result["defence_dice"])
	
func new_turn():
	make_action_button.disabled=false

@rpc("authority","call_local","reliable")
func main_game():
	print("GAME STARTED")
	
	$GUI/character_selection_container.queue_free()
	#print("connected="+str(connected))
	#spawn random dommies
	#generate_characters_on_random_kletkax()
	glow_cletki_intiate()
	#choose kletka so spawn
	print("occupied_kletki="+str(occupied_kletki))
	reset_button.queue_free()
	#random_kletka()
	if multiplayer.get_unique_id()==1:
		players_handler.start()
	start_button.queue_free()
	#attack_button.visible=true
	#move_button.visible=true
	#cancel_button.visible=true
	current_action_points=3
	current_action_points_label.text=str(current_action_points)
	
	
	
	#players_handler.peer_id_to_np_points["peer_id"]=0
	
	#players_handler.
	for pu_id in Globals.pu_id_player_info.keys():
		kletka_owned_by_pu_id[pu_id]=Array()

		print(str(pu_id," kletka_owned_by_pu_id =[]"))
		print(str("kletka_owned_by_pu_id =",kletka_owned_by_pu_id))
	rpc("sync_owned_kletki",kletka_owned_by_pu_id)
	pass
	
	
@rpc("any_peer","call_local","reliable")
func sync_owned_kletki(kletka_owned_by_pu_id_local):
	kletka_owned_by_pu_id=kletka_owned_by_pu_id_local
	
@rpc("authority","call_local","reliable")
func initial_spawn():
	pass
	
@rpc("authority")
func inital_spawn_of_player():
	print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	current_action="initial_spawn"
	var kletka_to_initial_spawn=get_unoccupied_kletki()
	choose_glowing_cletka_by_ids_array(kletka_to_initial_spawn)
	
func _on_attack_pressed(counter_attack:bool=false):
	print("_________________attack______________")
	print("occupied_kletki="+str(occupied_kletki))
	print("current_kletka="+str(current_kletka))
	magical_damage_button.disabled=true
	#var magic_power=players_handler.get_peer_id_magical_attack(Globals.self_peer_id)
	
	var player_has_magic_attack=Globals.pu_id_player_info[Globals.self_pu_id]["servant_node"].default_stats["magic"]["Power"]
	
	if player_has_magic_attack:
		magical_damage_button.disabled=false
	if current_action_points>=1 or counter_attack:
		type_of_damage_choose_buttons_box.visible=true
		actions_buttons.visible=false
		current_action="attack"
		pass
		#for i in occupied_kletki.keys():
		#pass


func _on_regular_damage_button_pressed():
	var attack_range=players_handler.get_pu_id_attack_range(Globals.self_pu_id)
	
	var kk=get_kletki_ids_with_enemies_you_can_reach_in_steps(attack_range)
	if kk.size()==0:
		type_of_damage_choose_buttons_box.visible=false
		return
	print(kk)
	damage_type="Physical"
	choose_glowing_cletka_by_ids_array(kk)
	for i in kk:
		print(occupied_kletki[i])
	type_of_damage_choose_buttons_box.visible=false

func _on_magical_damage_button_pressed():
	var kk=get_kletki_ids_with_enemies_you_can_reach_in_steps(3)
	print(kk)
	if kk.size()==0:
		type_of_damage_choose_buttons_box.visible=false
		return
	damage_type="Magical"
	choose_glowing_cletka_by_ids_array(kk)
	for i in kk:
		print(occupied_kletki[i])
	type_of_damage_choose_buttons_box.visible=false

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


func add_passive_skills_for_pu_id(pu_id:String):

	if not "passive_skills" in Globals.self_servant_node:
		print("no passive skills found for pu_id="+str(pu_id))
		return
	var passive_buffs=Globals.pu_id_player_info[pu_id]["servant_node"].passive_skills
	for buff in passive_buffs:
		#func remove_buff(cast_array,skill_name,remove_passive=false,remove_only_passive_one=false):
		#players_handler.rpc("remove_buff",[pu_id],buff["Name"],true,true)
		#await players_handler.buff_removed
		var buff_copy=buff.duplicate(true)
		buff_copy["Type"]="Status"
		players_handler.rpc("add_buff",[pu_id],buff)




@rpc("authority","call_local","reliable")
func start_turn():
	print("It is my turn:",Globals.self_pu_id)
	my_turn=true
	
	current_action_points=3
	current_action_points_label.text=str(current_action_points)
	make_action_button.disabled=false
	end_turn_button.disabled=false
	paralyzed=false
	
	print(players_handler.pu_id_player_game_stat_info)
	#players_handler.pu_id_player_game_stat_info[Globals.self_peer_id]["attacked_this_turn"]=0

	players_handler.rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"attacked_this_turn",0,true)
	players_handler.rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"skill_used_this_turn",0,true)
	players_handler.rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"kletki_moved_this_turn",0,true)

	print("Current_action="+str(current_action)+"\n\n")
	if is_game_started:
		if players_handler.pu_id_has_buff(Globals.self_pu_id,"Paralysis") or players_handler.pu_id_has_buff(Globals.self_pu_id,"Stun"):
			paralyzed=true
			disable_every_button()
			info_table_show("You're paralyzed\n")
			end_turn_button.disabled=false
			command_spells_button.disabled=false
		if players_handler.pu_id_has_buff(Globals.self_pu_id,"Presence Concealment"):
			var buff_info=players_handler.pu_id_has_buff(Globals.self_pu_id,"Presence Concealment")
			var turns_passed=players_handler.turns_counter-buff_info["Turn Casted"]
			var minimum_turns=buff_info["Minimum Turns"]
			var maximum_turns=buff_info["Maximum Turns"]

			if turns_passed>=maximum_turns:
				release_from_Presence_Concealment(false)
			elif turns_passed>minimum_turns:
				release_from_Presence_Concealment(true)
			else:#waiting for minumum turns
				disable_every_button()
				info_table_show("Вы в сокрытии присутствия и не можете ходить еще\n"+str(abs(turns_passed-minimum_turns))+" ходов")
	
	
	
	players_handler.reduce_skills_cooldowns(Globals.self_pu_id)
	players_handler.rpc("reduce_skills_cooldowns",Globals.self_pu_id)
	
	players_handler.reduce_buffs_cooldowns(Globals.self_pu_id)
	players_handler.rpc("reduce_buffs_cooldowns",Globals.self_pu_id)
	players_handler.trigger_buffs_on(Globals.self_pu_id,"Turn Started")
	players_handler.check_if_hp_is_bigger_than_max_hp_for_pu_id(Globals.self_pu_id)
	#removing and adding skill in case it got remove by something
	

func release_from_Presence_Concealment(stun:bool):
	if stun:
		info_table_show("Вы можете выйти из сокрытия присутствия сейчас, но будете застанены следующий ход")
		await info_ok_button.pressed
		fill_are_you_sure_screen("Выйти из сокрытия присутствия")
		var choose=await are_you_sure_signal
		print("choose="+str(choose))
		if choose=="no":
			return
		
		
		current_action="move"
		var kletka_to_initial_spawn=get_unoccupied_kletki()
		choose_glowing_cletka_by_ids_array(kletka_to_initial_spawn)
		await glow_kletka_pressed_signal
		rpc("show_pu_id_servant_node",Globals.self_pu_id,true)
		players_handler.rpc("add_buff",[Globals.self_pu_id],{"Name":"Paralysis",
				"Duration":1,
				"Power":1
				})
	else:
		info_table_show("Вы обязаный выйти из сокрытия присутствия сейчас")
		await info_ok_button.pressed
		
		current_action="move"
		var kletka_to_initial_spawn=get_unoccupied_kletki()
		choose_glowing_cletka_by_ids_array(kletka_to_initial_spawn)
		await glow_kletka_pressed_signal
		rpc("show_pu_id_servant_node",Globals.self_pu_id,true)
	players_handler.rpc("remove_buff",[Globals.self_pu_id],"Presence Concealment",true)



@rpc("any_peer","reliable","call_local")
func show_pu_id_servant_node(pu_id:int,visible_loc:bool):
	Globals.pu_id_player_info[pu_id]["servant_node"].visible=visible_loc

func _on_cancel_pressed():
	if current_action_points>=1:
		pass


func _on_move_pressed():
	print(current_action_points)
	if current_action_points>=1:
		current_action="move"
		_on_make_action_pressed()
		var move_ck=[]
		print("current_kletka="+str(current_kletka)+" connected[current_kletka]="+str(connected[current_kletka]))
		for i in connected[current_kletka]:
			if occupied_kletki.has(i):
				continue
			if kletka_preference[i].has("Blocked"):
				continue
			move_ck.append(int(glow_array[i].name.trim_prefix("glow ")))#.visible=true
		pass
		choose_glowing_cletka_by_ids_array(move_ck)
		players_handler.rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"total_kletki_moved",1)
		players_handler.rpc("change_game_stat_for_pu_id",Globals.self_pu_id,"kletki_moved_this_turn",1)


func field_manipulation(buff_config:Dictionary):
	#{"Buffs":[
	#	{"Name":"Field Manipulation",
	#	"Amount":3,"Range":3,"Config":
	#		{"Owner":Globals.self_peer_id,
	#			"Stats Up By":1,
	#			"Additional":null}
	#		}
	#	],
	var BLOCKED_KLETKA_CONFIG={
		"Owner":Globals.self_pu_id,
		"Blocked":true
	}
	var amount_to_manipulate=buff_config.get("Amount",0)
	var range_of_manipulatons=buff_config.get("Range",0)
	var kletka_config=buff_config.get("Config",0)
	var amount_kletki=buff_config.get("Amount",1)
	kletka_config["Owner"]=Globals.self_pu_id
	kletka_config["Turn Casted"]=players_handler.turns_counter
	kletka_config["Color"]=Globals.self_field_color
	
	if not (amount_to_manipulate and range_of_manipulatons and kletka_config):
		push_error("Bad field manipulation config=",buff_config)
		return
	for i in range(amount_kletki+1):
		var type=await choose_between_two("Capture", "Manupulate")
		
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
		
	
	pass


func choose_between_two(first:String,second:String)->String:
	var out:String
	
	info_but_choose_1.text=first
	info_but_choose_2.text=second

	info_but_choose_1.pressed.connect(info_but_choose.bind(first))
	info_but_choose_2.pressed.connect(info_but_choose.bind(second))
	disable_every_button()
	info_but_choose_1.visible=true
	info_but_choose_2.visible=true
	info_label_panel.visible=true
	
	out=await choose_two

	info_but_choose_1.visible=false
	info_but_choose_2.visible=false
	info_label_panel.visible=false
	disable_every_button(false)
	info_but_choose_1.pressed.disconnect(info_but_choose.bind(first))
	info_but_choose_2.pressed.disconnect(info_but_choose.bind(second))
	return out

func info_but_choose(choose_local:String):
	choose_two.emit(choose_local)


func capture_field_kletki(amount,config_of_kletka):
	
	print("capture_field_kletki, pu_id="+str(Globals.self_pu_id))
	print("amount=="+str(amount))
	
	var available_to_capture=[]
	config_of_kletka_to_capture=config_of_kletka
	current_action="field capture"
	
	
	var owner_pu_id=config_of_kletka["Owner"]
	
	#print("connected="+str(connected))
	temp_kletka_capture_config=config_of_kletka
	
	temp_kletka_capture_config.merge({"turn_casted":players_handler.turns_counter})
	
	print(str("pu_id_to_kletka_number=",pu_id_to_kletka_number))
	
	if !kletka_owned_by_pu_id.has(owner_pu_id):
		kletka_owned_by_pu_id[owner_pu_id]=[]
	

	temp_kletka_capture_config["Color"]=Globals.self_field_color
	if kletka_owned_by_pu_id[owner_pu_id]==[]:
		kletka_owned_by_pu_id[owner_pu_id]=[pu_id_to_kletka_number[owner_pu_id]]
		rpc("sync_owned_kletki",kletka_owned_by_pu_id)
		rpc("capture_single_kletka_sync", pu_id_to_kletka_number[owner_pu_id],temp_kletka_capture_config)
	else:
		kletka_owned_by_pu_id[owner_pu_id]+=[pu_id_to_kletka_number[owner_pu_id]]
		
		
	print(str("kletka_owned_by_pu_id=",kletka_owned_by_pu_id))
	var to_glow_depends_on_owned=[]
	for amount_to_capture in range(amount):
		for klettka in kletka_owned_by_pu_id[owner_pu_id]:
			to_glow_depends_on_owned+=connected[klettka].keys()
			
		print(str("to_glow_depends_on_owned=",to_glow_depends_on_owned))
		for klekta_number in to_glow_depends_on_owned:
			if not kletka_preference[klekta_number].is_empty():
				continue
			available_to_capture.append(int(glow_array[klekta_number].name.trim_prefix("glow ")))#.visible=true
		available_to_capture=array_unique(available_to_capture)
		for already_captured_kletki in kletka_owned_by_pu_id[owner_pu_id]:
			available_to_capture.erase(already_captured_kletki)
		print("available_to_capture="+str(available_to_capture))
		choose_glowing_cletka_by_ids_array(array_unique(available_to_capture))
		await klekta_captured
		available_to_capture=[]
		to_glow_depends_on_owned=[]
		print(str("kletka_owned_by_pu_id=",kletka_owned_by_pu_id))
	pass
	
	current_action="wait"
	

func line_attack_phantasm(phantasm_config,dash:bool=false):
	
	var amount=phantasm_config["Range"]
	var already_clicked=[]
	var temp_current_kletka=current_kletka
	var move_ck=[]
	var attacked_enemies=[]
	var phantasm_damage=phantasm_config["Damage"]
	current_action="wait"
	for count in range(amount):
		print("current_kletka="+str(temp_current_kletka)+" connected[current_kletka]="+str(connected[temp_current_kletka]))
		for i in connected[temp_current_kletka]:
			if already_clicked.has(i) or i==current_kletka:
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
		var temp_kletka_id=current_kletka
		if kletka_to_dash==-1:
			pass#no available kletki nearly impossible
		else:
			for kletka in kletki_to_dash_array:
				rpc("move_player_from_kletka_id1_to_id2",Globals.self_pu_id,temp_kletka_id,kletka,false,true)
				await get_tree().create_timer(0.5).timeout
				temp_kletka_id=kletka
			await get_tree().create_timer(2).timeout
			print("current_kletka=",current_kletka," kletka_to_dash=",kletka_to_dash)
			rpc("move_player_from_kletka_id1_to_id2",Globals.self_pu_id,current_kletka,kletka_to_dash)


	await await_dice_roll()
	await hide_dice_rolls_with_timeout(1)
	
	for kletka in already_clicked:
		if kletka in occupied_kletki.keys():
			var pu_id_to_attack = players_handler.servant_name_to_pu_id[occupied_kletki[kletka].name]
			if pu_id_to_attack==Globals.self_pu_id:
				rpc("line_attack_add_remove_kletka_number",kletka,"remove")
				await get_tree().create_timer(1).timeout
				continue
			var etmp=await attack_player_on_kletka_id(kletka,"Phantasm",false,phantasm_config)
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

		# Если клетка не занята — возвращаем её
		if not occupied_kletki.has(current):
			return current

		# Обходим соседей
		for neighbor in connected.get(current, {}).keys():
			if not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)

	# Если не нашли свободную клетку
	return -1


func _on_make_action_pressed():
	items_button.visible=true
	blinking_glow_button=false
	glow_cletki_node.visible=false
	
	
	
	print(str("players_handler.pu_id_to_items_owned=",players_handler.pu_id_to_items_owned))
	if players_handler.pu_id_to_items_owned[Globals.self_pu_id].is_empty():
		items_button.visible=false
	else:
		#{ "Name": &"Heal Potion", "Effect": [{ "Name": "Heal", "Power": 5 }] }
		print("players_handler.pu_id_to_items_owned[Globals.self_pu_id]="+str(players_handler.pu_id_to_items_owned[Globals.self_pu_id]))
	var max_hit= players_handler.pu_id_has_buff(Globals.self_pu_id,"Maximum Hits Per Turn")
	
	var maximum_skills=players_handler.pu_id_has_buff(Globals.self_pu_id,"Maximum Skills Per Turn")


	if maximum_skills:
		var used_skills_this_turn=players_handler.pu_id_player_game_stat_info[Globals.self_pu_id]["skill_used_this_turn"]
		if used_skills_this_turn>=maximum_skills["Power"]:
			$GUI/actions_buttons/Skill.disabled=true
			print("max skills reached")
		else:
			$GUI/actions_buttons/Skill.disabled=false
			print("max skills not reached")
	else:
		$GUI/actions_buttons/Skill.disabled=false


	print("\nmax_hit="+str(max_hit or false))
	if max_hit:
		
		print("\n\nmax hit is true")
		print(max_hit)
		var attacked_this_turn=players_handler.pu_id_player_game_stat_info[Globals.self_pu_id]["attacked_this_turn"]
		print("attacked_this_turn="+str(attacked_this_turn))
		
		if attacked_this_turn>=max_hit["Power"]:
			$GUI/actions_buttons/Attack.disabled=true
			print("max hit reached")
		else:
			$GUI/actions_buttons/Attack.disabled=false
			print("max hit not reached")
	else:
		$GUI/actions_buttons/Attack.disabled=false
		
	
	hide_all_gui_windows("actions_buttons")
	#actions_buttons.visible=!actions_buttons.visible
	pass # Replace with function body.


func _on_end_turn_pressed():
	blinking_glow_button=false
	blink_timer_node.timeout.emit()
	#current_action_points=3
	#current_action_points_label.text=str(current_action_points)
	disable_every_button(false)#if paralysis
	make_action_button.disabled=true
	end_turn_button.disabled=true
	print(players_handler.trigger_buffs_on)
	await players_handler.trigger_buffs_on(Globals.self_pu_id,"End Turn")
	await players_handler.reduce_all_cooldowns(Globals.self_pu_id, "End Turn")
	players_handler.rpc("pass_next_turn",Globals.self_pu_id)
	
	pass # Replace with function body.


func _on_skill_pressed():
	print(occupied_kletki)
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

func fill_are_you_sure_screen(text:String=""):
	are_you_sure_label.text="Are you sure you want to:\n"+text
	are_you_sure_main_container.visible=true

func _on_im_sure_button_pressed():
	are_you_sure_main_container.visible=false
	#are_you_sure_result="yes"
	#are_you_sure_signal.emit()
	emit_signal("are_you_sure_signal", "yes")
	
	pass # Replace with function body.


func _on_im_not_sure_button_pressed():
	are_you_sure_main_container.visible=false
	#are_you_sure_result="no"
	emit_signal("are_you_sure_signal", "no")
	#are_you_sure_signal.emit()
	
	pass # Replace with function body.


func _on_dices_toggle_button_pressed():
	var vis=roll_dice_control_container.visible
	roll_dice_control_container.visible= !vis
	dice_holder_hbox.visible= !vis
	for pu_id in Globals.pu_id_player_info.keys():
		print(Globals.pu_id_player_info[pu_id]["servant_node"].buffs)
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

func hide_all_gui_windows(except_name="all"):
	if except_name!="servant_info_main_container":
		players_handler.player_info_button_current_pu_id=""
	print("hide_all_gui_windows= "+str(except_name))
	match except_name:
		"all":
			players_handler.servant_info_main_container.visible=false
			skill_info_tab_container.visible=false
			menu_vbox_container.visible=false
			actions_buttons.visible=false
			players_handler.use_custom_but_label_container.visible=false
			players_handler.custom_choices_tab_container.visible=false
			use_skill_but_label_container.visible=false
			command_spell_choices_container.visible=false
		"servant_info_main_container":
			players_handler.servant_info_main_container.visible=!players_handler.servant_info_main_container.visible
			skill_info_tab_container.visible=false
			actions_buttons.visible=false
			players_handler.use_custom_but_label_container.visible=false
			players_handler.custom_choices_tab_container.visible=false
			use_skill_but_label_container.visible=false
			command_spell_choices_container.visible=false
			menu_vbox_container.visible=false
		"skill_info_tab_container":
			skill_info_tab_container.visible=!skill_info_tab_container.visible
			use_skill_but_label_container.visible=!use_skill_but_label_container.visible
			actions_buttons.visible=false
			players_handler.use_custom_but_label_container.visible=false
			players_handler.custom_choices_tab_container.visible=false
			players_handler.servant_info_main_container.visible=false
			command_spell_choices_container.visible=false
			menu_vbox_container.visible=false
		"actions_buttons": 
			actions_buttons.visible=!actions_buttons.visible
			skill_info_tab_container.visible=false
			players_handler.use_custom_but_label_container.visible=false
			players_handler.custom_choices_tab_container.visible=false
			players_handler.servant_info_main_container.visible=false
			use_skill_but_label_container.visible=false
			command_spell_choices_container.visible=false
			menu_vbox_container.visible=false
		"use_custom":
			players_handler.use_custom_but_label_container.visible=!players_handler.use_custom_but_label_container.visible
			players_handler.custom_choices_tab_container.visible=!players_handler.custom_choices_tab_container.visible
			skill_info_tab_container.visible=false
			players_handler.servant_info_main_container.visible=false
			use_skill_but_label_container.visible=false
			actions_buttons.visible=false
			command_spell_choices_container.visible=false
			menu_vbox_container.visible=false
		"command_spells":
			command_spell_choices_container.visible=!command_spell_choices_container.visible
			players_handler.use_custom_but_label_container.visible=false
			players_handler.custom_choices_tab_container.visible=false
			skill_info_tab_container.visible=false
			players_handler.servant_info_main_container.visible=false
			use_skill_but_label_container.visible=false
			actions_buttons.visible=false
			menu_vbox_container.visible=false
		"menu":
			command_spell_choices_container.visible=false
			players_handler.use_custom_but_label_container.visible=false
			players_handler.custom_choices_tab_container.visible=false
			skill_info_tab_container.visible=false
			players_handler.servant_info_main_container.visible=false
			use_skill_but_label_container.visible=false
			actions_buttons.visible=false
			menu_vbox_container.visible=!menu_vbox_container.visible

func _on_self_info_show_button_pressed():
	hide_all_gui_windows("servant_info_main_container")
	#players_handler.servant_info_main_container.visible= !players_handler.servant_info_main_container.visible
	

	pass # Replace with function body.


func _on_class_skill_tab_changed(_tab):
	_on_skill_info_tab_container_tab_changed()

func _on_skill_info_tab_container_tab_changed(tab=-1):
	if tab==-1:
		tab=skill_info_tab_container.current_tab
	use_skill_button.disabled=true
	var skills_available=true
	var servant_skills:Dictionary=Globals.pu_id_player_info[Globals.self_pu_id]["servant_node"].skills
	var skill_info


	var is_skill_free_from_actions=false
	if !my_turn:
		skills_available=false
	for buff in Globals.self_servant_node.buffs:
		if buff["Name"]=="Skill Seal":
			skills_available=false
			break



	var maximum_skills=players_handler.pu_id_has_buff(Globals.self_pu_id,"Maximum Skills Per Turn")

	if maximum_skills:
		var used_skills_this_turn=players_handler.pu_id_player_game_stat_info[Globals.self_pu_id]["skill_used_this_turn"]
		print("used_skills_this_turn=",used_skills_this_turn," =maximum_skills['Power']=",maximum_skills["Power"])
		if used_skills_this_turn>=maximum_skills["Power"]:
			skills_available=false
			print("max skills reached")
		else:
			skills_available=true
			print("max skills not reached")
	var skill_cooldown=0
	match tab:
		0:
			skill_cooldown=Globals.self_servant_node.skill_cooldowns[0]
			skill_info=servant_skills.get("First Skill")
		1:
			skill_cooldown=Globals.self_servant_node.skill_cooldowns[1]
			skill_info=servant_skills.get("Second Skill")
		2:
			skill_cooldown=Globals.self_servant_node.skill_cooldowns[2]
			skill_info=servant_skills.get("Third Skill")
		3:
			var class_skill_number=skill_info_tab_container.get_current_tab_control().current_tab+1
			skill_info=servant_skills.get("Class Skill "+str(class_skill_number),{})
			if skill_info.is_empty():
				skills_available=false
			else:
				skill_cooldown=Globals.self_servant_node.skill_cooldowns[2+class_skill_number]
	
	if not skill_info.get("Consume Action",true):
		is_skill_free_from_actions=true


	if (skill_cooldown==0 or is_skill_free_from_actions) and current_action_points>0 and skills_available:
		use_skill_button.disabled=false
	else:
		print("Skills blocked")
		print("skill_cooldown==0: "+str(skill_cooldown==0))
		print("current_action_points>0   = "+str(current_action_points>0))
		print("skills_available="+str(skills_available))
		
	current_skill_cooldown_label.text=str("Cooldown: ",skill_cooldown)
	pass # Replace with function body.


func _on_refresh_buffs_button_pressed():
	var buffs=Globals.self_servant_node.buffs
	var display_buffs=""
	
	var buff_duration
	for buff in buffs:
		buff_duration=buff.get("Duration","-")
		display_buffs+=str(buff["Name"],"(",buff_duration,")\n")
	$GUI/buffs_temp_container/buffs_label.text="Buffs:"+display_buffs
	pass # Replace with function body.


func _on_command_spells_button_pressed():
	if players_handler.pu_id_to_command_spells_int[Globals.self_pu_id]<=0:
		return
	hide_all_gui_windows("command_spells")
	
	pass # Replace with function body.


func _on_command_spell_heal_button_pressed():
	hide_all_gui_windows("command_spells")
	var pu_id_to_cast_to=Globals.self_pu_id
	if players_handler.pu_id_has_buff(Globals.self_pu_id,"Code Cast"):
		pu_id_to_cast_to=await players_handler.choose_allie()
		pu_id_to_cast_to=pu_id_to_cast_to[0]
	players_handler.heal_pu_id(pu_id_to_cast_to,0,"command_spell")
	players_handler.rpc("reduce_command_spell_on_pu_id",Globals.self_pu_id)
	
	players_handler.reduce_command_spell_on_pu_id(Globals.self_pu_id)
	pass # Replace with function body.


func _on_command_spell_np_charge_button_pressed():
	hide_all_gui_windows("command_spells")
	var pu_id_to_cast_to=Globals.self_pu_id
	if players_handler.pu_id_has_buff(Globals.self_pu_id,"Code Cast"):
		pu_id_to_cast_to=await players_handler.choose_allie()
		pu_id_to_cast_to=pu_id_to_cast_to[0]

	players_handler.rpc("change_phantasm_charge_on_pu_id",pu_id_to_cast_to,6)
	
	players_handler.reduce_command_spell_on_pu_id(Globals.self_pu_id)
	pass # Replace with function body.


func _on_command_spell_add_moves_button_pressed():
	hide_all_gui_windows("command_spells")
	var pu_id_to_cast_to=Globals.self_pu_id
	if players_handler.pu_id_has_buff(Globals.self_pu_id,"Code Cast"):
		pu_id_to_cast_to=await players_handler.choose_allie()
		pu_id_to_cast_to=pu_id_to_cast_to[0]
	#Globals.self_servant_node.additional_moves+=3
	players_handler.rpc("reduce_additional_moves_for_pu_id",pu_id_to_cast_to,-3)
	players_handler.reduce_command_spell_on_pu_id(Globals.self_pu_id)
	pass # Replace with function body.


func get_players_array_sorted_by_points():
	var points=[]
	var pu_id_to_points={}
	var stat_dic=players_handler.pu_id_player_game_stat_info
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


func _on_command_spell_transfer_button_pressed():
	hide_all_gui_windows("command_spells")


	info_table_show("Choose player to transfer command spell to")
	await info_ok_button.pressed
	var pu_id_to_cast_to=await players_handler.choose_single_in_range(999)
	pu_id_to_cast_to=pu_id_to_cast_to[0]

	if players_handler.pu_id_to_command_spells_int[pu_id_to_cast_to]>=3:
		info_table_show("Player has maximum command spells, transfer failed")
		await info_ok_button.pressed
		return
	players_handler.rpc("reduce_command_spell_on_pu_id",pu_id_to_cast_to,-1)
	players_handler.reduce_command_spell_on_pu_id(pu_id_to_cast_to,-1)
	players_handler.rpc("reduce_command_spell_on_pu_id",Globals.self_pu_id)
	players_handler.reduce_command_spell_on_pu_id(Globals.self_pu_id)
	
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
			$GUI/disconnect_alert_panel/disconnect_alert_label.text="Someone disconnected\nawaiting reconnection"
		else:
			$GUI/disconnect_alert_panel/disconnect_alert_label.text=disconnect_names

	$GUI/disconnect_alert_panel.visible=peer_disconnected


func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		if OS.has_feature("editor"):
			$GUI/menu_vbox_container/disconnect_Button.visible=true
			$GUI/menu_vbox_container/reconnect_button.visible=true
		hide_all_gui_windows("menu")

func _on_disconnect_button_pressed():
	Globals.disconnection_request.emit()
	pass # Replace with function body.


func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_reconnect_button_pressed():
	Globals.reconnect_requested.emit()
	pass # Replace with function body.

signal refresh_data_get(refresh_data:Dictionary)

@rpc("any_peer","reliable","call_local")
func request_data_from_host_to_refresh():
	var sender_peer_id = multiplayer.get_remote_sender_id()
	var refresh_data:Dictionary={}
	refresh_data["pu_id_player_info"]=Globals.pu_id_player_info.duplicate(true)
	refresh_data["servant_data"]={}
	for pu_id in Globals.pu_id_player_info:
		var pu_serv_node=Globals.pu_id_player_info[pu_id]["servant_node"]
		if pu_serv_node!=null:
			refresh_data["servant_data"]={
				"buffs": pu_serv_node.buffs.duplicate(true),
				"skill_cooldowns": pu_serv_node.skill_cooldowns.duplicate(true),
				"additional_moves": pu_serv_node.additional_moves,
				"additional_attack": pu_serv_node.additional_attack,
				"phantasm_charge": pu_serv_node.phantasm_charge,
				"hp": pu_serv_node.hp
			}
	
	
	
	refresh_data["peer_to_persistent_id"]=Globals.peer_to_persistent_id.duplicate(true)
	refresh_data["pu_id_to_kletka_number"]=pu_id_to_kletka_number.duplicate(true)
	refresh_data["is_game_started"]=is_game_started.duplicate(true)
	refresh_data["pu_id_to_np_points"]=players_handler.pu_id_to_np_points.duplicate(true)

	refresh_data["occupied_kletki"]=occupied_kletki.duplicate(true)
	refresh_data["pu_id_to_kletka_number"]=pu_id_to_kletka_number.duplicate(true)
	refresh_data["kletka_preference"]=kletka_preference.duplicate(true)
	refresh_data["pole_generated_seed"]=pole_generated_seed.duplicate(true)

	
	#refresh_data["kletka_owned_by_pu_id"]=kletka_owned_by_pu_id.duplicate(true)

	rpc_id(sender_peer_id,"get_data_nedded_for_refresh",refresh_data)
	pass


@rpc("authority","reliable","call_local")
func get_data_nedded_for_refresh(refresh_data:Dictionary):
	refresh_data_get.emit(refresh_data)
	pass

func refresh_everything_from_host():
	rpc_id(1,"request_data_from_host_to_refresh")
	var refresh_data:Dictionary=await refresh_data_get
	is_game_started=refresh_data["is_game_started"]
	if is_game_started:
		pass
		for pu_id in refresh_data["pu_id_player_info"].keys():
			var pu_id_data:Dictionary=refresh_data["pu_id_player_info"][pu_id]
			Globals.pu_id_player_info={}
			Globals.pu_id_player_info[pu_id]=pu_id_data.duplicate(true)
			if pu_id_data["servant_name"]!=null:

				players_handler.load_servant(pu_id)
				Globals.pu_id_player_info[pu_id]["servant_node"].buffs=pu_id_data["servant_node"].buffs.duplicate(true)
				Globals.pu_id_player_info[pu_id]["servant_node"].skill_cooldowns=pu_id_data["servant_node"].skill_cooldowns.duplicate(true)
				Globals.pu_id_player_info[pu_id]["servant_node"].additional_moves=pu_id_data["servant_node"].additional_moves
				Globals.pu_id_player_info[pu_id]["servant_node"].additional_attack=pu_id_data["servant_node"].additional_attack
				Globals.pu_id_player_info[pu_id]["servant_node"].phantasm_charge=pu_id_data["servant_node"].phantasm_charge
				Globals.pu_id_player_info[pu_id]["servant_node"].hp=pu_id_data["servant_node"].hp

	else:
		Globals.pu_id_player_info=refresh_data["pu_id_player_info"]

	Globals.peer_to_persistent_id=refresh_data["peer_to_persistent_id"]
	pu_id_to_kletka_number=refresh_data["pu_id_to_kletka_number"]

	players_handler.pu_id_to_np_points=refresh_data["pu_id_to_np_points"]

	occupied_kletki=refresh_data["occupied_kletki"]
	pu_id_to_kletka_number=refresh_data["pu_id_to_kletka_number"]
	for kletka_id in refresh_data["kletka_preference"].keys():
		capture_single_kletka_sync(kletka_id,refresh_data["kletka_preference"][kletka_id])
	kletka_preference=refresh_data["kletka_preference"]
	#kletka_owned_by_pu_id=refresh_data["kletka_owned_by_pu_id"]

	pole_generated_seed=refresh_data["pole_generated_seed"]
	reset_pole(pole_generated_seed)
	pass
