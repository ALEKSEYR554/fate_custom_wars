extends Node

const DATAFOUND = preload("res://datafound.png")
const DATALOST = preload("res://datalost.png")

@onready var back_button = $"../Back_button"
@onready var create_server_button = $Button # Переименовал для ясности
@onready var game_start_button = $game_start_button
@onready var nickname_edit = $nickname # Переименовал для ясности
@onready var main_menu = $".."
@onready var players_container = $players_container # Предполагаю, что это VBoxContainer или GridContainer
@onready var spin_box_max_players = $SpinBox # Для установки макс. кол-ва видимых слотов
@onready var connect_scene = $"../Connect_scene"

@onready var host_button = $Button



var peer = ENetMultiplayerPeer.new()
var player_disconnect_timers: Dictionary = {} # puid: Timer

# UI helpers
var container_slots: Array[Control] = [] # Ссылки на контролы слотов игроков в UI

func _ready():
	nickname_edit.max_length=Globals.MAX_NICKNAME_SIZE
	Globals.host_or_user = "host" # Устанавливаем роль сразу
	
	# Инициализируем UI слоты для игроков
	# Предполагаем, что у вас есть 7 слотов в players_container
	for i in range(7): # Или players_container.get_child_count()
		if i < players_container.get_child_count():
			var slot_node = players_container.get_child(i)
			container_slots.append(slot_node)
			slot_node.get_child(1).text = "Empty" # Предполагается, что 1-й ребенок - Label для имени/ID
			slot_node.get_child(0).texture = DATALOST # Предполагается, что 0-й ребенок - TextureRect для статуса
		else:
			push_warning("Not enough player slots in UI compared to hardcoded range 7.")

	update_player_list_ui() # Обновить UI при старте

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Globals.player_list_changed.connect(update_player_list_ui)



func _on_create_server_button_button_up():
	Globals.host_or_user = "host"
	
	Globals.DEFAULT_PORT=randi_range(2000,9000)
	
	host_button.text=str("Your port:\n",Globals.DEFAULT_PORT)
	if nickname_edit.text.is_empty():
		nickname_edit.grab_focus()
		OS.alert("Please enter a nickname.", "Nickname Required")
		return

	Globals.self_nickname = nickname_edit.text
	
	var error = peer.create_server(Globals.DEFAULT_PORT)
	if error != OK:
		OS.alert("Failed to create server. Error: " + str(error), "Server Error")
		return

	multiplayer.multiplayer_peer = peer
	print("Server created. Waiting for players...")

	# Хост тоже игрок
	var host_puid = Globals.self_pu_id # Используем PUID из Globals
	Globals.pu_id_player_info[host_puid] = {
		"nickname": Globals.self_nickname,
		"current_peer_id": multiplayer.get_unique_id(), # ID хоста всегда 1
		"is_connected": true,
		"disconnected_more_than_timeout":false,
		"servant_node_name":null,
		"servant_name": null,
		"servant_node": null
	}
	Globals.peer_to_persistent_id[multiplayer.get_unique_id()] = host_puid
	
	Globals.player_list_changed.emit()

	create_server_button.disabled = true
	if is_instance_valid(back_button): back_button.queue_free()
	game_start_button.disabled = false # Разрешить старт игры, если хост один


func _on_peer_connected(peer_id: int):
	print("Peer %s connected. Waiting for registration..." % peer_id)
	# На этом этапе мы еще не знаем PUID клиента. Ждем RPC от него.

func _on_peer_disconnected(peer_id: int):
	if peer_id == 1: # Хост отключился? Это не должно происходить, если сервер активен.
		print("Host somehow disconnected from itself. This is unusual.")
		return

	print("_on_peer_disconnected ",peer_id)
	
	rpc("status_of_peer_id_changed",Globals.peer_to_persistent_id[peer_id],true)

	if peer_id in Globals.peer_to_persistent_id:
		var puid = Globals.peer_to_persistent_id[peer_id]
		print("Player %s (PUID: %s, PeerID: %s) disconnected." % [Globals.pu_id_player_info[puid].nickname, puid, peer_id])
		
		if puid in Globals.pu_id_player_info:
			Globals.pu_id_player_info[puid].is_connected = false
			Globals.pu_id_player_info[puid].current_peer_id = 0 
			# Удаляем старую связь peer_id -> puid
			#Globals.peer_to_persistent_id.erase(peer_id) 
			Globals.player_list_changed.emit()
			#rpc("status_of_peer_id_changed",puid,false)
			# Запускаем таймер на полное удаление, если не переподключится
			var timer = Timer.new()
			timer.wait_time = Globals.PLAYER_DISCONNECT_TIMEOUT
			timer.one_shot = true
			timer.timeout.connect(_on_player_timeout.bind(puid))
			add_child(timer)
			timer.start()
			player_disconnect_timers[puid] = timer
			print("Started disconnect timeout for PUID: %s" % puid)
	else:
		print("Unknown peer %s disconnected (was not registered)." % peer_id)


