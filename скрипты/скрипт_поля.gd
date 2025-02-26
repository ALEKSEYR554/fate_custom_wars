extends Node2D
#1717486472.816
#1717743283.689
var glow_array=[]
const Glow = preload("res://glow.tscn")
var time
var glowing_kletka_number_selected
var is_game_started=false
@onready var players_handler = $players_handler
var is_pole_generated=false
@onready var character_selection_container = $GUI/character_selection_container
@onready var alert_label = $GUI/alert_label

var glow_cletki_node
var captured_kletki_node=null
var captured_kletki_nodes_dict={}

# kletka: who is there node2d
#{ 6: el_melloy:<Node2D#62159586689>, 25: bunyan:<Node2D#61807265149>}
var occupied_kletki={}
var peer_id_to_kletka_number={}
#kletka_preference[cletka_id]=config
var kletka_preference={}
#peer_id:[cletka_id,kletka_id]
var kletka_owned_by_peer_id={}
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

var dice_roll_result_list={"main_dice":0,"crit_dice":0,"defence_dice":0,"additional_d6":0,"additional_d6_2":0,"additional_d100":0}
var recieved_dice_roll_result
var attacking_player_on_kletka_id
var attacking_peer_id


const CapturedKletkaScript = preload("res://скрипты/captured_kletka_script.gd")
signal glow_kletka_pressed_signal


var blinking_glow_button
var blink_timer_node

var done_blinking=false
signal done_blinking_signal

const ANGRA = preload("res://player.tscn")
const cell_scene = preload("res://клетка.tscn")

@onready var actions_buttons = $GUI/actions_buttons

@onready var current_action_points_label = $GUI/action/current_actions
@onready var make_action_button = $GUI/make_action
@onready var items_button = $GUI/actions_buttons/Items


@onready var are_you_sure_main_container = $GUI/are_you_sure_main_container
@onready var are_you_sure_label = $GUI/are_you_sure_main_container/are_you_sure_label
@onready var im_sure_button = $GUI/are_you_sure_main_container/are_you_sure_buttons_container/im_sure_button
signal are_you_sure_signal


@onready var im_not_sure_button = $GUI/are_you_sure_main_container/are_you_sure_buttons_container/im_not_sure_button

var are_you_sure_result#"yes","no"

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
var attacked_by_peer_id

signal attack_response

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


# Словарь позиций клеток, где ключ - индекс клетки, значение - позиция клетки
var cell_positions = {}
# Словарь соединений, где connected[i][j] == true, если клетка i соединена с клеткой j
var connected = {}


@onready var host_buttons = $GUI/host_buttons

func _ready():
	character_selection_container.visible=true
	if Globals.host_or_user=='host':
		pass
		#host_buttons.visible=true
	#gui.z_index=99
	players_handler.fuck_you()
	#print(get_all_children(self))

@rpc("call_local","reliable")
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

func get_random_unoccupied_kletka():
	var rand_kletka
	for p in range(10):
		rand_kletka=int(round(randf_range(0,cell_count-1)))
		if !occupied_kletki.has(rand_kletka):
			break
	return rand_kletka

func get_kletki_ids_with_enemies_you_can_reach_in_steps(steps):
	#current_kletka
	var output=[]
	var path=[]
	for end in occupied_kletki.keys():
		if current_kletka == end:
			continue
		var queue = []
		var visited = {}
		queue.append([current_kletka, 0])
		visited[current_kletka] = true
		while not queue.is_empty():
			var current = queue.front()
			queue.pop_front()
			var current_node = current[0]
			var current_steps = current[1]
			if current_steps >= steps:
				continue
			for neighbor in connected[current_node].keys():
				if neighbor == end:
					if !output.has(neighbor):
						output.append(neighbor)
				if not visited.has(neighbor):
					visited[neighbor] = true
					queue.append([neighbor, current_steps + 1])
	output.erase(current_kletka)
	return output

# Функция для определения пути между клетками через N шагов (BFS способ)
func get_path_in_n_steps(start, end, steps):
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



func pull_enemy(enemy_peer_id):
	current_action="emeny pulling"
	enemy_to_pull=enemy_peer_id
	var path=get_path_in_n_steps(current_kletka,peer_id_to_kletka_number[enemy_peer_id],999)
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
	for j in range(cell_count):
		var new_position = generate_random_position(preset_time)
		if new_position != Vector2():
			cell_positions[i] = new_position
			kletka_preference[i]="none"
			var cell_instance = cell_scene.instantiate()
			add_child(cell_instance,true)
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
	add_child(line,true)
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


