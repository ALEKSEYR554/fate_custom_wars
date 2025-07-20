extends Node

@onready var IP_entry = $IP
@onready var connect_button = $connect # Переименовал для ясности
@onready var port_entry = $Port # Переименовал для ясности
@onready var nickname_edit = $nickname # Переименовал для ясности
@onready var back_button = $"../Back_button" # Осторожно с free(), если он нужен для UI после дисконнекта
@onready var main_menu = $".."
@onready var host_scene = $"../Host_scene"

var peer = ENetMultiplayerPeer.new()
var connection_attempts: int = 0
var is_intentionally_disconnecting: bool = false # Флаг для выхода из игры

var reconnect_timer: Timer

func _ready():
	nickname_edit.max_length=Globals.MAX_NICKNAME_SIZE
	Globals.host_or_user = "user"

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	Globals.disconnection_request.connect(disconnect_from_server)
	Globals.reconnect_requested.connect(_attempt_reconnect)
	# Globals.player_list_changed.connect(_on_player_list_updated_from_globals) # Если нужно

	reconnect_timer = Timer.new()
	reconnect_timer.one_shot = true
	reconnect_timer.wait_time = Globals.RECONNECT_ATTEMPT_DELAY
	reconnect_timer.timeout.connect(_on_reconnect_timer_timeout) # Или _on_reconnect_timer_timeout
	add_child(reconnect_timer)

	# Подписываемся на сигнал закрытия окна
	get_window().close_requested.connect(_on_window_close_requested)


func disconnect_from_server(is_quitting_game: bool = false):
	if multiplayer.multiplayer_peer and \
	   multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		
		#is_intentionally_disconnecting = true
		peer.close()
		multiplayer.multiplayer_peer = null 
		
		if is_instance_valid(connect_button):
			connect_button.disabled = false
			connect_button.text = "Connect"

		Globals.connection_status_changed.emit(false)

		if not is_quitting_game:
			OS.alert("You have been disconnected.", "Disconnected")
			# Здесь логика возврата в меню, например:
			# get_tree().change_scene_to_file("res://main_menu.tscn")
		else:
			print("Disconnected due to game quit.")

	elif not is_quitting_game:
		print("Client already disconnected or multiplayer_peer is null.")
		if is_instance_valid(connect_button):
			connect_button.disabled = false
			connect_button.text = "Connect"
		Globals.connection_status_changed.emit(false)


func _on_connect_button_button_up():
	Globals.host_or_user = "user"
	if nickname_edit.text.is_empty():
		nickname_edit.grab_focus()
		OS.alert("Please enter a nickname.", "Nickname Required")
		return

	Globals.self_nickname = nickname_edit.text
	# PUID уже должен быть сгенерирован в Globals._ready()
	if Globals.self_pu_id.is_empty():
		push_error("Self Persistent ID is empty! This should not happen.")
		# Можно сгенерировать здесь как запасной вариант, но лучше в Globals
		Globals.self_pu_id = "client_" + OS.get_unique_id()
	
	var ip = IP_entry.text
	var port = int(port_entry.text) if port_entry.text.is_valid_int() else Globals.DEFAULT_PORT

	if ip.is_empty():
		ip = "127.0.0.1" # По умолчанию, если пусто

	print("Attempting to connect to %s:%s with PUID: %s" % [ip, port, Globals.self_pu_id])
	
	# Сбрасываем попытки подключения перед новым подключением вручную
	connection_attempts = 10
	is_intentionally_disconnecting = false 
	
	var error = peer.create_client(ip, port)
	if error != OK:
		OS.alert("Failed to create client. Error: " + str(error), "Client Error")
		return

	multiplayer.multiplayer_peer = peer
	connect_button.disabled = true
	nickname_edit.editable=false
	port_entry.editable=false
	IP_entry.editable=false
	if is_instance_valid(back_button): back_button.queue_free()

func _on_connected_to_server():
	print("Connection established with server! Peer ID: %s. Registering..." % multiplayer.get_unique_id())
	connection_attempts = 0 # Сброс счетчика попыток при успешном соединении
	Globals.connection_status_changed.emit(true)
	
	# Отправляем PUID и ник серверу для регистрации
	# Используем ID 1 для отправки RPC хосту
	host_scene.rpc_id(1, "register_player", Globals.self_pu_id, Globals.self_nickname)


func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

@rpc("authority","call_local", "reliable")
func player_timeout(pu_id:String):
	Globals.pu_id_player_info[pu_id]["disconnected_more_than_timeout"]=true