@rpc("any_peer", "call_local", "reliable")
func register_player(puid: String, nickname: String):
	var sender_peer_id = multiplayer.get_remote_sender_id()
	print("Registration request from PeerID: %s, PUID: %s, Nickname: %s" % [sender_peer_id, puid, nickname])

	if puid in Globals.pu_id_player_info: # Это переподключение или уже существующий PUID
		print("reconnect player")
		var player_entry = Globals.pu_id_player_info[puid]
		if player_entry.is_connected and player_entry.current_peer_id != sender_peer_id:
			# Кто-то пытается использовать PUID уже подключенного игрока с другим peer_id. Подозрительно.
			# В LAN это маловероятно, но можно добавить обработку (например, кикнуть нового).
			print("Warning: PUID %s already connected with different peer_id. New connection from %s ignored." % [puid, sender_peer_id])
			# Возможно, стоит кикнуть sender_peer_id
			# multiplayer.disconnect_peer(sender_peer_id) 
			return

		player_entry.is_connected = true
		player_entry.current_peer_id = sender_peer_id
		player_entry.nickname = nickname # Может, ник изменился? Обновим.
		print("Player %s (PUID: %s) reconnected with new PeerID: %s." % [nickname, puid, sender_peer_id])
		
		# Если был таймер на удаление, отменяем его
		if puid in player_disconnect_timers:
			player_disconnect_timers[puid].stop()
			player_disconnect_timers[puid].queue_free()
			player_disconnect_timers.erase(puid)
			print("Reconnection timer for PUID %s cancelled." % puid)
	else: # Новый игрок
		print("new player")
		Globals.pu_id_player_info[puid] = {
			"nickname": nickname,
			"current_peer_id": sender_peer_id,
			"is_connected": true,
			"servant_name": null,
			"servant_node_name":null,
			"disconnected_more_than_timeout":false,
			"servant_node": null
		}
		print("New player %s (PUID: %s, PeerID: %s) registered." % [nickname, puid, sender_peer_id])

	Globals.peer_to_persistent_id[sender_peer_id] = puid
	rpc("sync_peer_ids",Globals.peer_to_persistent_id)
	
	# Отправляем всем обновленный список игроков
	#connect_scene.rpc("sync_full_player_list", Globals.pu_id_player_info.duplicate(true))
	#sync_full_player_list(Globals.pu_id_player_info)
	# И локально обновляем UI
	Globals.player_list_changed.emit()
	print("PU_ID=",puid," RECONNECTED")
	rpc("status_of_peer_id_changed",puid,false)
	
	# Отправляем новому/переподключившемуся клиенту его подтвержденный PUID и текущий peer_id
	# Хотя PUID он и так знает, а peer_id ему не особо нужен. Важнее подтверждение.
	var refresh_data:Dictionary={}
	if Globals.is_game_started:
		var field_node:Node=get_tree().root.find_child("game_field",false,false)
		if field_node!=null:
			
			refresh_data["servant_data"]={}
			for pu_id in Globals.pu_id_player_info:
				var pu_serv_node=Globals.pu_id_player_info[pu_id]["servant_node"]
				if pu_serv_node:
					refresh_data["servant_data"][pu_id]={
						"buffs": pu_serv_node.buffs.duplicate(true),
						"skill_cooldowns": pu_serv_node.skill_cooldowns.duplicate(true),
						"additional_moves": pu_serv_node.additional_moves,
						"additional_attack": pu_serv_node.additional_attack,
						"phantasm_charge": pu_serv_node.phantasm_charge,
						"hp": pu_serv_node.hp
					}
			
			refresh_data["pu_id_to_kletka_number"]=field_node.pu_id_to_kletka_number.duplicate(true)
			
			refresh_data["pu_id_to_np_points"]=field_node.players_handler.pu_id_to_np_points.duplicate(true)

			refresh_data["occupied_kletki"]={}
			for kletka_id in field_node.occupied_kletki:
				refresh_data["occupied_kletki"][kletka_id]=field_node.occupied_kletki[kletka_id].name



			refresh_data["pu_id_to_kletka_number"]=field_node.pu_id_to_kletka_number.duplicate(true)
			refresh_data["kletka_preference"]=field_node.kletka_preference.duplicate(true)
			refresh_data["pole_generated_seed"]=field_node.pole_generated_seed
		refresh_data["pu_id_player_info"]=Globals.pu_id_player_info.duplicate(true)
		refresh_data["is_game_started"]=Globals.is_game_started
		refresh_data["peer_to_persistent_id"]=Globals.peer_to_persistent_id.duplicate(true)
		
		
		connect_scene.rpc_id(sender_peer_id, "registration_successful", puid, refresh_data)
		
		var timer = Timer.new()
		timer.wait_time = Globals.PLAYER_DISCONNECT_TIMEOUT
		timer.one_shot = true
		add_child(timer)
		timer.start()
		player_disconnect_timers[puid] = timer

		await timer.timeout

		if timer.is_paused():
			#registration signal recieved from user
			pass
			connect_scene.rpc("sync_full_player_list", Globals.pu_id_player_info.duplicate(true))
		else:
			#not
			pass

		return

	var timer = Timer.new()
	timer.wait_time = Globals.PLAYER_DISCONNECT_TIMEOUT
	timer.one_shot = true
	add_child(timer)
	timer.start()
	player_disconnect_timers[puid] = timer

	await timer.timeout

	if timer.is_paused():
		#registration signal recieved from user
		pass
		connect_scene.rpc_id(sender_peer_id, "registration_successful", puid)
	else:
		#not
		pass