@rpc("call_local")
func reset_pole(cur_time):
	is_pole_generated=true
	for i in get_all_children(self):
		pass
	for i in get_all_children(self):
		if i.name.contains("клетка") or i.name.contains("Line2D") or i.name.contains("angra"):
			remove_child(i)
		#print(i.name)
	generate_pole(cur_time)

func _on_reset_pressed():
	time=Time.get_unix_time_from_system()
	rpc("reset_pole",time)

func glow_cletki_intiate():
	glow_array=[]
	glow_cletki_node=Node2D.new()
	glow_cletki_node.name="Glow_cletki_node"
	add_child(glow_cletki_node,true)
	for i in get_all_children(self):
		if str(i.name).contains("клетка"):
			var kletka_numebr=int(i.name.trim_prefix("клетка "))
			var pos = cell_positions[int(kletka_numebr)]
			var glow = Glow.instantiate()
			glow.visible=false
			glow_cletki_node.add_child(glow,true)
			glow.position = pos
			glow.name="glow "+str(kletka_numebr)
			#glow.button_down.connect(glow_cletka_pressed)
			#print(glow.name)

			glow.button_down.connect(glow_cletka_pressed.bind(glow))
			glow_array.append(glow)

func add_all_additional_nodes():
	print("add_all_additional_nodes")
	captured_kletki_node=Node2D.new()
	captured_kletki_node.name="Captured_kletki_node"
	add_child(captured_kletki_node,true)
	print("-add_all_additional_nodes----")
	

func get_unoccupied_kletki():
	var output=[]
	for i in range(glow_array.size()):
		if occupied_kletki.has(i):
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
			rpc("move_player_from_kletka_id1_to_id2",Globals.self_peer_id,-1,glowing_kletka_number_selected)
			current_kletka=glowing_kletka_number_selected
			print("current kletka="+str(current_kletka))
			print(connected[current_kletka])
			#make_action_button.disabled=false
			right_ange_buttons_container.visible=true
			$GUI/ChatLog_container/HBoxContainer/Chat_send_button.disabled=false
			
			players_handler.current_hp_value_label.text=str(Globals.self_servant_node.hp)
			players_handler.rpc("pass_next_turn",Globals.self_peer_id)
			is_game_started=true
		"field capture":
			rpc("sync_owned_kletki",kletka_owned_by_peer_id)
			rpc("capture_single_kletka_sync", glowing_kletka_number_selected,temp_kletka_capture_config)
			print("temp_kletka_capture_config  222="+str(temp_kletka_capture_config))
			klekta_captured.emit()
		"move":
			current_action="wait"
			print("cr-klet="+str(current_kletka))
			
			var cn=connected[current_kletka]
			print("cn= "+str(cn))
			for i in cn:
				if occupied_kletki.has(i):
					continue
				glow_array[i].visible=true
			pass
			if Globals.self_servant_node.additional_moves>=1:
				players_handler.rpc("reduce_additional_moves_for_peer_id",Globals.self_peer_id)
			else:
				reduce_one_action_point()
			#move_player_from_kletka_id1_to_id2(Globals.self_peer_id,current_kletka,glowing_kletka_number_selected)
			rpc("move_player_from_kletka_id1_to_id2",Globals.self_peer_id,current_kletka,glowing_kletka_number_selected)
			current_kletka=glowing_kletka_number_selected
		"attack":
			attacking_player_on_kletka_id=glowing_kletka_number_selected
			#SHIT START
			attacking_peer_id=occupied_kletki[glowing_kletka_number_selected].name
			attacking_peer_id=players_handler.servant_name_to_peer_id[attacking_peer_id]
			#SHIT END
			await attack_player_on_kletka_id(attacking_player_on_kletka_id,damage_type)
			players_handler.peer_id_player_game_stat_info[Globals.self_peer_id]["attacked_this_turn"]+=1
		"choose_allie":
			print("occupied_kletki="+str(occupied_kletki))
			players_handler.choosen_allie_return_value=occupied_kletki[glowing_kletka_number_selected]
			players_handler.chosen_allie.emit()
		"emeny pulling":
			var atk_id=attacking_peer_id
			rpc("move_player_from_kletka_id1_to_id2",atk_id,peer_id_to_kletka_number[atk_id],glowing_kletka_number_selected)
			
			
	glow_kletka_pressed_signal.emit()

