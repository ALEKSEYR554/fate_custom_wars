extends Node

const DATAFOUND = preload("res://images/datafound.png")
const DATALOST = preload("res://images/datalost.png")

@onready var back_button = $"../Back_button"

@onready var host_button: Button = %host_Button
@onready var nickname_line_edit: LineEdit = %nickname_lineEdit
@onready var game_start_button: Button = %game_start_button

@onready var players_container: HBoxContainer = $players_container
@onready var players_count_spin_box: SpinBox = %players_count_SpinBox
@onready var amount_of_teams_spin_box: SpinBox = %amount_of_teams_SpinBox

@onready var main_menu = $".."
@onready var connect_scene = $"../Connect_scene"


var peer = ENetMultiplayerPeer.new()
var container_slots: Array[Control] = []

func _ready():
	
	nickname_line_edit.max_length = Globals.MAX_NICKNAME_SIZE
	
	for i in range(players_container.get_child_count()):
		var slot_node = players_container.get_child(i)
		container_slots.append(slot_node)
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(peer_id: int):
	print("Peer %s connected. Awaiting pu_id from it." % peer_id)
	#=> user_requested_registration
	

func _on_peer_disconnected(peer_id: int):
	pass

@rpc("any_peer","call_local","reliable")
func user_requested_registration(pu_id:String,nickname:String)->void:
	if multiplayer.get_unique_id()!=1:
		return
	
	
	var is_reconnecting=false
	var sender_peer_id = multiplayer.get_remote_sender_id()
	if pu_id in Globals.pu_id_player_info.keys():
		print("user requested registration already registered so reconnect attempt")
		is_reconnecting=true
		#do hot-connect thing
		if Globals.is_game_started:
			print("refreshing all data to reconnected player")
			var all_data:Dictionary=collect_all_nesessary_veriables()

		return
	
	var pu_id_info_to_send=Globals.default_pu_id_player_info_dic.duplicate(true)
	pu_id_info_to_send["current_peer_id"]=sender_peer_id
	pu_id_info_to_send["is_connected"]=true
	pu_id_info_to_send["units"]={}
	pu_id_info_to_send["nickname"]=nickname
	
	connect_scene.rpc("registration_complete",pu_id,pu_id_info_to_send.duplicate())
	update_player_list_ui()

	if Globals.is_game_started:
		print("hot-connect thing if game started")
		var all_data:Dictionary=collect_all_nesessary_veriables()
	pass


func collect_all_nesessary_veriables()->Dictionary:
	var field_node:Node=get_tree().root.find_child("game_field",false,false)
	var players_handler_node:Node=field_node.find_child("players_handler",false,false)

	var output:Dictionary={}
	output['is_game_started']=Globals.is_game_started
	output["players_handler"]={
		"turns_order_by_pu_id":players_handler_node.turns_order_by_pu_id,
		"teams_by_pu_id":players_handler_node.teams_by_pu_id,
		"turns_counter":players_handler_node.turns_counter,
		"current_player_pu_id_turn":players_handler_node.current_player_pu_id_turn,
		"unit_uniq_id_player_game_stat_info":players_handler_node.unit_uniq_id_player_game_stat_info.duplicate(true),
		"pu_id_to_command_spells_int":players_handler_node.pu_id_to_command_spells_int.duplicate(true),
		"unit_unique_id_to_items_owned":players_handler_node.unit_unique_id_to_items_owned.duplicate(true),
		"pu_id_to_inventory_array":players_handler_node.pu_id_to_inventory_array.duplicate(true),
		"servant_name_to_pu_id":players_handler_node.servant_name_to_pu_id.duplicate(true)
	}

	output["game_field"]={
		"kletka_preference":field_node.kletka_preference.duplicate(true),
		"kletka_owned_by_unit_uniq_id":field_node.kletka_owned_by_unit_uniq_id.duplicate(true),
		"pole_generated_seed":field_node.pole_generated_seed,
		"cell_positions":field_node.cell_positions.duplicate(true),
		"connected":field_node.connected.duplicate(true),
		"field_status":field_node.field_status.duplicate(true)
	}


	output["servant_data"]={}
	for pu_id in Globals.pu_id_player_info.keys():
		output["servant_data"][pu_id]={}
		for unit_id in Globals.pu_id_player_info[pu_id]["units"].keys():
			var pu_serv_node=Globals.pu_id_player_info[pu_id]["units"][unit_id]
			if pu_serv_node:
				output["servant_data"][pu_id][unit_id]={
					"buffs": pu_serv_node.buffs.duplicate(true),
					"skill_cooldowns": pu_serv_node.skill_cooldowns.duplicate(true),
					"additional_moves": pu_serv_node.additional_moves,
					"additional_attack": pu_serv_node.additional_attack,
					"phantasm_charge": pu_serv_node.phantasm_charge,
					"hp": pu_serv_node.hp
				}
			output["servant_data"][pu_id][unit_id]["meta"]={}
			for meta_name in pu_serv_node.get_meta_list():
				output["servant_data"][pu_id][unit_id]["meta"][meta_name]=pu_serv_node.get_meta(meta_name)
	

	output["occupied_kletki"]={}
	for kletka_id in field_node.occupied_kletki:
		output["occupied_kletki"][kletka_id]=[]
		for node_on_kletka in field_node.occupied_kletki[kletka_id]:
			output["occupied_kletki"][kletka_id].append(node_on_kletka.name)
	
	output["pu_id_player_info"]=Globals.pu_id_player_info.duplicate(true)
	output["is_game_started"]=Globals.is_game_started
	output["peer_to_persistent_id"]=Globals.peer_to_persistent_id.duplicate(true)
	output["pu_id_to_allies"]=Globals.pu_id_to_allies.duplicate(true)
	output["connected_players"]=Globals.connected_players
	return output

