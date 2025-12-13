class_name BattleStateMachine extends Node

@export var initial_state: BattleState
@onready var field = $".." # Ссылка на родителя (Field)

var current_state: BattleState

# Сигнал, чтобы UI знал, что происходит (включал/выключал кнопки)
signal state_changed(state_name: String, data: Dictionary)

func _ready():
	# Раздаем ссылки всем детям
	for child in get_children():
		if child is BattleState:
			child.field = field
			child.fsm = self
	
	# Запускаем машину (только на сервере, если Host Authoritative)
	if multiplayer.is_server():
		change_state(initial_state)


func change_state_for_pu_ud(pu_id: String, state_name: String, data: Dictionary = {}):
	if not multiplayer.is_server(): return
	
	match state_name:
		"MoveSelection":
			Globals.pu_id_to_current_action[pu_id]="move"
			if data.get("Initial Spawn",false):
				Globals.pu_id_to_current_action[pu_id]="initial_spawn"
		"ChoosingTarget":
			Globals.pu_id_to_current_action[pu_id]="attack"

	
	var peer_id = Globals.pu_id_player_info[pu_id]["current_peer_id"]
	
	rpc_id(peer_id, "client_set_state", state_name, data)


@rpc("authority", "call_local", "reliable")
func client_set_state(state_name: String, data: Dictionary):
	# Эта функция выполняется на клиенте, когда сервер прислал приказ
	var new_state = get_node_or_null(state_name)
	
	if not new_state:
		push_error("Нет такого стейта: " + state_name)
		return

	if current_state:
		current_state.exit()
	
	current_state = new_state
	# Передаем данные (например, каким юнитом ходить)
	current_state.enter(data)
	
	print("Мой стейт изменился на: ", state_name)

# Главная функция смены состояния
func change_state(new_state: BattleState, data: Dictionary = {}):
	if current_state:
		current_state.exit()
	
	current_state = new_state
	
	# Синхронизируем состояние с клиентами
	# Передаем имя ноды состояния (например, "PlayerTurn")
	rpc("sync_state", current_state.name, data)
	
	# Локальный вход (для Хоста)
	current_state.enter(data)

# Клиенты получают приказ сменить состояние
@rpc("authority", "call_remote", "reliable")
func sync_state(state_name: String, data: Dictionary):
	var new_state = get_node(state_name)
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter(data) # Клиент входит в состояние (обновляет UI)
	state_changed.emit(state_name, data)

# Перенаправляем инпут в текущее состояние
func _unhandled_input(event):
	if current_state:
		current_state.handle_input(event)