@rpc("any_peer","call_local","reliable")
func capture_single_kletka_sync(glowing_kletka_number_selected,temp_kletka_capture_config):
	if typeof(captured_kletki_node)==TYPE_NIL:
		captured_kletki_node=Node2D.new()
		captured_kletki_node.name="Captured_kletki_node"
		add_child(captured_kletki_node,true)
	print(str(glowing_kletka_number_selected," is captured"))
	kletka_preference[glowing_kletka_number_selected]=temp_kletka_capture_config
	kletka_owned_by_peer_id[temp_kletka_capture_config["Owner"]].append(glowing_kletka_number_selected)
	
	var captur_klet=Node2D.new()
	var pos = cell_positions[int(glowing_kletka_number_selected)]
	captur_klet.position = pos
	captur_klet.name="glow "+str(glowing_kletka_number_selected)
	
	captur_klet.set_script(CapturedKletkaScript)
	captur_klet.color=Color.DARK_BLUE
	captured_kletki_node.add_child(captur_klet,true)
	captured_kletki_nodes_dict[glowing_kletka_number_selected]=captur_klet

func reduce_one_action_point(amount_to_reduce=-1):
	current_action_points+=amount_to_reduce
	current_action_points_label.text=str(current_action_points)
	if current_action_points==0:
		make_action_button.disabled=true

@rpc("any_peer","call_local","reliable")
func move_player_from_kletka_id1_to_id2(peer_id,current_kletka_local,glowing_kletka_number_selected,is_partial=false):
	print("_________________movement______________-")
	print("peer_id="+str(peer_id)+" players_handler.peer_id_player_info="+str(players_handler.peer_id_player_info))
	
	var player_node_to_move=players_handler.peer_id_player_info[peer_id]["servant_node"]
	
	
	var chastei=10
	var addition=0
	if is_partial:
		addition=-3
		
	if current_kletka_local!=-1:
		print("player_node_to_move.position="+str(player_node_to_move.position)+" cell_positions[glowing_kletka_number_selected]="+str(cell_positions[glowing_kletka_number_selected]))
		print("player_node_to_move.position="+str(player_node_to_move.position)+" cell_positions[current_kletka_local]="+str(cell_positions[current_kletka_local]))
		var one=player_node_to_move.position.round()!=cell_positions[glowing_kletka_number_selected].round()
		var second=player_node_to_move.position.round()!=cell_positions[current_kletka_local].round()
		if one and second:
			addition=0
	
	
	
	#cell_positions[glowing_kletka_number_selected]
					#from 											to
	var mnoghitel=(cell_positions[glowing_kletka_number_selected]-player_node_to_move.position)/chastei
	
	
	for i in range(chastei+addition):
		player_node_to_move.position+=mnoghitel
		await get_tree().create_timer(0.01).timeout
	
	if not is_partial:
		if current_kletka_local!=-1:
			occupied_kletki.erase(current_kletka_local)
		occupied_kletki[glowing_kletka_number_selected]=player_node_to_move
		peer_id_to_kletka_number[peer_id]=glowing_kletka_number_selected
	pass
	
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
	for child in get_all_children($GUI):
		if "Button" in str(child.get_class()):
			if child.is_visible_in_tree():
				child.disabled=block
	$GUI/ChatLog_container/HBoxContainer/Chat_send_button.disabled=true
	pass

func info_table_show(text="someone forgot to set this, contact anyone, SCREAM"):
	hide_all_gui_windows()
	disable_every_button(true)
	info_label.text=text
	info_label_panel.visible=true
	info_ok_button.visible=true

func _on_info_ok_button_pressed():
	info_label_panel.visible=false
	info_ok_button.visible=false

func alert_label_text(show=false,text=""):
	
	if show:
		alert_label.visible=true
		alert_label.text=text
		alert_label.grab_focus()
	else:
		alert_label.text=""
		alert_label.visible=false
		

