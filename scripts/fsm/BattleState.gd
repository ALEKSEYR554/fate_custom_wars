class_name BattleState extends Node

# Ссылка на "Божественный скрипт" (чтобы иметь доступ к карте, игрокам)
var field: Node2D 
var fsm: BattleStateMachine # Ссылка на машину
var players_handler: Node2D

var current_char_info:CharInfo
# Вызывается при входе в состояние
func enter(data: Dictionary = {}):
	if data.has("char_info_dic"):
		current_char_info=CharInfo.from_dictionary(data["char_info_dic"])
	pass

# Вызывается при выходе из состояния
func exit():
	pass

# Вызывается каждый кадр (если нужно)
func update(_delta: float):
	pass

# Вызывается при получении input (клики мыши и т.д.)
func handle_input(_event: InputEvent):
	pass

# Обработка сетевых сообщений (например, клиент нажал кнопку)
func handle_network_message(message: String, net_data: Dictionary):
	pass