@rpc("call_local", "reliable") # Вызывается сервером
func registration_successful(registered_puid: String,refresh_data:Dictionary={}):
	if registered_puid == Globals.self_pu_id:
		print("Successfully registered with server. My PUID: %s" % registered_puid)
		# Здесь можно разблокировать UI игры, скрыть лобби и т.д.
		connect_button.text = "Connected" # Или что-то подобное
		if is_instance_valid(back_button): back_button.queue_free() # Теперь можно удалить
	else:
		# Это странно, сервер подтвердил другой PUID. Возможно, ошибка или попытка взлома.
		print("Warning: Server confirmed registration for PUID %s, but my PUID is %s." % [registered_puid, Globals.self_pu_id])
		multiplayer.multiplayer_peer.close() # Разрываем соединение
	
	print("\n\n registration_successful Globals.pu_id_player_info=",Globals.pu_id_player_info)
	
	print("\n\n registration_successful refresh_data=",Globals.pu_id_player_info)
	if not refresh_data.is_empty():
		print("\n registraion with refresh_data=",refresh_data)
		Globals.is_game_started=refresh_data["is_game_started"]
		if Globals.is_game_started:
			pass
			#print("\n\nroot_count=",get_tree().root.get_child_count())
			#print("get_tree().root=",get_tree().root.name)
			#print("root_childern=",get_tree().root.game_field("Globals"))
			
			#print("get_all_children,root=",get_all_children(get_tree().root))

			var field_node:Node=get_tree().root.find_child("game_field",false,false)
			var players_handler_node:Node=field_node.find_child("players_handler",false,false)
			
			var last_pu_id_player_info=Globals.pu_id_player_info.duplicate(true)
			
			Globals.pu_id_player_info={}
			for pu_id in refresh_data["pu_id_player_info"].keys():
				var current_servant_node=last_pu_id_player_info[pu_id]["servant_node"]
				var pu_id_data:Dictionary=refresh_data["pu_id_player_info"][pu_id]
				
				Globals.pu_id_player_info[pu_id]=pu_id_data.duplicate(true)
				if current_servant_node!=null:
					print("\ncurrent_servant_node!=null")
					if refresh_data.get("servant_data",{}) != {}:
						var pu_id_servant_data=refresh_data.get("servant_data",{}).get(pu_id,"")
						if not pu_id_servant_data.is_empty():

							if Globals.pu_id_player_info[pu_id].get("servant_node")!=null:
								Globals.pu_id_player_info[pu_id]["servant_node"]=current_servant_node
							else:
								players_handler_node.load_servant(pu_id)


							Globals.pu_id_player_info[pu_id]["servant_node"].buffs=pu_id_servant_data["buffs"].duplicate(true)
							Globals.pu_id_player_info[pu_id]["servant_node"].skill_cooldowns=pu_id_servant_data["skill_cooldowns"].duplicate(true)
							Globals.pu_id_player_info[pu_id]["servant_node"].additional_moves=pu_id_servant_data["additional_moves"]
							Globals.pu_id_player_info[pu_id]["servant_node"].additional_attack=pu_id_servant_data["additional_attack"]
							Globals.pu_id_player_info[pu_id]["servant_node"].phantasm_charge=pu_id_servant_data["phantasm_charge"]
							Globals.pu_id_player_info[pu_id]["servant_node"].hp=pu_id_servant_data["hp"]
				else:
					print("\ncurrent_servant_node==null loading servant after register")
					if Globals.pu_id_player_info[pu_id].get("servant_node")!=null:
						Globals.pu_id_player_info[pu_id]["servant_node"]=current_servant_node
					else:
						players_handler_node.load_servant(pu_id)
					if refresh_data.get("servant_data",{}) != {}:
						print_debug('refresh_data.get("servant_data",{}) != {}')
						var pu_id_servant_data=refresh_data.get("servant_data",{}).get(pu_id,"")
						if not pu_id_servant_data.is_empty():
							if Globals.pu_id_player_info[pu_id].get("servant_node")!=null:
								continue
							
							Globals.pu_id_player_info[pu_id]["servant_node"].buffs=pu_id_servant_data["buffs"].duplicate(true)
							Globals.pu_id_player_info[pu_id]["servant_node"].skill_cooldowns=pu_id_servant_data["skill_cooldowns"].duplicate(true)
							Globals.pu_id_player_info[pu_id]["servant_node"].additional_moves=pu_id_servant_data["additional_moves"]
							Globals.pu_id_player_info[pu_id]["servant_node"].additional_attack=pu_id_servant_data["additional_attack"]
							Globals.pu_id_player_info[pu_id]["servant_node"].phantasm_charge=pu_id_servant_data["phantasm_charge"]
							Globals.pu_id_player_info[pu_id]["servant_node"].hp=pu_id_servant_data["hp"]

			field_node.pu_id_to_kletka_number=refresh_data["pu_id_to_kletka_number"]

			players_handler_node.pu_id_to_np_points=refresh_data["pu_id_to_np_points"]

			field_node.occupied_kletki=refresh_data["occupied_kletki"]
			field_node.pu_id_to_kletka_number=refresh_data["pu_id_to_kletka_number"]
			for kletka_id in refresh_data["kletka_preference"].keys():
				if not refresh_data["kletka_preference"][kletka_id].is_empty():
					field_node.capture_single_kletka_sync(kletka_id,refresh_data["kletka_preference"][kletka_id])
			field_node.kletka_preference=refresh_data["kletka_preference"]
			#kletka_owned_by_pu_id=refresh_data["kletka_owned_by_pu_id"]
			if not field_node.is_pole_generated:
				field_node.pole_generated_seed=refresh_data["pole_generated_seed"]
				field_node.reset_pole(field_node.pole_generated_seed)

		else:
			print("Registrating when game not started, just copying refresh data")
			Globals.pu_id_player_info=refresh_data["pu_id_player_info"]

		Globals.peer_to_persistent_id=refresh_data["peer_to_persistent_id"]
		

	host_scene.rpc_id(1, "registration_completed", Globals.self_pu_id)