func attack_player_on_kletka_id(kletka_id,attack_type="Physical",phantasm_config={}):
	if attack_type=="Physical" or attack_type=="Magical":
		if attack_responce_string!="parried":
			type_of_damage_choose_buttons_box.visible=false
			are_you_sure_main_container.visible=true
			await are_you_sure_signal
			if are_you_sure_result=="no":
				return
			parry_count_max=players_handler.get_endurance_in_numbers(Globals.self_servant_node.endurance)
		else: 
			roll_dice_optional_label.text="Enemy parried, reroll"
			roll_dice_optional_label.visible=true
		await await_dice_roll()
		roll_dice_control_container.visible=false
		you_were_attacked_container.visible=false
		are_you_sure_main_container.visible=false
		
	#TODO
	#magical and physical damage difference
	var peer_id_to_attack = players_handler.servant_name_to_peer_id[occupied_kletki[kletka_id].name]
	rpc_id(peer_id_to_attack,"receice_dice_roll_results",dice_roll_result_list)
	if attack_responce_string!="parried":
		rpc_id(peer_id_to_attack,"set_action_status",Globals.self_peer_id,"getting_attacked",attack_type,phantasm_config)
	else:
		rpc_id(peer_id_to_attack,"set_action_status",Globals.self_peer_id,"parrying",attack_type,phantasm_config)
	disable_every_button()
	if attack_type=="Physical" and Globals.self_servant_node.attack_range<=2:
		rpc("move_player_from_kletka_id1_to_id2",Globals.self_peer_id,current_kletka,kletka_id,true)
	
	
	alert_label_text(true,"You've attacked an enemie, waiting for it's responce")
	await attack_response
	match attack_responce_string:
		"parried":
			parry_count_max-=1
			if parry_count_max!=0:
				current_action="wait"
				rpc("systemlog_message",str(Globals.nickname," stamina left:",parry_count_max))
				await attack_player_on_kletka_id(kletka_id,damage_type)
				await players_handler.trigger_buffs_on(Globals.self_peer_id,"enemy parried",peer_id_to_attack)
				return
		"Halfed Damage":
			players_handler.charge_np_to_peer_id_by_number(Globals.self_peer_id,1)
			current_action="wait"
			await players_handler.trigger_buffs_on(Globals.self_peer_id,"success attack",peer_id_to_attack)
			await players_handler.trigger_buffs_on(Globals.self_peer_id,"enemy halfed damage",peer_id_to_attack)
		"damaged":
			players_handler.charge_np_to_peer_id_by_number(Globals.self_peer_id,1)
			current_action="wait"
			await players_handler.trigger_buffs_on(Globals.self_peer_id,"success attack",peer_id_to_attack)
		"defending":
			players_handler.charge_np_to_peer_id_by_number(Globals.self_peer_id,1)
			current_action="wait"
			await players_handler.trigger_buffs_on(Globals.self_peer_id,"success attack",peer_id_to_attack)
			await players_handler.trigger_buffs_on(Globals.self_peer_id,"enemy defended",peer_id_to_attack)
		"evaded":
			current_action="wait"
			await players_handler.trigger_buffs_on(Globals.self_peer_id,"enemy evaded",peer_id_to_attack)
		
	roll_dice_optional_label.visible=false
	if attack_type=="Physical" and Globals.self_servant_node.attack_range<=2:
		rpc("move_player_from_kletka_id1_to_id2",Globals.self_peer_id,kletka_id,current_kletka,true)
	if attack_type!="Phantasm":
		reduce_one_action_point()
	dice_holder_hbox.visible=false
	roll_dice_control_container.visible=false
	disable_every_button(false)
	alert_label_text(false)
	return peer_id_to_attack

func roll_a_diсe():
	randomize()
	dice_roll_result_list["main_dice"]=randi_range(1,6)
	main_dice_node.roll(dice_roll_result_list["main_dice"])
	attack_label.text="Attack roll: "+str(dice_roll_result_list["main_dice"])
	
	dice_roll_result_list["crit_dice"]=randi_range(1,6)
	crit_dice_node.roll(dice_roll_result_list["crit_dice"])
	crit_label.text="Crit roll: "+str(dice_roll_result_list["crit_dice"])
	
	dice_roll_result_list["defence_dice"]=randi_range(1,4)
	defence_dice_node.roll(dice_roll_result_list["defence_dice"])
	defence_label.text="Defence roll: "+str(dice_roll_result_list["defence_dice"])
	
	dice_roll_result_list["additional_d6"]=randi_range(1,6)
	dice_roll_result_list["additional_d6_2"]=randi_range(1,6)
	dice_roll_result_list["additional_d100"]=randi_range(1,100)
	
	print(dice_roll_result_list)
	#rpc_id("receice_dice_roll_results",dice_roll_result_list)
	
	rpc("get_message",str(Globals.nickname,"'s roll"),str("main:",dice_roll_result_list["main_dice"]," crit:",dice_roll_result_list["crit_dice"]," def:",dice_roll_result_list["defence_dice"]))
	#return dice_roll_result_list

func _roll_dices_button_pressed():
	roll_a_diсe()
	rolled_a_dice.emit()
	pass