@rpc("any_peer", "call_local", "reliable") 
func sync_peer_ids(peer_ids=Globals.peer_to_persistent_id):
	Globals.peer_to_persistent_id=peer_ids
	



@rpc("any_peer", "call_local", "reliable") 
func registration_completed(pu_id:String):
	player_disconnect_timers[pu_id].set_paused(true)
	player_disconnect_timers[pu_id].timeout.emit()
	pass

@rpc("authority", "call_local", "reliable") 
func status_of_peer_id_changed(puid: String,disconnected:bool):
	print("status_of_peer_id_changed=",puid, " ",disconnected)
	Globals.someone_status_changed.emit(puid,disconnected)


func _on_player_timeout(puid_timed_out: String):
	print("Player PUID %s timed out. Removing permanently." % puid_timed_out)
	if puid_timed_out in Globals.pu_id_player_info:
		# Убедимся, что он все еще не подключен (на всякий случай)
		if not Globals.pu_id_player_info[puid_timed_out].is_connected:

			Globals.pu_id_player_info[puid_timed_out]["disconnected_more_than_timeout"]=true

			rpc("status_of_peer_id_changed",puid_timed_out,true)
			#Globals.pu_id_player_info.erase(puid_timed_out)
			# Нужно также обновить peer_to_persistent_id, если вдруг старый peer_id остался
			for peer_id_key in Globals.peer_to_persistent_id.keys():
				if Globals.peer_to_persistent_id[peer_id_key] == puid_timed_out:
					#Globals.peer_to_persistent_id.erase(peer_id_key)
					break
			
			connect_scene.rpc("player_timeout", puid_timed_out) # Отправить обновленный список всем
			Globals.player_list_changed.emit() # Обновить UI локально

	if puid_timed_out in player_disconnect_timers: # Удаляем таймер из словаря
		# Сам узел таймера уже должен был быть удален через queue_free() или будет удален при выходе из сцены
		player_disconnect_timers.erase(puid_timed_out)