func _on_players_count_spin_box_value_changed(value: float) -> void:
	if %amount_of_teams_SpinBox.value>value:
		%amount_of_teams_SpinBox.value=value
	var max_visible_slots = int(value)
	for i in range(container_slots.size()):
		if i < max_visible_slots:
			if not container_slots[i].visible:
				container_slots[i].visible = true
				
				var found_player_for_slot = false
				var _player_index_counter = 0
				if i == 0 and Globals.self_pu_id in Globals.pu_id_player_info: # Хост
					found_player_for_slot = true
				else: # Клиенты
					var client_slot_index = i -1 # Слот для первого клиента
					var current_client_scanned = 0
					for puid_scan in Globals.pu_id_player_info:
						if puid_scan == Globals.self_pu_id: continue
						if current_client_scanned == client_slot_index:
							found_player_for_slot = true
							break
						current_client_scanned += 1
				
				if not found_player_for_slot: # Если для этого видимого слота нет игрока
					container_slots[i].get_child(1).text = "Empty"
					container_slots[i].get_child(0).texture = DATALOST
		else:
			container_slots[i].visible = false
	# После изменения видимости, можно вызвать update_player_list_ui для корректного заполнения
	update_player_list_ui()
	pass # Replace with function body.


func update_player_list_ui()->void:
	print("Updating player list UI. Players info: ", Globals.pu_id_player_info)
	if Globals.is_game_started:
		print("game started, no need for UI update")
		return
	var _connected_puids = Globals.get_connected_persistent_ids()
	
	# Сначала хост
	if Globals.self_pu_id in Globals.pu_id_player_info:
		var host_data = Globals.pu_id_player_info[Globals.self_pu_id]
		if 0 < container_slots.size(): # Первый слот для хоста
			container_slots[0].get_child(1).text = "%s (Host)" % host_data.nickname
			container_slots[0].get_child(0).texture = DATAFOUND
			container_slots[0].visible = true

	var current_slot_index = 1 # Начинаем со второго слота для клиентов
	for puid in Globals.pu_id_player_info:
		if puid == Globals.self_pu_id: continue # Пропускаем хоста, уже обработали

		if current_slot_index < container_slots.size():
			var player_data = Globals.pu_id_player_info[puid]
			var slot = container_slots[current_slot_index]
			slot.get_child(1).text = "%s" % [player_data.nickname]
			if player_data.is_connected:
				slot.get_child(0).texture = DATAFOUND
			else:
				slot.get_child(0).texture = DATALOST 
			slot.visible = true
			current_slot_index += 1
		else:
			print("Warning: Not enough UI slots for all players.")
			break # Закончились слоты в UI

	
	for i in range(current_slot_index, container_slots.size()):
		if i < players_count_spin_box.value: 
			container_slots[i].get_child(1).text = "Empty"
			container_slots[i].get_child(0).texture = DATALOST
			container_slots[i].visible = true 
		else:
			container_slots[i].visible = false 

	var connected_clients_count = 0
	for puid in Globals.pu_id_player_info:
		if puid != Globals.self_pu_id and Globals.pu_id_player_info[puid].is_connected:
			connected_clients_count +=1
	
	game_start_button.disabled = connected_clients_count == 0


func _on_amount_of_teams_spin_box_value_changed(value: float) -> void:
	if value>players_count_spin_box.value:
		%amount_of_teams_SpinBox.value=value-1
	
	Globals.start_teams_amount=%amount_of_teams_SpinBox.value
	pass # Replace with function body.


func _on_game_start_button_pressed() -> void:
	
	Globals.start_teams_amount=amount_of_teams_spin_box.value
	pass # Replace with function body.


func _on_host_button_pressed() -> void:
	if nickname_line_edit.text.is_empty():
		OS.alert("Please enter a nickname.", "Nickname Required")
		return

	Globals.self_nickname = nickname_line_edit.text
	
	var amount_of_players=players_count_spin_box.value
	
	var port = Globals.DEFAULT_PORT
	
	var error = peer.create_server(port)
	
	if error != OK:
		OS.alert("Failed to create server on port %s. It might be in use." % port, "Server Error")
		return

	multiplayer.multiplayer_peer = peer
	
	host_button.text = "Port: %s" % port
	host_button.disabled = true
	if is_instance_valid(back_button): back_button.queue_free()
	game_start_button.disabled = false
	nickname_line_edit.editable = false
	update_player_list_ui()
	pass # Replace with function body.