@rpc("any_peer","call_remote","reliable")
func set_action_status(by_whom_peer_id,status,attack_type="Physical",phantasm_config={}):
	self_action_status=status
	attacked_by_peer_id=by_whom_peer_id
	
	recieved_damage_type=attack_type
	recieved_phantasm_config=phantasm_config
	
	print(str("status=",status," attacked_by_peer_id=",attacked_by_peer_id))
	match status:
		"getting_attacked":
			you_were_attacked_label.text=str("You were attacked with this dice rolls:\n",
"Attack: ", recieved_dice_roll_result["main_dice"] ,"Crit: ",recieved_dice_roll_result["crit_dice"],
"\nWhat do you do?")
			if attack_type=="Phantasm":
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
	are_you_sure_main_container.visible=true
	await are_you_sure_signal
	if are_you_sure_result=="no":
		return
	
	await await_dice_roll()
	#dice_roll_result_list
	#recieved_dice_roll_result
	if dice_roll_result_list["main_dice"]>recieved_dice_roll_result["main_dice"]:
		rpc_id(attacked_by_peer_id,"answer_attack","evaded")
		rpc("systemlog_message",str(Globals.nickname," evaded by throwing ",dice_roll_result_list["main_dice"]))
	elif dice_roll_result_list["main_dice"]==recieved_dice_roll_result["main_dice"]:
		var damage_to_take=players_handler.calculate_damage_to_take(attacked_by_peer_id,recieved_dice_roll_result,recieved_damage_type,"Halfed Damage")
		
		if typeof(damage_to_take)==TYPE_STRING:
			if damage_to_take=="evaded":
				rpc_id(attacked_by_peer_id,"answer_attack","evaded")
				rpc("systemlog_message",str(Globals.nickname," evaded by buff"))
		else:
			rpc_id(attacked_by_peer_id,"answer_attack","Halfed Damage")
			rpc("systemlog_message",str(Globals.nickname," halfed damage by throwing ",dice_roll_result_list["main_dice"]))
			players_handler.rpc("take_damage_to_peer_id",Globals.self_peer_id,damage_to_take)
	else: 
		var damage_to_take=players_handler.calculate_damage_to_take(attacked_by_peer_id,recieved_dice_roll_result,recieved_damage_type)
		
		if typeof(damage_to_take)==TYPE_STRING:
			if damage_to_take=="evaded":
				rpc_id(attacked_by_peer_id,"answer_attack","evaded")
				rpc("systemlog_message",str(Globals.nickname," evaded by buff"))
		else:
			rpc_id(attacked_by_peer_id,"answer_attack","damaged")
			players_handler.rpc("take_damage_to_peer_id",Globals.self_peer_id,damage_to_take)
			rpc("systemlog_message",str(Globals.nickname," got damaged thowing ",dice_roll_result_list["main_dice"]))
	
	roll_dice_control_container.visible=false
	dice_holder_hbox.visible=false


func _on_defence_button_pressed():
	you_were_attacked_container.visible=false
	are_you_sure_main_container.visible=true
	await are_you_sure_signal
	if are_you_sure_result=="no":
		return
	
	await await_dice_roll()
	rpc_id(attacked_by_peer_id,"answer_attack","defending")
	var damage_to_take=players_handler.calculate_damage_to_take(attacked_by_peer_id,recieved_dice_roll_result,recieved_damage_type,"Defence")
		
	if typeof(damage_to_take)==TYPE_STRING:
		if damage_to_take=="evaded":
			rpc_id(attacked_by_peer_id,"answer_attack","evaded")
			rpc("systemlog_message",str(Globals.nickname," evaded by buff"))
	else:
		rpc_id(attacked_by_peer_id,"answer_attack","damaged")
		players_handler.rpc("take_damage_to_peer_id",Globals.self_peer_id,damage_to_take)
		rpc("systemlog_message",str(Globals.nickname," got damaged thowing ",dice_roll_result_list["main_dice"]))
	
	
	
	rpc("systemlog_message",str(Globals.nickname," defending by throwing ",dice_roll_result_list["defence_dice"]))
	
	dice_holder_hbox.visible=false


func _on_parry_button_pressed():
	
	#TODO fix multyparry error when only parry with no choose
	if self_action_status!="parrying":
		you_were_attacked_container.visible=false
		are_you_sure_main_container.visible=true
		await are_you_sure_signal
		if are_you_sure_result=="no":
			return
		
	await await_dice_roll()
	
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
	rpc_id(attacked_by_peer_id,"answer_attack","damaged")
	var damage_to_take=players_handler.calculate_damage_to_take(attacked_by_peer_id,recieved_dice_roll_result,recieved_damage_type)
	players_handler.rpc("take_damage_to_peer_id",Globals.self_peer_id,damage_to_take)
	dice_holder_hbox.visible=false


func _on_phantasm_evation_button_pressed():
	#TBA
	#TODO
	pass # Replace with function body.