func _on_connection_failed():
	print("Connection failed.")
	Globals.connection_status_changed.emit(false)
	multiplayer.multiplayer_peer = null # Сброс пира
	connect_button.disabled = false
	connect_button.text = "Connect"
	
	if not is_intentionally_disconnecting:
		_attempt_reconnect() # Попробовать переподключиться

func _on_server_disconnected():
	print("Disconnected from server by server or network issue.")
	Globals.connection_status_changed.emit(false)
	
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null

	if is_instance_valid(connect_button):
		connect_button.disabled = false 
		connect_button.text = "Connect" 

	if not is_intentionally_disconnecting:
		OS.alert("Lost connection to the server. Attempting to reconnect...", "Connection Lost")
		_attempt_reconnect() # Ваша функция переподключения
	else:
		is_intentionally_disconnecting = false 
		print("Server confirmed intentional disconnect by client.")


func _attempt_reconnect():

	if is_intentionally_disconnecting:
		return
	print("_attempt_reconnect not intentionally")
	if connection_attempts < Globals.MAX_RECONNECT_ATTEMPTS:
		connection_attempts += 1
		print("Attempting to reconnect... (Attempt %s/%s)" % [connection_attempts, Globals.MAX_RECONNECT_ATTEMPTS])
		# Используем те же IP и порт, что и при последнем успешном подключении
		# Их нужно где-то сохранить. Предположим, они все еще в IP_entry и port_entry
		#var ip = IP_entry.text
		#var port = int(port_entry.text) if port_entry.text.is_valid_int() else Globals.DEFAULT_PORT

		# Запускаем таймер перед следующей попыткой
		reconnect_timer.start() 
		# В _on_reconnect_timer_timeout будет сам вызов create_client
	else:
		print("Max reconnection attempts reached. Giving up.")
		OS.alert("Could not reconnect to the server after multiple attempts.", "Reconnection Failed")
		connection_attempts = 0 # Сброс для будущих ручных попыток
		# Здесь можно вернуть игрока в главное меню или показать сообщение об ошибке
		# main_menu.visible = true (или аналогичная логика для возврата в UI)


func _on_reconnect_timer_timeout(): # Вызывается по таймеру reconnect_timer
	var ip = IP_entry.text
	var port = int(port_entry.text) if port_entry.text.is_valid_int() else Globals.DEFAULT_PORT
	if ip.is_empty(): ip = "127.0.0.1"

	# Убедимся, что peer сброшен перед новой попыткой
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close() # Закрываем старое, если есть
		multiplayer.multiplayer_peer = null
	peer = ENetMultiplayerPeer.new() # Создаем новый объект пира
	var error = peer.create_client(ip, port)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		# _on_connected_to_server вызовется автоматически при успехе
	else:
		print("Reconnect attempt failed to initiate client. Error: %s" % error)
		# Повторяем попытку, если еще не достигли лимита
		if connection_attempts < Globals.MAX_RECONNECT_ATTEMPTS:
			reconnect_timer.start() # Еще одна попытка через задержку
		else:
			print("Max reconnection attempts reached during timer. Giving up.")
			OS.alert("Could not reconnect to the server after multiple attempts.", "Reconnection Failed")
			connection_attempts = 0