func update_player_list_ui():
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
			slot.get_child(1).text = "%s (PUID: ...%s)" % [player_data.nickname, puid.right(6)] # Показываем ник и часть PUID
			if player_data.is_connected:
				slot.get_child(0).texture = DATAFOUND
			else:
				slot.get_child(0).texture = DATALOST # Или другая текстура "ожидание переподключения"
			slot.visible = true
			current_slot_index += 1
		else:
			print("Warning: Not enough UI slots for all players.")
			break # Закончились слоты в UI

	# Скрываем неиспользуемые слоты (начиная с current_slot_index)
	for i in range(current_slot_index, container_slots.size()):
		if i < spin_box_max_players.value : # Учитываем настройку максимального числа видимых слотов
			container_slots[i].get_child(1).text = "Empty"
			container_slots[i].get_child(0).texture = DATALOST
			container_slots[i].visible = true # Показываем пустые слоты до лимита
		else:
			container_slots[i].visible = false # Скрываем слоты сверх лимита

	# Кнопка старта игры активна, если есть хотя бы один подключенный клиент (или если разрешена игра в одиночку)
	# Это упрощенная логика, можно сделать сложнее (мин. кол-во игроков)
	var connected_clients_count = 0
	for puid in Globals.pu_id_player_info:
		if puid != Globals.self_pu_id and Globals.pu_id_player_info[puid].is_connected:
			connected_clients_count +=1
	
	# spin_box_max_players.min_value = connected_clients_count + 1 # +1 для хоста
	# Устанавливаем минимальное значение для SpinBox в зависимости от числа подключенных игроков
	# spin_box_max_players.min_value = max(1, connected_puids.size()) # Минимум 1 (хост) или текущее кол-во
	# Если у вас SpinBox определяет "максимальное число игроков в матче", а не "видимых слотов",
	# то его min_value должно быть связано с текущим числом подключенных.
	# Если он просто для UI, то эта логика не нужна здесь.

	game_start_button.disabled = connected_clients_count == 0 # Пример: можно начать, если есть хоть один клиент
	# Или game_start_button.disabled = connected_puids.size() < spin_box_max_players.min_value (если min_value это мин. игроков для старта)


func _on_game_start_button_button_up():
	# Убедимся, что все необходимые игроки готовы/подключены
	# Например, если spin_box_max_players используется для установки точного числа игроков
	var required_players = spin_box_max_players.value 
	var current_connected_players = 0
	for puid in Globals.pu_id_player_info:
		if Globals.pu_id_player_info[puid].is_connected:
			current_connected_players += 1
	
	if current_connected_players < required_players:
		OS.alert("Not enough players connected to start the game. Required: %s, Connected: %s" % [required_players, current_connected_players], "Game Start")
		return

	rpc("hide_main_menu_on_clients") # Отправляем всем клиентам
	hide_main_menu_locally()        # Выполняем локально для хоста
	
	rpc("initiate_game_on_clients") # Отправляем всем клиентам
	initiate_game_locally()         # Выполняем локально для хоста

@rpc("any_peer", "call_remote", "reliable") # Должно быть доступно для вызова клиентами, если это не так, то `authority`
func hide_main_menu_on_clients(): # Эта функция будет на клиентах
	hide_main_menu_locally()

func hide_main_menu_locally():
	main_menu.visible = false # Проще скрыть родительский узел
	# self.visible = false # Если этот узел (Host.gd) тоже часть UI лобби

@rpc("any_peer", "call_remote", "reliable")
func initiate_game_on_clients(): # Эта функция будет на клиентах
	initiate_game_locally()

func initiate_game_locally():
	# game_field = load("res://game_field.tscn") # Лучше загружать один раз в _ready или экспортировать
	print("Game initiation called by host or RPC.")
	if main_menu and main_menu.has_method("game_initiate"):
		main_menu.game_initiate()
		Globals.menu_left=true
	else:
		push_error("main_menu node or game_initiate method not found!")
	# var game_field_instanse = game_field.instantiate()
	# get_tree().root.add_child(game_field_instanse)

func _on_spin_box_value_changed(value: float):
	# Эта функция теперь должна просто обновить видимость слотов,
	# не меняя данные в Globals.pu_id_player_info
	var max_visible_slots = int(value)
	for i in range(container_slots.size()):
		if i < max_visible_slots:
			if not container_slots[i].visible: # Если был скрыт, но теперь должен быть виден
				container_slots[i].visible = true
				# Если слот пустой (нет игрока), обновим текст/текстуру
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