@rpc('any_peer',"call_remote","reliable")
func answer_attack(status):
	attack_responce_string=status
	attack_response.emit()

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
	if Globals.host_or_user=="host":
		players_handler.start()
	start_button.queue_free()
	#attack_button.visible=true
	#move_button.visible=true
	#cancel_button.visible=true
	current_action_points=3
	current_action_points_label.text=str(current_action_points)
	
	
	
	#players_handler.peer_id_to_np_points["peer_id"]=0
	
	#players_handler.
	for peer_id in players_handler.peer_id_player_info.keys():
		kletka_owned_by_peer_id[peer_id]=Array()

		print(str(peer_id," kletka_owned_by_peer_id =[]"))
		print(str("kletka_owned_by_peer_id =",kletka_owned_by_peer_id))
	rpc("sync_owned_kletki",kletka_owned_by_peer_id)
	pass
	
	
@rpc("any_peer","call_local","reliable")
func sync_owned_kletki(kletka_owned_by_peer_id_local):
	kletka_owned_by_peer_id=kletka_owned_by_peer_id_local
	
@rpc("authority","call_local","reliable")
func initial_spawn():
	pass
	
@rpc("authority")
func inital_spawn_of_player():
	print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	current_action="initial_spawn"
	var kletka_to_initial_spawn=get_unoccupied_kletki()
	choose_glowing_cletka_by_ids_array(kletka_to_initial_spawn)
	
func _on_attack_pressed():
	print("_________________attack______________")
	print("occupied_kletki="+str(occupied_kletki))
	print("current_kletka="+str(current_kletka))
	if current_action_points>=1:
		type_of_damage_choose_buttons_box.visible=true
		actions_buttons.visible=false
		current_action="attack"
		pass
		#for i in occupied_kletki.keys():
		#pass


func _on_regular_damage_button_pressed():
	var attack_range=players_handler.get_peer_id_attack_range(Globals.self_peer_id)
	
	var kk=get_kletki_ids_with_enemies_you_can_reach_in_steps(attack_range)
	print(kk)
	damage_type="Physical"
	choose_glowing_cletka_by_ids_array(kk)
	for i in kk:
		print(occupied_kletki[i])
	type_of_damage_choose_buttons_box.visible=false


func _on_magical_damage_button_pressed():
	var kk=get_kletki_ids_with_enemies_you_can_reach_in_steps(3)
	print(kk)
	damage_type="Magical"
	choose_glowing_cletka_by_ids_array(kk)
	for i in kk:
		print(occupied_kletki[i])
	type_of_damage_choose_buttons_box.visible=false

func deal_damage():
	pass

@rpc("authority","call_local","reliable")
func start_turn():
	my_turn=true
	
	current_action_points=3
	current_action_points_label.text=str(current_action_points)
	make_action_button.disabled=false
	end_turn_button.disabled=false
	paralyzed=false
	players_handler.peer_id_player_game_stat_info[Globals.self_peer_id]["attacked_this_turn"]=0
	print("Current_action="+str(current_action)+"\n\n")
	if is_game_started:
		for buff in players_handler.peer_id_player_info[Globals.self_peer_id]["servant_node"].buffs:
			if buff["Name"]=="Paralysis":
				paralyzed=true
				disable_every_button()
				info_table_show("You're paralyzed\n")
				end_turn_button.disabled=false
				command_spells_button.disabled=false
	players_handler.rpc("reduce_skills_cooldowns",Globals.self_peer_id)
	players_handler.rpc("reduce_buffs_cooldowns",Globals.self_peer_id)

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
			move_ck.append(int(glow_array[i].name.trim_prefix("glow ")))#.visible=true
		pass
		choose_glowing_cletka_by_ids_array(move_ck)


