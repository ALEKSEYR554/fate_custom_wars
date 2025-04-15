extends Node

# Assign this variable to MPAuth node
@onready var IP_entry = $IP
@onready var connect = $connect
@onready var port = $Port
var peer = ENetMultiplayerPeer.new()
@onready var nickname = $nickname
@onready var back_button = $"../Back_button"
var game_field
@onready var main_menu = $".."

func _ready():
	#game_field = load("res://game_field.tscn")
	pass

@rpc("call_local")
func hide_main_menu():
	for i in get_tree().root.get_children():
		if i.name=="Main Menu":
			i.visible=false
	self.visible=false

func _on_connected_to_server():
	print("Connection stablished!")
	connect.disabled=true


func _on_connect_button_up():
	if nickname.text=="":
		nickname.grab_focus()
		return
	Globals.nickname=nickname.text
	print(str(IP_entry.text)+":"+str(port.text))
	peer.create_client(IP_entry.text, int(port.text))
	multiplayer.multiplayer_peer = peer
	back_button.free()
	Globals.host_or_user="user"
	multiplayer.connected_to_server.connect(_on_connected_to_server)

@rpc("call_local")
func game_initiate():
	main_menu.game_initiate()
	return
	print("FUCK")
	var game_field_instanse=game_field.instantiate()
	get_tree().root.add_child(game_field_instanse)
	pass