@rpc("call_local", "reliable") # Вызывается сервером для всех клиентов
func sync_full_player_list(full_list: Dictionary,exept_pu_id:String=""):
	print("\nClient received full player list: ", Globals.host_or_user, "  ", full_list)
	print("\n pu_id_player_info=", Globals.host_or_user, "  ", Globals.pu_id_player_info)
	#var changed = false
	# Сначала удалим тех, кого нет в новом списке (кроме себя, если вдруг сервер себя не прислал)
	#var puids_to_remove = []
	#for existing_puid in Globals.pu_id_player_info:
	#	if not full_list.has(existing_puid) and existing_puid != Globals.self_pu_id:
	#		puids_to_remove.append(existing_puid)
	#		changed = true
	#for puid_to_remove in puids_to_remove:
		#Globals.pu_id_player_info.erase(puid_to_remove)
	if exept_pu_id!="":
		full_list.erase(exept_pu_id)
	# Теперь обновим/добавим из присланного списка
	for pu_id in full_list:
		var pu_id_data:Dictionary=full_list[pu_id]
		if pu_id_data["servant_name"]==null:
			#Globals.pu_id_player_info[pu_id]=pu_id_data
			continue
		else:
			#var serv_node=Globals.pu_id_player_info[pu_id]["servant_node"]
			print("\nsync_full_player_list and name != null")
			#Globals.pu_id_player_info[pu_id]=pu_id_data
			#Globals.pu_id_player_info[pu_id]["servant_node"]=serv_node

			Globals.pu_id_player_info[pu_id]["nickname"]=pu_id_data["nickname"]
			Globals.pu_id_player_info[pu_id]["current_peer_id"]=pu_id_data["current_peer_id"]
			Globals.pu_id_player_info[pu_id]["is_connected"]=pu_id_data["is_connected"]
			Globals.pu_id_player_info[pu_id]["servant_name"]=pu_id_data["servant_name"]
			Globals.pu_id_player_info[pu_id]["servant_node_name"]=pu_id_data["servant_node_name"]
			Globals.pu_id_player_info[pu_id]["disconnected_more_than_timeout"]=pu_id_data["disconnected_more_than_timeout"]


		#if not Globals.pu_id_player_info.has(puid) or Globals.pu_id_player_info[puid] != full_list[puid]:
		#	Globals.pu_id_player_info[puid] = full_list[puid].duplicate(true) # Глубокое копирование
		#	changed = true
	
	#if changed:
		#Globals.player_list_changed.emit() # Сигнал для обновления UI, если оно есть на клиенте
	
	print("\full player list after update", Globals.host_or_user, "  ", full_list)



func _on_player_list_updated_from_globals():
	# Здесь клиент может обновить свой UI, если у него отображается список игроков
	print("Client's copy of player list updated in Globals: ", Globals.pu_id_player_info)
	# Например, обновить какой-нибудь PlayerListUI элемент


func _on_window_close_requested():
	print("Window close requested by user. Disconnecting and quitting.")
	is_intentionally_disconnecting = true 
	if multiplayer.multiplayer_peer:
		if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
			multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	get_tree().quit() # Завершаем работу приложения



func _notification(what):
	match what:
		MainLoop.NOTIFICATION_APPLICATION_PAUSED:
			print("Application paused (e.g., minimized or lost focus).")
			# Если вы хотите разрывать соединение при каждой паузе:
			if multiplayer.multiplayer_peer and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
				print("Disconnecting due to application pause.")
				is_intentionally_disconnecting = true # Считаем это намеренным (временным) разрывом
				multiplayer.multiplayer_peer.close_connection()
				# multiplayer.multiplayer_peer = null # Опционально, если не хотим пытаться восстановить этот peer
				Globals.connection_status_changed.emit(false) # Обновить UI
				connect_button.disabled = false # Позволить переподключиться вручную
				connect_button.text = "Connect"


		MainLoop.NOTIFICATION_APPLICATION_RESUMED:
			print("Application resumed.")
			# Если is_intentionally_disconnecting было true из-за паузы,
			# здесь можно, например, предложить пользователю переподключиться
			# или просто оставить как есть (пользователь нажмет кнопку Connect).
			# Если соединение не было разорвано при паузе, ничего делать не нужно.

		# MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		#    print("Application lost focus.")
			# Можно использовать вместо PAUSED, если нужно более гранулярно, но PAUSED обычно покрывает это.
		# MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		#    print("Application gained focus.")