func capture_field_kletki(amount,config_of_kletka):
	var available_to_capture=[]
	config_of_kletka_to_capture=config_of_kletka
	current_action="field capture"
	
	print("amount=="+str(amount))
	var owner_peer_id=config_of_kletka["Owner"]
	
	print("connected="+str(connected))
	temp_kletka_capture_config=config_of_kletka
	
	temp_kletka_capture_config.merge({"turn_casted":players_handler.turns_counter})
	
	print(str("peer_id_to_kletka_number=",peer_id_to_kletka_number))
	
	if !kletka_owned_by_peer_id.has(owner_peer_id):
		kletka_owned_by_peer_id[owner_peer_id]=[]
	
	if kletka_owned_by_peer_id[owner_peer_id]==[]:
		kletka_owned_by_peer_id[owner_peer_id]=[peer_id_to_kletka_number[owner_peer_id]]
		rpc("sync_owned_kletki",kletka_owned_by_peer_id)
		rpc("capture_single_kletka_sync", peer_id_to_kletka_number[owner_peer_id],temp_kletka_capture_config)
	else:
		kletka_owned_by_peer_id[owner_peer_id]+=[peer_id_to_kletka_number[owner_peer_id]]
		
		
	print(str("kletka_owned_by_peer_id=",kletka_owned_by_peer_id))
	var to_glow_depends_on_owned=[]
	for amount_to_capture in range(amount):
		for klettka in kletka_owned_by_peer_id[owner_peer_id]:
			to_glow_depends_on_owned+=connected[klettka].keys()
			
		print(str("to_glow_depends_on_owned=",to_glow_depends_on_owned))
		for klekta_number in to_glow_depends_on_owned:
			if typeof(kletka_preference[klekta_number])!=TYPE_STRING:
				continue
			available_to_capture.append(int(glow_array[klekta_number].name.trim_prefix("glow ")))#.visible=true
		available_to_capture=array_unique(available_to_capture)
		for already_captured_kletki in kletka_owned_by_peer_id[owner_peer_id]:
			available_to_capture.erase(already_captured_kletki)
		print("available_to_capture="+str(available_to_capture))
		choose_glowing_cletka_by_ids_array(array_unique(available_to_capture))
		await klekta_captured
		available_to_capture=[]
		to_glow_depends_on_owned=[]
		print(str("kletka_owned_by_peer_id=",kletka_owned_by_peer_id))
	pass
	
	current_action="wait"
	

func line_attack_phantasm(phantasm_config):
	
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
		choose_glowing_cletka_by_ids_array(move_ck)
		await glow_kletka_pressed_signal
		#current_action="wait"
		move_ck=[]
		print("cr-klet="+str(temp_current_kletka))
		temp_current_kletka=glowing_kletka_number_selected
		already_clicked.append(temp_current_kletka)
		rpc("line_attack_add_remove_kletka_number",glowing_kletka_number_selected,"add")
	await await_dice_roll()
	await hide_dice_rolls_with_timeout(1)
	for kletka in already_clicked:
		if kletka in occupied_kletki.keys():
			var etmp=await attack_player_on_kletka_id(kletka,"Phantasm",phantasm_config)
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


func _on_make_action_pressed():
	items_button.visible=true
	print(str("players_handler.peer_id_to_items_owned=",players_handler.peer_id_to_items_owned))
	if players_handler.peer_id_to_items_owned[Globals.self_peer_id].is_empty():
		items_button.visible=false
	else:
		#{ "Name": &"Heal Potion", "Effect": [{ "Name": "Heal", "Power": 5 }] }
		print("players_handler.peer_id_to_items_owned[Globals.self_peer_id]="+str(players_handler.peer_id_to_items_owned[Globals.self_peer_id]))
	var max_hit= players_handler.peer_id_has_buff(Globals.self_peer_id,"Maximum Hits Per Turn")
	
	print("\nmax_hit="+str(max_hit or false))
	if max_hit:
		
		print("\n\nmax hit is true")
		print(max_hit)
		var attacked_this_turn=players_handler.peer_id_player_game_stat_info[Globals.self_peer_id]["attacked_this_turn"]
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
	await players_handler.trigger_buffs_on(Globals.self_peer_id,"turn_ended")
	players_handler.rpc("pass_next_turn",Globals.self_peer_id)
	
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
	chat_log_main.scroll_vertical = INF

@rpc("any_peer","call_local","reliable")
func get_message(username,message):
	chat_log_main.text+=str(username, ": ", message, "\n")


func _on_chat_hide_show_button_pressed():
	if chat_log_container.visible:
		chat_log_container.visible=false
	else:
		chat_log_container.visible=true
	pass # Replace with function body.



func _on_im_sure_button_pressed():
	are_you_sure_main_container.visible=false
	are_you_sure_result="yes"
	are_you_sure_signal.emit()
	
	pass # Replace with function body.


func _on_im_not_sure_button_pressed():
	are_you_sure_main_container.visible=false
	are_you_sure_result="no"
	are_you_sure_signal.emit()
	
	pass # Replace with function body.


func _on_dices_toggle_button_pressed():
	var vis=roll_dice_control_container.visible
	roll_dice_control_container.visible= !vis
	dice_holder_hbox.visible= !vis
	for peer_id in players_handler.peer_id_player_info.keys():
		print(players_handler.peer_id_player_info[peer_id]["servant_node"].buffs)
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
	
	print("hide_all_gui_windows= "+str(except_name))
	match except_name:
		"all":
			players_handler.servant_info_main_container.visible=false
			skill_info_tab_container.visible=false
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
		"skill_info_tab_container":
			skill_info_tab_container.visible=!skill_info_tab_container.visible
			use_skill_but_label_container.visible=!use_skill_but_label_container.visible
			actions_buttons.visible=false
			players_handler.use_custom_but_label_container.visible=false
			players_handler.custom_choices_tab_container.visible=false
			players_handler.servant_info_main_container.visible=false
			command_spell_choices_container.visible=false
		"actions_buttons": 
			actions_buttons.visible=!actions_buttons.visible
			skill_info_tab_container.visible=false
			players_handler.use_custom_but_label_container.visible=false
			players_handler.custom_choices_tab_container.visible=false
			players_handler.servant_info_main_container.visible=false
			use_skill_but_label_container.visible=false
			command_spell_choices_container.visible=false
		"use_custom":
			players_handler.use_custom_but_label_container.visible=!players_handler.use_custom_but_label_container.visible
			players_handler.custom_choices_tab_container.visible=!players_handler.custom_choices_tab_container.visible
			skill_info_tab_container.visible=false
			players_handler.servant_info_main_container.visible=false
			use_skill_but_label_container.visible=false
			actions_buttons.visible=false
			command_spell_choices_container.visible=false
		"command_spells":
			command_spell_choices_container.visible=!command_spell_choices_container.visible
			players_handler.use_custom_but_label_container.visible=false
			players_handler.custom_choices_tab_container.visible=false
			skill_info_tab_container.visible=false
			players_handler.servant_info_main_container.visible=false
			use_skill_but_label_container.visible=false
			actions_buttons.visible=false

func _on_self_info_show_button_pressed():
	hide_all_gui_windows("servant_info_main_container")
	#players_handler.servant_info_main_container.visible= !players_handler.servant_info_main_container.visible
	

	pass # Replace with function body.


func _on_class_skill_tab_changed(tab):
	_on_skill_info_tab_container_tab_changed()

func _on_skill_info_tab_container_tab_changed(tab=-1):
	if tab==-1:
		tab=skill_info_tab_container.current_tab
	use_skill_button.disabled=true
	var skills_available=true
	
	if !my_turn:
		skills_available=false
	for buff in Globals.self_servant_node.buffs:
		if buff["Name"]=="skill seal":
			skills_available=false
			break
	var skill_cooldown=0
	match tab:
		0:
			skill_cooldown=Globals.self_servant_node.skill_cooldowns[0]
		1:
			skill_cooldown=Globals.self_servant_node.skill_cooldowns[1]
		2:
			skill_cooldown=Globals.self_servant_node.skill_cooldowns[2]
		3:
			var class_skill_number=skill_info_tab_container.get_current_tab_control().current_tab+1
			skill_cooldown=Globals.self_servant_node.skill_cooldowns[2+class_skill_number]
			
	if skill_cooldown==0 and current_action_points>0 and skills_available and current_action_points>0:
		use_skill_button.disabled=false
	current_skill_cooldown_label.text=str("Cooldown: ",skill_cooldown)
	pass # Replace with function body.


func _on_refresh_buffs_button_pressed():
	var buffs=Globals.self_servant_node.buffs
	var display_buffs=""
	for buff in buffs:
		display_buffs+=str(buff["Name"],"(",buff["Duration"],")\n")
	$GUI/buffs_temp_container/buffs_label.text="Buffs:"+display_buffs
	pass # Replace with function body.


func _on_command_spells_button_pressed():
	if players_handler.peer_id_to_command_spells_int[Globals.self_peer_id]<=0:
		return
	hide_all_gui_windows("command_spells")
	
	pass # Replace with function body.


func _on_command_spell_heal_button_pressed():
	hide_all_gui_windows("command_spells")
	
	players_handler.heal_peer_id(Globals.self_peer_id,0,"command_spell")
	players_handler.rpc("reduce_command_spell_on_peer_id",Globals.self_peer_id)
	
	players_handler.reduce_command_spell_on_peer_id(Globals.self_peer_id)
	pass # Replace with function body.


func _on_command_spell_np_charge_button_pressed():
	hide_all_gui_windows("command_spells")
	
	players_handler.rpc("change_phantasm_charge_on_peer_id",Globals.self_peer_id,6)
	
	players_handler.reduce_command_spell_on_peer_id(Globals.self_peer_id)
	pass # Replace with function body.


func _on_command_spell_add_moves_button_pressed():
	hide_all_gui_windows("command_spells")
	Globals.self_servant_node.additional_moves+=3
	players_handler.reduce_command_spell_on_peer_id(Globals.self_peer_id)
	pass # Replace with function body.


